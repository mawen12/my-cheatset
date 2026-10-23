# 总览

Spring Cloud Task 允许用户使用 Spring Cloud 开发和运行短期微服务，并在本地、云中甚至在 Spring Coud Data Flow 上运行它们。只需添加 `@EnableTask` 并将你的应用作为 Spring Boot 应用（单个应用上下文）运行。如果你是 Spring Cloud Task 的新手，请查看我们 `https://docs.spring.io/spring-cloud-task/docs/2.0.0.RELEASE/reference/htmlsingle/#getting-started` 开始文档。



# 介绍



## 前言

本节提供了 Spring Cloud Task 参考文档的简要概述。将其视为文档其余部分的地图。你可以以线性方式阅读本参考指南，如果你不感兴趣，也可以跳过某些部分。



## 关于文档

Spring Cloud Task 参考指南以 html 形式提供。最新副本可在 [docs.spring.io/spring-cloud-task/reference/](https://docs.spring.io/spring-cloud-task/reference/) 提供。

你可以制作文档的副本提供你自己使用或分发给其他人，前提是你不能收取此类副本的任何费用，并且每份副本都包含本版权声明，无论是印刷版还是电子版形式分发。



## 获取帮助

Spring Cloud Task 遇到了问题？我们乐意提供帮助。

- 问一个问题。我们监控 `stackoverflow.com` 以查找带有 `spring-cloud-task` 标签的问题
- 在 `github.com/spring-cloud/spring-cloud-task/issues` 上报告 Spring Cloud Task 的错误。

> [!NOTE]
>
> 所有 Spring Cloud Task 都是开源的，包括文档。如果你发现文档存在问题或者只是向改进它们，请参与其中。



## 第一步

如果你刚刚开始使用 Spring Cloud Task 或一般的 "Spring"，我们建议你阅读入门章节。

要从开开始，请阅读以下部分：

- 介绍 Spring Cloud Task
- 系统需求

要学习本课程，请阅读开发你的第一个 Spring Cloud Task 应用程序。

要运行你的示例，请阅读运行示例。

版本 5.0.2



# 入门

如果你刚刚开始使用 Spring Cloud Task，你应该阅读本节。在这里，我们回答基本的 "what?"，"how?" 和 "why?" 问题。我们首先简单介绍一下 Spring Cloud Task。然后，我们构建一个 Spring Cloud Task 应用程序，并讨论一些核心原则。



## 介绍 Spring Cloud Task

Spring Cloud Task 可以轻松创建短期微服务。它提供了允许在生产环境按需执行短期 JVM 进程的功能。



## 系统要求

你需要安装 Java（JDK 17 或更高版本）。

### 数据库要求

Spring Cloud Task 使用关系数据库来存储执行任务的结果。虽然你可以在没有数据库的情况下开始开发任务（任务状态记录为任务存储库更新的一部分），但对于生产环境，你希望使用受支持的数据库。Spring Cloud Task 目前支持一下数据库：

- DB2
- H2
- HSQLDB
- MySQL
- Oracle
- Postgres
- SqlServer



# 开发你的第一个 Spring Cloud Task 应用程序

一个好的起点是简单的 "Hello, World!" 应用程序，因此我们创建 Spring Cloud Task 相当于突出框架的功能。大多数 IDE 对 Apache Maven 都有很好的支持，因此我们使用它作为该项目的构建工具。

> [!NOTE]
>
> spring.io 网站包含许多使用 Spring Boot 的 `Getting Started`指南。如果你需要解决特定问题，请先检查那里。你可以通过转到 Spring Initializr 并创建一个新项目来简化以下步骤。这样做会自动生成一个新项目结构，以便你可以立即开始编码。我们建议尝试使用 Spring Initializr 以属性它。

## 使用 Spring Initializr 创建 Spring Task 项目

现在我们可以创建并测试一个打印 `Hello, World` 到控制台的应用程序。

为此：

1. 访问 Spring Initialize 网站
   1. 创建一个新的 Maveb 项目，其 `Group` 名称为 `io.spring.demo`，`Artifact` 名为 `helloworld`
   2. 在依赖项文本框中，输入 `task`，然后选择带有 `Spring Cloud` 标签的 `Task` 依赖项
   3. 在依赖项文本框中，输入 `h2`，然后选择带有 `SQL` 标签的 `H2` 依赖项
   4. 点击 **Generate Project** 按钮
2. 解压 helloworld.zip 文件并将项目导入到你最喜欢的 IDE 中

## 编写代码

为了完成我们的应用程序，我们需要使用以下内容更新生成的 `HelloworldApplication`，以便它启动任务。

```java
@SpringBootApplication
@Task
public class HelloworldApplication {
  @Bean
  public ApplicationRunner applicationRunner() {
    return new HelloWorldApplicationRunner();
  }
  
  public static void main(String[] args) {
    SpringApplication.run(HelloworldApplication.class, args);
  }
  
  public static class HelloWorldApplicationRunner implements ApplicationRunner {
    @Override
    public void run(ApplicationArguments args) throws Exception {
      System.out.println("Hello, World!")
    }
  } 
}
```

虽然看起来很小，但正在发生很多事情。有关 Spring Boot 详细信息，请参阅 Spring Boot 参考文档。

现在我们可以打开 `src/main/resources` 中的  `application.properties` 文件。我们需要在 `application.properties` 中配置两个属性：

- `application.name`：设置应用名称（翻译为任务名称）
- `logging.level`：将 Spring Cloud Task 日志记录设置为 `DEBUG`，以便了解正在发生的情况

以下示例展示了如何同时执行这两项操作：

```properties
logging.level.org.springframework.cloud.task=DEBUG
spring.application.name=helloworld
```

### Task 自动配置

当包含 Spring Cloud Task 启动器依赖项时，Task 自动配置所有 bean 以引导其功能。此配置的一部分注册 `TaskRepository` 以其使用的基础设施。

 在我们的示例中，`TaskRepository` 使用嵌入式 `H2` 数据库来记录任务的结果。这个 H2 嵌入式数据库对于生产环境来说不是一个实用的解决方案，因为一旦任务结束，H2 数据库就会消失。但是，为了获得快速入门体验，我们可以在示例中使用它，并回显该存储库中正在更新的内容到日志。在配置部分（本文档后面）中，我们介绍了如何自定义 Spring Cloud Task 提供的各个部分的配置。

当我们的示例应用程序运行时，Spring Boot 启动我们的 `HelloWorldApplicationRunner` 并输出我们的 "Hello, World!" 消息到标准输出。`TaskLifecycleListener` 在存储库记录任务的开始和结束。

### main 方法

main 方法充当任何 java 应用程序的入口点。我们的主要方法委托给 Spring Boot 的 SpringApplication 类。

### ApplicationRunner

Spring 包含众多引导应用程序逻辑的方法。Spring Boot 通过其 `*Runner` 接口（`CommandLineRunner` 或 `ApplicationRunner`）提供了一种有组织的方式执行此操作的便捷方法。行为良好的任务可以通过使用这两个运行程序之一来引导任何逻辑。

任务的生命周期是从执行 `*Runner#run` 方法之前到它们全部完成之后考虑的。Spring Boot 允许应用程序使用多个 `*Runner` 实现，Spring Cloud Task 也是如此。

> [!NOTE]
>
> Spring Cloud Task 不会记录从 `CommandLineRunner` 或 `ApplicationRunner` 以外的机制引导的任何处理（例如通过使用 `InitializingBean#afterPropertiesSet`）。



## 运行示例

此时，我们的应用程序应该可以工作了。由于此应用程序是基于 Spring Boot 的，因此 `$ ./mvn2 spring-boot:run` 从应用程序的根目录运行它，如以下示例所示（及其输出）：

```bash
$ mvn clean spring-boot:run
....... . . .
....... . . . (Maven log output here)
....... . . .

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::                (v3.3.0)

2024-01-04T10:07:01.102-06:00  INFO 18248 --- [helloWorld] [           main] i.s.d.helloworld.HelloworldApplication   : Starting HelloworldApplication using Java 21.0.1 with PID 18248 (/Users/dashaun/fun/dashaun/spring-cloud-task/helloworld/target/classes started by dashaun in /Users/dashaun/fun/dashaun/spring-cloud-task/helloworld)
2024-01-04T10:07:01.103-06:00  INFO 18248 --- [helloWorld] [           main] i.s.d.helloworld.HelloworldApplication   : No active profile set, falling back to 1 default profile: "default"
2024-01-04T10:07:01.526-06:00  INFO 18248 --- [helloWorld] [           main] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Starting...
2024-01-04T10:07:01.626-06:00  INFO 18248 --- [helloWorld] [           main] com.zaxxer.hikari.pool.HikariPool        : HikariPool-1 - Added connection conn0: url=jdbc:h2:mem:3ad913f8-59ce-4785-bf8e-d6335dff6856 user=SA
2024-01-04T10:07:01.627-06:00  INFO 18248 --- [helloWorld] [           main] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Start completed.
2024-01-04T10:07:01.633-06:00 DEBUG 18248 --- [helloWorld] [           main] o.s.c.t.c.SimpleTaskAutoConfiguration    : Using org.springframework.cloud.task.configuration.DefaultTaskConfigurer TaskConfigurer
2024-01-04T10:07:01.633-06:00 DEBUG 18248 --- [helloWorld] [           main] o.s.c.t.c.DefaultTaskConfigurer          : No EntityManager was found, using DataSourceTransactionManager
2024-01-04T10:07:01.639-06:00 DEBUG 18248 --- [helloWorld] [           main] o.s.c.t.r.s.TaskRepositoryInitializer    : Initializing task schema for h2 database
2024-01-04T10:07:01.772-06:00 DEBUG 18248 --- [helloWorld] [           main] o.s.c.t.r.support.SimpleTaskRepository   : Creating: TaskExecution{executionId=0, parentExecutionId=null, exitCode=null, taskName='helloWorld', startTime=2024-01-04T10:07:01.757268, endTime=null, exitMessage='null', externalExecutionId='null', errorMessage='null', arguments=[]}
2024-01-04T10:07:01.785-06:00  INFO 18248 --- [helloWorld] [           main] i.s.d.helloworld.HelloworldApplication   : Started HelloworldApplication in 0.853 seconds (process running for 1.029)
Hello, World!
2024-01-04T10:07:01.794-06:00 DEBUG 18248 --- [helloWorld] [           main] o.s.c.t.r.support.SimpleTaskRepository   : Updating: TaskExecution with executionId=1 with the following {exitCode=0, endTime=2024-01-04T10:07:01.787112, exitMessage='null', errorMessage='null'}
2024-01-04T10:07:01.799-06:00  INFO 18248 --- [helloWorld] [ionShutdownHook] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Shutdown initiated...
2024-01-04T10:07:01.806-06:00  INFO 18248 --- [helloWorld] [ionShutdownHook] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Shutdown completed.
```

前面的输出中有三行是我们感兴趣的：

- `SimpleTaskRepository` 记录了 `TaskRepository` 中条目的创建
- 我们的 `ApplicationRunner` 的执行，通过 "Hello, World!" 来演示输出
- `SimpleTaskRepository` 在 `TaskRepository` 中记录了任务的完成情况

> [!NOTE]
>
> 可以在 Spring Cloud Task 项目的示例默认中找到一个简单的 Task 应用程序。



# 功能

本节将更详细地介绍 Spring Cloud Task 包括如何使用它、如何配置它以及适当的扩展点。



## Spring Cloud Task 的生命周期

在大多数情况下，现在云环境是围绕执行预计不会结束的进程而设计的。如果它们确实结束，通常会重新启动。虽然大多数平台确实有某种方式来运行一个进程，该进程在结束时不会重新启动，但该运行的结果通常不会以可消耗的方式维护。Spring Cloud Task 提供了在环境中执行短期进程并记录结果的能力。这样做可以通过消息集成任务来围绕短期流程以及长期运行的服务建立微服务架构。

虽然此功能在云环境中很有用，但在传统部署模型中也可能出现相同的问题。当使用 cron 等调度程序运行 Spring Boot 应用程序时，能够在应用程序完成后监视其结果会很有用。

Spring Cloud Task 采用的方法是 Spring Boot 应用程序可以有开始和结束，并且仍然成功。批处理应用程序是预期结束（通常是短暂的）进程如何发挥作用的示例之一。

Spring Cloud Task 记录给定任务的生命周期事件。大多数长时间运行的进程（以大多数 Web 应用程序为代表）不会保存其生命周期事件。Spring Cloud Task 的核心任务就是这样做的。

生命周期由单个任务执行组成。这是配置为任务的 Spring Boot 应用程序的物理执行（即，它具有 Spring Cloud 任务依赖项）。

在任务开始时，在运行任务 `CommandLindRunner` 或 `ApplicationRunner` 实现之前，会在 `TaskRepository` 中创建一个记录启动事件的条目。该事件是通过 Spring 框架触发的 `SmartLifecycle#start` 来触发的。这向系统表明所有 bean 都已准备好使用，并且在运行 Spring Boot 提供的任何 `CommandLineRunner` 或 `ApplicationRunner` 实现之前出现。

> [!note]
>
> 任务的记录仅在成功引导 `ApplicationContext` 时发生。如果上下文根本无法引导，则不会记录任务的执行。

当 Spring Boot 完成所有 `*Runner#run` 调用或 `ApplicationContext` 失败（由 `ApplicationFailedEvent` 指示）时，任务执行将在存储库中更新结果。

> [!note]
>
> 如果应用程序要求在任务完成时关闭 `ApplicationContext`（所有 `*Runner#run` 方法都已被调用并且任务存储库已更新），请将属性 `spring.cloud.task.closecontextEnabled` 设置为 `true`。

### TaskExecution

存储在 `TaskRepository`中的信息在 `TaskExecution` 类中建模，并包含以下信息：

| 字段           | 描述                                                         |
| -------------- | ------------------------------------------------------------ |
| `executionId`  | 任务运行的唯一 ID                                            |
| `exitCode`     | 从 `ExitCodeExceptionMapper` 实现生成的退出代码。如果没有生成退出代码但抛出了 `ApplicationFailedEvent`，则设置为 1，否则，假定为 0 |
| `taskName`     | 任务的名称，有配置的 `TaskNameResolver` 确定                 |
| `startTime`    | 任务开始的时间，由 `SmartLifecycle#start` 调用指示           |
| `endTime`      | 任务结束的时间，有 `ApplicationReadyEvent` 指示              |
| `exitMessage`  | 退出时可用的任何信息。这可以通过 `TaskExecutionListener` 以编程方式设置 |
| `errorMessage` | 如果异常是任务结束的原因（如 `ApplicationFailedEvent` 所示），则该异常的堆栈跟踪存储在此处 |
| `arguments`    | 传递到可执行引应用程序时的字符串命令行参数的 `List`          |

### 映射 Exit Codes

当任务完成时，它会尝试向操作系统返回退出代码。如果我们看一下原来的示例，我们可以看到我们没有控制应用程序的这方面。因此，如果抛出异常，JVM 将返回一段代码，该代码可能对你的调试有任何用处，也可能没有用处。

因此，Spring Boot 提供了一个接口 `ExitCodeExceptionMapper`，可以让你将未捕获的异常映射到退出代码。这样做可以让你在退出代码级别指示出了什么问题。此外。通过以这种方式映射退出代码，Spring Cloud Task 记录返回的退出代码。

如果任务以 SIG-INT 或 SIG-TERM 终止，则退出代码为零，除非代码中另有指定。

> [!note]
>
> 当任务运行时，退出代码在存储库中存储为 null。任务完成后，将根据本节前面描述的准则存储适当的退出代码。



## 配置

Spring Cloud Task 提供了即用型配置，如 `DefaultTaskConfigurer` 和 `SimpleTaskConfiguration` 类中所定义。本节将介绍默认配置以及如何根据你的需求自定义 Spring Cloud Task。

### DataSource

Spring Cloud Task 使用数据源来存储任务执行的结果。默认情况下，我们提供 H2 的内存实例，以提供简单的引导开发方法。但是，在生产环境中，你可能希望配置自己的 `DataSource`。

如果你的应用程序仅使用单个数据源，并且它即充当业务模式又充当任务存储库，那么你所需要做的就是提供任何数据源（最简单的方法是通过 Spring Boot 的配置约定）。Spring Cloud Task 自动将此数据源用于存储库。

如果你的应用程序使用多个数据源，你需要使用适当的数据源陪字号任务存储库。这种定制可以通过 `TaskConfigurer` 的实现来完成。

### Table Prefix

`TaskRepository` 的一项可修改属性是任务表的表前缀。默认情况下，它们都以 `TASK_` 开头。`TASK_EXECUTION` 和 `TASK_EXECUTION_PARAMS` 是两个示例。但是，修改此前缀有潜在的原因。如果模式名称需要添加到表名称前面，或者同一模式中需要多组任务表，则必须更改表前缀。你可以通过将 `spring.cloud.task.tablePrefix` 设置为你需要的前缀实现此目的，如下所示：

```properties
spring.cloud.task.tablePrefix=yourPrefix
```

通过使用 `spring.cloud.task.tablePrefix`，用户承担创建满足任务表架构标准的任务表的责任，但需要根据用户的业务需求进行修改。在创建你自己的任务 DDL 时，你可以使用 Spring Cloud Task 架构 DDL 作为指南，如此处所示。

### 打开/关闭表初始化

如果你要创建任务表并且不希望 Spring Cloud Task 在任务启动时创建它们，请将 `spring.cloud.task.initialize-enabled` 属性设置为 `false`，如下所示：

```properties
spring.cloud.task.initialize-enabled=false
```

默认值为 `true`。

> [!NOTE]
>
> `spring.cloud.task.initialize.enable` 属性已经过期。

### 外部生成的任务 ID

在某些情况下，你可能需要考虑任务与基础架构实际启动任务之间的时间差。Spring Cloud Task 允许你在请求任务时创建 `TaskExecution`。然后将生成的 `TaskExecute` 的执行 ID 传递给任务，以便它可以在任务的生命周期中更新 `TaskExecution`。

可以通过在引用保存 `TaskExecution` 的实现上调用 `createTaskExecution` 方法来创建 `TaskExecution`。

为了将你的任务配置为使用生成的 `TaskExecutonId`，请添加以下属性：

```properties
spring.cloud.task.executionid=yourtaskid
```

### 外部任务 ID

Spring Cloud Task 允许你为每个 `TaskExecution` 存储外部任务 ID。为了将你的任务配置为使用生成的 `TaskExecutionId`，请添加以下属性：

```properties
spring.cloud.task.external-execution-id=<externalTaskId>
```

### 父级任务 ID

Spring Cloud Task 允许你存储每个 `TaskExecution` 的父任务 ID。例如，一个任务执行另一个或多个任务，并且你想要记录哪个任务启动了每个子任务。为了配置你的任务以设置父 `TaskExecutionId`，请在子任务上添加以下属性：

```properties
spring.cloud.task.parent-execution-id=<parentExecutionTaskId>
```

### TaskConfigurer

`TaskConfigurer` 是一个策略接口，可让你自定义 Spring Cloud Task 组件的配置方式。默认情况下，我们提供的 `DefaultTaskConfigurer` 提供逻辑默认值：基于映射的内存组件（如果未提供 `DataSource`，则对开发有用）和基于 JDBC 的组件（如果有可用的 `DataSource`，则使用）。

`TaskConfigurer` 允许你配置三个主要组件：

| 组件                         | 描述                                                         | 默认（由 `DefaultTaskConfigurer` 提供）                      |
| ---------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| `TaskRepository`             | 要使用的 `TaskRepository` 的实现                             | `SimpleTaskRepository`                                       |
| `TaskExplorer`               | 要使用的 `TaskExplorer` （用于只读访问任务存储库的组件）的实现 | `SimpleTaskExplorer`                                         |
| `PlatformTransactionManager` | 运行任务更新时使用的事务管理器                               | `JdbcTransactionManagerDataSource` （如果使用数据源）。`ResourcelessTransactionManager`（如果不是） |

你可以通过创建 `TaskConfigurer` 接口的自定义实现来自定义上表中描述的任何组件。通常，扩展 `DefaultTaskConfigurer` （如果未找到 `TaskConfigurer` 则提供）并覆盖所需的 getter 就足够了。但是，可能需要从头开始实现你自己的。

> [!note]
>
> 用户不应该直接使用 `TaskConfigurer` 中的 getter 方法，除非他们使用它来提供要作为 Spring Bean 公开的实现。

### Task Execution Listener

`TaskExecutionListener` 允许你注册任务生命周期期间发生的特定事件的监听器。为此，请创建一个实现 `TaskExecutionListener` 接口的类。实现 `TaskExecutionListener` 接口的类会收到以下事件的通知。

- `onTaskStartup`：在将 `TaskExecution` 存储到 `TaskRepository` 之前
- `onTaskEnd`：在更新 `TaskRepository` 中的 `TaskExecution` 条目并标记任务的最终状态之前
- `onTaskFailed`：当任务抛出为处理的异常时，在调用 `onTaskEnd` 方法之前

Spring Cloud Task 还允许你使用以下方法注解将 `TaskExecutionListener` 添加到 bean 内的方法：

- `@BeforeTask`：在将 `TaskExecution` 存储到 `TaskRepository` 之前
- `@AfterTask`：在更新 `TaskRepository` 中的 `TaskExecution` 条目并标记任务的最终状态之前
- `@FailedTask`：当任务抛出为处理的异常时，在调用 `onTaskEnd` 方法之前

以下示例显示了正在使用的三个注解：

```java
public class MyBean {
  @BeforeTask
  public void methodA(TaskExecution taskExecution) {
  }
  
  @AfterTask
  public void methodB(TaskExecution taskExecution) {
  }
  
  @FailedTask
  public void methodC(TaskExecution taskExecution, Throwable throwable) {
  }
}
  
```

> [!note]
>
> 在链中早于 `TaskLifecycleListener` 插入 `ApplicationListener` 可能会导致意外的影响。

#### Task Execution Listener 抛出的异常

如果 `TaskExecutionListener` 事件处理程序引发异常，则该事件处理程序的所有监听器都会停止。例如，如果三个 `onTaskStartup` 监听器已启动，并且第一个 `onTaskStartup` 事件处理程序引发异常，则不会调用其他两个 `onTaskStartup` 方法。但是，会调用 `TaskExecutionListener` 的其他事件处理程序（`onTaskEnd` 和 `onTaskFailed`）。

`TaskExecutionListener` 事件处理程序引发异常时返回的退出代码时 `ExitCodeEvent` 报告的退出代码。如果没有发出 `ExitCodeEvent`，则会评估抛出的异常以查看它是否为 `ExitCodeGenerator` 类型。如果是，则它从 `ExitCodeGenerator` 返回退出代码。否则，返回 1。

如果在 `onTaskStartup` 方法中引发异常，则应用程序的退出代码将为 1。如果在 `onTaskEnd` 或 `onTaskFailed` 方法中引发异常，则应用程序的退出代码将是使用上面列举的规则建立的退出代码。

> [!note]
>
> 如果在 `onTaskStartup`、`onTaskEnd` 或 `onTaskFailed` 中引发异常，则无法使用 `ExitCodeExceptionMapper` 覆盖应用程序的退出代码。

#### Exit Messages

你可以使用 `TaskExecutionListener` 以编程方式设置任务的退出消息。这是通过设置 `TaskExecution` 的 `exitMessage` 来完成的，然后将其传递到 `TaskExecutionListener` 中。以下示例提供了使用 `@AfterTask` 注解的 `ExecutionListener`  示例：

```java
@AfterTask
public void afterMe(TaskExecution taskExecution) {
	taskExecution.setExitMesssage("AFTER EXIT MESSAGE");
}
```

可以在任何监听器事件（`onTaskStartup`、`onTaskFailed` 和 `onTaskEnd`）处设置 `ExitMessage`，这三个监听器的优先顺序如下：

1. `onTaskEnd`
2. `onTaskFailed`
3. `onTaskStartup`

例如，如果你为 `onTaskStartup` 和 `onTaskFailed` 监听器设置 `exitMessage`，并且任务结束且未为失败，则来自 `onTaskStartup` 的 `exitMessage` 将存储在存储库中。否则，如果发生失败，则会存储来自 `onTaskFailed` 的  `exitMessage`。此外。如果你使用 `onTaskEnd` 监听器设置 `exitMessage`，则 `onTaskEnd` 中的 `exitMessage` 将取代 `onTaskStartup` 和 `onTaskFailed` 中的 `exitMessage`。

### 限制 Spring Cloud Task 实例

Spring Cloud Task 允许你确定一次只能运行一个具有给定任务名称的任务。为此，你需要建立任务名称并为每个任务执行设置 `spring.cloud.task.single-instance-enabled=true`。当第一个任务执行正在运行时，任何其他时间你尝试运行具有相同任务名称和 `spring.cloud.task.single-instance-enabled=true` 的任务时，该任务都会失败并显示以下错误消息：`名称为 "application" 的任务已在运行`。`spring.cloud.task.single-instance-enabled` 的默认值为 `false`，以下示例显示如何将 `spring.cloud.task.single-instance-enabled` 设置为 `true`：

```properties
spring.cloud.task.single-instance-enabled=true or false
```

要启用此功能，你必须将以下 Spring Integration 依赖项添加到你的应用程序中：

```xml
<dependency>
	<groupId>org.springframework.integration</groupId>
  <artifactId>spring-integration-core</artifactId>
</dependency>
<dependency>
	<groupId>org.springframework.integration</groupId>
  <artifactId>spring-integration-jdbc</artifactId>
</dependency>
```

> [!note] 
>
> 如果由于启用此功能并且另一个任务正在使用相同名称运行而导致任务失败，则应用程序的退出码为 1。

#### Spring AOT 与原生编译的单实例应用

要在创建原生编译的应用程序时使用 Spring Cloud Task 的单实例功能，你需要在构建时启用该功能。为此，请添加 process-aot 执行并将 `spring.cloud.task.single-step-instance-enabled=true` 设置为 JVM 参数，如下所示：

```xml
<plugin>
	<groupId>org.springframework.boot</groupId>
  <artifactId>spring-boo-maven-plugin</artifactId>
  <executions>
    <execution>
    	<id>process-aot</id>
      <goals>
      	<goal>process-aot</goal>
      </goals>
      <configuration>
      	<jvmArguments>
        	-Dspring.cloud.task.single-instance-enabled=true
        </jvmArguments>
      </configuration>
    </execution>
  </executions>
</plugin>
```

### 启用 ApplicationRunner 和 CommandLineRunner 的观测

要为 `ApplicationRunner` 和 `CommandLineRunner` 启用任务观测，请将 `spring.cloud.task.observation.enabled` 设置为 `true`。

可以在此处找到具有观测功能的示例任务应用程序，可以使用 `SimpleMeterRegistry`。

### 禁用 Spring Cloud Task 自动配置

如果 Spring Cloud Task 不应自动配置实现，，你可以禁用 Task 的自动配置。这可以通过将以下注解添加到你的 Task 应用程序来完成：

```java
@EnableAutoConfiguration(exclude={SimpleTaskAutoConfiguration.class})
```

你也可以通过将 `spring.cloud.task.autoconfiguration.enabled` 设置为 `false` 来禁用 Task 自动配置。

### 关闭 Context

如果应用程序要求在 Task 完成时关闭 `ApplicationContext`（所有 `*Runner#run` 方法已被调用并且 `TaskRepository` 已更新），请将属性 `spring.cloud.task.closecontextEnabled` 设置为 `true`。

关闭上下文的另一种情况时 Task 执行完成但应用程序未终止时。在这些情况下，上下文保持打开状态，因为已分配线程（例如：如果你正在使用 `TaskExecutor`）。在这些情况下，启动任务时将 `spring.cloud.task.closecontextEnabled` 属性设置为 `true`。一旦任务完成，这将关闭应用程序的上下文。从而允许应用程序终止。

### 启用任务指标

Spring Cloud Task 与 Micrometer 集成并为其执行的任务创建观测。要启用任务可观测性集成，你必须将 `spring-boot-starter-actuator`、你首选的注册表实现（如果你想发布指标）和 `micrometer-tracing` （如果你想要发布追踪数据）添加到你的应用程序。使用 Influx 启用任务可观测性和指标的 Maven 依赖项示例集如下：

```
<dependency>
	<groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
<dependency>
	<groupId>io.micrometer</groupId>
  <artifactId>micrometer-registry-influx</artifactId>
  <scope>runtime</scope>
</dependency>
```

### Spring Task 与 Spring Cloud Task 属性

`task` 一词是业界常用的词。在一个这样的示例中，Spring Boot 提供 `spring.task`，而 Spring Cloud Task 提供 `spring.cloud.task` 属性。这在过去引起了一些混乱，认为这两组属性是直接相关的。然而，它们代表了 Spring 生态系统中提供的两组不同的功能。

- `spring.task` 指的是配置 `ThreadPoolTaskScheduler` 的属性
- `spring.cloud.task` 是指配置 Spring Cloud Task 功能的属性



# Batch

本节将更详细地介绍 Spring Cloud Task 与 Spring Batch 的集成。以及跟踪作业执行与其所在任务之间的关联。



## 将 Job Execution 与其执行的 Task 关联起来

Spring Boot 提供了在 Spring Boot Uber-jar 中执行批处理 Job 的工具。Spring Boot 对此功能的支持使开发人员可以在该执行中执行多个批处理 Job。Spring Cloud Task 提供了将 Job 的执行（一次 job 执行）与 Task 的执行关联起来的能力，以便可以追溯到另一个。

Spring Cloud Task 通过使用 `TaskBatchExecutionListener` 来实现此功能。默认情况下，此监听器在任何配置了 Spring Batch Job （通过在上下文中定义 Job 类型的 bean）和类路径上的 `spring-cloud-task-batch` jar 的上下文中自动配置。监听器被注入到满足这些条件的所有 Job 中。

### 覆盖 TaskBatchExecutionListener

为了防止监听器被注入到当前上下文中的任何批处理 Job 中，你可以使用标准 Spring Boot 机制禁用自动配置。

要仅将监听器注入到上下文中的特定 Job 中，请重写 `batchTaskExecutionListenerBeanPostProcessor` 然后提供 Job bean 的 ID 列表，如以下示例所示：

```java
public static TaskBatchExecutionListenerBeanPostProcessor batchTaskExecutionListenerBeanPostProcessor() {
	TaskBatchExecutionListenerBeanPostProcessor postProcessor = new TaskBatchExecutionListenerBeanPostProcessor();
	
  postProcessor.SetJobNames(Arrays.asList(new String[]{"job1", "job2"}));
  
  return postProcessor;
}
```

> [!note]
>
> 你可以在此处的 Spring Cloud Task 项目的示例模块中找到一个批处理应用程序示例，链接在此。



## 批量信息性消息

Spring Cloud Task 允许批处理 Job 发出信息性消息。"Spring Batch Events" 部分详细介绍了此功能。



## 批量 Job 退出码

如前所述，Spring Cloud Task 应用程序支持记录任务执行的退出码功能。但是，如果你在任务中运行 Spring Batch Hob，则无论批处理 Job 执行如何完成，在使用默认批处理/引导行为时，Task 的结果始终为零。请记住，Task 是启动应用程序，并且从 Task 返回的退出码与启动应用程序相同。要覆盖此行为并允许 Task 在批处理 Job 返回  `BatchStatus=FAILED`  时返回非零的退出码，请将 `spring.cloud.task.batch.fail-on-job-failure` 设置为 `true`。那么退出码可以是 1（默认）或者基于指定的 `ExitCodeGenerator`。

此功能使用新的 `ApplicationRunner` 来替换 Spring Boot 提供的 `ApplicationRunner`。默认情况下，配置顺序相同。但是，如果你想自定义 `ApplicationRunner` 的运行顺序，可以通过设置 `spring.cloud.task.batch.applicationRunnerOrder` 属性来设置其顺序。要让你的 Task 根据批处理 Job 的结果返回退出码，你需要编写自己的 `CommandLineRunner`。



# 单步批处理 Job 启动器

本节介绍如何使用 Spring Cloud Task 中包含的启动器通过单个步骤开发 Spring Boot Batch Job。此启动器允许你使用配置来定义 `ItemReader`、`itemWriter` 或完整的单步 Spring Batch Job。有关 Spring Batch 将其功能的更多信息，请参阅 Spring Batch 文档。

要获取 Maven 的启动器，请将以下内容添加到你的构建中：

```xml
<dependency>
	<groupId>org.springframework.cloud</groupId>
  <artifactId>spring-cloud-starter-single-step-batch-job</artifactId>
  <version>2.3.0</version>
</dependency>
```

要获取 Gradle 的启动器，请将以下内容添加到你的构建中：

```groovy
compile "org.springframework.cloud:spring-cloud-starter-single-step-batch-job:2.3.0"
```



## 定义 Job

你可以使用启动器来定义少至 `ItemReader` 或 `ItemWriter` 或多至完整的 Job。在本节中，我们定义需要定义哪些属性来配置 Job。

### 属性

首先，启动器提供了一组属性，让你可以通过一个步骤配置 Job 的基础：

*表 1：Job 属性*

| 属性                         | 类型      | 默认值 | 描述                     |
| ---------------------------- | --------- | ------ | ------------------------ |
| `spring.batch.job.jobName`   | `String`  | `null` | Job 的名称               |
| `spring.batch.job.stepName`  | `String`  | `null` | Step 的名称              |
| `spring.batch.job.chunkSize` | `Integer` | `null` | 每笔交易要处理的项目数量 |

配置上述属性后，你就拥有了一个具有单个基于块的 Step 的 Job。这个基于块的 Step 读取、处理和写入 `Map<String, Object>` 实例作为项目。但是，该步骤尚未执行任何操作。你需要配置一个`ItemReader`、一个可选的 `ItemProcessor` 和一个 `ItemWriter` 来让它做一些事情。要配置其中之一，你可以使用属性并配置提供自动配置的选项之一，也可以使用标准 Spring 配置机制来配置你自己的选项。

> [!note]
>
> 如果你配置自己的输入和输出类型，则输入和输出类型必须与 Step 中的其他类型匹配。本入门中的 `ItemReader` 实现和 `ItemWriter` 实现都使用 `Map<String, Object>` 作为输入和输出项。



## ItemReader 实现类的自动配置

此启动器为四种不同的 `ItemReader` 实现提供自动配置：`AmqpItemReader`、`FlatFileItemReader`、`JdbcCursorItemReader` 和 `KafkaItemReader`。在本节中，我们概述如何使用提供的自动配置来配置其中一个。

### AmqpItemReader

你可以使用 `AmqpItemReader` 从 AMQP 的队列或主题中读取数据。此 `ItemReader` 实现的自动配置取决于两组配置。第一个是 `AmqpTemplate` 的配置。你可以自动配置或使用 Spring Boot 提供的自动配置。配置 `AmqpTemplate` 后，你可以通过设置以下属性来启动批处理功能以支持它：

*表 2：AmqpItemReader 属性*

| 属性                                                   | 类型      | 默认值  | 描述                                                     |
| ------------------------------------------------------ | --------- | ------- | -------------------------------------------------------- |
| `spring.batch.job.amqpitemreader.enabled`              | `boolean` | `false` | 如果为 `true`，将执行自动配置                            |
| `spring.batch.job.amqpitemreader.jsonConverterEnabled` | `boolean` | `true`  | 指示是否应注册 `Jackson2JsonMessageConverter` 来解析消息 |

有关更多信息，请参阅 `AmqpItemReader` 文档。

### FlatFileItemReader

`FlatFileItemReader` 允许你读取平面文件（例如 CSV 和其他文件格式）。要读取文件，你可以通过正常的 Spring 配置自动提供一些组件（`LineTokenizer`、`RecordSeparatorPolicy`、`FieldSetMapper`、`LineMapper` 和 `SkippedLinesCallback`）。你还可以使用以下属性来配置读取器：

*表 3：FlatFileItemReader 属性*

| 属性                                                   | 类型            | 默认值                                           | 描述                                                         |
| ------------------------------------------------------ | --------------- | ------------------------------------------------ | ------------------------------------------------------------ |
| `spring.batch.job.flatfileitemreader.saveState`        | `boolean`       | `true`                                           | 确定是否应保存状态以供冲重新启动                             |
| `spring.batch.job.flatfileitemreader.name`             | `string`        | `null`                                           | 用于在 `ExecutionContext` 中提供的唯一键的名称               |
| `spring.batch.job.flatfileitemreader.maxItemCount`     | `int`           | `Integer.MAX_VALUE`                              | 从文件中读取的最大元素数                                     |
| `spring.batch.job.flatfileitemreader.currentItemCount` | `int`           | 0                                                | 已度的元素数，用于重新启动                                   |
| `spring.batch.job.flatfileitemreader.comments`         | `List<String>`  | empty list                                       | 指示文件中注释行（要忽略的行）的字符串列表                   |
| `spring.batch.job.flatfileitemreader.resource`         | `Resource`      | `null`                                           | 要读取的资源                                                 |
| `spring.batch.job.flatfileitemreader.strict`           | `boolean`       | `true`                                           | 如果设置为 `true`，则如果未找到资源，读取器将引发异常        |
| `spring.batch.job.flatfileitemreader.encoding`         | `String`        | `FlatFileItemReader.DEFAULT_CHARSET`             | 读取文件时使用的编码                                         |
| `spring.batch.job.flatfileitemreader.linesToSkip`      | `int`           | 0                                                | 指示在文件开头要跳过的行数                                   |
| `spring.batch.job.flatfileitemreader.delimited`        | `boolean`       | `false`                                          | 指示文件是否为分隔文件（CSV 或其他格式）。此属性和 `spring.batch.job.flatfileitemreader.fixedLength` 只能有一个为 `true` |
| `spring.batch.job.flatfileitemreader.delimiter`        | `String`        | `DelimitedLineToken.DELIMITER_COMMA`             | 如果读取分隔文件，则指示要解析的分隔符                       |
| `spring.batch.job.flatfileitemreader.quoteCharacter`   | `char`          | `DelimitedLinkTokenizer.DEFAULT_QUOTE_CHARACTER` | 用于确定用于引用值的字符                                     |
| `spring.batch.job.flatfileitemreader.includedFields`   | `List<Integer>` | empty list                                       | 索引列表，用于确定记录中的哪些字段要包含在项目中             |
| `spring.batch.job.flatfileitemreader.fixedLength`      | `boolean`       | `false`                                          | 指示文件的记录是否按列号解析。此属性和 `spring.batch.job.flatfileitemreader.delimite` 只能有一个为 `true` |
| `spring.batch.job.flatfileitemreader.ranges`           | `List<Range>`   | empty list                                       | 用于解析固定宽度记录的列范围列表。请参阅范围文档。           |
| `spring.batch.job.flatfileitemreader.names`            | `String[]`      | `null`                                           | 从记录中解析的每个字段的名称列表，这些名称是从此 `ItemReader` 返回的项目中的 `Map<String, Object>` 中的键 |
| `spring.batch.job.flatfileitemreader.parsingStrict`    | `boolean`       | `true`                                           | 如果设置为 `true`，则如果字段无法映射，则映射失败            |

请参阅 `FlatFileItemReader` 文档。

### JdbcCursorItemReader

`JdbcCursorItemReader` 针对关系数据库运行查询并迭代结果游标（`ResultSet`）以提供结果项。此自动配置允许你提供 `PreparedStatementSetter`、`RowMapper` 或两者。你还可以使用以下属性来配置 `JdbcCursorItemReader`：

*表 4：JdbcCursorItemReader*

| 属性                                                         | 类型      | 默认值              | 描述                                                         |
| ------------------------------------------------------------ | --------- | ------------------- | ------------------------------------------------------------ |
| `spring.batch.job.jdbccursoritemreader.saveState`            | `boolean` | `true`              | 确定是否应保存状态以供重新启动                               |
| `spring.batch.job.jdbccursoritemreader.name`                 | `String`  | `null`              | 用于在 `ExecutuonContext` 中提供唯一的名称                   |
| `spring.batch.job.jdbccursoritemreader.maxItemCount`         | `int`     | `Integer.MAX_VALUE` | 从文件中读取的最大项目数                                     |
| `spring.batch.job.jdbccursoritemreader.currentItemCount`     | `int`     | 0                   | 已读的项目数，用于重新启动                                   |
| `spring.batch.job.jdbccursoritemreader.fetchSize`            | `int`     | // TODO 可能有值    | 向驱动程序发出指示，指示每次调用数据库系统要检索多少条记录。为了获得最佳性能，你通常系统将其设置为匹配块大小 |
| `spring.batch.job.jdbccursoritemreader.maxRows`              | `int`     | // TODO 可能有值    | 从数据库读取的最大元素数                                     |
| `spring.batch.job.jdbccursoritemreader.queryTimeout`         | `int`     | // TODO 可能有值    | 查询超时的毫秒数                                             |
| `spring.batch.job.jdbccursoritemreader.ignoreWarnings`       | `boolean` | `true`              | 确定读者在处理时是否应忽略 SQL 警告                          |
| `spring.batch.job.jdbccursoritemreader.verifyCursorPosition` | `boolean` | `true`              | 指示每次读取后是否应验证游标的位置，以验证 `RowMapper` 没有使用游标前进 |
| `spring.batch.job.jdbccursoritemreader.driverSupportsAbsolute` | `boolean` | `false`             | 指示驱动程序是否支持游标的绝对定位                           |
| `spring.batch.job.jdbccursoritemreader.useSharedExtendedConnection` | `boolean` | `false`             | 指示连接是否与其他处理共享（因此是事务的一部分）             |
| `spring.batch.job.jdbccursoritemreader.sql`                  | `String`  | `null`              | 从中读取的 SQL 查询                                          |

你还可以使用以下属性专门为读取器指定 JDBC 数据源：`JdbcCursorItemReader` 属性

| 属性                                                         | 类型      | 默认值  | 描述                                            |
| ------------------------------------------------------------ | --------- | ------- | ----------------------------------------------- |
| `spring.batch.job.jdbccursoritemreader.datasource.enable`    | `boolean` | `false` | 确定是否应启用 `JdbcCursorItemReaderDataSource` |
| `spring.batch.job.jdbccursoritemreader.datasource.url`       | `String`  | `null`  | 数据库的 JDBC 路径                              |
| `spring.batch.job.jdbccursoritemreader.datasource.username`  | `String`  | `null`  | 数据库的登录用户名                              |
| `spring.batch.job.jdbccursoritemreader.datasource.password`  | `String`  | `null`  | 数据库的登录密码                                |
| `spring.batch.job.jdbccursoritemreader.datasource.driver-class-name` | `String`  | `null`  | JDBC 驱动程序的完全限定名称                     |

> [!note]
>
> 如果未指定 `jdbccursoritemreader_datasource`，// TODO 此处应为小写 Jdbc 开头 则 `JDBCCursorItemReader` 将使用默认数据源。

请参阅 `JdbcCursorItemReader` 文档。

### KafkaItemReader

从 Kafka 主题中提取数据分区非常有用，这正是 `KafkaItemReader` 的功能。要配置 `KafkaItemReader`，需要两项配置。首先，需要两项配置。首先，需要使用 Spring Boot 的 Kafka 自动配置来配置 Kafka（请参阅 Spring Boot Kafka 文档）。从 Spring Boot 配置 Kafka 属性后，你可以通过设置以下属性来配置 `KafkaItemReader` 本身：

*表 5：KafkaItemReader 属性*

| 属性                                                    | 类型            | 默认值     | 描述                                         |
| ------------------------------------------------------- | --------------- | ---------- | -------------------------------------------- |
| `spring.batch.job.kafkaitemreader.name`                 | `String`        | `null`     | 用于在 `ExecutionContext` 中提供唯一键的名称 |
| `spring.batch.job.kafkaitemreader.topic`                | `String`        | `null`     | 要读取的主题的名称                           |
| `spring.batch.job.kafkaitemreader.partitions`           | `List<Integer>` | empty list | 要从中读取的分区索引列表                     |
| `spring.batch.job.kafkaitemreader.pollTimeOutInSeconds` | `long`          | 30         | `poll()` 操作超时时间                        |
| `spring.batch.job.kafkaitemreader.saveState`            | `boolean`       | `true`     | 确定是否应保存状态以供重新启动               |

请参阅 `KafkaItemReader` 文档。

### 原生编译

单步批处理的优点是，当你使用 JVM 时，它允许你在运行时动态选择要使用的读取器和写入器 bean。但是，当你使用原生编译时，你必须在构建时而不是运行时确定读取器和写入器。以下示例执行此操作：

```xml
<plugin>
	<groupId>org.sprinframework.boot</groupId>
  <aritfactId>spring-boot-maven-plugin</aritfactId>
  <executions>
  	<execution>
    	<id>process-aot</id>
      <goals>
      	<goal>process-aot</goal>
      </goals>
      <configuration>
      	<jvmArguments>
        	-Dspring.batch.job.flatfileitemreader.name=fooReader
          -Dspring.batch.job.flatfileitemwriter.name=fooWriter
        </jvmArguments>
      </configuration>
    </execution>
  </executions>
</plugin>
```



## ItemProcessor 配置

单步批处理 Job 自动配置接受 `ItemProcessor`（如果 `ApplicationContext` 中可用）。如果找到正确的类型（`ItemProcessor<Map<String, Object>，Map<String, Object>>`），则会将器自动连接到步骤中。



## ItemWriter 实现类的自动配置

此启动器为与支持的 `ItemReader` 实现相匹配的 `ItemWriter` 实现提供自动配置：`AmqpWriter`、`FlatFileItemWriter`、`JdbcItemWriter` 和 `KafkaItemWriter`。本节介绍如何使用自动配置来配置受支持的 `ItemWriter`。

### AmqpItemWriter

要写入 RabbitMQ 队列，你需要两组配置。首先，你需要一个 `AmqpTemplate`。最简单的方法是使用 Spring Boot  的 RabbitMQ 自动配置。请参阅 Spring Boot AMQP 文档。

配置 `AmqpTempalte` 后，你可以通过设置以下属性来配置 `AmqpItemWriter`：

*表 6：AmqpItemWriter 属性*

| 属性                                                   | 类型      | 默认值  | 描述                                                     |
| ------------------------------------------------------ | --------- | ------- | -------------------------------------------------------- |
| `spring.batch.job.ampqitemwrtier.enabled`              | `boolean` | `false` | 如果为 `true`，则自动配置运行                            |
| `spring.batch.job.ampqitemwrtier.jsonConverterEnabled` | `boolean` | `true`  | 指示是否应注册 `Jackson2JsonMessageConverter` 来转换消息 |



