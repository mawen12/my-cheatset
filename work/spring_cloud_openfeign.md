# Spring Cloud OpenFeign

> spring.io/projects/spring-cloud-openfeign

## 概述

该项目通过自动配置和绑定到 Spring 环境及其他 Spring 编程模型惯用法，为 Spring Boot 应用程序提供 OpenFeign 集成。

> 正如我们在 Spring Cloud 2022.0.0 发布博文中宣布的那样。我们现在将 Spring Cloud OpenFeign 项目视为功能已全部完成。我们将仅添加 bug 修复，并可能合并一些小型社区功能 PR。我们建议迁移到 Spring HTTP Service Clients。

## 功能

- 声明式 REST 客户端：Feign 创建了一个动态实现接口，该接口使用 JAX-RS 或 Spring MVC 注解进行装饰。

## 快速开始

```
@SpringBootApplication
@EnableFeignClients
public class WebApplication {
    public static void main(String[] args) {
        SpringApplication.run(WebApplication.class, args);
    }

    @FeignClient("name")
    static interface NameService {
        @RequestMapping("/")
        public String getName();
    }
}
```

## 贡献

我们欢迎大家贡献力量。您可以在这里了解更多关于如何为项目做贡献的信息。

## 社区支持

- 你可以通过 Github 报告问题和提问。

## 商业支持

商业支持是 VMware Spring Runtime 产品的一部分。

## Spring Cloud OpenFeign Features

### 声明式 REST 客户端：Feign

Feign 是一个声明式 Web 服务客户端，它简化了 Web 服务客户端的编写。要使用 Feign，只需创建一个接口并为其添加注解即可。它支持可插拔注解，包括 Feign 注解和 JAX-RS 注解。Feign 还支持可插拔的编码器和解码器。Spring Cloud 添加了对 Spring MVC 注解的支持，并支持使用与 Spring Web 默认相同的 HttpMessageConverters。Spring Cloud 集成了 Eureka、Spring Cloud CircuitBreaker 以及 Spring Cloud LoadBalancer，以便在使用 Feign 时提供负载均衡的 HTTP 客户端。

#### 如何引入 Feign

要将 Feign 集成到您的项目中，请使用 group 为 `org.springframework.cloud` 和 artifact id `spring-cloud-starter-openfegin` 的 starter。有关如何使用当前 Spring Cloud 版本配置构建系统的详细信息，请参阅 Spring Cloud 项目页面。

Spring Boot 应用实例：
```
@SpringBootApplication
@EnableFeignClients
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```
StoreClient.java
```
@FeignClient("stores")
public interface StoreClient {
    @RequestMapping(method = RequestMethod.GET, value = "/stores")
    List<Store> getStores();

    @GetMapping("/stores")
    Page<Store> getStores(Pageable pageable);

    @PostMapping(value = "/stores/{storeId}", consumes = "application/json", params = "mode=upsert")
    Store update(@PathVariable("storeId") Long storeId, Store store);

    @DeleteMapping("/stores/{storeId:\\d+}")
    void delete(@PathVariable Long storeId);
}
```

在 `@FeignClient` 注解中，字符串值（如上文中的 "stores"）是一个任意的客户端名称，用于创建 Spring Cloud LoadBalancer 客户端。您还可以使用 `url` 属性指定 URL（绝对值或主机名）。应用程序上下文中的 bean 名称是接口的完全限定名称。要指定您自己的别名，可以使用 `@FeignClient` 注解的 `qualifiers` 值。

上述负载均衡客户端需要发现 `stores` 服务的物理地址。如果您的应用程序是 Eureka 客户端，它将在 Eureka 服注册表中解析该服务。如果您不像使用 Eureka，可以使用 SimpleDiscoveryClient 在外部配置中配置服务器列表。

Spring Cloud OpenFeign 支持 Spring Cloud LoadBalancer 阻塞模式的所有功能。您可以在项目文档中了解更多信息。

> 要在 `@Configuration`-annotated-classes 上使用 `@EnableFeignClients` 注解，请确保指定客户端的位置，例如：`@EnableFeignClients(basePackages = "com.example.clients")` 或显示列出它们：`@EnableFeignClients(clients = InventoryServiceFeignClient.class)`。

要在多模块设置中加载 Spring Feign 客户端 bean，需要直接指定包。

> 由于 FactoryBean 对象可能在初始化上下文刷新之前被实例化，而 Spring Cloud OpenFeign Clients 的实例化会触发上下文刷新，因此不应该在 FactoryBean 类中声明它们。

##### 属性解析模式

当创建 Feign 客户端 bean 时，我们会解析通过 `@FeignClient` 注解传递的值。从 4.x 版本开始，这些值会立即解析。这对大多数用例来说都是一个不错的解决方案，并且也支持 AOT。

如果您需要延迟解析属性，请将 `spring.cloud.openfeign.lazy-attributes-resolution` 属性值设置为 false。

> 对于 Spring Cloud Contract 测试集成，应该使用延迟属性解析。

#### 覆盖 Feign 默认值

Spring Cloud 对 Feign 的支持的核心概念是命名客户端。每个 Feign 客户端都是一个组件集合的一部分，这些组件协同工作，按需连接远程服务器。该组件集合有一个名称，有应用程序开发人员使用 `@FeignClient` 注解为其命名。Spring Cloud 使用 `FeignClientsConfiguration` 为每个命名客户端按需创建一个新的 ApplicationContext 组件集合。该集合包含（但不限于）`feign.Decoder`、`feign.Encoder` 和 `feign.Contract`。可以使用 `@FeignClient` 注解的 contextId 属性来覆盖该组件集的名称。

Spring Cloud 允许您通过使用 `@FeignClient` 注解（在 `FeignClientsConfiguration` 之上）来声明额外的配置，从而完全控制 Feign 客户端。例如：
```
@FeignClient(name = "stores", configuration = FooConfiguration.class)
public interface StoreClient {
    // ....
}
```
在这种情况下，客户端有 `FeignClientsConfiguration` 中已有的组件以及 FooConfiguration 中的任何组件组成（其中后者将覆盖前者）。

> `FooConfiguration` 不需要使用 `@Configuration` 注解。但是，如果使用了 `@Configuration` 注解，则需要注意将其从任何可能包含此配置的 `@Component` 注解中排除，因为当指定 `feign.Decoder`、`feign.Encoder`、`feign.Contract` 等组件时，它将成为默认的配置源。可以通过将其放在一个与任何 `@ComponentScan` 或 `@SpringBootApplication` 注解都不同的、互不重叠的包中来避免这种情况，或者也可以在 `@ComponentScan` 注解中显式地将其排除。

> 除了更改 `ApplicationContext` 集合的名称之外，使用 `@FeignClient` 注解的 `contextId` 属性，它将覆盖客户端名称的别名，并将其用作该客户端创建的配置 bean 的名称的一部分。

> 以前使用 `url` 属性时，不需要 `name` 属性。现在必须使用 `name` 属性。

`name` 和 `url` 属性支持占位符。

```
@FeignClient(name = "${feign.name}", url = "${feign.url}")
public interface StoreClient {
    //...
}
```

Spring Cloud OpenFeign 默认为 feign 提供一下 bean（`BeanType` beanName: `ClassName`）：
- `Decoder` feignDecoder: `ResponseEntityDecoder`（它封装了一个 `SpringDecoder`）
- `Encoder` feignEncoder: `SpringEncoder`
- `Logger` feignLogger: `Slf4jLogger`
- `MicrometerObservationCapability` micrometerObservationCapability: 如果类路径上有 `feign-micrometer` 并且 `ObservationRegistry` 可用
- `MicrometerCapacity` micrometerCapacity:  如果类路径上有 `feign-micrometer` 并且 `micrometerCapacity` 可用且 `ObservationRegistry` 不可用
- `CachingCapability`: 如果启用了 `@EnableCaching`。可以通过 `spring.cloud.openfeign.cache.disabled` 禁用
- `Contract` feignContract: `SpringMvcContract`
- `Feign.Builder` feignBuilder: `FeignCircuitBreaker.Builder`
- `Client` feignClient: 如果类路径上存在 Spring Cloud LoadBalancer，使用 `FeignBlockingLoadBalancerClient`。如果两者都不在类路径上，则使用默认的 Feign 客户端。

> 客户端 bean 必须配置为单例模式。如果客户端 bean 不是单例模式，则每次 FeignClient 初始化时都可能创建一个新的连接池，这会导致连接池耗尽和资源泄露。如果您看到关于具有给定 contextId 的 FeignClient 被多次初始化的警告日志。请确认您的自定义客户端 bean 是否为单例模式。

> `spring-cloud-starter-openfeign` 支持 `spring-cloud-starter-loadbalancer`。但是，由于它是一个可选依赖项，如果您想要使用它，则需要确保已将其添加到您的项目中。

当使用 Apache HttpClient 5 的 Feign 客户端，只需确保 HttpClient 5 位于类路径中即可。但您仍可以通过将 `spring.cloud.openfeign.httpclient.hc5.enabled` 设置为 `false` 来禁用 Feign 客户端对 HttpClient 5 的使用。在使用 Apache HC5 时，您可以通过提供 `org.apache.hc.client5.http.impl.classic.ClosableHttpClient` 类型的 bean 来自定义使用的 HTTP 客户端。

你可以通过设置 `spring.cloud.openfeign.httpclient.xxx` 属性的值来进一步自定义 HTTP 客户端。以 `httpClient` 为前缀的属性适用于所有客户端，以 `httpClient.hc5` 为前缀的属性适用于 Apache HttpClient 5,以 `htttpclient.http2` 为前缀的属性适用于 Http2Client。您可以在附录中找到可自定义属性的完整列表。如果您无法通过属性配置 Apache HttpClient5，可以使用 `HttpClient5FeignConfigurataion.HttpClient` 接口进行编程配置。同样，要配置 `HttpClientConnectionManager`，可以使用 `HttpClient5FeignConfiguration.HttpClientConnectionManagerBuilderCustomizer`。以下示例展示了这两种用法。
```
public class HttpClientConfiguration {
    @Bean
    public HttpClient5FeignConfiguration.HttpClientBuilderCustomizer httpClientBuilder() {
        return (httpClientBuilder) -> {
            RequestConfig.Builder requestConfigBuilder = RequestConfig.custom();
            requestConfigBuilder.setPortocolUpgradeEnabled(false);
            httpClientBuilder.setDefaultRequestConfig(requestConfigBuilder.build());
        };
    }
}
```

> Apache HTTP Components 5.4 更改了 HttpClient 中与 HTTP/1.1 TLS 升级相关的默认配置。大多数代理服务器都能顺利完成升级，但 Envoy 或 Istio 可能会出现问题。如果需要恢复之前的行为，可以使用 `HttpClient5FeignConfiguration.HttpClientBuilderCustomizer` 来实现，如下例所示：
```
public class HttpClientConnectionManagerConfiguration {
    @Bean
    public HttpClient5FeignConfiguration.HttpClientConnectionManagerBuilderCustomizer httpClientConnectionManagerBuilderCustomizer() {
        return (httpClientConnectionManagerBuilder) -> {
            TlsConfig.Builder tlsConfigBuilder = TlsConfig.custom();
            tlsConfigBuilder.setHandshakeTimeout(Timeout.of(0, TimeUnit.SECONDS));
            httpClientConnectionManagerBuilder.setDefaultTlsConfig(tlsConfigBuilder.build());
        };
    }
}
```

> 从 Spring Cloud OpenFeign 4 开始，不再支持 Feign Apache HttpClient 4，我们建议您该用 Apache HttpClient 5。

Spring Cloud OpenFeign 默认情况下不为 Feign 提供以下类型的 bean，但仍然会从应用程序上下文中查找这些类型的 bean 来创建 Feign 客户端：
- `Logger.Level`
- `Retryer`
- `ErrorDecoder`
- `Request.Options`
- `Collection<RequestInterceptor>`
- `SetterFactory`
- `QueryMapEncoder`
- `Capability` (默认情况下提供 `MicrometerObservationCapability` 和 `CachingCapability`)

默认情况下会创建一个类型为 `Retryer` 的 `Retryer.NEVER_RETRY` bean，这将禁用重试。请注意，此重试行为与 Feign 的默认行为不同，Feign 会自动重试 IOException，将其视为瞬态网络相关异常，以及 ErrorDecoder 抛出的任何 RetryableException。

创建上述类型的 bean 并将其放置在 `@FeignClient` 配置（例如上面的 FooConfiguration）中，即可覆盖每个已描述的 bean。实例：
```
@Configuration
public class FooConfiguration {
    @Bean
    public Contract feignContract() {
        return new feign.Contract.Default()
    }

    @Bean
    public BasicAuthRequestInterceptor basicAuthRequestInterceptor() {
        return new BasicAuthRequestInterceptor("user", "password");
    }
}
```
这会将 `SpringMvcContract` 替换为 `feign.Contract.Default`，并将 `RequestInterceptor` 添加到 `RequestInterceptor` 集合中。

`@FeignClient` 也可以同时使用配置属性进行配置。
application.yml
```
spring:
    cloud:
        openfeign:
            client:
                config:
                    feignName:
                        url: http://remote-service.com
                        connectTimeout: 5000
                        readTimeout: 5000
                        loggerLevel: full
                        errorDecoder: com.example.SimpleErrorDecoder
                        retryer: com.example.SimpleRetryer
                        defaultQueryParameters:
                            query:  queryValue
                        defaultRequestHeaders:
                            header: headerValue
                        requestInterceptors:
                            - com.example.FooRequestInterceptor
                            - com.example.BarRequestInterceptor
                        responseInterceptor: com.example.BazResponseInterceptor
                        dismiss404: false
                        encoder: com.example.SimpleEncoder
                        decoder: com.example.SimpleDecoder
                        contract: com.exampe.SimpleContract
                        capabilities:
                            - com.example.FooCapability
                            - com.example.BarCapability
                        queryMapEncoder: com.example.SimpleQueryMapEncoder
                        micrometer.enabled: false
```

本例中 `feignName` 指的是 `@FeignClient` 的值，它也与 `@FeignClient` 的名称和 `@FeignClient` 的 `contextId` 具有别名。在负载均衡场景中，它还对应用于检索服务市里的服务器应用程序的 serviceId。指定的解码器、重试器和其他类必须在 Spring 上下文中拥有 bean 或具有默认构造函数。

默认配置可以通过 `@EnableFeignClients` 的 `defaultConfiguration` 属性来指定，方法与上述类似。不同之处在于，此配置将应用于所有 Feign 客户端。

如果您希望使用配置属性来配置所有 `@FeignClient`，您可以创建具有 `default` feign 名称的配置属性。

您可以使用 `spring.cloud.openfeign.client.config.feignName.defaultQueryParameters` 和 `spring.cloud.openfeign.client.config.feignName.defaultRequestHeaders` 来指定名为 feignName 的客户端的每个请求将发送的查询参数和标头。

application.yml
```
spring:
    cloud:
        openfeign:
            client:
                config:
                    default:
                        connectTimeout: 5000
                        readTimeout: 5000
                        loggerLevel: basic
```

如果我们同时创建了 `@Configuration` bean 和配置属性，配置属性会优先生效，它会覆盖 `@Configuration` 的值。但如果您想让 `@Configuration` 优先，可以将 `spring.cloud.openfeign.client.default-to-properties` 的值设置为 `false`。

如果我们想要创建多个名称或 URL 相同的 Feign 客户端，使它们指向同一个服务器，但每个客户端都有不同的自定义配置，那么我们必须使用 `@FeignClient` 的 `contextId` 属性，以避免这些配置 bean 的名称冲突。

```
@FeignClient(contextId = "fooClient", name = "stores", configuration = FooConfiguration.class)
public interface FooClient {
    //..
}
```

```
@FeignClient(contextId = "barClient", name = "stores", configuration = BarConfiguration.class)
public interface BarClient {
    //..
}
```

还可以配置 FeignClient 不从上下文继承 bean。你可以通过重写 `FeignClientConfigurer` bean 中的 `inheritParentConfiguration()` 方法并使其返回 `false` 来实现这一点。
```
@Configuration
public class CustomConfiguration {
	@Bean
	public FeignClientConfigurer feignClientConfigurer() {
		return new FeignClientConfigurer() {
			@Override
			public boolean inheritParentConfiguration() {
				return false;
			}
		}
	}
}
```

> 默认情况下，Feign 客户端不会对斜杠 `/` 字符进行编码。你可以通过将 `spring.clouud.openfeign.client.decode-slash` 的值设置为 `false` 来更改此行为。

> 默认情况下，Feign 客户端不会移除请求路径末尾的斜杠 `/` 字符。你可以通过将 `spring.cloud.openfeign.client.remove-trailing-slash` 的值设置为 `true` 来更改此行为。在下一个主要版本中，移除请求路径末尾的斜杠将成为默认行为。

##### SpringEncoder 配置

在我们提供的 `SpringEncoder` 中，我们将二进制内容类型设置为 `null` 字符集，将所有其他内容类型设置为 `UTF-8` 字符集。

你可以通过将 `spring.cloud.openfeign.encoder.charset-from-content-type` 的值设置为 `true` 来修改此行为，从而从 `Content-Type` 标头字符集派生字符集。

#### 超时处理

我们可以为默认客户端和指定客户端配置超时时间。OpenFeign 使用两个超时参数：
- `connectionTimeout` 可以防止因服务器处理时间过长而阻塞调用者
- `readTimeout` 从连接建立时开始应用，当返回响应时间过长时触发。

> 如果服务器未运行或不可用，数据包将导致连接被拒绝。通信要么以错误消息结束，要么进入备用方案。如果 `connectionTimeout` 设置得很短，则可能在超时之前发生这种情况。执行查找和接受此类数据包所需的时间是造成延迟的主要原因。此延迟会根据涉及的 DNS 查找的远程主机而变化。

#### 手动创建 Feign 客户端

在某些情况下，你可能需要对 Feign 客户端进行一些自定义，而上述方法无法实现。此时，你可以使用 Feign Builder API 创建客户端。以下示例创建了两个具有相同接口的 Feign 客户端，但分别配置了不同的请求拦截器。
```
@Import(FeignClientConfiguration.class)
class FooController {
	private FooClient fooClient;
	private FooClient adminClient;
	
	@Autowired
	public FooController(Client client, Encoder encoder, Decoder decoder, Contact contact, MicrometerObservationCapability micrometerObservationCapability) {
		this.fooClient = Feign.builder().client(client)
			.encoder(encoder)
			.decoder(decoder)
			.contract(contract)
			.addCapability(micrometerObservationCapability)
			.requestInterceptor(new BasicAuthRequestInterceptor("user", "user"))
			.target(FooClient.class, "https://PROD-SVC");
			
		this.adminClient = Feign.builder().client(client)
			.encoder(encoder)
			.decoder(decoder)
			.contract(contract)
			.addCapability(micrometerObservationCapability)
			.requestInterceptor(new BasicAuthRequestInterceptor("admin", "admin"))
			.target(FooClient.class, "https://PROD-SVC");
	}
}
```

> 在上面的示例中，`FeignClientConfiguration.class` 是 Spring Cloud OpenFeign 提供的默认配置。

> `PROD-SVC` 是客户端要将请求的服务的名称。

> Feign `Contract` 对象定义了接口上哪些注解和值是有效的。自动注入的 `Contract` bean 提供对 Spring MVC 注解的支持，而不是默认的 Feign 原生注解。不建议将 Spring MVC 注解和 Feign 原生注解混用。

你还可以使用 `Builder` 来配置 FeignClient 不要从父上下文继承 bean。你可以通过重写 `Builder` 上的 `inheritParentContext(false)` 方法来做到这一点。

#### Feign Spring Cloud CircuitBreaker 支持

如果 Spring Cloud CircuitBreaker 在类路径中并且 `spring.cloud.openfeign.circuitbreaker.enabled=true`，Feign 将使用断路器包装所有方法。

要针对每个客户端禁用 Spring Cloud CircuitBreaker 支持，请创建一个作用域为 `prototype` 的普通 `Feign.Builder`，例如：
```
@Configuration
public class FooConfiguration {
	@Bean
	@Scope("prototype")
	public Feign.Builder feignBuilder() {
		return Feign.builder()
	}
}
```

熔断器名称遵循以下模式：`<feignClientClassName>#<calledMethod>(<parameterTypes>)`。当使用 `FooClient` 接口调用 `@FeignClient` 时，如果被调用的接口方法没有参数且名为 `bar`，则熔断器名称为 `FootClient#bar()`。

> 自从 2020.0.2 版本起，熔断器名称模式已从 `<feignClientClassName>_<calledMethod>` 更改为上述模式。使用 2020.0.4 版本引入的 `CircuitBreakerNameResolver`，熔断器名称可以保留旧模式。

提供一个 `CircuitBreakerNameResolver` bean，即可更改断路器名称模式。
```
@Configuraion
public class FooConfiguration {
	@Bean
	public CircuitBreakerNameResolver circuitBreakerNameResolver() {
		return (String feignClientName, Target<?> target, Method method) -> feignClientName + "_" + method.getName();
	}
}
```

要启用 Spring Cloud CircuitBreaker 组，请将 `spring.cloud.openfeign.circuitbreaker.group.enabled` 的值设置为 `true`（默认值为 false）。

#### 使用配置属性配置 CircuitBreaker

你可以通过配置属性来配置断路器。

例如，如果你有这样一个 Feign 客户端。
```
@FeignClient(url = "http://locahost:8080")
public interface DemoClient {
	@GetMapping("demo")
	String getDemo();
}
```

你可以通过执行以下操作，使用配置属性对其进行配置：
```yaml
spring:
  cloud:
	openfeign:
	  circuitbreaker:
		enabled: true
		alphanumeric-ids:
		  enabled: true

resilience4j:
  circuitbreaker:
    instances:
      DemoClientgetDemo:
        minimumNumberOfCalls: 69
  timelimiter:
  	instances:
  	  DemoClientgetDemo:
  	  	timeoutDuration: 10s
```

> 如果你想切换回 Spring Cloud 2022.0.0 之前使用的断路器名称，你可以将 `spring.cloud.openfeign.circuitbreaker.alphanumeric-ids.enabled` 设置为 `false`。

#### Feign Spring Cloud CircuitBreaker 回退/降级

Spring Cloud CircuitBreaker 支持回退机制：当断路器打开或发生错误时，将执行默认代码路径。要为给定的 `@FeignClient` 启用回退机制，请将 `fallback` 属性设置为实现该回退机制的类名。此外，你还需要将该实现声明为 Spring bean。

```
@FeignClient(name = "test", url = "http://localhost:${server.port}/", fallback = Fallback.class)
protected interface TestClient {
	@GetMapping("/hello")
	Hello getHello();
	
	@GetMappng("hellonotfound")
	String getException();
}

@Component
static class Fallback implements TestClient {
	@Override
	public Hello getHello() {
		throw new NoFallbackAvaiableException("Boom!", new RuntimeException())
	}
	
	@Override
	public String getException() {
		return "Fixed response";
	}
}
```

如果需要连接触发回退的原因，可以使用 `@FeignClient` 中的 `fallbackFactory` 属性。

```
@FeignClient(name = "testClientWithFactory", url = "http://;localhost:${server.port}/", fallbackFactory = TestFallbackFactory.class)
protected interface TestClientWithFactory {
	@GetMapping("/hello")
	Hello getHello();
	
	@GetMappng("hellonotfound")
	String getException();
}

@Component
static class TestFallbackFactory implements FallbackFactory<FallbackWithFactory> {
	@Override
	public FallbackWithFactory create(Throwable cause) {
		return new FallbackWithFactory;
	}
}

static class FallbackWithFactory implements TestClientWithFactory {
	@Override
	public Hello getHello() {
		throw new NoFallbackAvaiableException("Boom!", new RuntimeException())
	}
	
	@Override
	public String getException() {
		return "Fixed response";
	}
}
```

#### Feign 和 `@Primary`

当 Feign 与 Spring Cloud CircuitBreaker 回退机制结合使用时，`ApplicationContext` 中可能存在多个相同类型的 bean。这会导致 `@Autowired` 注解失效，因为没有一个 bean 被明确标记为主 bean。为了解决这个问题，Spring Cloud OpenFeign 会将所有 Feign 实例标记为 @Primary，以便 Spring Framework 知道要注入哪个 bean。但在某些情况下，这种做法可能并不理想。要禁用此行为，请将 `@FeignClient` 的 `primary` 属性设置为 `false`。

```
@FeignClient(name = "hello", primary = false)
public interface HelloClient {
	// ..
}
```

#### Feign 继承支持

Feign 通过单一继承接口支持样板 API。这使得我们可以将常用操作分组到便捷的基础接口中。

UserService.java
```
public interface UserService {
	@GetMapping("/user")
	User getUser(@PathVariable("id") long id);
}
```
UserResource.java
```
@RestController
public class UserResource implements UserService {

}
```
UserClient.java
```
@FeignClient("users")
public interface UserClient extends UserService {

}
```

> `@FeignClient` 接口不应在服务器和客户端之间共享，并且不再支持在类级别使用 `RequestMapping`注解 `@FeignClient` 接口。

#### Feign 请求/响应压缩

你可以考虑为 Feign 请求启用 GZIP 压缩。你可以通过启用以下属性之一来实现：
```
spring.cloud.openfeign.compression.request.enabled=true
spring.cloud.openfeign.compression.response.enabled=true
```

Feign 请求压缩提供的设置与你为 Web 服务器设置的类似：
```
spring.cloud.openfeign.compression.request.enabled=true
spring.cloud.openfeign.compression.request.mime-types=text/xml,application/xml,application/json
spring.cloud.openfeign.compression.request.min-request-size=2048
```

这些属性允许你选择压缩媒体类型和最小请求阈值长度。

当请求的 mime 类型与 `spring.cloud.openfeign.compression.request.mime-types` 中设置的值匹配，且请求大小符合 `spring.cloud.openfeign.compression.request.min-request-size` 中设置的大小要求，`spring.cloud.openfeign.compression.request.enabled=true` 时会将压缩头添加到请求中。这些压缩头的作用是向服务器发出信号，表明客户端期望收到压缩后的请求体。服务器端应用程序负责根据请求头来提供压缩后的请求体。

#### Feign 日志

每个创建的 Feign 客户端都会创建一个日志记录器。默认情况下，日志记录器的名称是用于创建 Feign 客户端的接口的完整类名。Feign 日志记录仅响应 DEBUG 级别。

application.yml
```
logging.level.project.user.UserClient: DEBUG
```

你可以为每个客户端配置 `Logger.Level` 对象，该对象告诉 Feign 要记录多少日志。选项包括：
- `NONE` 不记录（默认）
- `BASIC` 仅记录请求方法、URL、响应状态码和执行时间
- `HEADERS` 记录请求和响应标头的基本信息
- `FULL` 完整记录请求和响应的标头、正文和元数据。

例如：以下代码会为 `Logger.Level` 设置为 `FULL`:
```
@Configuration
public class FooConfiguration {
	@Bean
	Logger.Level feignLoggerLevel() {
		return Logger.Level.FULL;
	}
}
```

#### Feign 能力支持

Feign 的功能公开了 Feign 的核心组件，以便可以对其进行修改 。例如，这些功能可以获取客户端，对其进行装饰，并将装饰后的实例返回给 Feign。对 Micrometer 的支持就是一个很好的实际示例。请参阅 Micrometer 支持。

创建一个或多个 `Capability` bean 并将它们放置在 `@FeignClient` 配置中，即可注册它们并修改相关客户端的行为。
```
@Configuration
public class FooConfiguration {
	@Bean
	Capability customCapability() {
		return new CustomCapability();
	}
}
```

#### Micrometer 支持

如果以下所有条件都成立，则会创建并注册一个 `MicrometerObservationCapability` bean，以便 `Micrometer` 可以观察您的 Feign 客户端：
- `feign-micrometer` 存在于类路径上
- 有一个 `ObservationCapability` bean 可用
- feign micrometer 属性设置为 `true`（默认）
	- `spring.cloud.openfeign.micrometer.enabled=true` (用于所有客户端)
	- `spring.cloud.openfeign.client.config.feignName.micrometer.enabled=true` (用于单个客户端)

> 如果你的应用已经使用 Micrometer，那么启用此功能只需将 `feign-micrometer` 添加到你的类路径中即可。

你还可以通过以下两种方式禁用此功能：
- 从类路径排除 `feign-micrometer`
- 将 micrometer 的某个属性设置为 `false`
	- `spring.cloud.openfeign.micrometer.enabled=false`
	- `spring.cloud.openfeign.client.config.feignName.micrometer.enabled=false`

> `spring.cloud.openfeign.micrometer.enabled=false` 会禁用所有 Feign 客户端的 Micrometer 支持，无论客户端级别的标志 `spring.cloud.openfeign.client.config.feignName.micrometer.enabled` 值如何。如果要为每个客户端启用或禁用 Micrometer 支持，请不要设置 `spring.cloud.openfeign.micrometer.enabled`，而是使用 `spring.cloud.openfeign.client.config.feignName.micrometer.enabled`。

你可以通过注册自己的 bean 来自定义 `MicrometerObservationCapability`:
```
@Configuration
public class FooConfiguration {
	@Bean
	MicrometerObservationCapability micrometerObservationCapability(ObservationRegistry registry) {
		return new MicrometerObservationCapability(registry);
	}
}
```

仍然可以将 `MicrometerCapability` 与 Feign （仅支持指标）一起使用，你需要禁用 Micrometer 支持（`spring.cloud.openfeign.micrometer.enabled=false`）并创建一个 `MicrometerCapability` bean:
```
@Configuration
public class FooConfiguration {
	@Bean
	MicrometerCapability micrometerCapability(MeterRegistry registry) {
		return new MicrometerCapability(registry);
	}
}
```

#### Feign 缓存

如果使用 `@EnableCaching` 注解，则会创建并注册一个 `CacheCapability` bean，以便你的 Feign 客户端能够识别到接口上的 `@Cache*` 注解。

```
public interface DemoClient {
	@GetMapping("/demo/{filterParam}")
	@Cacheable(cacheNames = "demo-cache", key = "#keyParam")
	String demoEndpoint(String keyParam, @PathVariable String filterParam);
}
```

你可以通过属性 `spring.cloud.openfeign.cache.enabled=false` 来禁用此功能。

#### Spring @RequestMapping 支持

Spring Cloud OpenFeign 提供对 Spring `@RequestMapping` 注解及其派生注解（例如 `@GetMapping`、`@PostMapping`）的支持。`@RequestMapping` 注解的属性（包括`value`、`method`、`params`、`headers`、`consumers` 和 `producers`）由 `SpringMvcContract` 解析为请求的内容。

请看以下示例：

使用 `params` 属性定义接口：
```
@FeignClient("demo")
public interface DemoTemplate {
	@PostMapping(value = "/store/{storeId}", params = "mode=upsert")
	String demoEndpoint(@PathVariable("storeId") Long storeId, Store store);
}
```

在上面的示例中，请求 URL 解析为 `/stores/storeId?mode=upsert`。
`params` 属性还支持使用多个 `key=value` 或仅使用一个 `key`:
- 当 `params = { "key1=v1", "key2=v2" }`，请求 url 解析为 `/stores/storeId?key1=v1&key2=v2`
- 当 `params = "key"`，请求 url 解析为 `/stores/storeId?key`

#### Feign @QueryMap 支持

Spring Cloud OpenFeign 提供了一个等效的 `@SpringQueryMap` 注解，用于将 POJO 或 Map 参数注解为查询参数映射。

例如，`Params` 定义了参数 `param1` 和 `param2`:
```
// Params.java
public class Params {
	private String param1;
	private String param2;
	
	//..
}
```

以下 Feign 客户端通过使用 `@SpringQueryMap` 注解来使用 `Params` 类:
```
@FeignClient("demo")
public interface DemoTemplate {
	@GetMapping(path = "/demo")
	String demoEndpoint(@SpringQueryMap Params params);
}
```

如果你需要对生成的查询参数映射进行更多控制，你可以实现自定义 `QueryMapEncoder` bean。

#### HATEOAS 支持

Spring 提供了一些 API 来创建遵循 HATEOAS 原则的 REST 表示，即 Spring Hateoas 和 Spring Data REST。

如果你的项目使用 `org.springframework.boot:spring-boot-starter-hateoas` 或 `org.springframework.boot:spring-boot-starter-data-rest-starter`，则默认情况下会启用 Feign HATEOAS 支持。

启用 HATEOAS 支持后，Feign 客户端可以序列化和反序列化 HATEOAS 表示模型：EntityModel、CollectionModel 和 PagedModel。
```
@FeignClient("demo")
public interface DemoTemplate {
	@GetMapping(path = "/stores")
	CollectionModel<Store> getStores(); 
}
```

#### Spring @MatrixVariable 支持

Spring Cloud OpenFeign 为 Spring `@MatrixVariable` 注解提供了支持。

如果将 Map 作为方法参数传递，则通过将 Map 中的键值对用 `=` 连接来创建 `@MatrixVariable` 路径段。

如果传递的是不同的对象，则使用 `=` 将 `@MatrixVariable` 注解中提供的名称（如果已定义）或带注解的变量名与提供的方法参数连接起来。

> 尽管在服务器端，Spring 不要求用户将路径段占位符命名为与 matrix 变量相同的名称，因为这会在客户端造成歧义，但 Spriing Cloud OpenFeign 要求你添加一个路径段占位符，其名称必须与 `@MatrixVariable` 注解中提供的名称（如果已定义）或注解变量的名称相匹配。

实例：
```
@GetMapping("/objects/links/{matriVars}")
Map<String, List<String>> getOBjects(@MatrixVariable Map<String, List<Strting>> matrixVars);
```

请注意，变量名和路径段占位符都称为 `matriVars`。

TODO 源文档需要修复，去除重复代码。

#### Feign CollectionFormat 支持

我们通过提供 `@CollectionFormat` 注解来支持 `feign.CollectionFormat`。你可以通过传递所需的 `feign.CollectionFormat` 作为注解值，来为 Feign 客户端方法（或整个类以影响所有方法）添加注解。

在以下示例中，使用 `CSV` 格式而不是默认的 `EXPLODED` 格式来处理该方法。
```
@FeignClient(name = "demo")
public interface DemoFeignClient {
	@CollectionFormat(feign.CollectionFormat.CSV)
	@GetMapping(path = "/test")
	ResponseEntity performRequest(String test); 
}
```

#### FeignClientBuilder

` FeignClientBuilder` 允许以编程方式创建 Feign 客户端，而无需使用 `@FeignClient` 注解。

它以与 `@FeignClient` 相同的方式构建客户端，但为动态用例提供了灵活性。

与静态定义客户端的 `@FeignClient` 不同，`FeignClientBuilder` 允许在运行时动态创建客户端。

基础用例：
```
@Autowired
private ApplicationContext applicationContext;

FeignClientBuilder builder = new FeignClientBuilder(applicationContext);

MyClient client = builder
	.forType(MyClass.class, "myClient")
	.url("http://localhost:8080")
	.build();
```

配置选项：
- `url(String url)` - 设置目标 URL
- `path(String path)` -  添加基础的路径
- `contextId(String contextId)` - 唯一标识符
- `dismiss404(boolean)` - 忽略 404 错误
- `inheritParentContext(boolean)` - 继承父级配置
- `fallback(Class<? extends T>)` - 降级类
- `customize(FeignBuilderCustomizer)` - 自定义 Feign Builder

#### 响应式支持

由于在 Spring Cloud OpenFeign 积极开发期间，OpenFeign 项目不支持 Spring WebClient 等响应式客户端，因此也无法将此类支持添加到 Spring Cloid OpenFeign 中。

由于 Spring Cloud OpenFeign 项目目前已被视为功能完善，即使上游项目提供了相关支持，我们也不打算添加。我们建议迁移到 Spring HTTP Service Clients。该组件同时支持阻塞式和响应式堆栈。

##### 早期初始化错误

我们不建议在应用程序生命周期的早期阶段（例如处理配置和初始化 bean 时）使用 Feign 客户端。在 bean 初始化期间使用客户端是不受支持的。

同样，根据你使用 Feign 客户端的方式，你可能会在启动应用程序时遇到初始化错误。要解决此问题，你可以在自动装配客户端时使用 `ObjectProvider`
```
@Autowired
ObjectProvider<TestFeignClient> testFeignClient;
```

#### Spring Data 支持

如果 Jackson Databind 和 `spring-boot-data-commons` 在类路径中，则会自动添加 `org.springframework.data.domain.Page` 和 `org.springframework.data.domain.Sort` 的转换器。

要禁用此行为，请设置：
```
spring.cloud.openfeign.autoconfiguration.jackson.enabled=false
```

详情请参阅 `org.springframework.cloud.openfeign.FeignAutoConfiguration.FeignJacksonConfiguration`。

#### Spring @RefreshScope 支持

如果启用了 Feign 客户端刷新 ，则每个 Feign 客户端都将使用以下方式创建：
- `feign.Request.Options` 是一个刷新作用域的 bean。这意味着诸如 `connectTimeout` 和 `readTimeout` 之类的属性可以针对任何 Feign 客户端进行刷新
- 一个封装在 `org.springframework.cloud.openfeign.RefreshableUrl` 下的 URL。这意味着，如果 Feign 客户端的 URL 是通过 `spring.cloud.openfeign.client.config.{feignName}.url` 属性定义的，那么它可以针对任何 Feign 客户端实例进行刷新。

你可以通过 POST `/actuator/refresh` 刷新。

默认情况下，Feign 客户端的刷新行为处于禁用状态。使用以下属性启动刷新行为：
```
spring.cloud.openfeign.client.refresh-enabled=true
```

> 请勿使用 `RefreshScope` 注解来注解 `@FeignClient` 接口。

#### OAuth2 支持

可以通过在项目中添加 `spring-boot-starter-oauth2-client` 依赖项并设置以下标志来启用 OAuth2 支持：
```
spring.cloud.openfeign.oauth2.enabled=true
```

当该标志设置为 true 且存在 OAuth2 客户端上下文资源详细信息时，将创建一个 `OAuth2AccessTokenInterceptor` 类的 bean。在每个请求之前，拦截器会解析所需的访问令牌并将其作为标头包含在请求中。`OAuth2AccessTokenInterceptor` 使用 `OAuth2AuthorizedClientManager` 获取持有`OAuth2AccessToken` 的 `OAuth2AuthorizedClient`。如果用户已使用 `spring.cloud.openfeign.oauth2.clientRegistrationId` 属性指定了 OAuth2 客户端注册 ID，则该 ID 将用于检索令牌。如果未检索到令牌或未指定 `clientRegistrationId`，则将使用从 URL 主机段搜索到的服务 ID。

> 对于负载均衡的 Feign 客户端，使用 `serviceId` 作为 OAuth2 客户端注册 ID 非常方便，对于非负载均衡的客户端，基于属性的 `clientRegistrationId` 则更为合适。

> 如果你不想要使用 `OAuth2AuthorizedClientManager` 的默认设置，你可以直接在配置中实例化一个这种类型的 bean。

#### 转换负载均衡的 HTTP 请求

你可以使用选定的 `ServiceInstance` 来转换负载均衡的 HTTP 请求。

对于 `Request`，你需要实现并定义 `LoadBalancerFeignRequestTransformer`，如下所示：
```
@Bean
public LoadBalancerFeignRequestTransformer transformer() {
	return new LoadBalancerFeignRequestTransformer() {
		@Override
		public Request transformRequest(Request request, ServiceInstance instance) {
			Map<String, Collection<String>> headers = new HashMap<>(request.headers());
			headers.put("X-ServiceId", Collections.singletonList(instance.getServiceId()));
			headers.put("X-InstanceId", Collections.singletonList(instance.getInstanceId()));
			return Request.create(request.method(), request.url(), headers, request.body(), request.charset(), request.requestTemplate());
		}
	}
}
```

如果定义了多个转换器，则按照 bean 的定义顺序应用它们。或者，你可以使用 `LoadBalancerFeignRequestTransformer` 来指定顺序。

#### X-Forwarded 标头支持

可以通过设置以下标志来启用 `X-Forwarded-Host` 和 `X-Forwarded-Proto` 支持：
```
spring.cloud.loadbalancer.x-forwarded.enabled=true
```

#### 向 Feign 客户端提供 URL 的支持方式

你可以通过以下任一方式向 Feign 客户端提供 URL：

| 场景 | 示例 | 细节 |
| --- | ---| --- |
| URL 已在 `@FeignClient` 注解中提供 | `@FeignClient(name = "testClient", url = "http://localhost:80801")` | URL 是从注解的 url 属性解析出来的，没有进行负载均衡 |
| URL 在 `@FeignClient` 注解和配置属性中提供 | `@FeignClient(name = "testClient", url = "http://localhost:80801")` 以及  `application.yml` 中定义的属性 `spring.cloud.openfeign.client.config.testClient.url=http://localhost:80801` | URL 解析自注解的 URL 属性，未进行负载均衡。配置属性中提供的 URL 未使用 |
| `@FeignClient` 注解未提供 URL，但配置属性中提供了 URL | `@FeignClient(name = "testClient")` 以及  `application.yml` 中定义的属性 `spring.cloud.openfeign.client.config.testClient.url=http://localhost:80801` | URL 解析自配置属性，未进行负载均衡。如果 `spring.cloud.openfeign.client.refresh-enabled=true`，则可以按照 Spring RefreshScope 支持文档中的说明刷新配置属性中定义的 URL |
| `@FeignClient` 注解和配置属性中均未提供 URL | `@FeignClient(name = "testClient")` | URL 由注解的`name` 属性解析，并进行了负载均衡 |

#### AOT 和原生镜像支持

Spring Cloud OpenFeign 支持 Spring AOT 转换和原生镜像，但是，只有在禁用刷新模式、禁用 Feign 客户端刷新（默认设置）和禁用延迟 `@FeignClient` 属性解析（默认设置）的情况下才支持。

> 如果要以 AOT 或原生镜像模式运行 Spring Cloud OpenFeign 客户端，请确保将 `spring.cloud.openfeign.refresh.enabled` 设置为 `false`。

> 如果要以 AOT 或原生镜像模式运行 Spring Cloud OpenFeign 客户端，请确保 `spring.cloud.openfeign.client.refresh-enabled` 没有设置为 `true`。

> 如果要以 AOT 或原生镜像模式运行 Spring Cloud OpenFeign 客户端，请确保 `spring.cloud.openfeign.lazy-attributes-resolution` 没有被设置为 `true`。

> 但是，如果你通过属性设置了 URL 值，则可以通过运行带有 `-Dspring.cloud.openfeign.client.config.[clientId].url=[url]` 的标志的镜像来覆盖 `@FeignClient` 的值。为了启用覆盖功能，URL 值也必须通过属性设置，而不是在构建时通过 `@FeignClient` 属性设置。

### 配置属性

## 通用应用配置

各种属性可以在 `application.properties`、`application.yml` 或命令行参数中指定。本附录提供了常用的 Spring Cloud OpenFeign 属性以及使用这些属性的底层类的引用。

> 属性可以来自类路径上 的其他 jar 文件，因此你不应将此列表视为完整列表。此外，你还可以定义自己的属性。

### 配置属性

下面列出了配置属性。

| 名称 | 默认值 |描述 |
| --- | --- | --- |
| spring.cloud.compatibility-verifier.compatible-boot-versions |  | Spring Boot 依赖项的默认版本。如果你不想指定具体版本，可以设置 `x` 来表示补丁版本。例如 `3.5.x` |
| spring.cloud.compatibility-verifier.enabled | `false` | 支持创建 Spring Cloud 兼容性验证 |
| spring.cloud.config.allow-override | `true` | 此标志用于标识是否可以使用 `isOverrideSystemProperties()`。设置为 `false` 可防止用户意外更改默认值。 |
| spring.cloud.config.initialize-on-context-refresh | `false` | 启用此标志可在上下文刷新事件时初始化引导配置 |
| spring.cloud.config.override-none | `false` | 此标志用于指示当 `setAllowOverride(boolean)` 为 `true` 时，外部属性的优先级应最低，并且不应覆盖任何现有的属性源（包括本地配置文件）。默认值为 `false`，此标志仅在使用配置优先引导时生效 |
| spring.cloud.config.override-system-properties | `true` | 指示外部属性是否应覆盖系统属性的标志 |
| spring.cloud.decrypt-environment-post-processor.enabled | `true` | 启用 EncrptyEnvironmentPostProcessor |
| spring.cloud.discovery.client.composite-indicator.enabled | `true` | 启动 discovery 客户端综合健康指标 |
| spring.cloud.discovery.client.health-indicator.enabled | `true` |  |
| spring.cloud.discovery.client.health-indicator.include-description | `false` |  |
| spring.cloud.discovery.client.health-indicator.user-services-query | `true` | 指示是否应使用 `DiscoveryClient#getServices` 来检查其运行状况。当设置为 `false` 时，指示将该用轻量级的 `DiscoveryClient#probe()`。这在大规模部署中非常有用，因为返回的服务数量过多会操作过于繁重 |
| spring.cloud.discovery.client.simple.instances | | |
| spring.cloud.discovery.client.simple.local.host |  | |
| spring.cloud.discovery.client.simple.local.instance-id |  | |
| spring.cloud.discovery.client.simple.local.metadata |  | |
| spring.cloud.discovery.client.simple.local.port | `0` | |
| spring.cloud.discovery.client.simple.local.secure | `false` | |
| spring.cloud.discovery.client.simple.local.service-id |  | |
| spring.cloud.discovery.client.simple.local.uri |  | |
| spring.cloud.discovery.client.simple.order |  | |
| spring.cloud.discovery.enabled | `true` | 启用 discovery client 健康指标发现功能 |
| spring.cloud.features.enabled | `true` | 启用 features 端点 |
| spring.cloud.httpclientfactories.apache.enabled | `true` | 启用 Apache Http Client 工厂 bean 的创建 |
| spring.cloud.httpclientfactories.ok.enabled | `true` | 启用 OK Http Client 工厂 bean 的创建 |
| spring.cloud.hypermedia.refresh.fixed-delay | `5000` | |
| spring.cloud.hypermedia.refresh.initial-delay | `10000` | |
| spring.cloud.inetutils.default-hostname | `localhost` | 默认主机名，用于发生错误时 |
| spring.cloud.inetutils.default-ip-address | `127.0.0.1` | 默认IP地址，用于发生错误时 |
| spring.cloud.inetutils.ignored-interfaces | | 将被忽略的网络接口的 Java 正则表达式列表 |
| spring.cloud.inetutils.preferred-networks | | 列出用于网络地址的 Java 正则表达式，以便优先使用 |
| spring.cloud.inetutils.timeout-seconds | `1` | 计算机主机名的超时时间（以秒为单位） |
| spring.cloud.inetutils.use-only-site-local-interfaces | `false` | 是否仅使用具有站点本地地址的接口。有关更多详细信息，请参阅 `InetAddress#isSiteLocalAddress()` |
| spring.cloud.loadbalancer.api-version.default | | 设置每个请求应使用的默认版本 |
| spring.cloud.loadbalancer.api-version.fallback-to-available-instances | `false` | 指示如果指定版本没有可用实例，是否应返回所有可用实例 |
| spring.oud.loadbalancer.api-version.header | | 使用给定名称的 HTTP 标头来获取版本 |
| spring.cloud.loadbalancer.api-version.media-type-parameters | | 使用给定名称的媒体类型参数来获取版本 |
| spring.cloud.loadbalancer.api-version.path-segment | | 使用给定索引处的路径段来获取版本 |
| spring.cloud.loadbalancer.api-version.query-parameter | | 使用具有给定名称的查询参数来获取版本 |
| spring.cloud.loadbalancer.api-version.required | `false` | 指示每次请求是否需要提供 API 版本 |
| spring.cloud.loadbalancer.call-get-with-request-on-delegates | `true` | 如果此标志设置为 `true`，则 `ServiceInstanceListSupplier#get(Request)` 方法将被实现，以便在可从 `DelegatingServiceInstanceListSuppier` 分配的类中调用 `delegate.get(request)`，但 `CachingServiceInstanceListSupplier` 和 `HealthCheckServiceInstanceListSupplier` 除外，这两个类应直接放置在实例提供程序层次结构中执行实例的提供程序之中，位于通过网络执行实例检索的供应商之后，在执行任何基于请求的过滤之前，默认情况下为 `true` |
| spring.cloud.loadbalancer.clients | |  |
| spring.cloud.loadbalancer.eager-load.clients | |  |
| spring.cloud.loadbalancer.health-check.initial-delay | `0` | 健康检查调度程序的初始延迟值 |
| spring.cloud.loadbalancer.health-check.interval | `25s` | 健康检查调度程序重新运行的间隔 |
| spring.cloud.loadbalancer.health-check.path | | 发出健康检查请求的路径。可按服务ID进行设置。也可设置默认值。如果未设置，则将使用 /actuator/health |
| spring.cloud.loadbalancer.health-check.port | | TODO 源文档写错，不应该是Port，发出健康检查请求的端口，如果未设置，则为服务实例上所请求服务可用的端口 |
| spring.cloud.loadbalancer.health-check.refetch-instances | `false` | 指示 `HealthCheckServiceInstanceListSupplier` 是否应重新获取实例。如果实例可以更新，则底层委托不提供持续的实例更新，则可以使用此选项 |
| spring.cloud.loadbalancer.health-check.refetch-instances-interval | `25s` | 重新获取可用服务实例的间隔 |
| spring.cloud.loadbalancer.health-check.repeat-health-check | `true` | 指示是否应持续重复进行健康检查。如果定期重新获取实例，则将其设置为 `false` 可能很有用，因为每次重新获取实例都会触发一次健康检查 |
| spring.cloud.loadbalancer.health-check.update-results-list | `true` | 指示是否应在检索到的每个存活的 `ServiceInstance` 上发出 `healthCheckFlux` 事件，如果设置为 `false`，则首先将所有存活的实例序列收集到一个列表中，然后再发出该事件 |
| spring.cloud.loadbalancer.hint | | 允许设置传递给 LoadBalancer 请求的 `hint` 值，该值随后可在 `ReactiveLoadBalancer` 实现中使用  |
| spring.cloud.loadbalancer.hint-header-name | `X-SC-LB-Hint` | 允许设置用于传递提示以进行基于提示的服务实例过滤的标头名称 |
| spring.cloud.loadbalancer.retry.backoff.enabled | `false` | 指示是否应应用反应式重试退避机制 |
| spring.cloud.loadbalancer.retry.backoff.jitter | `0.5` | 用于设置 `RetryBackoffSpec.jitter` |
| spring.cloud.loadbalancer.retry.backoff.max-backoff | `Long.MAX ms` | 用于设置 `RetryBackoffSpec.maxBackOff` |
| spring.cloud.loadbalancer.retry.backoff.min-backoff | `5 ms` | 用于设置 `RetryBackoffSpec.minBackOff` |
| spring.cloud.loadbalancer.retry.enabled | `true` | 开启负载均衡器的重试 |
| spring.cloud.loadbalancer.retry.max-retries-on-next-service-instance | `1` | 在下一个 `ServiceInstance` 上执行的重试次数。每次重试调用之前都会选择一个 `ServiceInstance` |
| spring.cloud.loadbalancer.retry.max-retires-on-same-service-instance | `0` | 对同一 `ServiceInstance` 执行的重试次数 |
| spring.cloud.loadbalancer.retry.retry-on-all-excetpions | `false` | 指示应该对所有异常进行重试，而不仅仅是 `retryableException` 中指定的异常 |
| spring.cloud.loadbalancer.retry.retry-on-all-operations | `false` | 指示对除 `HttpMethod.GET` 之外的操作应尝试重试 |
| spring.cloud.loadbalancer.retry.retryable-exceptions | `{}` | 一组可触发重试的 `Throwable` |
| spring.cloud.loadbalancer.retry.retryable-status-code | `{}` | 一组可触发重试的状态码 |
| spring.cloud.loadbalancer.stats.include-path | `true` | 指示是否应将 `path` 添加到指标中的 `uri` 标签，当使用 `RestTemplate` 执行具有高基数路径的负载均衡请求时，建议将其设置为 `false` |
| spring.cloud.loadbalancer.stats.micrometer.enabled | `false` | 为负载均衡请求启用 `Micrometer` 指标 |
| spring.cloud.loadbalancer.sticky-session.add-service-instance-cookie | `false` | 指示负载均衡器是否应该包含选定实例的 Cookie |
| spring.cloud.loadbalancer.sticky-session.instance-id-cookie-name. | `sc-lb-instance-id` | 保存首选实例ID 的 cookie 名称 |
| spring.cloud.loadbalancer.subset.instance-id | | 确定性子集的实例ID，如果未设置，则将使用 `IdUtils#getDefaultInstanceId(PropertyResolver)` |
| spring.cloud.loadbalancer.subset.size | | 确定性子集的最大子子集大小 |
| spring.cloud.loadbalancer.x-forwarded-enabled | `false` | 启用 `X-Forwadrded` 请求标头 |
| spring.cloud.openfeign.autoconfiguration.jackson.enabled | `true` | 如果为 `true`，则会提供 PageJacksonModule 和 SortJacksonModule bean 用于 Jackson 页面解码 |
| spring.cloud.openfeign.circuitbreaker.alphanumberic-ids.enabled | `true` | 如果为 `true`，断路器ID将仅包含字母数字字符，以便通过配置属性进行配置 |
| spring.cloud.openfeign.circuitbreaker.enabled | `false` | 如果为 `true`，OpenFeign 客户端将被 Spring Cloud CircuitBreaker 断路器封装 |
| spring.cloud.openfeign.circuitbreaker.group.enabled | `false` | 如果为 `true`，OpenFeign 客户端将被包装在带有组的 Spring Cloud CircuitBreaker 断路器中 |
| spring.cloud.openfeign.client.config |  |  |
| spring.cloud.openfeign.client.decode-slash | `true` | Feign 客户端默认情况下不对斜杠 `/` 字符进行编码，要更改此行为，请将 `decodeSlash` 设置为 `false` |
| spring.cloud.openfeign.client.default-config | `default` |  |
| spring.cloud.openfeign.client.default-to-properties | `true` | |
| spring.cloud.openfeign.client.refresh-enabled | `false` | 为 Feign 启用选项值刷新功能 |
| spring.cloud.openfeign.client.remove-trailing-slash | `false` | 如果为 `true`，则会删除请求末尾的斜杠 |
| spring.cloud.openfeign.compression.request.content-encoding-types |  | 内容编码列表（使用的编码取决于所使用的客户端） |
| spring.cloud.openfeign.compression.request.enabled | `false` | 允许对 Feign 发送的请求进行压缩 |
| spring.cloud.openfeign.compression.request.mini-types | `[text/xml, application/xml, application/json]` | 支持的 MIME 类型列表 |
| spring.cloud.openfeign.compression.request.min-request-size | `2048` | 最小阈值内容大小 |
| spring.cloud.openfeign.compression.response.enabled | `false` | 允许压缩来自 Feign 的响应 |
| spring.cloud.openfeign.encoder.charset-from-content-type | `false` | 指示是否从 `Content-Type` 标头中派生字符串 |
| spring.cloud.openfeign.http2client.enabled | `false` | 启用 `Feign` 的 Java11 HTTP 2 客户端 |
| spring.cloud.openfeign.httpclient.connection-timeout | `2000` |  |
| spring.cloud.openfeign.httpclient.connection-timer-repeat | `3000` | |
| spring.cloud.openfeign.httpclient.disable-ssl-validation | `false` | |
| spring.cloud.openfeign.httpclient.follow-redirects | `true` | |
| spring.cloud.openfeign.httpclient.hc5.connection-request-timeout | `3` | 连接请求超时的默认值 |
| spring.cloud.openfeign.httpclient.hc5.connection-request-timeout-unit | `minutes` | 连接请求超时单位的默认值 |
| spring.cloud.openfeign.httpclient.hc5.enabled | `true` | 启用 Feign 的 Apache HTTP Client 5 |
| spring.cloud.openfeign.httpclient.hc5.pool-concurrency-policy | `strict` | 池化并发策略 |
| spring.cloud.openfeign.httpclient.hc5.pool-reuse-policy | `fifo` | 连接池复用策略 |
| spring.cloud.openfeign.httpclient.hc5.socket-timeout | `5` | Socket 超时的默认值 |
| spring.cloud.openfeign.httpclient.hc5.socket-timeout-unit | `seconds` | Socket 超时单位的默认值 |
| spring.cloud.openfeign.httpclient.http2.version | `HTTP_2` | 配置此客户端与远程服务器通信时使用的协议。使用 `HttpClient.Version` 的 `String` 值 |
| spring.cloud.openfeign.httpclient.max-connections | `200` |  |
| spring.cloud.openfeign.httpclient.max-connections-per-route | `50` | |
| spring.cloud.openfeign.httpclient.time-to-live | `900` | |
| spring.cloud.openfeign.httpclient.time-to-live.unit | `seconds` | |
| spring.cloud.openfeign.lazy-attributes-resolution | `false` | 将 `@FeignClient` 属性解析模式切换为延迟解析 |
| spring.cloud.openfeign.micrometer.enabled | `true` | 为 Feign 启用 `Micrometer` 功能 |
| spring.cloud.openfeign.oauth2.client-registration-id | | 用于检索 OAuth2 访问令牌的客户端注册ID。如果未指定，则将使用从 `url` 主机段检索到的 `serviceId`。这对于负载均衡的 Feign 客户端非常方便。对于非负载均衡的客户端，建议指定 `clientRegistrationId` |
| spring.cloud.openfeign.oauth2.clientRegistrationId |  | 提供用于 OAuth2 的客户端ID |
| spring.cloud.openfeign.oauth2.enabled | `false` | 启用 Feign 拦截器以管理 OAuth2 访问令牌 |
| spring.cloud.refresh.additional-property-sources-to-retain |  | 刷新期间保留的其他属性源。通常情况下，仅保留系统属性源。此属性允许保留属性源，例如由 `EnvironmentPostProcessor` 创建的属性源 |
| spring.cloud.refresh.enabled | `true` | 启用刷新范围及相关功能的自动配置 |
| spring.cloud.refresh.extra-refreshable | `true` | 添加到刷新作用域的 bean 的名称或类名（用于进行后处理） |
| spring.cloud.refresh.never-refreshable | `true` | 以逗号分隔的 bean 名称或类名列表，这些 bean 永远不会被刷新或重新加载 |
| spring.cloud.refresh.never-reset-nested-types |  | 嵌套属性配置值的安全限定类名前缀，这些属性值在 bean 重新绑定时决不能递归重置。JDK 和标准 API 类型始终会被跳过；使用此选项还可以排除对象图存在循环或包含不可修改的内部状态的库类型。每个条目都会使用前缀比较与完全限定类名进行匹配，因此可以提供包名或单个类名。 |
| spring.cloud.refresh.on-restart.enabled | `true` | 启用启动时刷新上下文的功能 |
| spring.cloud.service-registry.auto-registration.enabled | `true` | 是否启用服务自动注册，默认为 `true` |
| spring.cloud.service-registry.auto-registration.fail-fast | `false` | 如果未进行自动服务注册，则启动是否失败，默认为 `false` |
| spring.cloud.service-registry.auto-registration.register-management | `true` | 是否将管理功能注册为服务，默认为 `true` |
| spring.cloud.util.enabled | `true` | 允许创建 Spring Cloud 实用 bean |