# 主页

Brave 是一个分布式追踪工具库。Brave 通常会拦截生产环境中的请求，以收集时间数据，并关联和传播追踪上下文。虽然追踪数据通常会发送到 Zipkin Server，但也支持使用第三方插件将其发送到其他服务，例如 Amazon X-Ray。

此仓库包含无需依赖项的 Java 库以及用于生产服务中常用组件的检测工具。例如，它包含 Servlet 的跟踪过滤器和 Apache Log4J 的日志关联工具。

你可以查看我们的示例项目，了解如何跟踪简单的 Web 应用程序。



## 包含哪些内容

Brave 的无依赖追踪器库支持 JRE6+。它是用于检测操作并添加描述标签的底层 API。该库还包含解析 `X-B3-TraceId` 标头的代码。

大多数用户不会直接编写追踪代码，而是会复用其他人编写的追踪工具。在自行开发之前，请先查看我们的追踪工具列表和 Zipkin 的列表。Servlet 和 Spring 等常用的追踪库已经存在。这里提供的追踪工具都经过了测试和基准测试 。

如果你正在尝试追踪旧版应用程序，你可能会对 Spring XML 配置感兴趣。它允许你在无需编写任何自定义代码的情况下设置追踪。

你可能需要将跟踪 ID 添加到日志文件中，或者更改线程局部行为。请查看我们 `context`  库，以便与 SLF4J 集成。



## 版本兼容性策略

所有 Brave 库都与被跟踪或集成项目的最低 Java 版本相匹配，并且不添加任何第三方依赖项。我们的目标既不影响你项目的选择，也不让你的项目受制于他人做出的依赖项决策。

例如，即使包含一个基本的上报库，`zipkin-sender-connection`，Brave 也不会间接引入 json、logging、protobuf 或 thrift 依赖。这意味着，如果你的应用程序选择特定版本的 SLF4J、Gson 或 Guava。你无需担心。此外，包括 json、thrift 或 protobuf 等基本上报功能在内的整个依赖树，其 JAR 文件大小也小于 512KB。

Java 最低版本为 1.6，它允许使用交旧的 JRE 和 Android 运行时环境，但可能会限制某些应用程序的功能。例如，Servlet 2.5 可以与 Java 1.5 兼容，但由于 Brave 的 Java 版本为 1.6，因此你必须使用至少 1.6 的 JRE 才能跟踪 Servlet 2.5 应用程序。

所有集成都会将关联的库设置为 **provided** 范围，这可以确保 Brave 不会干扰你选择的版本。

有些库更新频繁，会导致 API 版本不一致。为了减少这种影响，我们会测试不同版本之间的兼容性。例如，我们会针对多个库版本测试 `gRPC` 和 `Kafka`。



## 构件

所有构件都发布到 ID 为 `io.zipkin.brave` 的组。我们对所有构件使用相同的发布版本。

### 库发布

发布信息位于 `Maven Central`。

### 库镜像

提交到主分支后，快照很快上传到 `Sonatype`。

### 版本对齐

使用多个 Brave 组件时，最好将版本统一管理。这样可以更安全地升级，减少冲突的风险。

你可以使用我们的 Maven 仪器物料清单（BOM）来实现此目的：

例如，在依赖项部分，像这样导入 BOM：

```xml
<dependencyManagement>
	<dependencies>
  	<dependency>
    	<groupId>io.zipkin.brave</groupId>
      <artifactId>brave-bom</artifactId>
      <version>${brave.version}</version>
      <type>pom</type>
      <scope>import</scope>
    </dependency>
  </dependencies>
</dependencyManagement>
```

现在，在选择任何受支持的检测工具时，你可以省略版本号。此外，任何间接使用都会确保版本号一致：

```xml
<dependency>
	<groupId>io.zipkin.brave</groupId>
  <artifactId>brave-instrumentation-okhttp3</artifactId>
</dependency>
```

完成上述步骤后，你可以使用 `brave.version`  属性来统一覆盖依赖项版本。这通常用于测试功能或修复程序。

注意：如果你要覆盖某个版本，请务必仔细检查你的版本是否有效（等于或高于你要更新的版本）。这将避免类冲突。



# Brave Core Library

Brave 是一个用于捕获分布式操作延迟信息并将其报告给 Zipkin 的库。大多数用户不会直接使用 Brave，而是使用代表他们调用 Brave 的库或框架。

该模块包含用于创建和连接 `span` 的 `tracer`，这些 `span` 模拟了潜在分布式工作的延迟。它还用于跨越网络边界传播跟踪上下文的库，例如，通过 HTTP 标头。



## 设置

最重要的是，你需要一个 `Tracer`，通常配置为向 Zipkin 报告。

以下是一个通过 HTTP（而不是 Kafka）向 Zipkin 发送跟踪数据（span）的示例设置：

```java
// 配置一个报告器，用于控制 span 的发送频率
// 此依赖项为 io.zipkin.reporter2:zipkin-sender-okhttp3
sender = OkHttpSender.create("http://127.0.0.1:9411/api/v2/spans");
// 此依赖项为 io.zipkin.reporter2:zipkin-reporter-brave
zipkinSpanHandler = AsyncZipkinSpanHandler.create(sender);

// 使用你希望在 Zipkin 中看到的服务名称创建一个跟踪组件
tracing = Tracing.newBuilder()
  	.localServiceName("my-service")
  	.addSpanHandler(zipkinSpanHandler)
  	.build();

// Tracing 会暴露你可能需要的对象，其中最重要的是 Tracer
tracer = tracing.tracer();

// 未关闭资源可能会导致 span 丢失！当不再需要跟踪时，请按相反顺序关闭你创建的组件
// 这可能是某些用户的关闭钩子
tracing.close();
zipkinSpanHandler.close();
sender.close();
```

### Zipkin v1 设置

如果你需要连接到旧版本的 Zipkin API，可以使用以下方法以使用 Zipkin v1 格式。更多信息请参阅 `zipkin-reporter`。

```java
sender = URLConnectionSender.create("http://127.0.0.1:9411/api/v1/spans");
reporter = AsyncReporter.builder(sender).build(SpanBytesEncoder.JSON_V1); // 不要忘记关闭它
zipkinSpanHandler = ZipkinSpanHandler.create(reporter);
```

注意：`ZipkinSpanHandler` 需要显式依赖  `io.zipkin.reporter2:zipkin-reporter`。



## 追踪

`Tracer` 创建并连接用于模拟潜在分布式工作延迟的 `Span`。它可以采用采样来减少进程开销或减少发送到 Zipkin 的数据量。

`Tracer` 返回的 `Span` 会在完成后将数据报告给 Zipkin，如果未采样则不执行任何操作。启动 `Span` 后，你可以注解感兴趣的事件，或添加包含详细信息或查找键的标签。

`Span` 具有上下文，其中包括追踪标识符，该标识符将其放置在表示分布式操作的树中的正确位置。

### 进程内追踪

当追踪永远不会离开进程的代码时，请在作用域 `Span` 内运行它。

```java
// 开始一个新的追踪或在现有追踪中创建一个 span，表示一个操作
ScopedSpan span = tracer.startScopedSpan("encode");
try {
  // 该 span 处于作用域（scope）内，这意味着下游代码（例如日志记录器）可以看到追踪ID
  return encoder.encode();
} catch (RuntimeException | Error e) {
  span.error(e); // 除非你处理异常，否则你可能不会知道操作失败了
  throw e;
} finally {
  span.finish(); // 总是完成 span
}
```

当你需要更多功能或更精细的控制时，请使用 `Span` 类型：

```java
// 开始一个新的追踪或在现有追踪中创建一个 span，表示一个操作
Span span = tracer.nextSpan().name("encode").start();
// 将 span 放在作用域（scope）中，以便下游代码（例如日志记录器）可以看到追踪ID
try (SpanInScope scope = tracer.withSpanInScope(span)) {
  return encoder.encode();
} catch (RuntimeException | Error e) {
  span.error(e); // 除非你处理异常，否则你可能不会知道操作失败了
  throw e;
} finally {
  span.finish(); // 总是完成 span
}
```

以上两个例子都报告了完全相同的完成 `Span`。

在上面的例子中，`span` 要么是一个新的根 `span`，要么是现有追踪中的下一个子 `span`。其工作原理将在后面详细介绍。

### 自定义 span

创建 `span` 元素后，你可以向其中添加标签，这些标签可用作查找键或详细信息。例如，你可以添加一个包含运行时版本的标签。

```java
span.tag("clnt/finagle.version", "6.36.0");
```

`Tag` 类型是一个辅助类型，适用于 `Span` 的所有变体。对于常用或开销较大的标签，建议实现 `Tag` 类型或复用内置的 `Tag` 类型。

以下是一个可能成本高昂的标签示例：

```java
SUMMARY_TAG = new Tag<Summarizer>("summary"){
  @Override
  protected String parseValue(Summarizer input, TraceContext context)  {
    return input.computeSummary();
  }
}

// 这适用于 span 的任何变体
SUMMARY_TAG.tag(summarizer, span);
```

当需要向第三方开放自定义的 `span` 的功能时，建议使用 `brave.SpanCustomizer`  而不是 `brave.Span`。前者更容易理解和测试，并且不会通过 `span` 生命周期钩子来诱导用户。

```java
interface MyTraceCallback {
  void request(Request request, SpanCustomizer customizer);
}
```

由于 `brave.Span` 实现了 `brave.SpanCustomizer`，因此你可以很轻松地将其传递给用户。

```java
for (MyTraceCallback callback : userCallbacks) {
	callback.request(request, span);
}
```

### 隐式查找当前 Span

有时你可能无法确定跟踪是否正在执行，并且你不希望用户执行空值检查。`brave.CurrentSpanCustomizer` 会根据跟踪的进行情况，向任何 `Span` 添加数据或删除数据。

```java
// 一些依赖注入配置连接了当前的 span customizer
@Bean
SpanCustomizer currentSpanCustomizer(Tracing tracing) {
  return CurrentSpanCustomizer.create(tracing);
}

// 这样用户代码就可以注入此值，而不会出现值为空的情况
@Inject 
SpanCustomizer span;

void userCode {
  span.annotate("tx.started");
  ...
}
```

### 远程 Span

请检查 `instrumentation` 和 `abstractions` ，并参考 Zipkins 的常见模式列表，例如客户端-服务端或消息传递通信。在决定编写自己的代码来实现远程通信之前，请务必至少阅读此文档。

如果你真的认为现有的抽象无法满足你的需求，并且你想自己建模来满足你的需求，那你通常需要...

1. 启动 span 并将追踪头添加到请求上
2. 将 span 置于作用域内，以便日志集成等功能能够正常工作
3. 调用请求
4. 捕获任何错误
5. 完成 span

以下是一个简化的例子：

```java
requestWrapper = new ClientRequestWrapper(request);
span = tracer.nextSpan(sampler, requestWrapper); // 1.
tracing.propagation()
  .injector(ClientRequestWrapper::addHeader)
  .inject(span.context(), requestWrapper);
span.kind(request.spanKind());
span.name("Report");
span.start();
try (Scope scope = currentTraceContext.nextScope(span.context())) { // 2.
  return invoke(request); // 3.
} catch (Throwable e) {
  span.error(e); // 4.
  throw e;
} finally {
  span.finish(); // 5.
}
```



## 采样

可以采用采样来减少进程外收集和报告的数据量。