# 背景

每个 Go 开发者都写过成千上万遍 `if err != nil`。许多来自使用异常处理的语言的开发者认为这是一个缺陷。我以前也这么认为——直到我用 Go 构建生产系统多年，才意识到显示错误处理并非限制。它是一种特性，能让你的系统更可靠、更易于调试，也更容易在凌晨三点的压力下进行推理。

本文将详细介绍我在生产环境 Go 服务中所用的错误处理模式。没有简单的示例，所有内容都来自处理真实流量的真实系统。



# 为什么 Go 的错误处理机制实际上很好？

在深入探讨模式之前，我们先来谈谈一个显而易见的问题。Go 语言的 `if err != nil` 语句之所以显得冗长，是因为它本身就很冗长。这就是问题的关键所在。

在有异常处理的语言中，错误路径是不可见的。一个五层嵌套的函数可能会抛出异常，除非你记住了调用链中所有可能的异常，否则你根本不知道哪里会出错。但在 Go 语言中，所有潜在的错误都清晰地呈现在你的眼前。

```go
user, err := repo.FindUser(ctx, id)
if err != nil {
  return fmt.Errorf("finding user %s: %w", id, err)
}
```

这行代码告诉了你三件事：

1. `FindUser` 可能会失败
2. 你已经决定了如何应对那次失败了
3. 错误信息包含了出错时发生的情况背景

这不是千篇一律的模板 ，而是工程规范的明确体现。让我们以此为基础继续探讨。



# 使用上下文包装错误

你能做的最有效的错误改进就是统一的错误信息封装。缺乏上下文的原始错误信息在生产环境中几乎毫无用处。

**Bad**

```go
func GetOrder(ctx context.Context, id string) (*Order, error) {
  row := db.QueryRowContext(ctx, "SELECT ... WHERE id = $1", id)
 	var o Order
  if err := row.Scan(&o.ID, &o.Total, &o.Status); err != nil {
    return nil, err // "sql: no rows in result set" —— 在日志中毫无用处
  }
  return &o, nil
}
```

**Good**

```go
func GetOrder(ctx context.Context, id string) (*Order, error) {
  row := db.QueryRowContext(ctx, "SELECT ... WHERE id = $1", id)
 	var o Order
  if err := row.Scan(&o.ID, &o.Total, &o.Status); err != nil {
    return nil, fmt.Errorf("get order %s: %w", id, err)
  }
  return &o, nil
}
```

`fmt.Errorf` 中的 `%w` 动词会包装原始错误，保留完整的错误链。现在，当此错误出现在日志中时，你会看到 "get order abc-123: sql: no rows in result set" —— 可立即采取行动。

**包装规则**：每个函数都会添加自己的上下文——它试图做什么 以及使用了哪些输入——然后包装底层错误。这样就构建了一个 自然的、类似调用堆栈的跟踪信息：

```
processing payment for user u_43: charging card: stripe api: connection refused
```

你可以从左到右阅读这段文字，无需打开任何源文件就能完全理解发生了什么。



# 包装陷阱：不要包两层

常见的错误是将调用方和被调用方的信息重叠包裹起来：

```go
// 不要这样做
func getUser(id string) (*User, error) {
  u, err := db.Find(id)
  if err !=  nil {
    return nil, fmt.Errorf("failed to get user from database: %w", err)
  }
  return u, nil
}

func handleRequest(id sting) error {
  u, err := getUser(id)
  if err != nil {
    return fmt.Errorf("failed to get user from database: %w", err)
    // 结果："failed to get user from database: failed to get user from database: ..."
  }
  // ...
}
```

每一层都应该提供新的上下文。调用方说明它在做什么；被调用方说明它那一层出了什么问题。



# Sentinel 错误

Sentinel 错误是包级别的变量，代表特定的、众所周知的错误情况。标准库广泛使用它们：`io.EOF`、`sql.ErrNoRows`、`context.Canceled`。

明确区分哪些错误属于警示性错误，即调用者需要根据错误类型做出决策时：

```go
package order

import "errors"

var (
  ErrNotFound 			= errors.New("order not found")
  ErrAlreadyPaid 		= errors.New("order already paid")
  ErrInvalidStatus 	= errors.New("invalid order status transition")
)
```

在代码中使用它们：

```go
func (r *Repository) GetOrder(ctx context.Context, id string) (*Order, error) {
  row := r.db.QueryRowContext(ctx, query, id)
  var o Order
  if err := row.Scan(&o.ID, &o.Total, &o.Status); err != nil {
    if errors.Is(err, sql.ErrNoRows) {
      return nil, ErrNotFound
    }
    return nil, fmt.Errorf("scanning order %s: %w",  id, err)
  }
  return &o, nil
}
```

注意：当我们返回 `ErrNotFound` 时，我们不会包装 `sql.ErrNoRows`。我们将存储层错误转换为领域级错误。调用者无需了解或关心其中是否涉及 SQL。

# 自定义错误类型

当你需要将结构化数据与错误消息一起传递时，请定义一个自定义类型：

```go
type ValidationError struct {
  Field 	string
  Message string
  Value 	any
}

func (e *ValidationError) Error() string {
  return fmt.Errorf("validation failed on field %q: %s (got %v)", e.Field, e.Message, e.Value)
}
```

为了提供更丰富的领域错误信息，你可以嵌入更多上下文：

```go
type DomainError struct {
	Code 		string 	// 机器可读："ORDER_EXPIRED"、"INSUFFICIENT_FUNDS"
	Message string	// 人类可读描述
	Err 		error		// 底层原因（可选）
}

func (e *DomainError) Error() string {
	if e.Err != nil {
		return fmt.Sprintf("%s: %s: %v", e.Code, e.Message, e.Err)
	}
	return fmt.Sprintf("%s: %s", e.Code, e.Message)
}

func (e *DomainError) Unwrap() error {
	return e.Err
}
```

`Unwrap()` 方法至关重要——它允许 `errors.Is` 和 `errors.As` 通过你的自定义类型遍历错误链。



# errors.Is 和 errors.As

在 Go 1.13+ 中，这两个函数用于检查错误。它们会遍历整个包装后的错误链，这就是 `Unwrap()` 函数的重要性所在。

## errors.Is：检查特定错误

```go
order, err := svc.GetOrder(ctx, orderID)
if errors.Is(err, order.ErrNotFound) {
	// 返回给客户端 404
	http.Error(w, "order not found", http.StatusNotFound)
	return
}
if err != nil {
	// 发生意外情况——记录日志并返回 500
	log.Error("unexpected error", "err", err, "order_id", orderID)
	http.Error(w, "internal error", http.StatusInternalServerError)
	return
}
```

`errors.Is` 方法能够忽略包装层级。即使错误被包装了三次，`errors.Is(err, ErrNotFound)` 仍然能返回 true。

## errors.As：提取错误详情

```go
var validErr *ValidationError
if errors.As(err, &validErr) {
	respondJSON(w, http.StatusBadRequest, map[string]any{
		"error": "validation_failed",
		"field": validErr.Field,
		"detail": validErr.Message,
	})
	return
}
```

`errors.As` 函数会找到链中第一个与目标类型匹配的错误，并设置指针。这是 Go 语言中类型安全的替代方案，相当于其他语言中的 `catch(ValidationException e)`。

## 实现自定义匹配

你可以在自定义类型中定义 `Is` 以进行语义匹配：

```go
type NotFoundError struct {
	Resource string
	ID 			 string
}

func (e *NotFoundError) Error() string {
	return fmt.Errorf("%s %s not found", e.Resource, e.ID)
}

func (e *NotFoundError) Is(target error) bool {
	if target == ErrNotFound {
		return true
	}
	_, ok := target.(*NotFoundError)
	return ok
}
```

现在，即使实际错误是 `&NotFoundError{Resource: "order", ID: "abc"}`，`errors.Is(err, ErrNotFound)` 也能正常工作。



# Error Groups：处理并发错误

当你并发执行操作时，需要一种错误收集策略。`errgroup` 包（来自 `golang.org/x/sync`）是标准工具：

```go
import "golang.org/x/sync/errgroup"

func (s *Service) EnrichOrder(ctx context.Context, o *Order) error {
  g, ctx := errgroup.WithContext(ctx)
  
  g.Go(func() error{
    user, err := s.users.Get(ctx, o.UserID)
    if err != nil {
      return fmt.Errorf("fetching user: %w", err)
    }
    o.User = user
    return nil
  })
  
  g.Go(func() error {
    items, err := s.inventory.GetItems(ctx, o.ItemIDs)
    if err != nil {
      return fmt.Errorf("fetching inventory: %w", err)  
    }
    o.Items = items
    return nil
  })
  
  if err := g.Wait(); err != nil {
    return fmt.Errorf("enriching order %s: %w", o.ID, err)
  }
  return nil
}
```

关键行为：当任何 goroutine 返回错误时，`errgroup.WithContext` 会取消派生上下文。这意味着如果用户获取失败，库存获取操作也会自动取消——不会造成任何浪费。

如果你需要获取所有错误 （而不仅仅是第一个），请使用 Go 1.20+ 中的 `errors.Join` 方法：

```go
func ValidateOrder(o *Order) error {
	var errs []error
	
	if o.Total <= 0 {
		errs = append(errs, &ValidationError{
			Field: "total", Message: "must be positive", Value: o.Total,
		})
	}
	if o.UserID == "" {
		errs = append(errs, &ValidationError{
			Field: "user_id", Message: "required",
		})
	}
	if len(o.Items) == 0 {
		errs = append(errs, &ValidationError{
			Field: "items", Message: "at least one item required",
		})
	}
	
	return errors.Join(errs...) // 如果 errs 为空则返回 nil
}
```

`errors.Join` 会创建一个多错误集合，`errors.Is` 和 `errors.As` 可以遍历集合中的每个组成错误。这意味着调用者仍然可以使用 `errors.As(err, &validErr)` 从集合结果中提取单个验证失败。



# 结构化错误日志

将错误记录为非结构化字符串是一种生产环境中的反模式。请使用结构化日志记录，以便你的可观测工具能够真正处理错误数据。

```go
// 使用 log/slog（标准库，Go 1.21+）
func (h *Handler) HandlePayment(w http.ResponseWriter, r *http.Request) {
  ctx := r.Context()
  orderID := chi.URLParam(r, "orderID")
  
  err := h.service.ProcessPayment(ctx, orderID)
  if err != nil {
    slog.ErrContext(
      ctx, 
      "payment processing faield",
      "order_id", orderID,
      "error", err,
      "request_id", middleware.GetReqID(ctx),
      "user_id", auth.UserFromContext(ctx),
    )
    respondError(w, err)
    return
  }
  
  slog.InfoContext(ctx, "payment processed", "order_id", orderID)
  respondError(w, http.StatusOK, map[string]string{"status": "paid"})
}
```

通过结构化日志记录，你可以查询日志聚合器以获取注入 `error="*stripe*" AND order_id="ord_*"` 而不是使用正则表达式解析自由文本。

## 日志级别策略

并非所有错误都应该记录相同的日志级别：

```go
func classifyAndLog(ctx context.Context, err error, msg string, attrs  ...any) {
  switch {
  case errors.Is(err, context.Canceld):
    // 客户端已经断开——正常现象，无需发出警报
    slog.DebugContext(ctx, msg, append(attrs, "error", err)...)
  case errors.Is(err, ErrNotFound):
    // 预期的业务案例
    slog.InfoContext(ctx, msg, append(attrs, "error", err)...)
  case isTemporary(attr):
    // 瞬态故障——可重试
    slog.WarnContext(ctx, msg, append(attrs, "error", err)...)
  default:
    // 出乎意料——叫醒某人
    slog.ErrorContext(ctx, msg, append(attrs, "error", err)...)
  }
}
```





# HTTP Handlers 中的错误处理：领域错误模式

这是我在生产环境中使用最成功的模式。其思路是：你的领域/服务层返回领域错误，然后由一个中间件将其转换为 HTTP 响应。

首先，定义你的领域错误：

```go
package apperr

import "fmt"

type Code string

const (
	CodeNotFound 			Code = "NOT_FOUND"
  CodeAlreadyExists Code = "ALREADY_EXISTS"
  CodeInvalidInput 	Code = "INVALID_INPUT"
  CodeUnauthorized	Code = "UNAUTHORIZED"
  CodeForbidden			Code = "FORBIDDEN"
  CodeConflict			Code = "CONFLICT"
  CodeInternal			Code = "INTERNAL"
  CodeUnavailable		Code = "UNAVAILABLE"
)

type Error struct {
  Code Code 			`json:"code"`
  Message string 	`json:"message"`
  Err error 			`json:"-"` // 永远不要序列化内部错误
}

func (e *Error) Error() string {
  if e.Err != nil {
    return fmt.Sprintf("%s: %s: %v", e.Code, e.Message, e.Err)
  }
  return fmt.Sprintf("%s: %s", e.Code, e.Message)
}

func (e *Error) Unwrap() error {
  return e.Err
}

// 构造函数辅助函数保持调用点的整洁
func NotFound(msg string, args ...any) *Error {
  return &Error{Code: CodeNotFound, Message: fmt.Sprintf(msg, args...)}
}

func InvalidInput(msg string, args ...any) *Error {
  return &Error{Code: CodeInvalidInput, Message: fmt.Sprintf(msg, args...)}
}

func Conflict(msg string, args ...any) *Error {
  return &Error{Code: CodeConflict, Message: fmt.Sprintf(msg, args...)}
}

func CodeForbidden(msg string, args ...any) *Error {
  return &Error{Code: CodeForbidden, Message: fmt.Sprintf(msg, args...)}
}

func Internal(err error) *Error {
  return &Error{Code: CodeInternal, Message: "internal error", Err: err}
}
```

现在，你的服务层开始使用领域术语了：

```go
func (s *OrderService) CancelOrder(ctx context.Context, id string) error {
	order, err :=  s.repo.Get(ctx, id)
	if err != nil {
		return fmt.Errorf("cancel order: %w", err)
	}
	
	if order.Status == StatusShipped {
		return apperr.Conflict("cannot cancel shipped order %s", id)
	}
	if order.UserID != auth.UserFromContext(ctx) {
		return apperr.Forbidden("not your order")
	}
	
	if err := s.repo.UpdateStatus(ctx, id, StatusCancelled); err != nil {
		return fmt.Errorf("cancel order %s: %w", id, err)
	}
	return nil
}
```

HTTP 转换在一个地方完成：

```go
func respondError(w http.ResponseWriter, err error) {
  var appErr *apperr.Error
  if !errors.As(err, &appErr) {
    appErr = apperr.Internal(err)
  }
  
  status := mapCodeToHTTP(appErr.Code)
  respondJSON(w, status, map[string]any{
    "error": map[string]any{
      "code": appErr.Code,
      "message": appErr.Message,
    }
  })
}

func mapCodeToHTTP(code apperr.Code) int {
  switch code {
  case apperr.CodeNotFound:
    return http.StatusNotFound
  case apperr.CodeAlreadyExists:
    return http.StatusConflict
  case apperr.CodeInvalidInput:
    return http.StatusBadRequest
  case apperr.CodeUnauthorized:
    return http.StatusUnauthorized
  case apperr.CodeForbidden:
    return http.StausForbidden
  case apperr.CodeConflict:
    return http.StatusConflict
  case apperr.CodeUnavaiable:
  	return http.StatusServiceUnavailable
  default:
    return http.StatusInternalServerError
  }
}
```

这种模式可以让你：

- **简洁的服务代码** 无需了解 HTTP
- 所有端点的 **API 响应一致** 
- **安全的错误处理** —— 内部错误绝不会泄露给客户端（注意 `Err` 上的 `json:"-"` 标签）
- **易于测试** —— 断言错误代码，而不是 HTTP 状态代码

# 应避免的常见反模式 

## 1. 日志记录和返回

```go
// WRONG: 这会导致链上出现爱你重复的日志条目
if err !=  nil {
	log.Error("failed to get order", "err", err)
	return fmt.Errorf("getting user: %w", err)
}
```

规则：要么处理错误（记录日志、返回响应、重试），要么直接返回错误。两者不可兼得 。如果既记录日志又直接返回，那么 每个也记录日志的调用者都会生成指数级重复的日志行。

## 2. 吞咽错误

```go
// WRONG: 静默失败是最糟糕的失败
result, _ := json.Marshal(data)
```

只有当你真的不在乎结果，并且已经记录了原因时，你才应该忽略错误 ：

```go
// 尽力进行缓存更新——失败并不严重
_ = cache.Set(ctx, key, value, ttl)
```

## 3. 检查错误字符串

```go
// WRONG: 脆弱，如果错误消息发生变化就会崩溃
if strings.Contains(err.Error(), "not found") {
  // ...
}
```

务必使用 `errors.Is` 或 `errors.As`。字符串匹配是维护的噩梦，迟早会爆发。

## 4. 使用非描述性信息进行包装

```go
// WRONG: 增加的是噪音，而不是信号
return fmt.Errorf("error: %w", err)
return fmt.Errorf("an error occurred: %w", err)
return fmt.Errorf("failed: %w", err)
```

每个包装器都都应该注明尝试执行的操作以及使用的参数：

```go
// RIGHT: 可操作的上下文
return fmt.Errorf("updating user %s email to %q: %w", userID, newEmail, err)
```

## 5. 使用 panic 进行错误处理

```go
// WRONG: panic 不是控制流
func MustGetConfig(key string) string {
  v, err := getConfig(key)
  if err != nil {
    panic(err)
  }
  return v
}
```

仅在初始化过程中出现真正无法恢复的情况是才使用 `panic`（例如，启动时缺少必要的配置文件）。处理请求的代码中绝不应使用 panic。

## 6. 实用函数中的过度包装

```go
// WRONG: os.ReadFile 的错误信息已经包含了路径
func ReadFile(path string) ([]byte, error) {
  data, err := os.ReadFile(path)
  if err != nil {
    return nil, fmt.Errorf("ReadFile failed for path %s: %w", path, err)
  }
  return data, nil
}
```

`os.ReadFile` 的错误信息中已经包含了路径。在这个层级上进行包装会增加冗余信息 。应该在包含业务上下文的层级进行包装。

```go
cfg, err :=  ReadFile(configPath)
if err != nil {
  return fmt.Errorf("loading app config: %w", err)
}
```



# 综合起来

以下是一个完整的处理程序，展示了这些模式如何协同工作：

```go
func (h *PaymentHandler) CreatePayment(w http.ResponseWriter, r *http.Request) {
  ctx := r.Context()
  
  var req CreatePaymentRequest
  if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
    responseError(w, apperr.InvalidRequest("malformed request body"))
    return
  }
  
  if err := req.Validate(); err != nil {
    respondError(w, err) // Validate 返回 *apperr.Error
    return
  }
  
  payment, err := h.service.CreatePayment(ctx, req.OrderID, req.Method)
  if err != nil {
    slog.ErrorContext(
      ctx, 
      "payment creation failed",
      "order_id", req.OrderID,
      "method", req.Method,
      "error", err,
    )
    respondError(w, err)
    return
  }
  
  slog.InfoContext(
    ctx, 
    "payment created", 
    "payment_id", payment.ID,
    "order_id", req.OrderID,
  )
  respondError(w, http.StatusCreated, payment)
}
```

以及处理业务逻辑并返回领域错误的服务层：

```
func (s *PaymentService) CreatePayment(ctx context.Context, orderID, method string) (*Payment, error) {
	order, err := s.orders.Get(ctx, orderID)
	if err != nil {
		return nil, fmt.Errorf("create payment: %w", err)
	}
	
	if order.Status == StatusPending {
		return nil, apperr.Conflict("order %s is %s, expected pending", orderID, order.status)
	}
	
	charge, err := s.stripe.Charge(ctx, order.Total,  method)
	if err != nil {
		var stripeErr *stripe.Error
		if errors.As(err, &stripeErr) && stripeErr.Code ==  stripe.CardDeclined {
			return nil, apperr.InvalidInput("card was declined")
		}
		return nil, apperr.Internal(fmt.Errorf("charging order %s: %w", orderID, err))
	}
	
	payment := &Payment{
		ID: uuid.New().String(),
		OrderID: orderID,
		ChargeID: charge.ID,
		Amount: order.Total,
		Status: "completed",
	}
	
	if err := s.repo.Save(ctx, payment); err != nil {
		slog.ErrorContext(ctx, "CRITICAL: payment charged but save failed",
			"charge_id": charge.ID,
			"order_id": orderID,
			"error", err,
		)
		return nil, apperr.Internal(fmt.Errorf("saving payment for order %s: %w", orderID, err))
	}
	
	return payment, nil
}
```

请注意该服务是如何运行的：

- 将外部错误（Stripe）转换为域错误
- 在每个包级别添加上下文
- 使用相应的错误代码（`Conflict`、`InvalidInput` 、`Internal`）
- 日志记录层级正确——只有关键情况（已扣款但保存失败）才会记录在服务日志中；普通错误会逐级传递到处理程序



# 总结

Go 的错误处理机制设计得非常详尽。这种详尽性带来了清晰明确的错误信息，而清晰明确又保证了系统的可靠性。本文介绍的模式——一致的错误封装、领域错误、结构化日志记录、集中式 HTTP 转换——将这种详尽性转换为一个即使在凌晨三点调试起来也令人愉悦的系统。

要点总结：

- **在每个层级都加入上下文**——使用 `%w` 并描述你正在做的事情
- **使用 Sentinel 错误并自定义类型** 来处理调用者需要采取的错误
- **在边界处转换错误**——存储错误变成域错误，域错误变成 HTTP 响应
- **记录日志或返回数据，二者不可兼得**——每个函数只负责一项职责 
- **使用 `errors.Is` 和 `errors.As`**——永远不要进行字符串匹配错误
- **结构化你的日志**——未来的你会感谢自己的

错误处理并不是 Go 语言中最吸引人的部分。但它决定了你再凌晨 2 点看到的页面是"看看这个清晰的错误链"，还是 "某个地方出了问题，祝你好运"。

选择第一个。




