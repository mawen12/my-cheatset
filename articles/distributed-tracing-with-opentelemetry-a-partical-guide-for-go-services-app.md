# 背景

你有日志，你有指标。一个请求通过 API 网关进入你的系统，经过五个服务层层传递，最终在订单处理流程的深处失败。你打开 Kibana，在成千上万日志中搜索，然后花了四十分钟手动关联时间戳。

分布式追踪可以消除这个痛点。它能让你全面了解请求在架构中流经的每个服务的整个过程。随着 OpenTelemetry 逐渐成为行业标准，现在正是集成它的最佳时机。

本文将从零开始，逐步讲解如何使用 OpenTelemetry 为 Go 服务添加检测功能。没有玩具示例——这里的所有代码都是生产级的，你可以直接部署到实际系统中。

# 为什么分布式追踪至关重要？

在单体架构中，堆栈跟踪信息涵盖了所有问题。而在分布式系统中，单个用户操作可能涉及 API 网关，身份验证服务、订单服务、支付提供商、通知队列和数据库。当出现故障和运行缓慢时，你需要回答：是哪个服务、哪个调用、哪个依赖项出了问题？

分布式追中通过为每个传入请求分配一个追踪 ID，并将其传播到每个下游调用来解决这个问题。服务中的每个工作单元都成为为一个 span，而 span 嵌套形成一棵树，这棵树代表了完整的请求生命周期。

回报立竿见影：

- **延迟诊断**：准确查看哪个服务或数据库调用存在瓶颈
- **错误归属**：请注意，500 错误来自支付服务的连接池，而不是你的代码
- **依赖关系图**：可视化服务在运行时实际的通信方式，而不是架构图所描述的通信方式
- **SLA 跟踪**：测量整个呼叫链中每个端点的延迟分布

# 60 秒内掌握 OpenTelemetry

OpenTelemetry（OTel）是一个 CNCF 项目，它提供了一个厂商中立的 API、SDK 和一套用于生成遥测数据的工具。对于遥测而言，其关键概念包括：

- **TraceProvider**：创建跟踪器并管理 span 处理器的工厂
- **Tracer**：在特定的检测范围内创建 span (通常每个包一个)
- **Span**：代表一个工作单元。它具有名称、开始/结束时间、属性、事件和状态
- **SpanProcessor**：处理已完成的 span（批处理、导出）
- **Exporter**：将 span  数据发送到后端（Jager、Zipkin、OLTP 收集器）
- **Propagator**：跨进程边界（HTTP 标头、消息队列）序列化/反序列化跟踪上下文

# 设置 OTel SDK

首先是依赖项。我们将使用基于 gRPC 的 OTLP 作为 导出协议，它可与 Jaeger、Tempo、Datadog 以及任何兼容 OTLP 的后端使用。

```go
go get go.opentelemetry.io/otel \
			 go.opentelemetry.io/otel/sdk \
			 go.opentelemetry.io/otel/sdk/trace \
			 go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc \
			 go.opentelemetry.io/otel/propagation \
			 go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp
```

现在构建追踪器提供程序。这是应用程序追踪功能的核心——在启动时初始化一次，并在退出时干净利落地关闭它。

```go
package telemetry

import (
	"context"
  "fmt"
  "time"
  
  "go.opentelemetry.io/otel"
  "go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
  "go.opentelemetry.io/otel/propagation"
  "go.opentelemetry.io/otel/sdk/resource"
  sdktrace "go.opentelemetry.io/otel/sdk/trace"
  semconv "go.opentelemetry.io/otel/semconv/v1.24.0"
)

type Config struct {
  ServiceName 	 string
  ServiceVersion string
  Environment 	 string
  OTLPEndpoint   string // e.g., "otel-collector:4317"
  SampleRate 		 float64
}

func InitTrace(ctx context.Context, cfg Config) (shutdown func(context.Context) error, err error) {
  exporter, err := otlptracegrpc.New(
    ctx, 
    otlptracegrpc.WithEndpoint(cfg.OTLPEndpoint),
    otlptracegrpc.WithInsecure(), // 在生产中使用 WithTLSCredentials
  )
  if err != nil  {
    return nil, fmt.Errorf("creating OTLP exporter: %w", err)
  }
  
  res, err := resource.Merge(
    resource.Default(),
    resource.NewWithAttributes(
    	semconv.SechmaURL,
      semconv.ServiceName(cfg.ServiceName),
      semconv.ServiceVersion(cfg.ServiceVersion),
      semconv.DeploymentEnvironment(cfg.Environment),
    ),
  )
  if err != nil {
    return nil, fmt.Errorf("creating resource: %w", err)
  }
  
  sampler := sdktrace.ParentBase(
    sdktrace.TraceIDRatioBased(cfg.SampleRate),
  )
  
  tp := sdktrace.NewTracerProvider(
    sdktrace.WithBatcher(
      exporter, 
      sdktrace.withMaxQueueSize(2048),
      sdktrace.WithMaxExporterBatchSize(512),
      sdktrace.WithBatchTimeout(5*time.Second),
    ),
    sdktrace.WithResource(res),
    saktrace.WithSampler(sampler),
  )
  
  otel.SetTracerProvider(tp)
  otel.SetTextMapPropagator(progatation.NewCompositeTextMapPropagator(
    propagation.TraceContext(),
    propagation.Baggage{},
  ))
  
  return tp.Shutdown, nil
}
```

这里有几个值得解释的深思熟虑的决定：

**`ParentBased` sampler**：如果传入的请求已经包含采样决策（来自上游服务），我们将遵循该决策。这可以防止出现父级被采样而子级未被采样的情况，从而避免追踪信息不完整。基于 TraceIDRatio 的采样器仅适用于 root span——即来源此服务的请求。

**Batch processor tuning**：默认设置较为保守。对于高吞吐量服务（每秒 1 万个请求以上），请增加 `MaxQueueSize` 和 `MaxExporterBatchSize` 的值。`BatchTimeout` 控制批处理数据刷新前的最大延迟时间，即使批处理数据尚未满。

**Resource attributes**：这些属性为每个 span 添加服务标识。后端 UI 是哟功能它们进行筛选和分组。至少应包含服务名称、版本和环境 。

# 将其连接到 main()

```go
func main() {
  ctx := context.Background()
  
  shutdown, err := telemetry.InitTracer(ctx, telemetry.Config{
    ServiceName: 		"order-service",
    ServiceVersion: "1.4.2",
    Environment: 		os.Getenv("APP_ENV"),
    OTLPEnpdoint: 	os.Getenv("OTEL_EXPORTER_OTLP_ENDPOINT"),
    SampleRate: 		0.1, // 对 10% 的追踪进行采样
  })
  if err != nil {
    log.Fatalf("init tracer: %v", err)
  }
  defer func() {
    // 给导出器 10 秒时间来刷新剩余的 span
    ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
    defer cance()
    if err := shutdown(ctx); err != nil {
      log.Printf("tracer shutdown: %v", err)
    }
  }
  
  // ... start HTTP server
}
```

延迟关闭至关重要。如果没有它，批处理处理器 中缓存的数据 span 会在进程退出时丢失。这是与本系列第 14 篇中介绍的优雅关闭模式完美契合。

# 检测 HTTP Handlers

OpenTelemetry 提供了 `otelhttp`，这是一个中间件，可自动为传入的 HTTP 请求创建 span，并从标头中提取追踪上下文。

```go
package main

import (
    "net/http"
  
    "go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
)

func newRouter() http.Handler {
  mux := http.NewServeMux()
  mux.HandleFunc("/orders", handleListOrders)
  mux.HandleFunc("/orders/create", handleCreateOrder)
  
  // 使用 OTel 对整个 mux 进行插桩
  return otelhttp.NewHandler(
    mux, 
    "http-server", 
    otelhttp.WithMessageEvents(otelhttp.ReadEvents, otelhttp.WriteEvents),
  )
}
```

现在，每个传入的请求都会生成一个以 HTTP 路由命名的 span，其中包含方法、状态码、URL 以及请求/响应大小等属性。中间件还会自动提取 `traceparent` 和 `tracestate` 标头——这就是从上游服务获取追踪上下文的方式。

为了更精确的命名路由（避免使用像 `/orders/abc123` 这样基数很高的 span 名称），请使用自定义 span 名称格式化程序：

```go
otelhttp.NewHandler(
  mux, 
  "http-server", 
  otelhttp.WithSpanNameFormatter(func(operation string, r *http.Request) string {
    // 使用路由模式而不是实际的 URL
    return fmt.Sprintf("%s %s", r.Method, r.Pattern)
  }),
)
```

# 跨服务传播上下文

分布式追踪的名称正是来源于追踪上下文的传播。当服务 A 调用服务 B 时，它必须将当前追踪上下文注入到传出的请求头中。然后，服务 B 会提取该上下文并继续执行相同的值。

使用 `otelhttp.NewTransport` 包装你的 HTTP 客户端：

```go
package httpclient

import (
	"net/http"
  "time"
  
  "go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
)

// New 返回一个 http 客户端，该客户端传播跟踪上下文
// 并为每个传出的请求创建客户端 span
func New() *http.Client {
  return &http.Client{
    Timeout: 30 * time.Second,
    Transport: otelhttp.NewTransport(
      &http.Transport{
        MaxIdleConns: 			 100,
        MaxIdleConnsPerHost: 10,
        IdleConnTimeout: 		 90 * time.Second,
      },
    ),
  }
}
```

现在，每个发出的 HTTP 请求都会自动注入 `traceparent` 标头并创建一个客户端 span。以下是调用下游服务的处理程序中的示例：

```go
func handlerCreateOrder(w http.ResponseWriter, r *http.Request) {
  ctx := r.Context()
  
  // 此 span 是 otelhttp 创建的 HTTP 服务器 span 的子 span
  order, err := processOrder(ctx, r)
  if err !=  nil {
    http.Error(w, "failed to process order", http.StatusInternalServerError)
    return
  }
  
  // 该客户端会自动传播跟踪上下文
  client := httpclient.New()
  req, _ := http.NewRequestWithContext(
    ctx, 
    "POST",
    "http://payment-service/charge",
    orderToJSON(order),
  )
  resp, err := client.Do(req)
  // ...
}
```

关键细节：**始终传递 ctx**。上下文中包含当前 span。如果使用 `context.Background()` 而不是请求上下文，则会破坏跟踪链。

# 自定义 Spans 和 Attributes

自动检测可以覆盖 HTTP 边界，但最有价值的跟踪数据来自围绕业务逻辑的自定义 span。

```go
package order

import (
	"context"
  "fmt"
  
  "go.opentelemetry.io/otel"
  "go.opentelemetry.io/otel/attributes"
  "go.opentelemetry.io/otel/codes"
  "go.opentelemetry.io/otel/trace"
)

var tracer = otel.Tracer("github.com/yourorg/order-service/internal/order")

func ProcessOrder(ctx context.Context, req CreateOrderRequest) (*Order, error) {
  ctx, span := tracer.Start(
    ctx, 
    "order.Process",
    trace.WithAttributes(
      attribute.String("order.customer_id", req.Customers),
      attribute.String("order.item_count", len(req.Items)),
      attribute.String("order.currency", req.Currency),
    ),
  )
  defer span.End()
  
  // 校验库存
  if err := validateInventory(ctx, req.Items); err != nil {
    span.RecordError(err)
    span.SetStatus(codes.Error, "inventory validation failed")
    return nil, fmt.Errorf("validate inventory: %w", err)
  }
  span.SetAttributes(attribute.Float64("order.total", total))
  
  // 计算价格
  total, err := calculateTotal(ctx, req.Items, req.Currency)
  if err != nil {
    span.RecordError(err)
		span.SetStatus(codes.Error, "pricing calculation failed")
    return nil, fmt.Errorf("calculate total: %w", err)
  }
  
  // 持久保存
  order, err := saveOrder(ctx, req, total)
  if err != nil {
    span.RecordError(err)
    span.SetStatus(codes.Error, "persistence failed")
    return nil, fmt.Errorf("save order: %w", err)
  }
  
  
  span.SetAttributes(attribute.String("order.id", order.ID))
  return order, nil
}
```

这里涉及到几种模式：

- **Tracer per package**：`otel.Tracer("...")` 会创建一个检测范围。请使用完整的包路径。这会显示在追踪界面中，并有助于识别生成 span 的代码。
- **Record errors AND set status**：`RecordError` 会向 span 添加一个异常事件（如果可用，还会添加堆栈跟踪）。`SetStatus` 会将 span 标记为失败。两者都需要执行——有些后端使用其中一种，有些后端使用另一种。
- **Add attributes progressively**：你无需预先知道所有属性。随着函数的执行，逐步添加它们。`order.id` 仅在数据库写入后可用，因此我们在那时设置它。
- **Return the enricked ctx**：`tracer.Start` 返回一个包含 span 的新上下文。将此上下文传递给下游函数，以便它们的 span 能够正确嵌套。

# 检测 Database 调用

数据库调用几乎总是延迟的根源。围绕这些调用创建  span：

```go
func saveOrder(ctx context.Context, req CreateOrderRequest, total float64) (*Order, error) {
  ctx, span := tracer.Start(
    ctx, 
    "order.SaveToDB",
    trace.WithAttributes(
      attribute.String("db.system", "postgresql"),
      attribute.String("db.operation", "INSERT"),
      attribute.String("db.sql.table", "orders"),
    ),
  )
  defer span.End()
  
  query = `INSERT INTO orders (customer_id, total, currency, status) 
  				VALUES ($1, $2, $3, 'pending') RETURNING id, created_at`
  
 	var order Order
  err := db.QueryRowContext(ctx, query, req.CustomerID, total, req.Currency).
  	Scan(&order.ID, &order.CreatedAt)
  if err != nil {
    span.RecordError(err)
    span.SetStatus(codes.Error, "db insert failed")
    return nil, err
  }
  
  return &order, nil
}
```

请使用 OpenTelemetry 的数据库语义约定（`db.system`、`db.operation`、`db.sql.table`），以便你的追踪后端能够呈现特定于数据库的视图。请勿在生产环境中将完整的 SQL 查询语句放在 span 属性中——它可能包含个人身份信息（PII）。

# 连接到 Jaeger 或 Zipkin

## 选项 1：OLTP-native（推荐）

现在 Jaeger（v1.35+）原生支持通过 gRPC 在 4317 端口上使用 OTLP。我们的设置已经可以正常工作——只需将 `OTEL_EXPORTER_OTLP_ENDPOINT` 指向 ``jaeger:4317` 即可。

对于 Grafana Tempo，情况也一样；OTLP 在端口 4317 上运行。

## 选项 2：OpenTelemetry Collector

对于生产环境，请将 OTel Collector 作为 sidecar 或 daemonset 运行。这样可以将你的服务与追踪后端解耦，并增加诸如基于尾部的采样、属性过滤和多后端扇出等功能。

```yaml
# otel-collector-config.yaml
receivers:
	otlp:
		protocols:
			grpc:
				endpoint: 0.0.0.0:4317

processors:
	batch:
		timeout: 5s
		send_batch_size: 512
	memory_limiter:
		check_interval: 1s
		limit_mib: 512
		spike_limit_mib: 128

exporters:
	otlp/jaeger:
		endpoint: jaeger:4317
		tls:
			insecure: true
	otlp/tempo:
		endpoint: tempo:4317
		tls:
			insecure: true

service:
	pipelines:
		traces:
			receivers: [otlp]
			processors: [memory_limiter, batch]
			exporters: [otlp/jaeger, oltp/tempo]
```

收集器的 `memory_limiter` 处理器至关重要。如果没有它，流量高峰可能会导致收集器内存溢出（OOM），从而丢失所有已缓冲的数据  span。

## 选项 3：Zipkin Exporter

如果你必须使用 Zipkin，请使用专用导出器：

```go
import "go.opentelemetry.io/otel/exporters/zipkin"

exporter, err := zipkin.New("http://zipkin:9411/api/v2/spans")
```

# 异步工作流中的追踪上下文

HTTP 传播机制可以处理同步调用，但许多生产系统使用消息队列。你需要手动注入和提取追踪上下文。

## Producer（发布到队列）

```go
func publishOrderEvent(ctx context.Context, event OrderCreateEvent) error {
  carrier := make(propagation.MapCarrier)
  otel.GetTextMapPropagator().Inject(ctx, carrier)
  
  headers :=  make(map[string]string)
  for _, key := range []string{"traceparent", "tracestate"} {
    if val := carrier.Get(key); val != "" {
    	headers[key] = val
    }
  }
  
  msg := &queue.Message{
    Body: 	 encodeEvent(event),
    Headers: headers,
  }
  return queue.Publish(ctx, "order.created", msg)
}
```

## Consumer（从队列中读取）

```go
func handleOrderCreatedMessage(msg *queue.Message) error {
  carrier := propagation.MapCarrier(msg.Headers)
  ctx := otel.GetTextMapPropagator().Extract(context.Background(), carrier)
  
  ctx, span := tracer.Start(
    ctx, 
    "queue.ProcessOrderCreated",
    tracer.WithSpanKind(tracer.SpanKindConsumer),
    tracer.WithAttributes(
      attribute.String("messaging.system", "rabbitmq"),
      attribute.String("messaging.operation", "process"),      
    ),
  )
  defer span.End()
  
  // 使用恢复的追踪上下文进行处理
  return processOrderCreated(ctx, msg.Body)
}
```

# 生产环境最佳实践

## 1. 智能采样

追踪 100% 的流量成本很高。使用 `ParentBased(TraceIDRatioBased(0.1))` 对 10% 的新追踪数据进行采样，同时始终遵循上游的采样决策。对于错误调查，在收集器级别实施基于尾部的采样——它会捕获所有包含错误 span 的追踪数据。

## 2. 控制 span 基数

每个唯一的 span 名称都会在后端创建一个序列。请避免在 span 名称中使用动态值。

```go
// BAD: 创建上千个唯一的 span 名称
tracer.Start(ctx, fmt.Sprintf("getUser-%s", userID))

// GOOD: 使用属性来表示动态值
tracer.Start(ctx, "user.Get", trace.WithAttributes(attribute.String("user.id", userID)))
```

## 3. 保持属性值有界

高基数属性（完整 URL、原始 SQL、请求体）会占用大量存储空间并降低查询速度。建议使用 ID、枚举或字符串。对于仅偶尔需要的详细调试数据，请使用 span 事件。

## 4. 正确设置 Span Kind

Span kind 用于告诉后端如何渲染 span：

- `SpanKindServer` —— 进站的 RPC/HTTP（由 `otelhttp` 中间件设置）
- `SpanKindClient` —— 出站的 RPC/HTTP（由 `otelhttp transport` 设置）
- `SpanKindProducer` —— 发布到消息队列
- `SpanKindConsumer` —— 从消息队列消费
- `SpanKindInternal` —— 默认，本地操作

## 5. 使用 Span Links 进行扇出

当一个请求触发了多个异步操作时，应使用 span `links` 而非父子关系。处理 1000 条消息的批处理作业应该链接到每个生产者 span，而不是链接到它们的父级——否则会得到难以阅读的跟踪树。

```go
links := make([]trace.Link, len(messages))
for i, msg := range messages {
  carrier := propagation.MapCarrier(msg.Headers)
  remoteCtx := otel.GetTextMapPropagator().Extract(context.Background(), carrier)
  links[i] = trace.LinkFromContext(remoteCtx)
}

ctx, span := tracer.Start(ctx, "batch.ProcessMessages", tracer.WithLinks(links...))
```

## 6. 将跟踪数据与日志进行关联

将追踪 ID 注入dao结构化日志记录器中，以便可以按追踪搜索日志行：

```go
func loggerFromContext(ctx context.Context) *slog.Logger {
  spanCtx := trace.SpanContextFromContext(ctx)
  return slog.Default().With(
    slog.String("trace_id", spanCtx.TraceID().String()),
    slog.String("span_id", spanCtx.SpanID().String()),    
  )
}
```

Grafana、Datadog 和大多数可观测平台在存在 `trace_id` 时可以从日志行跳转到完整的追踪。

## 7. 关机前刷新

我们在设置部分已经提到过这一点，但值得再次强调：调用 `TraceProvider.Shutdown()` 时必须设置一个足够长的超时时间。批处理处理器可能已经排队数百个 span。请将其与你的优雅关闭处理程序配合使用。


# 完整的追踪记录是什么样的

在对两个服务进行插桩后，Jaeger 中的跟踪记录如下所示：

```
order-service: POST /orders/create		[============] 320ms
	├─ order.Process										[==========]   220ms
	│		├─ order.ValidateInventory			[===]					 85ms
	│		├─ order.CalculateTotal					[=]						 12ms
	│	  └─ order.SaveToDB								[==]					 45ms
	└ HTTP POST payment-service/charge	[=====]				 130ms
			payment-service; POST /charge		[====]				 125ms
				├─ payment.ValidateCard				[=]						 15ms	
				└─ payment.ProcessCharge			[===]					 105ms
```

概览：总延迟 320 毫秒，其中支付服务耗时 130 毫秒。数据库插入操作耗时 45 毫秒——对于包含索引更新的写入操作来说，这个延迟是合理的。如果此端点的延迟开始超出了其服务级别目标（SLO），你就知道该从哪里入手排查问题了。

# 总结

分布式追踪的初始投资在你首次无需手动关联日志即可调试跨服务延迟问题时即可收回成本。设置如下：

1. 初始化 `TracerProvider`，支持 OLTP 导出和合理的批处理
2. 使用 `otelhttp.NewHandler` 包装 HTTP 服务器，以实现自动创建 span
3. 使用 `otelhttp.NewTransport` 封装 HTTP 客户端，以实现自动上下文传播
4. 围绕业务逻辑和数据库调用添加自定义 span
5. 手动将上下文信息传递到消息队列
6. 样本、控制基数、与日志关联

本文所有代码均使用稳定的 OpenTelemetry Go SDK。它可与任何兼容 OLTP 的后端配合使用，例如 Jager、Tempo、Datadog、Honeycomb 或 OTel Collector。选择其中一个后端，将导出器指向它，即可开始了解系统的真实情况。
