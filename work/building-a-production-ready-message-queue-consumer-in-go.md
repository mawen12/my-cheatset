# 背景

在之前的文章中，我们探讨了如何使用 OpenTelemetry 进行分布式追踪。今天，我们将着重介绍后端基础设施中最关键——也是最容易出错——的组件之一：消息队列的消费者。

任何生产系统最终都会超越同步请求-响应的范畴。订单处理、邮件发送、图片缩放、Webhook 扇出——这些都应该放在队列中处理。但消费者端的情况却很糟糕。消息到达顺序混乱，工作进程在处理过程中崩溃，重复消息漏过。你原本"简单的消费者"最终会变为重试、崩溃和消息丢失的混乱局面。

本文使用 Go 语言逐步构建一个生产级的 NATS JetStream 消费者，涵盖了使其在凌晨 3 点仍能正常运行的各种模式。



### 为什么消息队列很重要 ？

同步架构在以下情况下会遇到瓶颈：

- **延迟预算非常紧张**——你的 API 不应该因为 PDF 渲染而阻塞 30 秒。
- **故障域之间发生故障蔓延**——下游服务中断不应该导致整个 API 瘫痪。
- **负载呈突发性**——黑色星期五的流量不应该需要一年365天都向黑色星期五那样高的计算能力。

消息队列将生产者和消费者解耦。生产者写入消息后即可继续执行其他操作。消费者可以按照自己的节奏处理消息，失败后会重试，并且可以独立扩展。这对于任何处理实际流量的系统来说都是基本要求。

我们将以 **NATS JetStream** 为例进行说明。它比 RabbitMQ 或 Kafka 更易于操作，支持至少一次交付的持久流，并且拥有有些的 Go 客户端。这些模式具有普遍适用性。



# 架构

我们正在构建的是：

```
Producer -> NATS JetStream Stream -> Consumer Group
																			├── Worker Pool（N goroutines）
																			├── 使用指数退避重试
																			├── 死信队列
																			├── 幂等性检查
																			└—— 指标 + 跟踪
```

我们先来定义核心接口：

```go
package consumer

import (
	"context"
	"time"
)

type Message struct {
	ID 				string
	Subject 	string
	Data 			[]byte
	Headers 	map[string]string
	Timestamp time.Time
	Attempt 	int
}

// Handler 处理单条消息，返回错误以触发重试
type Handler func(ctx context.Context, msg Message) error

// IdempotencyStore 跟踪处理的消息 ID
type IdempotencyStore interface {
	Exists(ctx context.Context, messageID string) (bool, error)
	Mark(ctx context.Context, messageID string, ttl time.Duration) error
}
```



## 设计幂等消费者

至少一次投递意味着你的处理程序会受到重复的消息。网络波动、消费者重启、重新平衡等都会导致消息重复投递。你的处理程序必须是幂等的：处理同一条消息两次必须产生相同的结果。

实践中有两种策略行之有效：

1. **在消费者层面去重**——处理前检查存储：

```go
type RedisIdempotencyStore struct {
	client *redis.Client
}

func (s *RedisIdempotencyStore) Exists(ctx context.Context, messageID string) (bool, error) {
	val, err := s.client.Exists(ctx, "idem:"+id).Result()
	if err != nil {
		return false, fmt.Errorf("idempotency check failed: %w", err)
	}
	return val > 0, nil
}

func (s *RedisIdempotencyStore) Mark(ctx context.Context, messageID string, ttl time.Duration) error {
  return s.client.Set(ctx, "idem:" + id, "1", ttl).Err() 
}
```

2. **幂等操作**——设计写入操作时要确保重复写入的安全。使用 `INSERT ... ON CONFLICT ON DOTHING`，带有版本检查的条件更新，或从消息内容派生的确定性 ID。

第一种方法更容易集成，第二种方法更稳健。生产系统通常会结合这两种方法：使用去重层作为快速通道，并使用幂等数据库操作作为安全保障。

幂等键的 TTL（生存时间）很重要。设置得太短，延迟的重发请求就会漏掉；设置得太长，存储量就会无限增长。应将其与流的最大重发窗口相匹配——通常为24~72小时。



## 消费者核心

现在我们来构建消费者，`Config` 结构体捕获了所有可调参数：

```go
type Config struct {
  // NATS 连接
	NATSUrl string
  StreamName string
  Subject string
  Durable string // 消费者组名
  
  // 并发
  WorkerCount int
  
  // 重试
  MaxRetries int
  InitialBackoff time.Duration
  MaxBackoff time.Duration
  BackoffFactor float64
  
  // 幂等
  IdempotencyTTL time.Duration
  
  // 可观测性
  ServiceName string
}

func DefaultConfig() Config {
  return Config{
    WorkerCount: 10,
    MaxRetries: 5,
    InitialBackoff: 1 * time.Second,
    MaxBackoff: 60 * time.Second,
    BackoffFactor: 2.0,
    IdempontencyTTL: 24 * time.Hour,
    ServiceName: "queue-consumer",
  }
}
```

消费者结构将一切联系起来：

```go
type Consumer struct {
	cfg				 	Config
  js 					nats.JetStreamContext
  handler 		Handler
  idemStore 	IdempotencyStore
  metrics 		*Metrics
  tracer 			trace.Tracer
  logger 			*slog.Logger
  sub 				*nats.Subscription
  wg 					sync.WaitGroup
  msgCh 			chan *nats.Msg
  shutdownCh chan struct{}
}

func New(nc *nats.Conn, cfg Config, handler Handler, idemStore IdempotencyStore) (*Consumer, error) {
  js, err := nc.JetStream()
  if err != nil {
    return nil, fmt.Errorf("jetstream init: %w", err)
  }
  
  tp := otel.GetTracerProvider()
  meter := otel.GetMeterProvider().Meter(cfg.ServiceName)
  
  return &Consumer{
    cfg: 				cfg,
    js: 				js,
    handler: 		handler,
    idemStore: 	idemStore,
    metrcs: 		NewMetrics(meter),
    tracer: 		tp.Tracer(cfg.ServiceName),
    logger: 		slog.Default(),
    msgCh: 			make(chan *nats.Msg, cfg.WorkerCount*2),
    shutdownCh: make(chan struct{}),
  }, nil
}
```



## 使用指数退避重试

重试逻辑位于消息处理路径中。NATS JetStream 支持服务器端 `NakWithDelay`，它指示服务器在指定时间后重新发送消息。这远优于客户端重试循环，因为它在消费者重启后仍然有效：

```go
func (c *Consumer) processMessagee(natsMsg *nats.Msg) {
  ctx, span := c.tracer.Start(context.Background(), "process_message", 
    trace.WithAttribute(
      attribute.String("subject", natsMsg.Subject),
    ),
 	)
  defer span.End()
  
  meta, err :=  natsMsg.Metadata()
  if err != nil {
    c.logger.Error("failed to read metadata", "error", err)
    natsMsg.Nak()
    return
  }
  
  attempt := int(meta.NumDelivered)
  msgID := natsMsg.Header.Get("Nats-Msg-Id")
  if msgID == "" {
    msgID = fmt.Sprintf("%s-%d", meta.Stream, meta.Sequence.Stream) 
  }
  
  span.SetAttributes(
    attribute.String("message_id", msgID),
    attribute.Int("attempt", attempt),
  )
  
  // 幂等检查
  if exists, err := c.idemStore.Exists(ctx, msgID); err != nil {
    c.logger.Error("idempotency check failed", "error", err, "msg_id", msgID)
    span.RecordError(err)
    // 重试 - 幂等存储可能暂时关闭
    c.nakWithBackoff(natsMsg, attempt)
    return
  } else if exists {
    c.logger.Debug("duplicate message, skipping", "msg_id", msgID)
    c.metrics.duplicateSkipped.Add(ctx, 1)
    natsMsg.Ack()
    return
  }
  
  msg := Message{
    ID: 				msgID,
    Subject: 		natsMsg.Subject,
    Data: 			natsMsg.Data,
    Headers: 		flattenHeaders(natsMsg.Header),
    Timestamp: 	meta.Timestamp,
    Attempt: 		attempt,
  }
  
  // 处理
  start := time.Now()
  err = c.handler(ctx, msg)
  duration := time.Since(start)
  
  c.metrics.processingDuration.Record(ctx, duration.Seconds(), 
    metric.WithAttributes(attribute.Bool("success", err == nil)),
  )
  
  if err !=  nil {
    span.RecordError(err)
    span.SetStatus(codes.Error, err.Error())
    c.metrics.processingErrors.Add(ctx, 1)
    
    if attempt >= c.cfg.MaxRetries {
      c.logger.Error("max retries exceeded, sending to DLQ", 
        "msg_id", msgID, "error", err, "attempts", attempt,
      )
      c.sendToDLQ(ctx, natsMsg, err)
      natsMsg.Ack() // 确认原始以停止重新投递
      return
    }
    
    c.logger.Warn("processing failed, scheduling retry", "msg_id", msgID, "error", err, "attempt", attempt)
    c.nakWithBackoff(natsMsg, attempt)
    return
  }
  
  // 成功 - 标记已处理且 ack
  if err := c.idemStore.Mark(ctx, msgID, c.cfg.IdempotencyTTL); err != nil {
    c.logger.Error("failed to mark idempotency", "error", err, "msg_id", msgID)
    // 不要使消息失败，它已经成功处理
    // 最坏情况：重复项将再次以幂等方式处理
  }
  
  c.metrics.messagesProcessed.Add(ctx, 1)
  natsMsg.Ack()
}

func (c *Consumer) nakWithBackoff(msg *nats.Msg, attempt int) {
  delay := c.cfg.InitialBackoff
  for i := 1; i < attempt; i++ {
    delay = time.Duration(float64(delay) * c.cfg.BackoffFactor)
    if delay > c.cfg.MaxBackoff {
      delay = maxBackoff
      break
    }
  }
  msg.NakWithDelay(delay)
}
```

关键决策：

- **服务器端通过 `NakWithDelay`**——消费者在退避期间不会保留消息。如果该消费者崩溃，另一个消费者会接手该消息 。
- **DLQ 发布后确认**——我们确认原始消息已阻止重复投递循环。DLQ 成为新的权威来源。
- **幂等标记发生在成功之后**——如果标记失败，消息可能会被重新处理。这没问题，因为操作是幂等的。



## 死信队列

所有重试失败的消息都会发送到单独的流中。你的运维团队会审核这些消息，修复错误，然后重新发送：

```go
func (c *Consumer) sendToDLQ(ctx context.Context, original *nets.Msg, processErr error) {
  _, span := c.tracer.Start(ctx, "send_to_dlq")
  defer span.End()
  
  headers := nats.Header{}
  // 保留原始头
  for k, v := range original.Header {
    headers[k] = v
  }
  headers.Set("X-DLQ-Error", processErr.Error())
  headers.Set("X-DLQ-Timestamp", time.Now().UTC().Format(time.RFC3339))
  headers.Set("X-Original-Subject", orginal.Subject)
  
  dlqMsg := &nats.Msg{
    Subject: 	fmt.Sprintf("dlq.%s", c.cfg.Subject)
    Data: 		orginal.Data,
    Header: 	headers,
  }
  
  if _, err := c.js.PublishMsg(dlqMsg); err != nil {
    c.logger.Error("failed to publish to DLQ", "error", err)
    span.RecordError(err)
    c.metrics.dlqFailures.Add(ctx, 1)
    // 这很糟糕，确认后消息就会丢失
    // 实际上，还要记录完整的消息正文以便手动恢复
    c.logger.Error("LOST MESSAGE - manual recovery required", 
                   "subject", original.Subject, 
                   "data", string(original.Data)),
    )
  }
  
  c.metrics.dlqMessages.Add(ctx, 1)
} 
```

 在安装过程中创建 DLQ 流：

```go
func EnsureStreams(js nats.JetStreamContext, streamName, subject string) error {
	// Main stream
  _, err := js.AddStream(&nats.StreamConfig{
    Name: streamName,
    Subjects: []string{subject},
    Retention: nats.WorkQueuePolicy,
    MaxAge: 72 * time.Hour,
  })
  if err != nil {
    return fmt.Errorf("create main stream: %w", err)
  }
  
  // DLQ stream
  _, err := js.AddStream(&nats.StreamConfig{
    Name: streamName +"_dlq",
    Subjects: []string{"dlq." + subject},
    Retention: nats.LimitsPolicy,
    MaxAge: 30 * 24 * time.Hour, // 保留 DLQ 消息30天
  })
  if err != nil {
    return fmt.Errorf("create DLQ stream: %w", err)
  }
  return nil
}
```



## 使用 Worker Pool 进行并发控制

单个 goroutine 处理消息时，大部分时间都浪费在等待 IO 上。Worker Pool 允许你并发处理 N 条消息，同时控制背压：

```go
func (c *Consumer) Start(ctx context.Context) error {
  sub, err := c.js.PullSubscribe(
    c.cfg.Subject,
    c.cfg.Durable,
    nats.ManualAck(),
    nats.AckWait(30*time.Second),
    nats.MaxDeliver(c.cfg.MaxRetries+1),
  )
  if err != nil {
    return fmt.Errorf("subscribe: %w", err)
  }
  c.sub = sub
  
  // 开启 Workers
  for i := 0;i < c.cfg.WorkerCount; i++ {
    c.wg.Add(1)
    go w.Worker(i)
  }
  
  // Fetch loop - 从 NATS 拉取消息并扇出到 workers
  c.wg.Add(1)
  go c.fetchLoop(ctx)
  
  c.logger.Info(
    "consumer started", 
    "workers", c.cfg.WorkerCount,
    "subject", c.cfg.Subject,
    "durable", c.cfg.Durable,
 	)
  return nil
}

func (c *Consumer) fetchLoop(ctx context.Context) {
  defer c.wg.Done()
  defer close(c.msgCh)
  
  for {
    select {
      case <- ctx.Done():
      	return
	    case <- c.shutdownCh:
      	return
	    default:
    }
    
    msgs, err := c.sub.Fetch(c.cfg.WorkerCount, nats.MaxWait(5*time.Second))
    if err != nil {
      if errors.Is(err, nats.ErrTimeout) {
        continue // 没有消息可用，再次拉取
      }
      c.logger.Error("fetch error", "error", err)
      time.Sleep(time.Second) // 遇到意外错误时暂停
      continue
    }
    
    for _, msg := range msgs {
      select {
        case c.msgSh <- msg:
        case <-ctx.Done():
        	return
        case <-c.shutdowCh:
        	return
      }
    }
  }
}

func (c *Consumer) worker(id int) {
  defer c.wg.Done()
  
  c.logger.Debug("worker started", "worker_id", id)
  for msg := range c.msgCh {
    c.processMessage(msg)
  }
  c.logger.Debug("worker stopped", "worker_id", id)
}
```

`Fetch` 批次大小与工作进程数相匹配。这既能防止通道缓冲区无限增长，又能确保每个工作进程都能获得数据。获取数据的最大等待时间可以防止数据流为空时出现死循环。



## 优雅关闭集成

我们与操作系统信号集成，以便在退出前释放正在进行的工作：

```go
func (c *Consumer) Shutdown(ctx context.Context) error {
  c.logger.Info("shutting down consumer...")
  
  // 发出停止获取循环的信号
  close(c.shutdownCh)
  
  // 取消订阅——将不会受到任何新消息
  if c.sub != nil {
    if err := c.sub.Drain(); err != nil {
      c.logger.Error("subscription drain failed", "error", err)
    }
  }
  
  done := make(chan struct{})
  go func() {
    c.wg.Wait()
    close(done)
  }
  
  select {
  case <-done:
    c.logger.Info("consumer shutdonw complete")
    return nil
  case <-ctx.Done():
    c.logger.Warn("shutdown timed out, some messages may be redelivered")
    return ctx.Err()
  }
}
```

将其连接到 `main`：

```
func main() {
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()
	
	nc, _ := nats.Connect(nats.DefaultURL)
	defer nc.Close()
	
	cfg := consumer.DefaultConfig()
	cfg.NATSUrl = nats.DefaultURL
	cfg.ServiceName = "ORDERS"
	cfg.Subject = "orders.process"
	cfg.Durable = "order-processor"
	
	store := &RedisIdempotencyStore{
		client: reids.NewClient(&redis.Options{
			Addr: "localhost:6379",
		}),
	}
	
	c, err := consumer.New(nc, cfg, handlerOrder, store)
	if err != nil {
		log.Fatal(err)
	}
	
	if err := c.Start(ctx); err != nil {
		log.Fatal(err)
	}
	
	<-ctx.Done()
	
	shutdownCtx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	c.Shutdown(shutdownCtx)
}

func handleOrder(ctx context.Context, msg consumer.Message) error {
	var order Order
	if err := json.Unmarshal(msg.Data, &order); err != nil {
		return fmt.Errorf("unmarshal order: %w", err) // 会重试，但是无济于事——考虑使用不可重试的错误类型
	}
	// 处理订单
	return nil
}
```

一个微秒之处：`handleOrder` 的注释暗示了一个重要的生产环境改进。有些错误是不可重试的——例如错误的 JSON、无效的业务数据、模式不匹配。重试并不会解决问题。生产环境中的用户应该能够区分这些错误：

```go
type PermanentError struct {
  Err error
}

func (e *PermanentError) Error() string { return e.Err.Error() }
func (e *PermanentError) Unwrap() error { return e.Err }

// 在 processMessage 方法中，在 retry 逻辑之前
var permErr *PermanentError
if errors.Is(err, &permErr) {
  c.logger.Error(
    "permanent error, sending to DLQ immediately",
    "msg_id", msgID,
    "error", err,
  )
  c.sendToDLQ(ctx, natsMsg, err)
  natsMsg.Ack()
  return
}
```



# 可观测性：指标和追踪

指标结构捕捉了队列消费的四个关键信息：

```go
type Metrics struct {
	messagesProcessed 	metric.Int64Counter
  processingErrors 		metric.Int64Counter
  processingDuration 	metric.Float64Histogram
  duplicatesSkipped 	metric.Int64Counter
  dlqMessages 				metric.Int64Counter
  dlqFailures 				metric.Int64Counter
  inflightMessages 		metric.Int64UpDownCounter
}

func NewMetrics(meter metric.Meter) *Metrics {
  m := &Metrics{}
  m.messagesProcessed, _ = meter.Int64Counter(
    "consumer.messages.processed", 
    metric.WithDescription("Total messages successfully processed"),
  )
  m.processingErrors, _ = meter.Int64Counter(
    "consumer.messages.errors", 
    metric.WithDescription("Total processing errors"),
  )
  m.processingDuration, _ = meter.Float64Histogram(
    "consumer.messages.duration_seconds", 
    metric.WithDescription("Message processing duration"),
    metric.WithExplicitBucketBoundaries(0.01, 0.05, 0.1, 0.5, 1, 5, 10, 30),
  )
  m.duplicatesSkipped, _ = meter.Int64Counter(
    "consumer.messages.duplicates", 
    metric.WithDescription("Duplicate messages skipped"),
  )
  m.dlqMessages, _ = meter.Int64Counter(
    "consumer.dlq.sent", 
    metric.WithDescription("Messages dlq sent"),
  )
  m.dlqFailures, _ = meter.Int64Counter(
    "consumer.dlq.failures", 
    metric.WithDescription("Failed DLQ publishes - potential message loss"),
  )
 	m.dlqFailures, _ = meter.Int64UpDownCounter(
    "consumer.dlq.inflight", 
    metric.WithDescription("Currently processing messages"),
  ) 
  return m
}
```

`consumer.dlq.failures` 计数器应该发出警报，如果此计数器触发，则表示你正在丢失消息。请将 `PagerDuty` 阈值设置为大于 `0`。

为了进行追踪，我们在 `processMessage` 中设置的 `span` 会为每条消息创建一个追踪。要连接生产者和消费者的追踪，请通过 NATS 标头传播上下文。

```go
// Producer 侧
func publishWithTrace(ctx context.Context, js nats.JetStreamContext, subject string, data []byte) error {
  msg := &nats.Msg{
    Subject: subject,
    Data: data,
    Header: nats.Header{},
  }
  otel.GetTextMapPropagator().Inject(ctx, propagation.HeaderCarrier(msg.Header))
  _, err := js.PublishMsg(msg)
  return err
}

// Consumer 侧，在 processMessage 中，替换 context.Background();
ctx  = otel.GetTextMapPropgator().Extract(ctx, propagation.HeaderCarrier(natsMsg.Header))
ctx, span := c.tacer.Start(ctx, "process_message", ...)
```

现在，你的跟踪记录显示了完整的流程：API 请求 -> 发布 -> 消费 ->  处理 -> 下游调用。这对于调试异步管道中的延迟至关重要。



## 测试策略

队列消费者历来难以测试。这里提供一种分层测试方法：

**单独对处理程序进行单元测试**——不涉及队列和基础设施：

```go
func TestHandleOrder_Success(t *testing.T) {
  msg := consumer.Message{
    ID: "test-1",
    Data: []byte(`{"id": "order-123", "amount": 99.99}`),
  }
  
  err := handleOrder(context.Background(), msg)
  assert.NoError(t, err)
  // 断言副作用：数据库写入、API 调用等
}

func TestHandleOrder_InvalidJSON(t *testing.T) {
  msg := consumer.Message{
    ID: "test-2",
    Data: []byte(`not json`)
  }
  
  err := handleOrder(context.Background(), msg)
  assert.Error(t, err)
  
  var permErr *consumer.PermanentError
  assert.True(t, errors.As(err, &permErr), "bad JSON should be a permanent error")
}
```

**与嵌入式 NATS 服务器的集成测试**——测试完整的消费者生命周期：

```go
func TestConsumer_ProcessAndCheck(t *testing.T) {
	// Start embedded NATS
  srv, _ := server.NewServer(&server.Options{
    Port: -1,
    JetStream: true,
    StoreDir: t.TempDir(),
  })
  go srv.Start()
  defer srv.Shutdown()
  srv.ReadyForConnections(5 * time.Second)
  
  nc, _ := nats.Connect(srv.ClientURL())
  defer nc.Close()
  
  js, _ := nc.JetStream()
  consumer.EnsureStreams(js, "TEST", "test.subject")
  
  processed := make(chan string, 1)
  handler := func(ctx context.Context, msg consumer.Message) error {
    processed <- msg.ID
    return nil
  }
  
  store := &InMemoryIdempotencyStore{seen: map[string]bool{}}
  cfg := consumer.DefaultConfig()
  cfg.StreamName = "TEST"
  cfg.Subject = "test.subject"
  cfg.Durable = "test-consumer"
  cfg.WorkerCount = 1
  
  c, _ := consumer.New(nc, cfg, handler, store)
  
  ctx, cancel := context.WithCancel(context.Background())
  defer cancel()
  c.Start(ctx)
  
  // 发布一条消息
  js.Publish("test.subject", []byte(`{"key":"value"}`), nats.MsgId("msg-001"))
  
  select {
  case id := <- processed
    assert.Equal(t, "msg-001", id)
  case <- time.After(5 *time.Second):
    t.Fatal("message not processed within timeout")
  }
}

func TestConsumer_DuplicateSkipped(t *testing.T) {
  // 和上述相同的步骤，但是预先标记消息 ID
  store := &InMemoryIdempotencyStore{seen: map[string]bool{"msg-001", true}}
  // 发布消息 msg-001，断言它被确认，但处理程序尚未调用
}

func TestConsumer_RetryThenDLQ(t *testing.T) {
  // 处理程序每次都会返回错误
  // 断言消息在 MaxRetries 后出现在 DLQ 流中
}
```

**混沌测试**——在处理过程中终止消费者进程，重新启动，并验证没有消息丢失：

```go
func TestConsumer_CrashRecovery(t *testing.T) {
	// 1. 发布 100 条消息
	// 2. 启动 Consumer，让它处理约 50 条数据
	// 3. 取消上下文（模拟崩溃）
	// 4. 使用相同的 durable 名称创建新的 Consumer
	// 5. 等待所有 100 个数据处理完毕（有些数据可能处理两次）
	// 6. 断言：处理程序被调用了 >= 100 此，所有消息 ID 都被覆盖
}
```

用于测试的内存幂等性存储：

```go
type InMemoryIdempotencyStore struct {
	mu sync.Mutex
  seen map[string]bool
}

func (s *InMemoryIdempotencyStore) Exists(_ context.Context, id string) {
  s.mu.Lock()
  defer s.mu.Unlock()
  return s.seen[id], nil
}

func (s *InMemoryIdempotencyStore) Mark(_ context.Context, id string,  _ time.Duration) error {
  s.mu.Lock()
  defer s.mu.Unlock()
  s.seen[id] = true
  return nil
}
```



# 生产检查清单

在向 Consumer 发送消息前：

- [ ] **幂等性**——处理程序可以安全地对同一输入运行两次
- [ ] **永久性错误与暂时性错误**——错误数据直接进入死信队列，而不是经过重试循环
- [ ] **退避边界**——`MaxBackoff` 可以防止重试风暴；抖动效果更佳
- [ ] **DLQ 监控**—— `dlq.sent > 0` 上的警报和 `dlq.failures > 0` 上的呼叫
- [ ] **优雅关闭**——清空订阅，等待传输中数据，然后退出
- [ ] **健康检查**——公开 `/healthz`，用于检查 NATS 和幂等性存储连接
- [ ] **消费者延迟指标**——通过 NATS 管理台 API 监控 `consumer.messages.pending`
- [ ] **资源限制**——工作进程数、通道缓冲区大小和消息大小的限制
- [ ] **追踪传播**——连接生产者和消费者 span，实现端到端的可见性



# 总结

消息队列消费者的原型设计看似简单，但实际部署缺难上加难。本文介绍的模式——幂等处理、服务端重试（带退避机制）、死信队列、有界工作池、优雅关闭以及完全可观测性——构成了应对实际系统故障的基础。

完整的消费者应用只有大约 300 行简洁的 Go 代码。没有框架、没有魔法。只有清晰的并发模式和精心设计的错误处理。这才是你希望在凌晨 3 点运行的代码。

