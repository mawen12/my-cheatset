# 总览

Spring Cloud Bus 将分布式系统的节点和轻量级消息代理连接起来。然后，这可以用于广播状态更改（例如配置更改）或其他管理指令。AMQP 和 Kafka 代理实现包含在该项目中。或者，在类路径上找到的任何链接：https://spring.io/projects/spring-cloud-stream[Spring Cloud Stream] 绑定器都将作为传输开箱即用。



## 入门

只要 Spring Cloud Bus AMQP 和 RabbitMQ 位于类路径上，任何 Spring Boot 应用程序都会尝试联系 `localhost:5672` 上的 RabbitMQ 服务器（`spring.rabbitmq.address` 的默认值）。

```java
@Configuration
@EnabledAutoConfiguration
@RestController
public class Application {
	@RequestMapping("/")
	public String home() {
    return "Hello World";
  }
  
  public static void main(String[] args) {
    SpringApplication.run(Application.class, args);
  }
}
```



# 介绍

Spring Cloud Bus 将分布式系统的节点和轻量级消息代理连接起来。然后，这可以用于广播状态更改（例如配置更改）或其他管理指令。一个关键思想是，总线就像是横向扩展的 Spring Boot 应用程序的分布式执行器。但是，它也可以用作应用程序之间的通信渠道。该项目为 AMQP 代理或 Kafka 作为传输提供了启动器。



# 快速启动

如果 Spring Cloud Bus 在类路径上检测到自身，则通过添加 `spring-cloud-starter-bus-amqp` 或 `spring-cloud-starter-bus-kafka` 添加到依赖项管理中。Spring Cloud 负责剩下的事情。确保代理（RabbitMQ 或 Kafka）可用已配置。在本地主机上运行时，你无需执行任何操作。如果远程运行，请使用 Spring Cloud Connectors 或 Spring Boot 约定来定义代理凭据，如一下 Rabbit 示例所示：

*application.yml*

```yaml
spring:
	rabbitmq:
		host: mybroker.com
		port: 5672
		username: user
		password: secret
```

该总线当前支持向所有侦听节点或特定服务（如 Eureka 定义）的所有节点发送消息。`/bus*` 执行器命名空间有一些 HTTP 端点。目前已实施三项。第一个是 `/busenv`，发送键/值对来更新每个节点的 Spring 环境。第二个是 `/busrefresh` 重新加载每个应用程序的配置，就好象它们都已在其 `/refresh` 端点上 ping 通一样。第三个是 `/busshutdown` 发送关闭事件以正常关闭应用程序实例。

> Spring Cloud Bus 启动器涵盖了 Rabbit 和 Kafka，因为它们是两种最常见的实现。然而，Spring Cloud Stream 非常灵活，并且 binder 与 `spring-cloud-bus` 配合使用。



# Spring Cloud Bus



## Bus 端点

Spring Cloud Bus 提供了三个端点，`/actuator/busrefresh`、`/actuator/busshutdown` 和 `/actuator/busenv`，分别对应于 Spring Cloud Commons 中的各个执行器端点，`/actuator/refresh`、`/actuator/shutdown`、`/actuator/env`。



### Bus 刷新端点

`/actuator/busrefresh` 端点清除 `RefreshScope` 缓存并重新绑定 `@ConfigurationProperties`。有关详细信息，请参阅 Refresh Scope 文档。

要公开 `/actuator/busrefresh` 端点，你需要向应用添加一下配置：

```properties
management.endpoints.web.exposure.include=busrefresh
```



### Bus 环境端点

`/actuator/busenv` 端点使用跨多个示例的指定键/值对更新每个实例环境。

要公开 `/actuator/busenv` 端点，你需要向应用添加一下配置：

```properties
management.endpoints.web.exposure.include=busenv
```

`actuator/busenv` 端点接受以下格式的 `POST` 请求：

```json
{
  "name": "key1",
  "value": "value1"
}
```



### Bus 关闭端点

`/actuator/busshutdown` 正常关闭应用程序。

要公开 `/actuator/busshutdown` 端点，你需要向应用添加一下配置：

```properties
management.endpoints.web.exposure.include=busshutdown
```

你可以通过发出 `POST` 请求来向总线关闭端点发出请求。

如果你像针对特定应用，你可以向 `/busshutdown` 发出 `POST` 请求，并可选择指定总线 id：

```bash
$ curl -X POST http://localhost:8080/actuator/busshutdown
```

你还可以通过指定总线 id 来定位特定的应用实例：

```bash
$ curl -X POST http://localhost:8080/actuator/busshutdown/busid:123
```



## 处理实例



### 处理单个实例

应用的每个实例都有一个服务 ID，其值可以使用 `spring.cloud.bus.id` 设置，并且其值应为以冒号分隔的标识符列表，按从最不具体到最具体的顺序排列。默认值是根据环境构造的，作为 `spring.application.name` 和 `server.port`（或 `spring.application.index`，如果设置）的组合。ID 的默认值以 `app:index:id` 的形式构造，其中：

- `app` 是 `vcap.application.name`（如果存在），或 `spring.application.name`
- `index` 是 `vcap.application.instance_index`（如果存在），或 `spring.application.index`、`local.server.port`、`server.port` 或 `0`（按此顺序）
- `id` 是 `vcap.application.instace_id`（如果存在），或随机值

HTTP 端点接受"目标"路径参数，例如 `/busrefresh/customers:9000`，其中 `destination` 是服务 ID。如果总线上的某个实例拥有该 ID，则它会处理该消息，而所有其它实例会忽略该消息。



### 处理服务的所有实例

Spring `PathMatcher` 中使用 `distination` 参数（路径分隔符为冒号 `:`）来确定实例是否处理消息。使用前面的示例，`/busenv/customers:**` 定位 "customers" 服务的所有实例，无论服务 ID 的其余部分如何。

 

### 服务 ID 必须是唯一的

总线尝试两次来消除对事件的处理-一次从原始应用事件中，一次从队列中。为此，它会根据当前服务 ID 检查发送服务 ID。如果服务的多个实例具有相同的 ID，则不会处理事件。当在本地计算机上运行时，每个服务都位于不同的端口上，并且该端口是 ID 的一部分。Cloud Foundry 提供了一个索引来区分。为了确保 ID 在 Cloud Foundry 外部是唯一的，请将 `spring.application.index` 设置为每个服务实例的唯一值。



## 配置



### 自定义消息代理

Spring Cloud Bus 使用 Spring Cloud Stream 来广播消息。因此，要使消息流动，你只需在类路径中包含你选择的绑定器实现即可。有 AMQP（RabbitMQ）和 Kafka（`spring-cloud-starter-bus-[amqp|kafka]`）的便捷总线启动器。一般来说，Spring Cloud Stream 依赖 Spring Boot 自定配置约定来配置中间件。例如，可以使用 `spring.rabbitmq.*` 配置属性更改 AMQP 代理地址。Spring Cloud Bus 在 `spring.cloud.bus.*` 中有一些本机配置属性（例如，`spring.cloud.bus.destination` 是用作外部中间件的主题的名称）。通常，默认值就足够了。

要了解有关如何自定义消息代理设置的更多信息，请参阅 Spring Cloud Stream 文档。

> 如果你启用了配置优先引导程序，则应将 `spring.cloud.bus.destination` 放置在 `bootstrap.[yaml | properties]` 中。否则如果触发刷新，该值将重置为默认值。



### 跟踪总线事件

可以通过设置 `spring.cloud.bus.trace.enabled=true` 来跟踪总线事件（子类 `RemoteApplicationEvent`）。如果这样做，Spring Boot `TraceRepository` （如果存在）将显示发送的每个事件以及来自每个服务实例的所有确认。以下示例来自 `/trace` 端点。

// TODO 格式错误，应为数组

```json
[
  {
    "timestamp": "2015-11-26T10:24:44.411+0000",
    "info": {
      "signal": "spring.cloud.bus.ack",
      "type": "RefreshRemoteApplicationEvent",
      "id": "c4d374b7-58ea-4928-a312-31984def293b",
      "origin": "stores:8081",
      "destination": "*:**"
    },
  },
  {
    "timestamp": "2015-11-26T10:24:41.864+0000",
    "info": {
      "signal": "spring.cloud.bus.sent",
      "type": "RefreshRemoteApplicationEvent",
      "id": "c4d374b7-58ea-4928-a312-31984def293b",
      "origin": "customers:9000",
      "destination": "*:**"
    },
  },
  {
    "timestamp": "",
    "info": {
      "signal": "spring.cloud.bus.ack",
      "type": "RefreshRemoteApplicationEvent",
      "id": "c4d374b7-58ea-4928-a312-31984def293b",
      "origin": "customers:9000",
      "destination": "*:**"
    }
  }
]
```

前面的跟踪显示 `RefreshRemoteApplicationEvent` 是从 `customers:9000` 发送的，广播到所有服务，并由 `customers:9000` 和 `stores:8081` 接受（确认）。

要自己处理 ack 信号，你可以将 `AckRemoteApplicationEvent` 和 `SentApplicationEvent` 类型的 `@EventListener` 添加到你的应用（并启用跟踪）。或者，你可以进入 `TraceRepository` 并从那里挖掘数据。

> 任何总线应用都可以跟踪 ack。然后，有时，在中央服务器中执行此操作很有用，该服务可以对数据进行更复杂的查询或将其转发到专门的跟踪服务。



## 自定义事件



### 广播你自己的事件

总线可以承载任何 `RemoteApplicationEvent` 类型的事件。默认传输的是 JSON，解析器需要提前知道要使用哪些类型。要注册新类型，必须将其放入 `org.springframework.cloud.bus.event` 的子包中。

要自定义事件名称，你可以在自定义类上使用 `@JsonTypeName` 或依赖默认策略，即使用类的简单名称。

> 生产者和消费者都需要访问类定义。



#### 在自定义包中注册事件

如果你不能或不想将 `org.springframework.cloud.bus.event` 的子包用于自定义事件，则必须使用 `@RemoteApplicationEventScan` 注解指定要扫描 `RemoteApplicationEvent` 类型事件的包，使用 `@RemoteApplicationEventScan` 指定的包包括子包。

例如，请考虑以下名为 `MyEvent` 的自定义事件：

```java
public class MyEvent extends RemoteApplicationEvent {
  // ...
}
```

你可以通过以下方式向解析器注册该事件：

```java
@Configuration
@RemoteApplicationEventScan
public class BusConfiguration {
  // ...
}
```

如果不指定值，则注册使用 `@RemoteApplicationEvent` 的类的包。在本例中，`com.acme` 是使用 `BusConfiguration` 包注册的。

```java
@Configuration
// @RemoteApplicationEventScan({"com.acme", "foo.bar"})
@RemoteApplicationEventScan(basePackageClasses = BusConfiguration.class)
public class BusConfiguration {
  // ...
}
```

所有前面的 `@RemoteApplicationEvent` 实例都是等效的，因为 `com.acme` 包是通过显示指定 `@RemoteApplicationEvent` 上的包来注册的。

> 你可以指定要扫描的多个基础包。



# 通用应用配置

可以在 `application.properties` 文件、`application.yml` 文件内或作为命令行开关指定各种属性。本附录提供了场景 Spring Cloud Bus 属性的列表以及对使用它们的底层类的引用。

> 属性贡献可以来自类路径上的其他 jar 文件，因此你不应认为这是一个详尽的列表。此外，你还可以定义自己的属性。

| 名称                                 | 默认值        | 描述                                            |
| ------------------------------------ | ------------- | ----------------------------------------------- |
| spring.cloud.bus.destination-service |               | 想要监听 ack 的服务，默认为空（意味着所有服务） |
| spring.cloud.bus.ack.enaled          | `true`        | 关闭 ack 的标志（默认打开）                     |
| spring.cloud.bus.content-type        |               | 总线媒体类型                                    |
| spring.cloud.bus.destination         |               | 消息的 Spring Cloud Stream 目的地的名称         |
| spring.cloud.bus.enabled             | `true`        | 指示总线已启用的标志                            |
| spring.cloud.bus.env.enabled         | `true`        | 用于关闭环境更改事件的标志（默认打开）          |
| spring.cloud.bus.id                  | `application` | 此应用实例的标识符                              |
| spring.cloud.bus.refresh.enabled     | `true`        | 用于关闭刷新事件的标志（默认打开）              |
| spring.cloud.bus.shutdown.enabled    | `true`        | 用于关闭关闭事件的标志（默认打开）              |
| spring.cloud.bus.trace.enabled       | `false`       | 打开 ack 跟踪的标志（默认关闭）                 |

