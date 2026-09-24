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

服务自动注册会触发两个事件。第一个事件名为 `InstancePreRegistrationEvent`，在服务注册之前触发。第二个事件名为 `InstanceRegisteredEvent`，在服务注册之后触发。你可以注册一个或多个 `ApplicationListener` 来监听并响应这些事件。

> 如果 `spring.cloud.service-registry.auto-registration.enabled` 设置为 `false`，则不会触发这些事件。


#### 服务注册执行器端点

Spring Cloud Commons 提供了一个 `/actuator/serviceregistry` 执行器端点。此端点依赖于 Spring 应用上下文中的 `Registration` bean。使用 GET 请求调用 `/serviceregistry` 会返回注册状态。使用 `POST` 请求并附带 JSON 请求体向同一端点发送请求会将当前注册的状态更新为新值。JSON 请求体必须包含 `status` 字段，并指定所需的值。有关允许的设置，请你参阅使用的 `ServiceRegistry` 实现的文档。了解更新状态时允许的值以及返回的状态值。例如，Eureka 支持的状态包括 `UP`、`OUT_OF_SERVICE` 和 `UNKNOWN`。


### Spring RestTemplate 作为 LoadBalancer 客户端

你可以配置 `RestTemplate` 以使用负载均衡客户端。要创建负载均衡的 `RestTemplate`，请创建一个 `RestTemplate` `@Bean` 并使用 `@LoadBalanced` 限定符。如下例所示：
```
@Configuration
public class MyConfiguration {
	@LoadBalanced
	@Bean
	RestTemplate restTemplate() {
		return new RestTemplate();  
	}
}

public class MyClass {
	@Autowired
	private RestTemplate restTemplate;
	
	public String doOtherStuff() {
	// TODO 此处代码可以精简
		String result = restTemplate.getForObject("http://stores/stores", String.class);
		return result;
	}
}
```

> `RestTempalte` bean 不再通过自动配置创建，各个应用必须自行创建。

URI 需要使用虚拟主机名（及服务名称，而非主机名）。`BlockingLoadBalancerClient` 用于创建完整的物理地址。

> 要使用负载均衡的 `RestTemplate`，你的类路径中需要包含 Spring Cloud LoadBalancer 的实现。请将 Spring Cloud LoadBalancer stater 添加到你的项目中以使用它。


#### 多个 RestTemplate 对象

如果你需要一个非负载均衡的 `RestTemplate`，请创建一个 `RestTemplate` bean 并将其注入。要访问负载均衡的 `RestTemplate`，请在创建 `@Bean` 时使用 `@LoadBalanced` 限定符，如下例所示：
```
@Configuration
public class MyConfiguration {
	@LoadBalanced
	@Bean
	RestTemplate loadBalanced() {
		return new RestTemplate();  
	}
	
	@Primary
	@Bean
	RestTemplate restTemplate() {
		return new RestTemplate();  
	}
}

public class MyClass {
	@Autowired
	private RestTemplate restTemplate;
	@Autowired
	@LoadBalanced
	private RestTemplate loadBalanced;
	
	public String doOtherStuff() {
		return loadBalanced.getForObject("http://stores/stores", String.class);
	}
	
	public String doStuff() {
		// TODO 此处代码可以优化为调用 stores，与上面对应
		return restTemplate.getForObject("http://example.com/stores", String.class);
	}
}
```

> 请注意前面示例中在普通的 `RestTemplate` 声明上使用 `@Primary` 注解，以消除未限定的 `@Autowired` 注入的歧义。

> 如果你看到类似 `java.lang.IllegalArgument`：无法将 `org.springframework.web.client.ResetTemplate` 字段 `com.my.app.Foo.restTemplate` 设置为 `com.sun.proxy.$Proxy89` 的错误，请尝试注入 `RestOptions` 或设置 `spring.aop.proxyTargetClass=true`。


### 使用 @LoadBalanced RestTemplateBuilder 创建负载均衡客户端

你还可以通过为 `RestTemplateBuilder` bean 添加 `@LoadBalanced` 注解来配置 `RestTemplate` 以使用负载均衡客户端：
```
@Configuration
public class MyConfiguration {
	@LoadBalanced
	@Bean
	RestTemplateBuilder loadBalancedRestTemplateBuilder() {
		return new RestTemplateBuilder();  
	}
}

public class MyClass {
	@Autowired
	private final RestTemplate restTemplate;	
	
	public MyClass(@LoadBalanced RestTemplateBuilder restTemplateBuilder) {
		this.restTemplate = restTemplateBuilder.build();
	}
	
	public String getStores() {
		return restTemplate.getForObject("http://stores/stores", String.class);
	}
}
```

URI 需要使用虚拟主机名（即服务名称，而非主机名）。`BlockingLoadBalancerClient` 用于创建完整的物理地址。

为了利用 Spring Boot 为 `RestTemplateBuilder` 提供的其他功能（例如，可观测性支持），你可能需要在创建 `@LoadBalanced RestTemplateBuilder` bean 时使用自动配置的 `RestTemplateBuilderConfigurer`。
```
@Configuration
public class MyConfiguration {
	// TODO 官方文档此处缺少 @Bean
	@LoadBalanced
	RestTemplateBuilder loadBalancedRestTemplateBuilder(RestTemplateBuilderConfigurer configurer) {
		return configurer.configure(new RestTemplateBuilder());  
	}
}
```

> 要使用它，请将 Spring Cloud LoadBalancer Starter 添加到你的项目中。

#### 多个 RestTemplateBuilder bean

如果你需要一个非负载均衡的 `RestTemplateBuilder`，请创建一个 `RestTemplateBuilder` bean 并将其注入。要访问负载均衡的 `RestTemplateBuilder`，请在创建 `@Bean` 时使用 `@LoadBalanced` 限定符，如下列所示：
```
@Configuration
public class MyConfiguration {
	@LoadBalanced
	@Bean
	RestTemplateBuilder loadBalancedRestTemplateBuilder() {
		return new RestTemplateBuilder();  
	}
	
	@Primary
	@Bean
	RestTemplateBuilder restTemplateBuilder() {
		return new RestTemplateBuilder();  
	}
}

public class MyClass {
	@Autowired
	private RestTemplateBuilder restTemplate;
	@Autowired
	@LoadBalanced
	private RestTemplateBuilder loadBalanced;
	
	public String doOtherStuff() {
		// TODO 官方实例中缺少 build()
		return loadBalanced.build().getForObject("http://stores/stores", String.class);
	}
	
	public String doStuff() {
		return restTemplateBuilder.build().getForObject("http://example.com/stores", String.class);
	}
}
```

> 请注意前面示例中在普通的 `RestTemplateBuilder` 声明上使用 `@Primary` 注解，以消除未限定的 `@Autowired` 注入的歧义。


### Spring RestClient 作为负载均衡客户端

你可以配置 `RestClient` 以使用负载均衡客户端。要创建负载均衡的 `RestClient`，请创建一个 `RestClient.Builder @Bean` 并使用 `@LoadBalanced` 限定符，如下例所示：
```
@Configuration
public class MyConfiguration {
	@LoadBalanced
	@Bean
	RestClient.Builder restClientBuilder() {
		return RestClient.builder();  
	}
}

public class MyClass {
	@Autowired
	private RestClient.Builder restClientBuilder;	
	
	public String doOtherStuff() {
		return restClientBuilder.build().get().uri(URI.create("http://stores/stores")).retrieve().body(String.class);
	}
}
```

URI 需要使用虚拟主机名（即服务名称，而非主机名）。`BlockingLoadBalancerClient` 用于创建完整的物理地址。

为了利用 Spring Boot 为 `RestClient.Builder` 提供的其他功能（例如，可观测性支持），你可能需要在创建 `@LoadBalanced RestClient.Builder` bean 时使用自动配置的 `RestClientBuilderConfigurer`。
```
@Configuration
public class MyConfiguration {
	@LoadBalanced
	@Bean
	RestClient.Builder restClientBuilder(RestClientBuilderConfigurer configurer) {
		return configurer.configure(RestClient.Builder());  
	}
}
```

> 要使用它，请将 Spring Cloud LoadBalancer Starter 添加到你的项目中。

#### 多个 RestClient.Builder bean

如果你需要一个非负载均衡的 `RestClient.Builder`，请创建一个 `RestClient.Builder` bean 并将其注入。要访问负载均衡的 `RestClient.Builder`，请在创建 `@Bean` 时使用 `@LoadBalanced` 限定符，如下列所示：
```
@Configuration
public class MyConfiguration {
	@LoadBalanced
	@Bean
	RestClient.Builder loadBalanced() {
		return RestClient.Builder();  
	}
	
	@Primary
	@Bean
	RestClient.Builder restClientBuilder() {
		return RestClient.Builder();  
	}
}

public class MyClass {
	@Autowired
	private RestClient.Builder restClientBuilder;
	@Autowired
	@LoadBalanced
	private RestClient.Builder loadBalanced;
	
	public String doOtherStuff() {
		return loadBalanced.build().get().uri("http://stores/stores").retrieve().body(String.class);
	}
	
	public String doStuff() {
		return restClientBuilder.build().get().uri("http://example.com/stores").retrieve().body(String.class);
	}
}
```

> 请注意前面示例中在普通的 `RestClient.Builder` 声明上使用 `@Primary` 注解，以消除未限定的 `@Autowired` 注入的歧义。


### Spring WebClient 作为负载均衡客户端

你可以配置 `WebClient` 以使用负载均衡客户端。要创建负载均衡的 `WebClient`，请创建一个 `WebClient.Builder @Bean` 并使用 `@LoadBalanced` 限定符，如下例所示：
```
@Configuration
public class MyConfiguration {
	@LoadBalanced
	@Bean
	WebClient.Builder webClientBuilder() {
		return WebClient.builder();  
	}
}

public class MyClass {
	@Autowired
	private WebClient.Builder webClientBuilder;	
	
	public Mono<String> doOtherStuff() {
		return webClientBuilder.build().get().uri("http://stores/stores").retrieve().bodyToMono(String.class);
	}
}
```

URI 需要使用虚拟主机名（即服务名称，而非主机名）。`BlockingLoadBalancerClient` 用于创建完整的物理地址。

为了利用 Spring Boot 为 `WebClient.Builder` 提供的其他功能（例如，可观测性支持），你可能需要在创建 `@LoadBalanced WebClient.Builder` bean 时使用自动配置的 `WebClientCustomizer`。
```
@Configuration
public class MyConfiguration {
	@LoadBalanced
	@Bean
	WebClient.Builder loadBalancedWebClientBuilder(ObjectProvider<WebClientCustomizer> customizerProvider) {
		WebClient.Builder builder = WebClient.Builder();
		customizerProvider.orderedStream().forEach((customizer) -> customizer.customize(builder));
		return builder;  
	}
}
```

> 如果你想要使用 `@LoadBalanced` 注解的 `WebClient.Builder`，则需要在类路径中包含 Spring Cloud LoadBalancer 的实现。我们建议你将 Spring Cloud LoadBalancer start 添加到你的项目中。这样，底层就会使用 `ReactiveLoadBalancer`。

#### 多个 WebClient.Builder 对象

如果你需要一个非负载均衡的 `WebClient.Builder`，请创建一个 `WebClient.Builder` bean 并将其注入。要访问负载均衡的 `WebClient.Builder`，请在创建 `@Bean` 时使用 `@LoadBalanced` 限定符，如下列所示：
```
@Configuration
public class MyConfiguration {
	@LoadBalanced
	@Bean
	WebClient.Builder loadBalanced() {
		return WebClient.Builder();  
	}
	
	@Primary
	@Bean
	WebClient.Builder webClientBuilder() {
		return WebClient.Builder();  
	}
}

public class MyClass {
	@Autowired
	private WebClient.Builder webClientBuilder;
	@Autowired
	@LoadBalanced
	private WebClient.Builder loadBalanced;
	
	public Mono<String> doOtherStuff() {
		return loadBalanced.build().get().uri("http://stores/stores").retrieve().body(String.class);
	}
	
	public Mono<String> doStuff() {
		return restClientBuilder.build().get().uri("http://example.com/stores").retrieve().body(String.class);
	}
}
```

#### 重试失败的请求

负载均衡的 `RestTemplate` 可以配置为重试失败的请求。默认情况下，此逻辑处于禁用状态。对于非响应式版本（使用 `RestTemplate`），你可以通过将 Spring Retry 添加到应用程序的类路径来启用它。对于响应式版本（使用 `WebTestClient` TODO 此处是否应为 WebClient），你需要设置 `spring.cloud.loadbalancer.retry.enabled=true`。

如果你想要禁用类路径中的 Spring Retry 或 Reactive Retry 的重试逻辑，你可以设置 `spring.cloud.loadbalancer.retry.enabled=false`。

对于非响应式实现，如果你想在重试中实现 `BackOffPolicy`，则需要创建一个 `LoadBalancerRetryFactory` 类型中  bean 并重写 `createBackOffPolicy()` 方法。

对于响应式实现，你只需将 `spring.cloud.loadbalancer.retry.backoff` 设置为 `false` 即可启用它。

你可以设置：
- `spring.cloud.loadbalancer.retry.maxRetriesOnSameServiceInstances` - 指示在同一 `ServiceInstance` 上应重试请求的次数（对每个选定的实例分别计数）
- `spring.cloud.loadbalancer.retry.maxRetriesOnNextServiceInstances` - 指示对新选择的 `ServiceInstance` 的重试次数
- `spring.cloud.loadbalancer.retry.retryableStatusCodes` -  始终重试失败请求的状态代码

对于响应式实现，你还可以设置 `spring.coud.loadbalancer.retry.backoff.minBackoff` - 设置最小退避持续时间（默认为5毫秒），`spring.cloud.loadbalancer.retry.backoff.maxBackoff` - 设置最大退避持续时间（默认为 毫秒的最大 Long 值），`spring.cloud.loadbalancer.retry.backoff.jitter` - 设置用于计算每次调用实际退避持续时间的抖动值（默认为0.5）。

对于响应式实现，你还可以实现自己的 `LoadBalancerRetryPolicy`，以便对负载均衡调用重试进行更详细的控制。

对于这两种实现方式，你还可以通过在 `spring.cloud.loadbalancer.[serviceId].retry.retryable-execption` 属性下添加值列表来设置触发重试的异常。如果你这样做，我们会确保将 `RetryableStatusCodeException` 添加到你提供的异常列表中，以便在遇到可重试状态码时也进行重试。如果你没有通过 属性指定任何异常，则我们默认使用的异常是 `IOException`、`TimeoutException` 和 `RetryableStatusCodeException`。你还可以通过将 `spring.cloud.loadbalancer.[serviceId].retry.retry-on-all-exceptions` 设置为 `true` 来启动对所有异常的重试。

> 如果你使用 Spring Retries 的阻塞实现，并且想要保留以前版本的行为，请将 `spring.cloud.loadbalancer.[serviceId].retry.retry-on-all-exceptions` 设置为 `false`。因为这曾经是阻塞实现的默认模式。

> 可以单独配置各个负载均衡器客户端，其属性与上述相同，只是前缀为 `spring.cloud.loadbalancer.clients.<clientId>.*`，其中`clientId` 是负载均衡器的名称。

> 对于负载均衡重试，默认情况下，我们会使用 `RetryAwareServiceInstanceSupplier` bean 包装 `ServiceInstanceListSupplier` bean，以便在有可用实例时选择与上次不同的实例。你可以通过将 `spring.cloud.loadbalancer.retry.aviodPreviousInstance` 设置为 `false` 来禁用此行为。

```
@Configuration
public class MyConfiguration {
	@Bean
	LoadBalancedRetryFactory retryFactory() {
		return new LoadBalancedRetryFactory() {
			@Override
			public BackOffPolicy createBackOffPolicy(String service) {
				return new ExponentialBackOffPolicy(service);
			}
		};  
	}
}
```

如果要向重试功能添加一个或多个 `RetryListener` 实现，则需要创建一个 `LoadBalancerRetryListenerFactory` 类型的 bean，并返回要用于给定服务的 `RetryListener` 数组，如下例所示：
```
@Configuration
public class MyConfiguration {
	@Bean
	LoadBalancedRetryListenerFactory retryListenerFactory() {
		return new LoadBalancedRetryListenerFactory() {
			@Override
			public RetryListener[] createRetryListeners(String service) {
				@Override
				public <T, E extends Throwable> boolean open(RetryContext context, RetryCallback<T,E> callback) {
					// you business..
					return true;
				}
				@Override
				public <T, E extends Throwable> void close(RetryContext context, RetryCallback<T,E> callback, Throwable throwable) {
					// you business..
				}
				@Override
				public <T, E extends Throwable> void onError(RetryContext context, RetryCallback<T,E> callback, Throwable throwable) {
					// you business..
				}
			}
		};  
	}
}
```


### Spring WebFlux 作为负载均衡客户端

Spring WebFlux 可以与响应式和非响应式 WebClient 配置一起使用。

#### Spring WebFlux `WebClient` 与 `ReactorLoadBalancerExchangeFilterFunction`

你可以配置 `WebClient` 以使用 `ReactiveLoadBalancer`。如果你将 Spring Cloud LoadBalancer starter 添加到项目中，并且 `spring-webflux` 以添加到类路径中，则 `ReactorLoadBalancerExchangeFilterFunction` 将自动配置。以下示例展示了任何配置 `WebClient` 以使用响应式负载均衡器：
```
public class MyClass {
	@Autowired
	private ReactorLoadBalancerExchangeFilterFunction lbFunction;
	
	public Mono<String> doOtherStuff() {
		return WebClient.builder().baseUrl("http://stores")
			.filter(lbFunction)
			.build()
			.get()
			.uri("/stores")
			.retrieve()
			.bodyToMono(String.class)
	}
}
```

URI 需要使用虚拟主机名（即服务名称，而非主机名）。`ReactorLoadBalancer` 用于创建完整的物理地址。


#### Spring WebFlux `WebClient` 与非响应式负载均衡客户端

如果 `spring-webflux` 已添加到类路径中，则 `LoadBalancerExchangeFilterFunction` 会自动配置。但请注意，这底层使用的是非响应式客户端。以下示例展示了如何配置 `WebClient` 以使用负载均衡器：
```
public class MyClass {
	@Autowired
	private LoadBalancerExchangeFilterFunction lbFunction;
	
	public Mono<String> doOtherStuff() {
		return WebClient.builder().baseUrl("http://stores")
			.filter(lbFunction)
			.build()
			.get()
			.uri("/stores")
			.retrieve()
			.bodyToMono(String.class)
	}
}
```

URI 需要使用虚拟主机名（即服务名称，而非主机名）。`ReactorLoadBalancer` 用于创建完整的物理地址。

> 这种方法现在已经弃用，我们推荐你使用带有响应式负载均衡器的 WebFlux。


### 忽略网络接口

有时，忽略某些指定的网络接口会很有用，这样就可以将它们从服务发现注册中排除（例如，在 Docker 容器运行时）。可以设置正则表达式列表来忽略所需的网络接口。一下配置会忽略 `docker0` 接口以及所有以 `veth` 开头的接口：
```
spring:
	cloud:
		inetutils:
			ignoredInterfacess:
				- docker0
				- veth.*
```

你也可以使用正则表达式列表强制仅使用指定的网络地址，如下例所示：
bootstrap.yml
```
spring:
	cloud:
		inetutils:
			preferredNetworks:
				- 192.168
				- 10.0
```

你还可以强制使用站点本地地址，如下例所示：
application.yml
```
spring:
	cloud:
		inetutils:
			useOnlySiteLocalInterfaces: true
```
有关站点本地地址的更多详细信息，请参阅 `Inet4Address.html.isSiteLocalAddress()`。


### 开启的功能

Spring Cloud Commons 提供了一个 `/features` 执行器端点。此端点返回类路径上可用的功能及其启用状态。返回的信息包括功能类型、名称、版本和供应商。

#### 功能类型

功能有两种类型：抽象和命名。

抽象功能是指定义了接口或抽象类，并由实现来创建的功能。例如 `DiscoveryClient`、`LoadBalancerClient`、或 `LockService`。抽象类或接口用于在上下文中查找该类型的 bean。显示的 bean 版本信息来自 `bean.getClass().getPackage().getImplementationVersion()`。

命名功能是指没有实现特定类的功能。这些功能包括：`Circuit Breaker`、`API Gateway`、`Spring Cloud Bus` 等。命名功能需要指定名称和 bean 类型。

#### 声明功能

任何模块都可以声明任意数量的 `HasFeatrue` bean，如下例所示：
```
@Bean
public HasFeatures commonsFactures() {
	return HasFeatures.abstractFeatures(DiscoveryClient.class, LoadBalancerClient.class);
}

@Bean
public HasFeatures consulFeatures() {
	return HasFeatures.namedFeatures(
		new NamedFeature("Spring Cloud Bus", ConsulBusAutoConfiguration.class),
		new NamedFeature("Circuit Breaker", HystrixCommandAspect.class),
	);
}

@Bean
HasFeatures localFeatures() {
	return HasFeatures.builder()
		.abstractFeature(Something.class)
		.namedFacture(new NamedFeature("Some Other Feature", Someother.class))
		.abstractFeature(Somethingelse.class)
		.build();
}
```

这些 bean 都应该放在经过适当保护的 `@Configuration` 中。


### Spring Cloud 兼容性验证

由于部分用户在配置 Spring Cloud 应用时遇到问题，我们决定添加兼容性验证机制。如果你的当前配置与 Spring Cloud 的要求不兼容，应用将会崩溃，并生成一份报告，详细说明具体出错的原因。

目前我们正在验证哪个版本的 Spring Boot 已经添加到你的类路径中。

报告实例：
```
***************************
APPLICATION FAILED TO START
***************************

Description:

Your project setup is incompatible with our requirements due to following reasons:

- Spring Boot [2.1.0.RELEASE] is not compatible with this Spring Cloud release train


Action:

Consider applying the following actions:

- Change Spring Boot version to one of the following versions [1.2.x, 1.3.x] .
You can find the latest Spring Boot versions here [https://spring.io/projects/spring-boot#learn].
If you want to learn more about the Spring Cloud Release train compatibility, you can visit this page [https://spring.io/projects/spring-cloud#overview] and check the [Release Trains] section.
```

要禁用此功能，请将 `spring.cloud.compatibility-verifier.enabled` 设置为 `false`。如果要覆盖兼容的 Spring Boot 版本，只需将 `spring.cloud.compatibility-verifier.compatible-boot-versions` 属性设置为逗号分割的兼容 Spring Boot 版本列表即可。


## Spring Cloud LoadBalancer

Spring Cloud 提供了自己的客户端负载均衡器抽象和实现。对于负载均衡机制，我们添加了 `ReactiveLoadBalancer` 接口，并提供了基于轮询（(**Round-Robin**）和随机（**Random**）的实现。为了从响应式 获取可供选择的实例，我们使用 `ServiceInstanceListSupplier`。目前，我们支持基于微服务的 `ServiceInstanceListSupplier` 实现，它使用类路径中提供的 Discovery Client 从服务发现中检索可用实例。

> 可以通过将 `spring.cloud.loadbalancer.enabled` 设置为 `false` 来禁用 Spring Cloud LoadBalancer。


### LoadBalancer 上下文的预加载

Spring Cloud LoadBalancer 会为每个服务 ID 创建一个独立的 Spring 子上下文。默认情况下，这些上下文会延迟初始化，仅在对某个服务 ID 的第一个请求进行负载均衡时才会初始化。

你可以选择预加载这些上下文。为此，请使用 `spring.cloud.loadbalancer.eager-load.clients` 属性指定要预先加载的服务ID，例如：
```
spring.cloud.loadbalancer.eager-load.clients[0]=my-first-client
spring.cloud.loadbalancer.eager-load.clients[0]=my-second-client
```


### 在负载均衡算法之间切换

默认使用的 `ReactiveLoadBalancer` 实现是 `RoundRobinLoadBalancer`。要切换到其他实现，无论是针对特定服务还是所有服务，都可以使用自定义的负载均衡机制。

例如，可以通过 `@LoadBalancerClient` 注解传递以下配置，以切换到使用 `RandomLoadBalancer`：
```
public class CustomLoadBalancerConfiguration {
	@Bean
	ReactorLoadBalancer<ServiceInstance> randomLoadBalancer(Environment environment,
		LoadBalancerClientFactory loadBalancerClientFactory) {
		String name = environment.getProperty(LoadBalancerClientFactory.PROPERTY_NAME);
		return new RandomLoadBalancer(loadBalancerClientFactory.getLazyProvider(name, ServiceInstance.class), name);
	}
}
```

> 你作为 `@LoadBalancerClent` 或 `@LoadBalancerClients` 配置参数传递的类要么不应该使用 `@Configuration` 注解，要么应该在组件扫描范围之外。


### Spring Cloud LoadBalancer 集成

为了方便使用 Spring Cloud LoadBalancer，我们提供了 `ReactorLoadBalancerExchangeFilterFunction`（可与 WebClient 配合使用）和 `BlockingLoadBalancerClient` （可与 `RestTemplate`  和 `RestClient` 配合使用）。

- Spring `RestTemplate` 作为负载均衡客户端
- Spring `RestClient` 作为负载均衡客户端
- Spring `WebClient` 作为负载均衡客户端 
- Spring `WebFlux WebClient` 与 `ReactorLoadBalancerExchangeFilterFunction`


### Spring Cloud LoadBalancer 缓存

除了每次需要选择实例时都通过 `DiscoveryClient` 检索实例的基本 `ServiceInstanceListSupplier` 实现之外，我们还提供了两种缓存实现。

#### 基于 Caffeine 的负载均衡器缓存实现

如果类路径中包含 `com.github.ben-manes.caffeine:caffeine`，则会使用基于 Caffeine 的实现。有关如何配置它的信息，请参阅 `LoadBalancerCacheConfiguration` 部分。

如果你正在使用 Caffeine，你还可以通过在 `spring.cloud.loadbalancer.cache.caffeine` 属性中传递你自己的 Caffeine 规范来覆盖 LoadBalancer 的默认 Caffeine Cache 设置。

> 传递你自己的 Caffeine 规范将覆盖任何其他 LoadBalancerCache 设置，包括常规 LoadBalancer Cache 配置字段，例如 `ttl` 和 `capacity`。

#### LoadBalancer 的默认缓存实现

如果类路径中没有 Caffeine，则会使用 `spring-cloud-starter-loadbalancer` 自动提供的 `DefaultLoadBalancerCache`。有关如何配置它的信息，请参阅 `LoadBalancerCacheConfiguration` 部分。

> 要使用 Caffeine 而不是默认缓存，请将 `com.github.ben-manes.caffeine:caffeine` 添加到类路径上。

#### LoadBalancer 缓存配置

你可以设置自定的 `ttl` 值（写入后条目过期的时间），以 `Duration` 格式表示，方法是将符合 Spring Boot `String` 到 `Duration` 转换器语法的 `String` 作为 `spring.cloud.loadbalancer.cache.ttl` 属性的值。你还可以通过设置 `spring.cloud.loadbalancer.cache.capacity` 属性的值来设置 `LoadBalancer` 缓存的初始容量。

默认设置包括将 `ttl` 设置为 35秒，默认的 `initCapacity` 为 256。

你可以通过将 `spring.cloud.loadbalancer.cache.enabled` 设置为 `false` 来禁用负载均衡器缓存。

> 虽然基本的非缓存实现对于原型设计和测试很有用，但其效率远低于缓存版本，因此我们建议在生产环境中始终使用缓存版本。如果 `DiscoveryClient` 实现（例如 `EurekaDiscoveryClient`）已经完成了缓存，则应禁用负载均衡器缓存，以防止重复缓存。

> 创建自己的配置时，如果使用 `CachingServiceInstanceListSupplier`，请确保将其配置在层次结构中，紧随通过网络检索实例的提供商之后，例如 `DiscoveryClientServiceInstanceListSupplier` 并且位于任何其他筛选提供商之前。


### 基于权重的负载均衡

为了实现加权负载均衡，我们提供了 `WeightedServiceInstanceListSupplier` 类。我们使用 `WeightFunction` 函数来计算每个实例的权重。默认情况下，我们会尝试从元数据映射（键为 `weight`）中读取并解析权重。

如果元数据映射中未指定权重，则此实例的默认权重为 1。

你可以通过将 `spring.cloud.loadbalancer.configurations` 的值设置为 `weighted` 来配置它，或者提供你自己的 `ServiceInstanceListSupplier` bean，例如：
```
public class CustomLoadBalancerConfiguration {
	@Bean
	public ServiceInstanceListSupplier discoveryClientServiceInstanceListSupplier(ConfigurationApplicationContext context) {
		return ServiceInstanceListSupplier.builder()
			.withDiscoveryClient()
			.withCaching()
			.withWeighted()
			.build(context);
	}
}
```

> 你也可以通过提供 `WeightFunction` 来自定义权重计算逻辑。

你可以使用此示例配置使所有实例都具有随机权重：
```
public class CustomLoadBalancerConfiguration {
	@Bean
	public ServiceInstanceListSupplier discoveryClientServiceInstanceListSupplier(ConfigurationApplicationContext context) {
		return ServiceInstanceListSupplier.builder()
			.withDiscoveryClient()
			.withCaching()
			.withWeighted(instance -> ThreadLocalRandom.current().nextInt(1, 101))
			.build(context);
	}
}
```


### 基于 zone 的负载均衡

为了实现基于区域的负载均衡，我们提供了 `ZonePreferenceServiceInstanceListSupplier`。我们使用 `DiscoveryClient` 特定的区域配置（例如，`eureka.instance.metadata-map.zone`）来选择客户端尝试筛选可用服务实例的区域。

> 你还可以通过设置 `spring.cloud.loadbalancer.zone` 属性值来覆盖  `DiscoveryClient` 特定的区域设置。

> 目前，只有 Eureka Discovery Client 支持设置 LoadBalancer 区域。对于其他发现客户端，请设置 `spring.cloud.loadbalancer.zone` 属性。更多功能即将推出。

> 要确定检索到的服务实例的区域，我们检查其元数据映射中 `zone` 键的值。

`ZonePreferenceServiceInstanceListSupplier` 会筛选检索到的实例，仅返回同一区域内的实例。如果区域为空或没有实例，则返回检索到的实例。

要使用基于区域的负载均衡方法，你需要在自定义配置中实例化 `ZonePreferenceServiceInstanceListSupplier` bean。

我们使用委托来操作 `ServiceInstanceListSupplier` bean。我们建议使用 `DiscoveryClientServiceInstanceListSupplier` 委托，并将其包装在 `CachingServiceInstanceListSupplier` 中，以利用 LoadBalancer 缓存机制，然后将生成的 bean 传递给 `ZonePreferenceServiceInstanceListSupplier` 的构造函数。

你可以使用以下示例配置进行设置：
```
public class CustomLoadBalancerConfiguration {
	@Bean
	public ServiceInstanceListSupplier discoveryClientServiceInstanceListSupplier(ConfigurationApplicationContext context) {
		return ServiceInstanceListSupplier.builder()
			.withDiscoveryClient()
			.withCaching()
			.withZonePreerence()
			.build(context);
	}
}
```


### LoadBalancer 的实例健康检查

可以为负载均衡器启用运行状态检查。为此，我们提供了 `HealthCheckServiceInstanceListSupplier` 服务。它会定期检查委托 `ServiceInstanceListSupplier` 提供的实例是否仍然存活，并且只返回存活的实例；如果没有存活的实例，则会返回所有已检索到的实例。

> 在使用 `SimpleDiscoveryClient` 时，此机制尤其有用，对于由实际服务注册中心支持的客户端，则无需使用此机制，因为我们在查询外部服务发现后即可获取运行状况良好的实例。

> 对于每个服务实例数量较少的设置，也建议使用此供应商，以避免在故障实例上重试调用。

> 如果使用任何由服务发现支持的供应商，通常不需要添加此健康检测机制，因为我们可以直接从服务注册表中检索实例的健康状态。

> `HealthCheckServiceInstanceListSupplier` 依赖于委托 Flux 提供的更新实例。在极少数情况下，如果你希望使用一个不会刷新实例的委托（即使实例列表可能会发生变化，例如我们提供的 `DiscoveryClientServiceInstanceListSupplier`），你可以将 `spring.cloud.loadbalancer.health-check.refetch-instances` 设置为 `true`。以便 `HealthCheckServiceInstanceListSupplier` 刷新实例列表。你还可以通过 `spring.cloud.loadbalancer.health-check.refetch-instances-interval` 的值来调整刷新间隔，并通过将 `spring.cloud.loadbalancer.haelth-check.repeat-health-check` 设置为 `false` 来禁用额外的健康检查重复，因为每次实例刷新都会触发一次健康检查。

`HealthCheckServiceInstanceListSupplier` 使用以 `spring.cloud.loadbalancer.health-check` 为前缀的属性。你可以为调度器设置初始延迟（`initialDelay`）和间隔（`interval`）。你可以通过设置 `spring.cloud.loadbalancer.health-check.path.default` 属性的值来设置健康检查 URL 的默认路径。你还可以通过 `spring.cloud.loadbalancer.health-check.path.[SERVICE_ID]` 属性的值来为任何给定服务设置特定值，只需将 `[SERVICE_ID]` 替换为你服务的正确 ID 即可。如果未指定 `[SERVICE_ID]`，则默认使用 `/actuator/health`。如果将 `[SERVICE_ID]` 的值设置为 `null` 或空值，则不会执行健康检查。你还可以通过设置 `spring.cloud.loadbalancer` 的值来为健康检查请求设置自定义端口。如果未设置，则使用请求的服务在服务实例上可用的端口。

> 如果你依赖默认路径 （`/actuator/health`），请确保将 `spring-boot-actuator` 添加到你的合作者的依赖项中，除非你计划自己添加此类端点。

> 默认情况下，`healthCheckFlux` 会在检索到每个存活的 `ServiceInstance` 时发出消息。你可以通过将 `spring.cloud.loadbalancer.health-check.update-results-list` 的值设置为 `false` 来修改此行为。如果此属性设置为 `false`，则会先将所有存活的实例序列收集到一个列表中，然后再发出消息，从而确保 Flux 不会在属性中设置的健康检查间隔之间发出消息。

要使用健康检查调度程序的方法，你需要在自定义配置中实例化一个 `HealthCheckServiceInstanceListSupplier` bean。

我们使用委托来操作 `ServiceInstanceListSupplier` bean。我们建议在 `HealthCheckServiceInstanceListSupplier` 的构造函数中传递一个 `DiscoveryClientServiceInstanceListSupplier` 委托。

你可以使用以下示例配置进行设置：
```java
public class CustomLoadBalancerConfiguration {
	@Bean
	public ServiceInstanceListSupplier discoveryClientServiceInstanceListSupplier(ConfigurableApplicationContext context) {
		return ServiceInstanceListSupplier.builder()
			.withDiscoveryClient()
			.withHealthChecks()
			.build(context);
	}
}
```

> 对于非响应式堆栈，请使用 `withBlockingHealthChecks()` 创建此供应者。你还可以传递自己的 `WebClient`、`RestTemplate` 和 `RestClient` 实例用于检查。

> `HealthCheckServiceInstanceListSupplier` 具有基于 Reactor Flux `replay()` 的自身缓存机制。因此，如果正在使用它，则可能需要省略使用 `CachingServiceInstanceListSupplier` 对该提供者进行包装的步骤。

> 创建自己的配置 `HealthCheckServiceInstanceListSupplier` 时，请确保将其放在层次结构中，紧随通过网络检索实例的供应商之后，例如 `DiscoveryClientServiceInstanceListSupplier` 并且位于任何其他筛选供应商之前。


### LoadBalancer 实例偏好相同

你可以设置负载均衡器，使其优先使用之前选择的实例（如果该实例可用）。

为此，你需要设置 `SameInstancePreferenceServiceInstanceListSupplier`。你可以通过将 `spring.cloud.loadbalancer.configurations` 的值设置为 `same-instance-preference` 来配置它，或者提供你自己的 `ServiceInstanceListSupplier` bean，例如：
```java
public class CustomLoadBalancerConfiguration {
	@Bean
	public ServiceInstanceListSupplier discoveryClientServiceInstanceListSupplier(ConfigurableApplicationContext context) {
		return ServiceInstanceListSupplier.builder()
			.withDiscoveryClient()
			.withSameInstancePreference()
			.build(context);
	}
}
```

> 它也是 Zookeeper `StickyRule` 的替代品。


### 基于请求的 LoadBalancer 粘性会话

你可以配置负载均衡器，使其优先使用请求 cookie 中提供的 `instanceId`对应的实例。目前，如果请求是通过 `ClientRequestContext` 或 `ServerHttpRequestContext` 传递给负载均衡器，我们支持这种配置，这些上下文 是由 SC 负载均衡器交换筛选函数和筛选器使用。

为此，你需要使用 `RequestBasedStickySessionServiceInstanceListSupplier`。你可以通过将 `spring.cloud.loadbalancer.configurations` 的值设置为 `request-based-sticky-session` 来配置它，或者提供你自己 的 `ServiceInstanceListSupplier` bean，例如：
```
public class CustomLoadBalancerConfiguration {
	@Bean
	public ServiceInstanceListSupplier discoveryClientServiceInstanceListSupplier(ConfigurableApplicationContext context) {
		return ServiceInstanceListSupplier.builder()
			.withDiscoveryClient()
			.withRequestBasedStickySession()
			.build(context);
	}
}
```

为了实现此功能，需要在转发请求之前更新所选的服务实例（如果原始请求 cookie 中实例不可用，则可以使用不同的实例）。为此，请将 `spring.cloud.loadbalancer.sticky-session.add-service-instance-cookie` 设置为 `true`。

默认情况下，cookie 的名称为 `sc-lb-instance-id`。你可以更改 `spring.cloud.loadbalancer.instance-id-cookie-name` 属性的值来修改它。

> 该 功能当前仅支持基于 WebClient 的 负载均衡。


### Spring Cloud  LoadBalancer 使用技巧

Spring Cloud  LoadBalancer 允许你设置 `String` 提示，这些提示会通过 `Request` 对象传递给 LoadBalancer，之后可以在能够处理它们的 `ReactiveLoadBalancer` 实现中使用。

你可以通过设置 `spring.cloud.loadbalancer.hint.default` 属性的值来为所有服务设置默认提示 。你还可以通过 `spring.cloud.loadbalancer.hint.[SERVICE_ID]` 属性的值来给任何给定服务设置特定提示，只需将 `[SERVICE_ID]` 替换为你服务的正确 ID 即可。如果用户未设置提示，则使用默认值。


### 基于提示的负载均衡

我们还提供了一个 `HintBasedServiceInstanceListSupplier`，它是 `ServiceInstanceListSupplier` 的一个实现，用于基于提示的实例选择。

`HintBasedServiceInstanceListSupplier` 会检查请求头（默认的标头名为 `X-SC-LB-Hint`，但你可以通过更改 `spring.cloud.balancer.hint-header-name` 属性的值来修改它），如果找到提示请求头，则使用在标头中传递的提示值来过滤服务实例。

如果没有添加提示标头，`HintBasedServiceInstanceListSupplier` 将使用属性中的提示值来筛选服务实例。

如果没有通过标头或属性设置提示，则返回委托提供的所有服务实例。

在筛选过程中，`HintBasedServiceInstanceListSupplier` 会查找元数据映射中 `hint` 键下设置了匹配值的服务实例。如果找不到匹配的实例，则返回委托提供的所有实例。

你可以使用以下示例配置进行设置：
```
public class CustomLoadBalancerConfiguration {
	@Bean
	public ServiceInstanceListSupplier discoveryClientServiceInstanceListSupplier(ConfigurableApplicationContext context) {
		return ServiceInstanceListSupplier.builder()
			.withDiscoveryClient()
			.withCaching()
			.withHints()
			.build(context);
	}
}
```


### 转换负载均衡的 HTTP 请求

你可以使用选定的 `ServiceInstance` 来转换负载均衡的 HTTP 请求。

对于 `RestTemplate` 和 `RestClient`，你需要按如下方式实现和定义 `LoadBalancerRequestTransformer`。
```
@Bean
public LoadBalancerRequestTransformer transformer() {
	return new LoadBalancerRequestTransformer() {
		@Override
		public HttpRequest transformRequest(HttpRequest request, ServiceInstance instance) {
			return new HttpRequestWrapper(request) {
				@Override
				public HttpHeaders getHeaders() {
					HttpHeaders headers = new HttpHeaders();
					headers.putAll(super.getHeaders());
					headers.add("X-InstanceId", instance.getInstanceId());
					return headers;
				}
			};
		}
	};
}
```

对于 `WebClient`，你需要按如下方式实现 `LoadBalancerClientRequestTransformer`：
```
@Bean
public LoadBalancerClientRequestTransformer transformer() {
	return new LoadBalancerClientRequestTransformer() {
		@Override
		public ClientRequest transformRequest(ClientRequest request, ServiceInstance instance) {
			return ClientRequest.from(request)
				.header("X-InstanceId", instance.getInstanceId())
				.build();
		}
	};
}
```

如果定义了多个转换器，则按照 Bean 的定义顺序应用它们。或者，你可以使用`LoadBalancerRequestTransformer.DEFAULT_ORDER` 或 `LoadBalancerClientRequestTransformer.DEFAULT_ORDER` 来指定顺序。


### Spring Cloud LoadBalancer 子集

`SubsetServiceInstanceListSupplier` 实现了一种确定性的子集算，用于在 `ServiceInstanceListSupplier` 委托层次结构中选择有限数量的实例。

你可以通过将 `spring.cloud.loadbalancer.configurations` 设置为 `subset` 或者提供你自己的 `ServiceInstanceListSupplier` bean 来进行配置，例如：
```
public class CustomLoadBalancerConfiguration {
	@Bean
	public ServiceInstanceListSupplier discoveryClientServiceInstanceListSupplier(ConfigurableApplicationContext context) {
		return ServiceInstanceListSupplier.builder()
			.withDiscoveryClient()
			.withCaching()
			.withSubset()
			.build(context);
	}
}
```

> 默认情况下，每个服务实例都会被分配一个唯一的 `instanceId`，不同的 `instanceId` 值通常会选择不同的子集。通常情况下，你无需关注这一点。但是，如果你需要多个实例选择同一子集，可以使用 `spring.cloud.loadbalancer.subset.instance-id` 进行设置（支持占位符）。

> 默认情况下，子集的大小设置为 100。你也可以使用 `spring.cloud.loadbalancer.subset.size` 来设置它。


### 基于 API 版本的负载均衡

为了实现基于 API 版本的负载均衡，我们提供了 `BlockingApiVersionServiceInstanceListSupplier` 和 `ReactiveApiVersionServiceInstanceListSupplier`，你可以根据客户端是否使用 Speing `RestClient` 或 `WebClient` 来选择使用哪个。

你可以通过将 `spring.cloud.loadbalancer.configurations` 设置为 `api-version` 或提供一个为所有或特定负载均衡器 `serviceIds` 配置了 API 版本控制的 `ServiceInstanceListSupplier` bean 来启用 API 版本控制：
```
public class CustomLoadBalancerConfiguration {
	@Bean
	public ServiceInstanceListSupplier discoveryClientServiceInstanceListSupplier(ConfigurableApplicationContext context) {
		return ServiceInstanceListSupplier.builder()
			.withDiscoveryClient()
			.withCaching()
			// 对于阻塞客户端使用 withBlockingApiVersioning()
			.withReactiveApiVersioning()
			.build(context);
	}
}
```

底层我们使用了 Spring Framework 的阻塞式和响应式 API 版本控制。请参阅框架文档，了解如何根据请求元素解析、比较和匹配版本。我们提供的负载均衡器 API 版本控制策略与默认策略的一个区别在于，我们不对版本进行验证，而是允许用户传递任何所需的版本。

要使用此功能，你需要使用 `LoadBalancerProperties.ApiVersion` 指定要从中检索版本的请求元素。通过 `spring.cloud.loadbalancer.clients.<serviceId>.api-version` 属性前缀，你可以指定用于在请求中传递所需版本的 `header`、`queryParameter`、`pathSegment`或 `mediaTypeParameters`。你还可以设置 `defaultVersion` （当请求中未传递版本时使用）以及是否传递 API 版本。

一旦启用 API 版本控制功能，并通过任何请求元素或 `defaultVersion` 提供版本，我们将在其 `metadata` 中查找设置了匹配 `API_VERSION` 的服务实例。

如果找不到任何匹配版本的服务实例，则会返回一个空的实例列表。你可以通过将 `spring.cloud.loadbalancer.clients.<serviceId>.api-version.fallbackToAvailableInstances` 设置为 `true` 来修改此行为，这样，如果找不到 API 版本匹配的实例，则会返回所有可用的实例。

> 我们使用委托来操作 `ServiceInstanceListSupplier` bean。我们建议使用 `DiscoveryClientServiceInstanceListSupplier` 委托，并将其包装在 `CachingServiceInstanceListSupplier` 中，以利用负载均衡器的委托机制，然后将生成的 bean 传递给 `ReactiveApiVersioningServiceInstanceListSupplier` 或 `BlockingApiVersioningServiceInstanceListSupplier` 的构造函数。

> 默认情况下，我们使用 `org.springframework.web.accept.SemanticApiVersionParser` 进行版本解析。你可以在上下文中提供你自己的 `ApiVersionParser` bean 来覆盖它。


### Spring Cloud LoadBalancer 启动器

我们还提供了一个入门模板，让你轻松地在 Spring Boot 应用中添加 Spring Cloud LoadBalancer。要使用它，只需将 `org.springframework.cloud:spring-cloud-starter-loadbalancer` 添加到构建文件中的 Spring Cloud 依赖项即可。

> Spring Cloud LoadBalancer 启动器包含 Spring Boot Caching 和 Evictor。


### 传递你自己的 Spring Cloud LoadBalancer 配置

你还可以使用 `@LoadBalancerClient` 注解来传递你自己的负载均衡器客户端配置，传递负载均衡器客户端的名称和配置类，如下所示：
```
@Configuration
@LoadBalancerClient(value = "stores", configuration = CustomLoadBalancerConfiguration.class)
public class MyConfiguration {
	@Bean
	@LoadBalanced
	public WebClient.Builder loadBalancedWebClientBuilder() {
		return WebClient.builder();
	}
}
```

> 为了让你更轻松地配置自己的 LoadBalancer，我们在 `ServiceInstanceListSupplier` 类中添加了 `builder()` 方法。

>  你还可以通过将 `spring.cloud.loadbalancer.configurations` 属性的值设置为 `zone-preference` 来使用带缓存的 `ZonePreferenceServiceInstanceListSupplier` 或者设置为 `health-check` 来使用带缓存的 `HealthCheckServiceInstanceListSupplier` 从而使用我们预定义的替代配置来代替默认配置。

你可以使用此功能实例化 `ServiceInstanceListSupplier` 或 `ReactorLoadBalancer` 的不同实现，这些实现是你自己编写的，也可以是我们提供的替代方案（例如 `ZonePreferenceServiceInstanceListSupplier`）以覆盖默认配置。

你可以在这里看到一个自定义配置的示例。

> 注解 `values` 参数（如上例所示 `stores`）指定了我们应该使用给定的自定义配置向其发送请求服务的服务ID。

你还可以通过 `@LoadBalancerClients` 注解传递多个配置（用于多个负载均衡器客户端），如下例所示：
```
@Configuration
@LoadBalancerClients(@LoadBalancerClient(value = "stores", configuration = StroesLoadBalancerConfiguration.class))
public class MyConfiguration {
	@Bean
	@LoadBalanced
	public WebClient.Builder loadBalancedWebClientBuilder() {
		return WebClient.builder();
	}
}
```

> 你作为 `@LoadBalancerClient` 或 `@LoadBalancerClients` 配置参数传递的类要么不应该使用 `@Configuration` 注解，要么应该在组件扫描范围之外 。

> 创建自己的配置时，如果使用 `CachingServiceInstanceListSupplier` 或 `HealthCheckServiceInstanceListSupplier`，请确保只使用其中一个，不要同时使用两个，并确保将其放置在层次结构中，紧随通过网络检索实例的提供程序之后，例如 `DiscoveryClientServiceInstanceListSupplier` ，并且位于任何其他筛选供应商之前。


### Spring Cloud LoadBalancer 生命周期

使用自定义负载均衡器配置注册的一种可能很有用的 bean 类型是 `LoadBalancerLifecycle`。

`LoadBalancerLifecycle` bean 提供了名为 `onStart(Request<RC> request)` 、`onStartRequest(Request<RC> request, Response<T> lbResponse)`、`onComplete(CompletionContext<RES, T, RC> completionContext)` 的回调方法，你应该实现这些方法来指定在负载均衡之前和之后应该执行哪些操作。
- `onStart(Request<RC> request)` 方法接受一个 `Request` 对象作为参数。该对象包含用于选择合适实例的数据，包括下游客户端请求和提示。
- `onStartRequest(Request<RC> request, Response<T> lbResponse)` 方法也接受一个 `Request` 对象以及 `Response<T>` 对象作为参数。
- `onComplete(CompletionContext<RES, T, RC> completionContext)` 方法接受一个 `CompletionContext` 对象，该对象包含负载均衡响应，其中包括选定的服务实例、针对该服务实例执行的请求的 `Status` 以及（如果可用）返回给下游客户端的响应，以及（如果发生异常）响应的 `Throwable` 对象。

`supports(Class requestContextClass, Class responseClass, Class serverTypeClass)` 方法用于确定目标处理器是否处理指定类型的对象。如果用户未重写此方法，则返回 `true`。

> 在前面的方法调用中，`RC` 标识 `RequestContext` 类型，`RES` 表示客户端响应类型，`T` 表示返回的服务器类型。


### Spring Cloud LoadBalancer 指标

我们提供了一个名为 `MicrometerStatsLoadBalancerLifecycle` 的 `LoadBalancerLifecycle` bean，它使用 `Micrometer` 为负载均衡调用提供统计信息。

要将此 bean 添加到你的应用程序上下文中，请见 `spring.cloud.loadbalancer.stats.micrometer` 的值设置为 `true`，并确保 `MeterRegistry` 可用（例如，通过向你的项目添加 Spring Boot Actuator）。

`MicrometerStatsLoadBalancerLifecycle` 在 `MeterRegistry` 中注册以下列表：
- `loadbalancer.requests.active`: Gauge，允许你监控任何服务实例当前活跃的请求数量（服务实例数据可通过标签获取）
- `loadbalancer.requests.success`: Timer，用于测量已完成并将响应传递给底层客户端的任何负载均衡请求的执行时间
- `loadbalancer.requests.failed`: Timer，用于测量任何因异常而结束的负载均衡请求的执行时间
- `loadbalancer.requests.discard`: Counter，用于衡量被丢弃的负载均衡请求的数量，及负载均衡器尚未检索到运行该请求的服务实例的请求

如有需要，会通过标签有关服务实例、请求数据和响应数据的其他信息添加到指标中。

> 对于 `WebClient` 和 `RestClient` 支持的负载均衡，我们会在可用时使用 `uriTemplate` 作为 `uri` 标签。

> 可以通过将 `spring.cloud.loadbalancer.stats.include-path` 设置为 `false` 来禁用向 `uri` 标签添加路径。

> 与基于 `RestTemplate` 的负载均衡一样，我们无法访问 `uriTemplate`，`uri` 标签中始终使用完整路径。为了避免高基数问题，如果路径的基数很高（例如，`/orders/{id}`，其中 `id` 可以取很多值），强烈建议通过将`spring.cloud.loadbalancer.stats.include-path` 设置为 `false` 来禁用向 `uri` 标签添加路径。

> 对于某些实现，例如 `BlockingLoadBalancerClient`，请求和响应数据可能不可用，因为我们从参数建立泛型类型，可能无法确定类型并读取数据。

> 当某个 meter 至少添加一条记录时，该 meter 就会被登录在册。

> 你可以通过添加 `MeterFilters` 来进一步配置这些指标的行为（例如，添加发布百位数和直方图）。


### 配置单个负载均衡器



