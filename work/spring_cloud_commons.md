# 总览

Spring Cloud Commons 通过两个库提供功能：Spring Cloud Context 和 Spring Cloud Commons。Spring Cloud Context 为 Spring Cloud 应用程序的 ApplicationContext 提供实用程序和特殊服务（例如引导上下文、加密、刷新作用域和环境端点）。Spring Cloud Commons 是一组抽象和通用类，用于不同的 Spring Cloud 实现（例如 Spring Cloud Netflix 和 Spring Cloud Consul）。


## 功能

### Spring Cloud Context 功能
- Bootstrap Context
- `TextEncryptor` beans
- Refresh Scope
- Spring Boot Actutor 端点用于操作 `Environment`

### Spring Cloud Commons 功能
- `DiscoveryClient` 接口
- `ServiceRegistry` 接口
- 使用 `DiscoveryClient` 解析主机名的 `RestTemplate` 仪表


# 云原生应用

> Spring Cloud 采用非限制性的 Apache 2.0 许可证发布。如果你想为本文档的这一部分做出贡献，或者发现错误，可以在 Github 上找到该项目的源代码和问题跟踪器。

## 介绍

云原生是一种应用开发风格，它鼓励轻松采用持续交付和价值驱动开发领域的最佳实践。与之相关的理念是构建十二要素应用，在这种理念中，开发实践与交付和运维目标保持一致-例如，通过使用声明式编程以及管理和监控。Spring Cloud 通过多种方式促进了这些开发风格。其开发是提供一系列功能，分布式系统中的所有组件都需要能够轻松访问这些功能。

Spring Cloud 正是基于 Spring Boot 构建的，Spring Boot 涵盖了其中许多特性。Spring Cloud 还通过两个库提供了一些其他特性：Spring Cloud Context 和 Spring Cloud Commons。Spring Cloud Context 为 Spring Cloud 应用程序的 ApplicationContext 提供实用程序和特殊服务（例如引导上下文、加密、刷新作用域和环境端点）。Spring Cloud Commons 是一组抽象和通用类，用于不同的 Spring Cloud 实现（例如 Spring Cloud Netflix 和 Spring Cloud Consul）。

## Spring Cloud Context: 应用上下文服务

Spring Boot 对如何使用 Spring 构建应用程序有着一套既定的方案。例如，它为常用配置文件设定了固定的值，并为常见的管理和监控任务提供了接口。Spring Cloud 在此基础上构建，并添加了一些系统中许多组件都会用到或偶尔需要的功能。

### Bootstrap 应用上下文

Spring Cloud 应用通过创建一个 "bootstrap" 上下文，该上下文是主应用的父上下文。此上下文负责从外部源加载配置属性，并解密本地外部配置文件中的属性。这两个上下文共享一个 `Environment`，该环境是任何 Spring 应用外部属性的来源。默认情况下，引导属性（不是 `bootstrap.properties` 文件，而是引导阶段加载的属性）具有很高的优先级，因此它们不能被本地配置覆盖。

Bootstrap 上下文使用与主应用上下文不同的外部配置定位约定。你可以使用 `bootstrap.yml` 而不是 `application.yml`（或 ` .properties`），从而将 Bootstrap 和主应用上下文的外部配置很好的分开。以下示例展示了 Bootstrap 的配置：

bootstrap.yml
```
spring:
	application:
		name: foo
	cloud:
		config:
			uri: ${SPRING_CONFIG_URI:http://localhost:8888}
```

如果你的应用程序需要从服务器获取任何应用程序特定的配置，最好设置 `spring.application.name`（在 `bootstrap.yml` 或 `application.yml` 中）。要将 `spring.application.name` 属性用作应用程序的上下文 ID，你必须在 `bootstrap.[properties | yml]`  中设置它。

如果要检索特定的配置文件，还应该在 `bootstrap.[properties | yml]` 中设置 `spring.profiles.active`。

你可以通过设置 `spring.cloud.bootstrap.enabled=false`（例如，在系统属性中）来完全禁用引导过程。


### 应用上下文层次结构

如果你使用 `SpringApplication` 或 `SpringApplicationBuilder` 构建应用上下文，Bootstrap 上下文将作为父上下文添加到该上下文中。Spring 的一个特性是子上下文会自动继承父上下文的属性源和配置文件，因此与不使用 Spring Cloud Config 构建的相同上下文相比，"main" 应用上下文包含额外的属性源。这些额外的属性源包括：
- `bootstrap`: 如果在引导上下文中找到任何 `PropertySourceLoader`，并且它们具有非空属性，则会以高优先级显示一个可选的 `CompositePropertySource`。例如，来自 Spring Cloud Config Server 的属性。有关如何自定义此属性源的内容，请参阅 "自定义引导属性源"。
- `applicationConfig: [classpath:boostrap.yml]` （如果启用了 Spring Profiles，则包括相关文件）：如果你有 `bootstrap.[properties | yml]` 文件，这些属性用于配置引导上下文。当设置父上下文时，这些属性会被添加到子上下文中。它们的优先级低于 `application.[properties | yml]` 以及在创建 Spring Boot 应用过程中作为正常步骤添加到子上下文的任何其他属性源。有关如何自定义这些属性源的内容，请参阅"更改 Bootstrap 属性的位置"。

> 在 Spring Cloud 2022.0.3 之前版本中，`PropertySourceLocators`（包括 Spring Cloud Config 的 PropertySourceLocators）是在主应用上下文中运行的，而不是在 Bootstrap 上下文中运行的。你可以通过在 `bootstrap.[properties | yml]` 中设置 `spring.cloud.config.initialize-on-context-refresh=true` 来强制 `PropertySourceLocators` 在 Bootstrap 上下文中运行。

由于属性源的排序规则，"bootstrap" 条目优先级最高。但请注意，这些条目不包含来自 `bootstrap.[properties | yml]` 的任何数据，`bootstrap.[properties | yml]` 的优先级很低，但可用于设置默认值。

你可以通过设置所创建的任何 `ApplicationContext` 的父上下文来扩展上下文层次结构-例如，使用其自身的接口或 `SpringApplicationBuilder` 的便捷方法（`parent()`、`child()`、`sibling()`）。引导上下文是你自己创建的最高级祖先上下文的父上下文。层次结构中每个上下文都有其自己的 `bootstrap`（可能为空）属性源，以避免无意中将父上下文中的值向下传递到子上下文。如果存在配置服务器，则层级结构中的每个上下文（原则上）也可以拥有不同的 `spring.application.name`，从而拥有不同的远程属性源。属性解析遵循 Spring 应用程序上下文的常规行为规则：子上下文中的属性会覆盖父上下文中的属性，无论按名称还是按属性源名称。（如果子上下文的属性源和父上下文的属性源名称相同，则父上下文中的值不会包含在子上下文中）。

请注意，`SpringApplicationBuilder` 允许你在整个层级结构中共享一个 `Environment`，但这并非默认设置。因此，即使同级上下文也可能与其父上下文共享一些公共值，它们也不需要具有相同的配置文件或属性源。


### 更改 Bootstrap 属性的位置

可以通过设置 `spring.cloud.bootstrap.name`（默认值：`bootstrap`）、`spring.cloud.bootstrap.location`（默认值：empty）或 `spring.cloud.bootstrap.additional-location`（默认值：empty）来指定 `bootstrap.[properties | yml]` 的位置-例如，在系统属性中。

这些属性的行为与同名的 `spring.config.*` 变体类似。使用 `spring.cloud.bootstrap.location` 会替换默认位置，并且只使用指定的位置。要将位置添加到默认位置列表中，可以使用 `sprin.cloud.bootstrap.additional-location`。实际上，它们通过在环境变量中设置这些属性来配置引导程序`ApplicationContext`。如果存在活动的配置文件（通过 `spring.profiles.active` 或通过 `Environment` API 获取），则该配置文件中的属性也会被加载，就像在常规 Spring Boot 应用中一样-例如，开发配置文件中的属性会从 `bootstrap-development.properties` 加载。


### 覆盖远程属性的值

引导上下文添加到应用程序的属性源通常是**远程**的（例如，来自 Spring Cloud Config Server）。默认情况下，它们无法在本地被覆盖。如果你希望应用程序使用自己的系统属性或配置文件覆盖远程属性，则远程属性源必须通过设置 `spring.cloud.config.allowOverride=true` 来授予权限（在本地设置此标志无效）。设置该标志后，两个 更细粒度的设置将控制远程属性对于系统属性和应用程序本地配置的位置：
- `spring.cloud.config.overrideNone=true`: 可覆盖任何本地属性源
- `spring.cloud.config.overrideSystemProperties=false`: 仅系统属性、命令行参数和环境变量（但 不包括本地配置文件）应覆盖远程设置


### 自定义 Bootstrap 配置

你可以在 `/META-INF/spring.factories` 文件中添加名为 `org.springframework.cloud.bootstrap.BootstrapConfiguration` 的键来设置引导上下文，使其执行你想要的任何操作。该键包含一个以逗号分隔的 Spring `@Configuration` 类列表，用于创建引导上下文。任何你希望主应用程序上下文能够自动装配的 bean 都可以在此处创建。对于类型为 `ApplicationContextInitializer` 的 `@Bean`，存在特殊的约定。如果你想要控制启动顺序，可以使用 `@Order` 注解标记类（默认顺序为最后）。

> 当添加自定义的 `BootstrapConfiguration` 时，请务必小心，避免误将添加的类添加到 "main" 应用上下文中，因为这些类可能并不需要在那里。请使用单独的包名来存放引导配置类，并确保该包名未被其他使用 `@ComponentScan` 和 `@SpringBootApplication` 注解的配置类覆盖。

引导过程的最后一步是将初始化器注入到主 `SpringApplication` 实例中（这是 Spring Boot 的标准启动顺序，无论它是作为独立应用程序运行还是部署在应用服务器上）。首先它会根据 `spring.factories` 中的类创建一个引导上下文。然后，在启动主 `SpringApplication` 之前，所有类型为 `ApplicationContextInitializer` 的 `@Bean` 都会被添加到主 `SpringApplication` 中。


### 自定义 Bootstrap 属性源

引导程序添加的外部配置的默认属性源是 Spring Cloud Config Server，但你可以通过向引导上下文（通过 `spring.factories`）添加类型为 `PropertySourceLocator` 的 bean 来添加其他属性源。例如，你可以从不同 的服务器或数据库插入其他属性。

例如，考虑以下自定义定位器：
```
@Configuration
public class CustomPropertySourceLocator implements PropertySourceLocator {
	@Override
	public PropertySource<?> locate(Environment env) {
		return new MapPropertySource("customProperty", Collections.<String, Object>singletonMap("property.from.sample.custom.source", "worked as intended");
	}
}
```

传入的 `Environment`是即将创建的 `Application` 的环境，换句话说，就是我们需要为其提供额外属性源的环境。它已经拥有 Spring Boot 提供的常规属性源，因此你可以使用这些属性源来查找特定于此环境的属性源（例如，通过 `spring.application.name` 作为键，就像在默认的 Spring Cloud Config Server 属性源定位器那样）。

如果你创建了一个包含此类的 jar 文件，然后添加一个包含以下配置的 `META-INF/spring.factories` 文件，则自定义属性 `PropertySource` 会出现在任何将该 Jar 文件添加到其类路径中的应用中：
```
org.springframework.cloud.bootstrap.BoostrapConfiguration=sample.custom.CustomPropertySourceLocator
```

从 Spring Cloud 2022.0.3 版本开始，Spring Cloud 将调用两次 `PropertySourceLocators`。第一次调用会检索所有未配置任何配置文件的属性源。这些属性源可以通过  `spring.profiles.active` 激活配置文件。主应用上下文启动后，`PropertySourceLocators` 将再次被调用，这次会获取所有已激活的配置文件，以便 `PropertySourceLocators` 能够查找到任何其他已配置配置文件的属性源。


### 日志配置

如果你使用 Spring Boot 配置日志，并且希望它应用于所有事件，则应将此配置放在 `bootstrap.[properties | yml]` 中。

> 为了使 Spring Cloud 正确初始化日志配置，你不能使用自定义前缀。例如，Spring Cloud 在初始化日志系统时无法识别 `custom.logging.logpath`。


### 环境变化

应用程序监听 `EnvironmentChangeEvent` 事件，并以几种标准方式响应该变化（可以向往常一样以 `@Bean` 的形式添加额外的 `ApplicationListener`）。当观察到 `EnvironmentChangeEvent` 事件时i，它会返回一个包含已更改键值的列表，应用程序会使用这些键值来：
- 重新绑定上下文中所有的 `@ConfigurationProperties` bean
- 设置 `logging.level.*` 中所有属性的日志级别

请注意，Spring Cloud Config Client 默认情况下不会轮询 `Environment` 变量的变更。通常，我们不建议使用这种方式检测变更（尽管你可以使用 `@Scheduled` 注解进行设置）。如果你有一个横向扩展的客户端应用程序，最好将 `EnvironmentChangeEvent` 广播到所有实例，而不是让它们轮询变更（例如，使用 Spring Cloud Bus）。

`EnvironmentChangeEvent` 涵盖了大部分刷新用例，前提是你能够实际变更环境并发布事件。请注意，这些 API 是公开的，并且是 Spring 核心功能的一部分。你可以通过访问 `/configprops` 端点（Spring Boot Actuator 的标准功能）来验证更改是否已经绑定到 `@ConfigurationProperties` bean。例如，`DataSource` 的 `maxPoolSize` 可以在运行时更改（Spring Boot 创建的默认 `DataSource` 是一个 `@ConfigurationProperties` bean），并动态地增加容量。

当一个 `@ConfigurationProperties` bean 被重新绑定时，其属性首先会被重置为类级别的默认值，以避免从 `Environment` 变量中移除的属性值残留。这种重置也会递归到嵌套的 `@ConfigurationProperties` 对象（例如，没有 `setter` 的嵌套对象）。为了避免深入到非配置属性的对象中，重置操作绝不会递归到 JDK 类型或标准 `jakarta.*` 和 `javax.*` API 命名空间中的类型。如果你有一个 `@ConfigurationProperties` bean 持有对其他库类型的引用，而该类型不应被递归到 （例如，具有循环对象图的类型或包含不可修改的内部状态的类型），则可以通过设置 `spring.cloud.refresh.never-reset-nested-types` 来排除它。该值是一个以逗号分隔的完全限定类名或包前缀列表，每个名称都与类型的类名进行前缀比较：
```
spring.cloud.refresh.never-reset-nested-types=com.example.MyClient,com.acme.sdk.
```

> 重新绑定会直接修改 `@ConfigurationProperties` bean 的字段，销毁并重新初始化同一个实例，而不是将其替换为新实例。对同一个 bean 的并发重新绑定操作在内部会被序列化，但这并不意味着在重新绑定进行期间可以从其他线程安全地读取该 bean：并发读取器可能会观察到瞬态的、部分更新的状态（例如，属性在应用新值之前会短暂地重置为其类级默认值）。如果你的应用需要在刷新后保持 bean 属性的一致性。请该用 `@RefreshScope` 注解，它会针对该作用域内的 bean 执行序列化读取操作和刷新操作。

重新绑定 `@ConfigurationProperties` 并不能涵盖另一大类使用场景，例如需要更精细地控制刷新，以及需要对整个 `ApplicationContext` 进行原子性更改。为了解决这些问题，我们引入了 `@RefreshScope`。

> 使用构造函数绑定的对象（包括带有 `@ConfigurationProperties`注解的 Java Record）无法刷新。


### 刷新范围

当配置发生更改时，标记为 `@RefreshScope` 的  Spring `@Bean` 会获得特殊处理。此功能解决了有状态 bean 仅在初始化时才注入配置的问题。例如，如果通过 `Environment` 变量更改数据库 URL 时，`DataSource` 仍有打开的连接，你可能希望这些连接的持有者能够完成他们正在执行的操作。然后，下次某个程序从连接池借用连接时，它将获得一个具有新 URL 的连接。

有时，对于只能初始化一次的 bean，甚至必须应用 `@RefreshScope` 注解。如果一个 bean 是**不可变的**，则必须使用 `@RefreshScope` 注解该 bean，或者在属性键下指定类名 `spring.cloud.refresh.extra-refreshable`。
```
如果你的 `DataSource` bean 是 `HikariDataSource` 类型，则无法刷新。这是 `spring.cloud.refresh.never-refreshable` 的默认值。如果需要刷新，请选择其他 `DataSource` 实现。
```

刷新作用域 bean 是惰性代理，它们在使用时（及方法调用时）才进行初始化，作用域充当已初始化值的缓存。要强制 bean 在下次方法调用时重新初始化，必须使其缓存条目失效。

`RefreshScope` 是一个上下文中的 bean，它有一个公共的 `refreshAll()` 方法，可以通过清除目标缓存来刷新作用域内的所有 bean。`/refresh` 端点公开了此功能（通过 HTTP 或 JMX）。此外，还有一个 `refresh(string)` 方法，可以按名称刷新单个 `bean`。

要公开 `/refresh` 端点，你需要在应用程序中添加以下配置：
```
management:
	endpoints:
		web:
			exposure:
				include: refresh
```

> `@RefreshScope` 注解（技术上）作用于 `@Configuration` 类，但可能会导致一些意想不到的行为。例如，这并不意味着该类中定义的所有 `@Bean` 都位于 `@RefreshScope` 中。具体来说，任何依赖于这些 bean 的对象都不能指望它们在刷新时得到更新，除非它们自身位于 `@RefreshScope` 中。在这种情况下，它会在刷新时重建，并且其依赖项会被重新注入。此时，它们会根据刷新后的 `@Configuration` 重新初始化。

> 移除配置值后在刷新并不会更新该配置值的存在状态。配置属性必须存在才能在刷新后更新其值。如果你的应用程序依赖于某个值的存在，则可能需要将逻辑更改为依赖于该值不存在。另一种方法是依赖于该值在应用程序配置中的更改，而不是依赖于该值在应用程序配置中的不存在。

> Spring AOT 转换和原生镜像不支持上下文刷新。对于 AOT 和原生镜像，需要将 `spring.cloud.refresh.enabled` 设置为 `false`。


#### 重启时刷新作用域

在重启时无缝刷新 bean 对于使用 JVM 检查点恢复功能（例如，项目 Project CRaC）的应用程序尤其有用。为了实现此功能，我们现在实例化了一个 `RereshScopeLifecycle` bean，该 bean 会在重启时触发上下文刷新，从而重新绑定配置属性并刷新所有带有 `@RefreshScope` 注解的 bean。你可以通过将 `spring.cloud.refresh.on-restart.enabled` 设置为 `false` 来禁用此行为。


#### 健康指示器

Spring Cloud 会自动配置一个 `RefreshScopeHealthIndicator` 来监控刷新作用域的健康状况。如果任何 bean 在上下文刷新后未能重新初始化或重新绑定其配置属性，则该指示器将变为 `DOWN` 状态，并显示相关的异常详情。

要禁用健康指示器，请设置：
```
management:
	health:
		refresh:
			enabled: false
```


### 加密和解密

Spring Cloud 提供了一个 `Environment` 预处理器，用于在本地解密属性值。它遵循与 Spring Cloud 配置服务器相同的规则，并通过 `encrypt.*` 实现相同的外部配置。因此，你可以使用 `{cipher}*` 形式的加密值，只要存在有效的秘钥，它们就会在主应用程序上下文获取 `Environment` 设置之前被解密。要在应用程序中使用加密功能，你需要在类路径中包含 Spring Security RSA（Maven 坐标：`org.springframework.security:spring-security-rsa`），并且你的 JVM 中还需要完整强度的 JCE 扩展。

如果你遇到**Illegal key size**的异常，并且你使用的是 Sun 的 JDK，则需要安装 Java 加密扩展（JCE）无限制强度管辖策略文件。请参阅一下链接了解更多信息：
- Java 6 JCE
- Java 7 JCE
- Java 8 JCE

将文件解压到你使用的 JRE/JDK x64/x86 版本的  JDK/jre/lib/security 文件夹中。


### 端点

对于 Spring Boot Actuator 应用程序，还有一些额外的管理端点可供使用。你可以使用：
- 向 `/actuator/env` 发送 `POST` 请求以更新 `Environment` 环境变量并重新绑定 `@ConfigurationProperties` 和日志级别。要启用此端点，你必须设置 `management.endpoint.env.post.enabled=true` 并在 `management.endpoint.env.post.valid-keys-regex` 中设置一个正则表达式来限制可以设置的属性。
- `/actuator/refresh` 重新加载引导上下文并刷新 `@RefreshScope` bean。
- `/actuator/restart` 关闭 `ApplicationContext` 并重新启动它（默认情况下禁用）。
- `/actuator/pause` 和 `/actuator/resume` 用于调用 `Lifecycle` 方法（`ApplicationContext` 上的 `stop()` 和 `start()`） 

> 启用 `/actuator/env` 端点的 `POST` 方法虽然可以更灵活便捷地管理应用环境变量，但务必确保该端点安全可靠，并受到监控，同时设置有效的更新密钥，以防止潜在的安全风险。添加 `spring-boot-starter-security` 依赖项即可配置执行器端点的访问控制。

> 如果禁用了 `/actuator/restart` 端点，则 `/actuator/pause` 和 `/actuator/resume` 端点也会被禁用，因为它们只是 `/actuator/restart` 的一个特例。


## Spring Cloud Commons: 通用抽象概念

服务发现、负载均衡和熔断器等模式可以构建一个通用的抽象层，供所有 Spring Cloud 客户端使用，而无需考虑具体实现方式（例如，使用 Eureka 或 Consul 进行发现）。


### @EnableDiscoveryClient 注解

Spring Cloud Commons 提供了 `@EnableDiscoveryClient` 注解。该注解会查找 `META-INF/spring.factories` 目录中 `DiscoveryClient` 和 `ReactiveDiscoveryClient` 接口的实现。发现客户段的实现会在 `spring.factories` 目录中添加一个配置类，其键为 `org.springframework.cloud.client.discovery.DiscoveryClient` 的实现。示例包括 Spring Cloud Netflix Eureka、Spring Cloud Consul Discovery 和 Spring Cloud Zookeeper Discovery。

Spring Cloud 默认提供阻塞式和响应式服务发现客户端。你可以通过设置 `spring.cloud.discovery.blocking.enabled=false` 或 `spring.cloud.discovery.reactive.enabled=false` 轻松禁用阻塞式或反应式客户端。要完全禁用服务发现，只需设置 `spring.cloud.discovery.enabled=false` 即可。

默认情况下，`DiscoveryClient` 的实现会自动将本地 Spring Boot 服务器注册到远程发现服务器。可以通过在 `@EnableDiscoveryClient` 注解中设置 `autoRegister=false` 来禁用此行为。

> 不再需要使用 `@EnableDiscoveryClient` 注解。你可以将 `DiscoveryClient` 的实现添加到类路径中，以使用Spring Boot 应用程序向服务器发现服务器注册。


#### 健康指示器

Commons 会自动配置以下 Spring Boot 健康指标。

##### DiscoveryClientHealthIndicator

该健康指标基于当前注册的 `DiscoveryClient` 实现。
- 要完全禁用，请设置 `spring.cloud.discovery.client.health-indicator.enabled=false`
- 要禁用描述字段，请设置 `spring.cloud.discovery.client.health-indicator.include-description=false`。否则，它可能会作为汇总的 `HealthIndicator` 的描述向上冒泡。
- 要禁用服务检索，请设置 `spring.cloud.discovery.client.health-indicator.user-services-query=false`。默认情况下，该指示器会调用客户端的 `getServices()` 方法。在已注册服务众多的部署环境中，每次检查都检索所有服务可能消耗过多资源。此设置将跳过服务检索，转而使用客户端的 `probe` 方法。

##### DiscoveryCompositeHealthContributor

此综合健康指标基于所有已注册的 `DiscoveryHealthIndicator` bean。要禁用此指标，请设置 `spring.cloud.discovery.client.composite-indicator.enabled=false`。


#### 排序 DiscoveryClient 实例

`DiscoveryClient` 接口继承自 `Ordered` 接口。这在使用多个发现客户端时非常有用，因为它运行你定义返回的发现客户端的顺序，类似于你可以对 Spring 应用程序加载的 bean 进行排序的方式。默认情况下，所有 DiscoveryClient 的顺序都设置为 0,。如果你想为自定义的 `DiscoveryClient` 实现设置不同的顺序，只需重写 `getOrder()` 方法，使其返回适合你设置的值即可。此外，你还可以使用属性来设置 Spring Cloud 提供的 `DiscoveryClient` 实现的顺序，例如，`ConsulDiscoveryClient`、`EurekaDiscoveryClient` 和 `ZookeeperDiscoveryClient`。为此，你只需将 `spring.cloud.{clientIdentifier}.discovery.order`（或 Eureka 的 `eureka.client.order`）属性设置为所需的值即可。


#### SimpleDiscoveryClient

如果类路径中没有由 Service-Registry 支持的 `DiscoveryClient`，则会使用 `SimpleDiscoveryClient` 实例，该实例使用属性来获取有关服务和实例的信息。

可用实例的信息应由以下格式通过属性传递：`spring.cloud.discovery.client.simple.instances.service1[0].uri=http://s11:8080`，其中 `spring.cloud.discovery.client.simple.instances` 是通用前缀，`service1` 代表相关服务的 ID，`[0]` 表示实例的索引号（如示例所示，索引从 0 开始），`uri` 的值是实例实际所在得 URI。


### ServiceRegistry

Commons 现在提供了一个 `ServiceRegistry` 接口，其中包含诸如 `register(Registration)` 和 `deregister(Registration)` 之类的方法，允许你提供自定义的注册服务。`Registration` 是一个标记接口。

以下示例展示了 `ServiceRegistry` 的使用方法：
```
@Configuration
@EnableDiscoveryClient(autoRegister=false)
public class MyConfiguration {
	private ServiceRegistry registry;
	
	public MyConfiguration(ServiceRegistry registry) {
		this.registry = registry;
	}
	
	// 通过某些外部进程调用，例如事件或自定义执行器端点
	public void register() {
		Registration registration = constructRegistration();
		this.registry.register(registration);
	}
}
```

每一个 `ServiceRegistry` 实现都有自己的 `Registry` 实现：
- `ZookeeperRegistration` 与 `ZookeeperServiceRegistry` 一起使用
- `EurekaRegistration` 与 `EurekaServiceRegistry` 一起使用
- `ConsulRegistration` 与 `ConsulServiceRegistry` 一起使用

如果你正在使用 `ServiceRegistry` 接口，则需要传递你正在使用的 `ServiceRegistry` 实现的正确 `Registry` 实现。

#### ServiceRegistry 自动注册

默认情况下，`ServiceRegistry` 实现会自动注册正在运行的服务。要禁用此行为，你可以进行如下设置：
- `@EnableDiscoveryClient(autoRegister=false)` 可永久禁用自动注册
- 通过配置 `spring.cloud.service-registry.auto-registration.enabled=false` 来禁用该行为

##### ServiceRegistry 自动注册事件

服务自动注册会触发两个事件。第一个是






