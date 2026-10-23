# 背景

你的服务刚刚收到  `SIGTERM` 信号。在 Kubernetes  发送 `SIGKILL` 信号之前，你大约有 30 秒的时间。在这段时间内，你需要完整正在进行的请求、刷新缓存数据、关闭数据库连接并从服务发现中注销——所有这些操作都必须在不丢弃任何用户请求的情况下完成。

如果出错，每次部署都会出现数据丢失、客户端连接中断和 502 错误。如果正确，用户将感觉不到部署过程。

本文将介绍在生产环境中实现可靠的 Go 服务优雅关闭的模式。



# 优雅关闭为何重要

服务突然中断时，通常会出现以下三个问题：

- **Data Loss**。缓冲区写入的数据（日志批处理、指标、队列消息）会消失。正在进行的数据库事务会被回滚（最好的情况），或者留下不一致的状态（最坏的情况）。
- **Connection drops**。传输中的 HTTP 请求收到 TCP RET 错误。gRPC 流在消息传输过程中中断。WebSocket 客户端出现意外断开连接。根据客户端的重试逻辑，这些问题可能会级联发生。
- **Load balancer draining failures**。Kubernetes 会从 Service 端点移除 Pod。但如果你的进程在 kubelet 传播此更改之前退出，负载均衡器仍然会将流量发送到已终止的 Pod。标准的解决方法是 在收到 `SIGTERM` 信号后继续服务几秒钟——但这仅限于你的关闭顺序正确的情况下。



# 基础：os.Signal + context.Context

Go 中所有优雅关闭都从相同的两个原语开始：信号通知和上下文取消。

```go
func main() {
  // 创建一个上下文，当收到 SIGINT 或 SIGTERM 信号时取消
  ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
  defer stop()
  
  // 将上下文传递给所有需要了解关机信息的组件
  if err := run(ctx); err !=  nil {
    log.Fatalf("service exited with error: %v", err)
  }
}
```

`signal.NotifyContext` （Go 1.16 新增）是将操作系统信号连接到上下文树的最简洁方式。当信号到达时，上下文的 `Done()` 通道会关闭，所有监视该上下文的 goroutine 都知道该结束执行了。

关键原则：**在所有地方传播上下文**。每个 HTTP Handler、每个数据库查询 、每个后台工作进程都应接受一个 `context.Context` 对象。这样才能使关闭操作更易于协作而非强制执行。

# HTTP Server 优雅关闭

`http.Server.Shutdown()` 正是你想要的：它会停止接受新的连接，等待正在进行的请求完成，然后返回。

```go
func runHttpServer(ctx context.Context) error {
  mux := http.NewServeMux()
  mux.Handler("/api/data", handleData)
  
  srv := &http.Server{
    Addr:  		":8080",
    Handler: 	mux,
  }
  
  // 在一个 goroutine 开启服务器
  errCh := make(chan error, 1)
  go func() {
    if err := srv.ListenAndServe(); err != http.ErrServerClosed {
      errCh <- err
    }
    close(errCh)
  }()
  
  // 等待关闭信号
  <-ctx.Done()
  log.Println("shutting down HTTP server...")
  
  // 为传输中提出的请求设定完成期限 
  shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
  defer cancel()
  
  if err := srv.Shutdown(shutdownCtx); err !+ nil {
    return fmt.Errorf("http server shutdown: %w", err)
  }
  
  // 在关闭服务器之前，检查服务器 goroutine 是否遇到错误
  return  <-errCh
}
```

 请注意，关闭上下文使用的是 `context.Background()`，而不是已被取消的父上下文。这是一个常见的错误——如果你从已取消的上下文中获取关闭超时时间，则超时时间已经过期，`Shutdown()` 会立即返回，从而丢弃正在进行的请求。



# gRPC 优雅停止

gRPC 有其自身的优雅关闭方法，该方法与 HTTP 模式类似：

```go
func runGRPCServer(ctx context.Context) error {
	lis, rr := net.Listen("tcp", ":9090")
	if err != nil {
		return fmt.Errorf("listen: %w", err)
	}
	
	grpcServer := grpc.NewServer()
	pb.RegistryMyServiceServer(grpcServer, &myService{})
	
	// 开始反射用于 debug
	reflection.Register(grpcServer)
	
	errCh := make(chan error, 1)
	go func() {
		if err := grpcServer.Serve(lis); err != nil {
			errCh <- err
		}
		close(errCh)
	}()
	
	<-ctx.Done()
	log.Println("shutting down gRPC server...")
	
	// GracefulStop 会等待活跃的 RPC 请求完成
	// 但为了安全起见，我们添加了一个硬性截止时间
	stopped := make(chan struct{})
	go func()  {
		grpcServer.GracefulStop()
		close(stopped)
	}()
	
	select {
	case <- stopped:
		log.Println("gRPC server stopped gracefully")
	case <-time.After(10*time.Second):
  	log.Println("gRPC server force stop (timeout)")
  	grpcServer.Stop()
	}
	
	return <-errCh
}
```

`GracefulStop()` 函数没有内置超时机制，因此你必须自动设置超时时间。否则，单个缓慢耗尽的流可能会关闭导致过程无限期的挂起。



# 使用 sync.WaitGroup 清空 Worker Pool

后台工作进程（例如队列消费者、定时任务、批处理处理器）需要不同的模式。Worker Pool 进程会在每个工作单元之间检查 `ctx.Done()`，而 `WaitGroup` 则允许主 goroutine 等待所有工作进程完成其当前任务。

```go
func runWorkerPool(ctx context.Context, queue <-chan Job) error {
  const numWorkers = 8
  var wg sync.WaitGroup
  
  for i := 0; i < numWorkers; i++ {
    wg.Add(1)
    go func(id int) {
      defer wg.Done()
      for {
        select {
        case <- ctx.Done():
          log.Printf("worker %d: shutting down", id)
        case job, ok := <-queue:
          if !ok {
            return // 通道关闭
          }
          if err := processJob(ctx, job); err != nil {
            log.Printf("worker %d: job failed: %v", id, err)
          }
        }
      }
    }(i)
  }
  
  // 等待所有 worker 完成他们的任务
  wg.Wait()
  return nil
}
```

关键细节：`processJob` 会接收上下文信息，以便放弃长时间运行的任务。如果一个任务耗时 5 分钟，而你的关闭预期是 30 秒，那么该任务必须遵循上下文取消机制，否则你会收到 `SIGKILL` 信号。



# Database 连接清理

数据库连接最容易配置正确，但一旦出错也最麻烦。连接泄露会耗尽数据库的连接池，导致所有服务都出现故障。

```go
func setupDatabase(ctx context.Context) (*sql.DB, error) {
  db, err := sql.Open("postgres", os.Getenv("DATABASE_URL"))
  if err != nil {
    return nil, err
  }
  
  db.SetMaxOpenConnections(25)
  db.SetMaxIdleConns(5)
  db.SetConnMaxLifetime（5 * time.Minute)
  
  if err := db.PintContext(ctx); err != nil {
    db.Close()
    return nil, fmt.Errorf("database ping: %w", err)
  }
  
  return db, nil
}
```

清理工作很简单 —— 使用 `db.Close()` —— 但顺序很重要。必须在服务器和工作进程停止后在关闭数据库，因为它们在清空数据库期间可能仍在执行查询。



# 使用 errgroup 组合所有内容

现在让我们把所有东西整合起来。`golang.org/x/sync` 中的 `errgroup` 为我们提供了结构化并发：并行允许组件，如果其中一个组件失败则关闭所有组件，并收集错误。

```go
func run(ctx context.Context) error {
  db, err := setupDatabase(ctx)
  if err != nil {
    return fmt.Errorf("database: %w", err)
  }
  defer db.Close() // 总是最后一个关闭
  
  jobQueue := make(chan Job, 100)
  
  g, ctx := errgroup.WithContext(ctx)
  
  // HTTP Server
  g.Go(func() error {
    return runHTTPServer(ctx)
  })
  
  // gRPC server
  g.Go(func() error {
    return runGRPCServer(ctx)
  })
  
  // Worker pool
  g.Go(func() error {
    return runWorkerPool(ctx, jobQueue)
  })
  
  // 健康检查器（发生严重故障时触发关机）
  g.Go(func() error {
    return runHealthMintor(ctx, db)
  })
  
  log.Println("service started")
  err = g.Wait()
  log.Println("all components stopped")
  
  return err
}
```

`errgroup.WithContext` 会派生一个派生上下文，当组中的任何 goroutine 返回错误时，该上下文都会被取消。这意味着如果 HTTP Server 绑定端口失败，则上下文会被取消，gRPC Server 和 Worker 也会开始关闭。统一的生命周期管理。

请注意，`db.Close()` 通过 `defer` 执行——它会在 `g.Wait()` 返回后执行，从而确保在关闭数据库连接之前所有 Server 和 Worker 都已完全情况。通过**延迟清理来控制依赖关系**是最简单的正确模式 。


# 与 Kubernetes 的健康检查集成

Kubernetes 需要知道你的 Pod 何时准备好接收流量，以及何时应该停止发送流量。`readiness probe` 就是你的协调点。

```go
type healthHandler struct {
  ready atomic.Bool
}

func (h *healthHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
  if h.ready.Load() {
    w.WriteHeader(http.StatusOK)
    w.Write([]byte("ok"))
  } else {
    w.WriteHeader(http.StatusServiceUnavailable)
    w.Write([]byte("shutting down"))
  }
}

func runHTTPServer(ctx context.Context) error {
  health := &healthHandler{}
  health.ready.Store(true)
  
  mux := http.NewServeMux()
  mux.Handle("/healthz", health)
  mux.HandleFunc("/api/data", handleData)
  
  srv := &http.Server{Addr: ":8080", Handler: mux}
  
  errCh := make(chan error, 1)
  go func() {
    if err := srv.ListenAndServe(); err != http.ErrServerClosed {
      errCh <- err
    }
    close(errCh)
  }()
  
  <-ctx.Done()
  
  // Step 1：标记为未就绪 —— kubernetes 停止发送流量
  health.ready.Store(false)
  
  // Step 2：等待负载均衡器传播变更
  time.Sleep(5 * time.Second)
  
  // Step 3: 停止服务器
  shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
  defer cancel()
  
  if err := srv.Shutdown(shutdownCtx); err != nil {
    return fmt.Errorf("http server shutdown: %w", err)
  }
  
  return <-errch
}
```

`time.Sleep(5 * time.Second)` 看起来不对劲，但它至关重要。Kubernetes 端点传播**最终一致性**。在就绪检测开始失败后，kube-proxy/iptables 规则需要几秒钟才能在各个节点上更新。在此期间，流量仍然会到达 。`sleep` 操作可以保持服务器运行，以便处理这些流量。

在你的 prod spec：

```yaml
readinessProbe:
	httpGet:
		path: /healthz
		port: 8080
	periodSeconds: 2
	failureThreashold:  1
terminationGracePeriodSeconds: 45
```

设置 `terminationGracePeriodSeconds` 以轻松超过你的总关机预算（sleep + drain timeout + cleanup）。


# 常见错误

## 1. 从已取消的父级派生上下文

```go
// WARONG: ctx 已经取消，timeout 没有影响
shutdownCtx, cancel := context.WithTimeout(ctx, 10*time.Second)

// RIGHT: 全新且使用其自己的截止日期
shutdownCtx, cancel := context.WithTimeout(context.WithBackground(), 10*time.Second)
```

## 2. 完全不设置关机超时

`GracefulStop()` 和自定义的循环停止操作可能会无限期阻塞。务必设置截止时间，并回退到强制停止。

## 3. 清理顺序错误

如果在 HTTP 服务器完成数据清空之前关闭数据库。正在进行的请求处理程序就会收到连接错误。经验法则：按照初始化的相反顺序关闭服务。先关闭服务器，然后是工作进程，最后是基础设施（数据库、缓存、消息代理）。

## 4. 忘记停 timer 和 ticker

```go
ticker := time.NewTicker(30 * time.Second)
defer ticker.Stop() // 不要泄露

for {
  select {
  case <- ctx.Done():
    return nil
  case <-ticker.C:
    doPeriodicWork()
  }
}
```

## 5. 未测试关闭过程

在集成测试中向你的服务发送 `SIGTERM` 信号。验证正在进行的请求是否完成，日志中是否出现任何错误，以及进程是否以代码 0 退出。

# 总结

完整模式：

1. 使用 `signal.NotifyContext` 捕获 `SIGINT` / `SIGTERM` 
2. 以信号感知上下文启动 `errgroup` 下的所有组件
3. 每个组件都会监听 `ctx.Done()` 并开始释放资源
4. 将准备就绪探针标记为不健康，为 LB 传播为睡眠
5. 使用超时关闭服务器（HTTP、gRPC）
6. 等待 Woker 完成当前任务
7. 最后通过 `defer` 关闭基础设施连接（数据库、缓存）

此顺序处理正常部署情况（Kubernetes 滚动更新）、崩溃情况（组件故障并触发组关闭）和手动停止情况（开发中的 `Ctrl+C`）。

优雅关闭虽然并不引人注目，但它决定了部署是用户完全察觉不到，还是会在控制面板引发大量错误。从一开始就将其融入设计——后期补救总是更加困难。

