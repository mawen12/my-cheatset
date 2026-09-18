# Spring AI

> spring.io/projects/spring-ai

## 概述

Spring AI 是一个面向人工智能工程的应用框架。它的目标是将 Spring 生态系统的设计原则（例如可移植和模块化设计）应用于人工智能领域，
并推广使用 POJO 作为人工智能领域应用程序的构建模块。

Spring AI 从 LangChain 和 LlamaIndex 等知名的 Python 项目中汲取灵感。当 Spring AI 并非是这些项目的直接移植。该项目创立的初衷是，下一代人工智能应用不仅面向 Python 开发者，还将广泛应用于多种编程语言。

Spring AI 的核心在于解决 AI 集成的根本挑战：将企业数据和 APIs 与 AI 模型连接起来。

## 功能

Spring AI 提供以下功能：
    - 支持所有主流大模型提供商，例如 Authropic、OpenAI、Microsoft、Amazon、Google 和 Ollama。
    支持的模型类型包含：
        - Chat Completion（聊天完善）
        - Embedding（嵌入）
        - Text to Image（文本转图像）
        - Audio Transcription（语音转换）
        - Text to Speech（文本转语音）
        - Moderation（审核）
    - 支持跨 AI 提供商的可移植 API，包括同步 API 和流式 API 选项。同时还提供对特定模型功能的访问。
    - 结构化输出 - 将 AI 模型输出映射到 POJO。
    - 支持所有主流向量数据库提供商，例如 Apache Cassandra、Azure Vector Search、Chroma、Milvus、MongoDB Atlas、Neo4j、Oracle、PostgreSQL/PGVector、PineCone、Qdrant、Redis 和 Weaviate。
    - 跨向量存储提供商的可移植 API，包括一种新颖的类似 SQL 的元数据筛选 API。
    - 工具/函数调用 - 允许模型请求执行客户端工具和函数，从而根据需要访问必要的实时信息。
    - 可观测性 - 提供有关人工智能相关操作的洞察。
    - 用于数据工程的文档注入式 ETL 框架。
    - AI 模型评估 - 用于帮助评估生成的内容并防止产生幻觉反应的实用程序。
    - ChatClient API - 用于与 AI 聊天模型通信的 Fluent API，其惯用方式与 WebClient 和 RestClient API 类似。
    - Advisors API - 封装了重复出现的生成式 AI 模式，转换发送到语言模型（LLM）和从语言模型（LLM）发送的数据，并提供了跨各种模型和用例的可移植性。
    - 支持聊天对话记忆和检索增强生成（RAG）。
    - Spring Boot 自动配置和启动器适用于所有 AI 模型和向量存储 - 使用 [start.spring.io](start.spring.io) 选择所需的模型或向量存储。

## 快速开始

1. 使用 Spring AI OpenAI 启动器依赖创建 Spring Boot 项目。
2. 在 application.properties 中配置 OpenAI key
```properties
spring.ai.openai.key=<YOUR OPENAI_KEY>
```
3. 添加一下代码到 SpringAiDemoApplication
```java
@Bean
public CommandLineRunner runner(ChatClient.Builder builder) {
    return args -> {
        CharClient chatClient = builder.build();
        String response = chatClient.prompt("Tell me a joke").call().content();
        System.out.println(response);
    };
}
```
4.运行应用
```bash
.mvnw spring-boot-run
```

## AI 概念

介绍了 Spring AI 使用的核心概念。我们建议您仔细阅读，以了解 Spring AI 的实现思路。

### 模型

人工智能模型是旨在处理和生成信息的算法，通常模仿人类的认知功能。通过学习大型数据集中的模式和洞察，这些模型可以进行预测、生成文本、图像或其他输出，从而增强各行各业的各种应用。

人工智能模型种类繁多，每种模型都适用于特定的应用场景。ChatGPT 及其生成式人工智能功能通过文本输入输出吸引了众多用户，但许多其他模型和公司也提供了多样化的输入输出方式。在 ChatGPT 出现之前，许多人对 Midourney 和 Stable Diffusion 等文本到图像生成模型非常着迷。

下表根据输入输出类型对几种模型:
| 输入数据类型 | 生成式 AI 模型规范 | 输出数据类型 |
| --- | --- | --- |
| 语言/代码（多模态：图像、音频、视频） | 大语言模型（LLM）| 语言/代码（多模态：音频）| 
| 语言/图像 | 图片生成模型 | 图片/视频 |
| 语言 | 文本转语音模型 | 音频 |
| 音频 | 语音转文本模型 | 语言 |
| 文本/图像/音频/视频 | 嵌入模型 | 向量/嵌入 |

Spring AI 目前支持以语言、图像和音频为输入和输出的模型。上述表中最后一行接受文本作为输入并输出数字，这通常被称为嵌入文本，它代表了 AI 模型中使用的内部数据结构。Spring AI 支持嵌入，从而可以实现更高级的应用场景。

GPT 等模型的独特之处在于其预训练特性，正如 GPT 中的 "P" 所示 - Chat Generatvie Pre-trained Transformer（聊天生成预训练 Transformer）。这种预训练特性将人工智能转变为一种通用的开发者工具，无需深厚的机器学习或模型训练背景。

### 提示词

提示词是语言输入的基础，它引导人工智能模型生成特定的输出。对于熟悉 ChatGPT 的用户来说，提示词可能看起来只是输入到对话框中发送到 API 的文本。然而，它的含义不止于此。在许多人工智能模型中，提示文本并非简单的字符串。

ChatGPT 的 API 在提示信息中包含多个文本输入框，每个输入框都被赋予一个角色。例如系统角色用于告知模型如何运行并设置交互上下文。用户角色通常代表用户的输入。

设计有效的提示语既是一门艺术，也是一门科学。ChatGPT 的设计初衷就是为了模拟人与人之间的对话。这与使用 SQL 之类的代码"提问"截然不同。用户必须向与真人交谈一样与 AI 模型进行沟通。

这种互动方式的重要性不言而喻，"提示工程"也因此发展称为一门独立的学科。目前涌现出大量能够提升提示效果的技巧。投入时间精心设计提示，可以显著改善最终的产出效果。

共享提示词已称为一种普遍做法，并且学术界也正积极开展相关的研究。举例来说，创建有效的提示语可能与直觉相悖（例如：与 SQL 形成对比），最近的一篇研究论文发现，最有效的提示语之一以"深呼吸，一步一步来"开头。这应该能让你明白语言为何如此重要。我们尚未完全了解如何最有效地利用该技术的先前版本，例如 ChatGPT 3.5，更不用说正在开发的新版本了。

#### 提示模板

创建有效的提示包括确定请求的上下文，并将请求中的部分内容替换为用户输入的特定值。

此过程使用传统的基于文本的模板引擎来创建和管理提示，Spring AI 为此采用了开源库 StringTempalte。

例如，考虑以下简单的提示模板：
```
Tell me a {adjective} joke about {content}.
```
在 Spring AI 中，提示模板可以类比于 Spring MVC 架构图中的"视图"。模板中会提供一个模型对象(通常是 java.util.Map)，用于填充占位符。渲染后的字符串将作为提示内容提供给 AI 模型。

发送给模型的提示数据格式存在相当大的差异，最初只是简单的字符串，后来提示逐渐演变为多条消息，每条消息中的每个字符串都代表模型的一个不同角色。

### 嵌入

嵌入是文本、图像或视频的数值表示，他捕捉输入之间的关系。

嵌入的工作原理是将文本、图像和视频转换为浮点数数组，称为向量。这些向量旨在捕捉文本、图像和视频的含义。嵌入数组的长度被称为向量的维度。

通过计算两段文本的向量表示之间的数值距离，应用程序可以确定用于生成嵌入向量的对象之间的相似性。

作为一名探索人工智能的 Java 开发者，无需理解复杂的数学理论或这些向量表示背后的具体实现。只需基本了解它们在人工智能系统中的作用和功能即可，尤其是在将人工智能功能集成到应用程序时。

嵌入在诸如检索增强生成(RAG)模式等实际应用中尤为重要。它们能够将数据表示为语义空间中的点，这类似于欧几里得几何的二维空间，但维度更高。这意味着，就像欧几里得几何中平面上的点可以根据其坐标相近或相远一样，在语义空间中，点的接近程序反映了语义上的相似性。这种相似性有助于文本分类，语义搜索甚至于产品推荐等任务，因为它使人工智能能够根据相关概念在扩展的语义环境的"位置"来识别和分组这些概念。

你可以把这个语义空间想象成一个向量。

### Token

Token是人工智能模型运行的基本组成部分。模型在输入时将单词转换为Token，在输出时将Token转换为单词。

在英语中，一个Token大约相当于一个单词的75%。作为参考，莎士比亚的全部作品，总计约90万个单词，相当于大约120万个Token。

或许更重要的是，Token等于货币。在托管式人工智能模型的背景下，您的费用取决于所使用的Token数量。输入和输出都会记入Token总数。

此外，模型还受到Token限制，该限制规定了单次 API 调用中处理的文本量。此阈值通常被称为"上下文窗口"。模型不会处理超出此限制的任何文本。

例如，ChatGPT3 的Token上限为4K，而 GPT4 提供不同的选项，例如 8K、16K 和 32K。Anthropic 的 Claude AI 模型具有 100K 的Token上限，而 Meta 最近的研究成果则产生了一个Token上限为 1M 的模型。

要使用 GPT-4 对莎士比亚全集进行概括，你需要设计软件工程策略来分割数据，并将其呈现在模型的上下文窗口范围内。Spring AI 项目可以帮助你完成这项任务。

### 结构化输出

即使您要求以 JSON 格式返回结果，AI 模型的输出通常也是以 `java.lang.String` 的形式返回。虽然它可能是正确的 JSON 格式，但它并非 JSON 数据格式，而只是一个字符串。此外，在提示中要求 "JSON" 也非完全准确。

这种复杂性催生了一个专门领域，该领域设计创建提示以产生预期的输出，然后将生成的简单字符串转换为可用于应用程序集成的数据结构。

结构化输出转换采用精心设计的提示，通常需要与模型进行多次交互才能达到所需的格式。

### 将您的数据和 API 引入 AI 模型

如何让模型掌握它未曾训练过的信息？

请注意：GPT 3.5/4.0 数据集仅更新至2021年9月。因此，对于需要了解该日期之后信息的问题，模型标识无法回答。值得一提的是，该数据集的大小约为 650GB。

目前有三种方法可以定制 AI 模型以整合您的数据：
    - 微调：这种传统的机器学习技术涉及对模型进行调整并改变其内部权重。然而，对于机器学习专家来说，这是一个具有挑战性的过程，而且对于像 GPT 这样规模庞大的模型来说，这会消耗大量的资源。此外，某些模型可能不提供此选项。
    - 提示填充：一种更实用的方法是将数据嵌入到提供给给模型的提示中。考虑到模型词元数量的限制，需要一些技术手段才能在模型的上下文窗口中呈现相关数据。这种方法俗称"提示填充"。Spring AI 库可以帮助您实现基于"提示填充"技术的解决方案，该技术也称为检索增强生成(RAG)。
    - 工具调用：此技术允许注册工具（用户自定义服务），将大型语言模型连接到外部系统的 API。Spring AI 大大简化了支持工具调用所需的代码编写。

#### 检索增强生成（Retrieval Augmented Generation）

一种名为检索增强生成(RAG)的技术应运而生，旨在解决将相关数据融入提示信息以获取准确人工模型响应的挑战。

该方法采用批处理式编程模型，作业从文档中读取非结构化数据，对其进行转换，然后将其写入向量数据库，对其进行转换，然后将其写入向量数据库。从宏观层面来看，这是一个ETL（提取、转换、加载）管道。向量数据库用于 RAG 技术的检索部分。

在将非结构化数据加载到矢量数据库的过程中，最重要的转换之一是将原始文档分割为更小的部分。将原始文档分割成更小部分的过程中包含两个重要步骤：
    1. 将文档拆分成多个部分，同时保持内容的语义边界。例如：对于包含段落和表格的文档，应避免在段落或表格中间拆分文档。对于代码，应避免在方法实现过程中拆分代码。
    2. 将文档的各个部分进一步拆分成若干部分，每个部分的大小应为 AI 模型Token限制的一小部分。

RAG 的下一阶段是处理用户输入。当用户的问题需要由 AI 模型回答时，问题及其所有"相似"的文档片段会被放入发送给 AI 模型的提示框中。这就是使用向量数据库的原因。向量数据库非常擅长查找相似内容。
    - ETL 管道提供了有关协调从数据源提取数据并将其存储在结构化向量存储中的流程更多信息，确保数据在传递给 AI 模型时处于最佳检索格式。
    - ChatClient - RAG 解释了如何使用 `QuestionAnswerAdvisor` 在应用程序中启用 RAG 功能。

#### 工具调用

大型模型语言（LLM）在训练后会被冻结，导致知识过时，并且无法访问或修改外部数据。

工具调用机制旨在解决这些不足。它允许您将自己的服务注册为工具，从而将大型语言模型连接到外部系统的API。这些系统可以为大型语言模型提供实时数据，并代表它们执行数据处理操作。

Spring AI 大大简化了您为支持工具调用而需要编写的代码。它会自动处理工具调用过程。您可以将工具作为带有 `@Tool` 注解的方法提供，并在提示选项中指定，使其可供模型使用。此外，您还可以在单个提示中定义和引用多个工具。
    1. 当我们想让模型可以使用某个工具时，我们会将其定义包含在聊天中。每个工具定义都包含名称、描述和输入参数的模式。
    2. 当模型决定调用某个工具时，它会发送一个响应，其中包含工具名称和根据已定义模式建模的输入参数。
    3. 该应用程序负责使用工具名称来识别和执行该工具，并根据提供的输入参数进行操作。
    4. 工具调用的结果应用程序处理。
    5. 应用程序将工具调用结果发送回模型。
    6. 该模型使用工具调用结果作为附加上下文生成最终响应。

有关如何将此功能与不同的 AI 模型结合使用的更多信息，请参阅工具调用文档。

### 评估 AI 响应

有效地评估人工智能系统对用户请求的响应输出对于确保最终应用程序的准确性和实用性至关重要。一些新兴技术使得利用预训练模型本身来实现这一目的成为可能。

此评估过程包括分析生成的响应是否符合用户的意图和查询上下文。相关性、连贯性和实施准确性等指标用于衡量人工智能生成的响应的质量。

一种方法是将用户的请求和 AI 模型的响应都呈现给模型，并查询响应是否与提供的数据一致。

此外，利用存储在向量数据库中的信息作为补充数据可以增强评估过程，有助于确定响应相关性。

Spring AI 项目提供了一个评估器 API，目前提供用于评估模型响应的基本策略。更多信息请参考评估测试文档。

## 入门

本节提供使用 Spring AI 的入门指南。

您应根据自身需求，按照一下各部分中的步骤进行操作。

> Spring AI 2.0.x 支持 Spring Boot 4.0.x 和 4.1.x。

### Spring 初始化器

前往 [start.spring.io](start.spring.io) 选择您想在新应用程序中使用的 AI 模型和向量存储。

### 制品仓库

#### Release - 使用 Maven Central

Spring AI 的构件已经发布zai Maven Central 上。无需额外的仓库配置。只需确保你的构建文件中已启用 Maven Central 即可。

```
<repositories>
    <repository>
        <id>central</id>
        <url>https://repo.maven.apache.org/maven2</url>
    </repository>
</repositories>
```

#### Snapshots - 添加 Snapshots 仓库

要使用最新的开发版本（例如 2.0.0-SNAPSHOT），您需要在构建文件中添加以下快照存储库。

将以下仓库定义添加到您的 Maven 或 Gradle 构建文件中：
```
<repositories>
    <repository>
        <id>spring-snapshots</id>
        <name>Spring Snapshots</name>
        <url>https://repo.spring.io/snapshot</url>
        <releases>
            <enabled>false</enabled>
        </releases>
    </repository>
    <repository>
        <id>central-portal-snapshots</id>
        <name>Central Portal Snapshots</name>
        <url>https://central.sonatype.com/repository/maven-snapshots</url>
        <releases>
            <enabled>false</enabled>
        </releases>
        <snapshots>
            <enabled>true</enabled>
        </snapshots>
    </repository>
</repositories>
```

注意：在使用 Maven 和 Spring AI 快照版本时，请注意 Maven 镜像配置。如果您已经在 settings.xml 中配置了镜像，如下所示：
```
<mirror>
    <id>my-mirror</id>
    <mirrorOf>*</mirrorOf>
    <url>htts://my-company-repository.com/maven</url>
</mirror>
```

通配符 * 会将所有仓库请求重定向到您的镜像，从而阻止对 Spring 快照仓库的访问。要解决此问题，请修改 mirrorOf 的配置以排除 Spring 仓库：
```
<mirror>
    <id>my-mirror</id>
    <mirrorOf>*,!spring-snapshots,!central-portal-snapshots</mirrorOf>
    <url>htts://my-company-repository.com/maven</url>
</mirror>
```
此配置允许 Maven 直接访问 Spring 快照存储库，同时仍然使用您的镜像来获取其他依赖项。

### 依赖管理

Spring AI 的物料清单（BOM）声明了特定 Spring AI 版本所使用的所有依赖项的推荐版本。这是一个仅包含 BOM 的版本，它只包含依赖项管理，不包含任何插件声明或对 Spring 或 Spring Boot 的直接引用。您可以使用 Spring Boot 的 BOM （spring-boot-dependencies）来管理 Spring Boot 版本。

添加 BOM 到您的项目：
```
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.springframework.ai</groupId>
            <artifactId>spring-ai-bom</artifactId>
            <version>2.0.0</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

### 为特定组件添加依赖

文档中的以下每个部分都说明了你需要向项目构建系统中添加哪些依赖项。
- Chat Models
- Embeddings Models
- Image Generation Models
- Transcription Models
- Text-To-Speech(TTS) Models
- Vector Databases


### Spring AI 示例

请参阅此页面以获取更多与 Spring AI 相关的资源和示例。

## Chat Client API

`ChatClient` 提供一个流畅的 API，用于与 AI 模型进行通信。它支持同步和流式编程模型。

> 请参阅文档底部的实现说明，了解有关在 ChatClient 中结合使用命令式和响应式的编程模型的信息。

流畅的 API 提供了用于构建提示信息组成部分的各种方法，该提示信息将作为输入传递给 AI 模型。提示信息包含指导 AI 模型输出和行为的指令文本。从 API 的角度来看，提示信息由一系列消息组成。

AI 模型处理两种主要类型的信息：用户消息（即用户直接输入的消息）和系统消息（即系统生成的用于引导对话的信息）。

这些消息经常包含占位符，这些占位符会在运行时根据用户输入进行替换，以定制 AI 模型对用户输入的响应。

还可以指定提示选项，例如要使用的 AI 模型名称和控制生成输出的随机性或创造性的温度设置。

### 创建一个 ChatClient

`ChatClient` 是通过 `ChatClient.Builder` 对象创建的。您可以为任何 Spring Boot 的 ChatModel 自动配置获取一个自动配置的 `ChatClient.Builder` 实例，也可以通过编程方式去创建一个。

#### 使用自动配置的 ChatClient.Builder

在最简单的使用场景中，Spring AI 提供 Spring Boot 自动配置功能，它会创建一个 ChatClient.Builder bean 原型供您注入到类中。以下是一个从简单用户请求中获取字符串响应的简单实例。

```
@RestController
class MyController {
    private final ChatClient chatClient;

    public MyController(ChatClient.Builder chatClientBuilder) {
        this.chatClient = chatClientBuilder.build();
    }

    @GetMapping("/ai")
    String generation(String userInput) {
        return this.chatClient.prompt()
            .user(userInput)
            .call()
            .content();
    }
}
```

在这个简单的例子中，用户输入决定了用户消息的内容。call() 方法向 AI 模型发送请求，content() 方法返回 AI 模型的响应字符串。

#### 使用多种聊天模型

在以下几种情况下，您可能需要在单个应用程序中使用多个聊天模型：
- 针对不同类型的任务使用不同的模型（例如：对于复杂的推理任务使用功能强大的模型，对于较简单的任务使用速度更快、成本更低的模型）
- 当某个模型服务不可用时，实现备用机制
- A/B 测试不同的模型或配置
- 根据用户的喜好，为其提供多种型号选择
- 结合专用模型（一个用于代码生成、另一个用于创意内容生成等）

默认情况下，Spring AI 会自动配置一个 ChatClient.Builder bean。但是，您的应用程序可能需要使用多个聊天模型，以下是处理这种情况的方法：

##### 具有单一模型类型的 ChatClients

本节介绍一个常见用例，即需要创建多个 ChatClient 实例，这些实例都使用相同的底层模型类型，但配置不同。您可以使用自动配置的 ChatClient.Builder，因为它是原型作用域的，这意味着每个注入点都会创建一个新实例：

```
@Configuration
class ChatClientConfig {
    @Bean
    ChatClient defaultChatClient(ChatClient.Builder builder) {
        return builder.build();
    }

    @Bean
    ChatClient customChatClient(ChatClient.Builder builder) {
        return builder.defaultSystem("You are a helpful assistant.").build();
    }
}
```

##### 适用于不同模型类型的 ChatClients

当使用多个 AI 模型时，您可能会通过 `ChatClient.create(chatModel)` 或 `ChatClient.builder(chatModel)` 来定义单独的 `ChatClient` bean。但是，这样做会绕过自动配置的 `ChatClient.Builder`，这意味着可观察性和 `ChatClientBuilderCustomizer` bean 将被忽略。

为了保留可观察性和自定义功能，您应该注入 `ChatClientBuilderConfigurer` 来创建自定义构建器。`ChatClientBuilderConfigurer` 会应用所有已注册的 `ChatClientBuilderCustomizer` bean 并配置可观测性，其内部实现与自动配置相同。

当应用程序上下文中存在多个 `ChatModel` bean 时，Spring 无法准确解析自动配置的 `ChatClient.Builder` bean 对 `ChatModel` 的依赖关系。为了解决这个问题，您可以将其中一个 `ChatClient` bean 标记为 `@Primary`。如果您手动定义了 `ChatModel` bean，也可能需要将其中一个标记为 `@Primary`；或者，您可以自定义自己的 `ChatClient.Builder` bean 来覆盖自动配置的那个。

```
@Configuration
public class ChatClientConfig {
    @Bean
    @Primary
    public ChatClient openAiChatClient(OpenAiChatModel chatModel, ChatClientBuilderConfigurer confgurer, 
            ObjectProvider<ObservationRegistry> observationRegistry,
            ObjectProvider<ChatClientObservationConvention> chatClientObservationConvention,
            ObjectProvider<AdvisorObservationConvention> advisorObservationConvention,
            ObjectProvider<ToolcallingAdvisor.Builder<?>> toolcallingAdvisorBuilder) {
        return buildChatClient(chatModel, configurer, observationRegistry, chatClientObservationConvention, advisorObservationConvention, toolcallingAdvisorBuilder);
    }

    @Bean
    public ChatClient anthropicChatClient(AnthropicChatModel chatModel, ChatClientBuilderConfigurer confgurer, 
            ObjectProvider<ObservationRegistry> observationRegistry,
            ObjectProvider<ChatClientObservationConvention> chatClientObservationConvention,
            ObjectProvider<AdvisorObservationConvention> advisorObservationConvention,
            ObjectProvider<ToolcallingAdvisor.Builder<?>> toolcallingAdvisorBuilder) {
        return buildChatClient(chatModel, configurer, observationRegistry, chatClientObservationConvention, advisorObservationConvention, toolcallingAdvisorBuilder);
    }

    private ChatClient buildChatClient(ChatModel chatModel, ChatClientBuilderConfigurer confgurer, 
            ObjectProvider<ObservationRegistry> observationRegistry,
            ObjectProvider<ChatClientObservationConvention> chatClientObservationConvention,
            ObjectProvider<AdvisorObservationConvention> advisorObservationConvention,
            ObjectProvider<ToolcallingAdvisor.Builder<?>> toolcallingAdvisorBuilder) {
        ChatClient.Builder builder = ChatClient.builder(chatModel, 
            observationRegistry.getIfUnique(() -> ObservationRegistry.NOOP)),
            chatClientObservationConvention.getIfUnqiue(),
            advisorObservationConvention.getIfUnqiue(),
            toolcallingAdvisorBuilder.getIfAvailable());
        return configurer.configure(builder).build();
    }
}
```

然后，您可以使用 `@Qualifier` 注解将这些 bean 注入到您的应用程序组件中：

```
@Configuration
public class ChatClientExample {
    @Bean
    CommandLineRunner cli(
        @Qualifier("openAiChatClient") ChatClient openAiChatClient,
        @Qualifier("anthropicChatClient") ChatClient anthropicChatClient) {
        return args -> {
            var scanner = new Scanner(System.in);
            ChatClient chat;

            // Model Selection
            System.out.println("\nSelect your AI model:");
            System.out.println("1. OpenAI");
            System.out.println("2. Anthropic");
            System.out.print("Enter your choic (1 or 2): ");

            String choice = scanner.nextLine().trim();

            if (choice.equals("1")) {
                chat = openAiChatClient;
                System.out.println("Using OpenAI model");
            } else {
                chat = anthropicChatClient;
                System.out.println("Using Anthropic model");
            }

            // Using  the selected chat client
            System.out.println("\nEnter your question:");
            String input = scanner.nextLine();
            String response = chat.prompt(input).call().content();
            System.out.println("ASSISTANT: " + response);

            scanner.Close();
        };
    }
}
```

##### 多个与 OpenAI 兼容的 API 端点

您可以使用 `OpenAiChatModel` 的构建器创建多个实例，以便连接到不同的 OpenAI 兼容 API。当您需要与多个提供商合作时，这尤其有用。

```
@Service
public class MultiModelService {
    private static Logger logger = LoggerFactory.getLogger(MultiModelService.class);

    public void multiClientFlow() {
        try {
            OpenAiChatModel groqModel = OpenAiChatModel.builder()
                .options(OpenAiOptions.builder()
                    .baseUrl("https://api.groq.com/openai/v1")
                    .apiKey(System.getenv("GROQ_API_KEY"))
                    .model("llama3-70b-8192")
                    .temperature(0.5)
                    .build())
                .build();

            OpenAiChatModel gpt4Model = OpenAiChatModel.builder()
                .options(OpenAiOptions.builder()
                    .baseUrl("https://api.openai.com")
                    .apiKey(System.getenv("OEPNAI_API_KEY"))
                    .model("gpt-4")
                    .temperature(0.7)
                    .build())
                .build();

            String prompt = "What is the capital of France?";

            String gropResponse = ChatClient.builder(groqModel).build().prompt(prompt).call().content();
            String gptResponse = ChatClient.builder(gpt4Model).build().prompt(prompt).call().content();

            logger.info("Groq (Llama3) response: {}", groqResponse);
            logger.info("OpenAI GPT-4 response: {}", gpt4Response);
        } catch (Exception e) {
            logger.error("Error in multi-client flow", e);
        }
    }
}
```


### ChatClient 流式 API

ChatClient 流式 API 允许您使用三种不同的方式创建提示，方法是使用重载的提示方法来启动流式 API:
- `prompt()`: 此方法不带有任何参数，可让您开始使用流式API，从而构建用户、系统和提示的其他部分。
- `prompt(Prompt prompt)`: 此方法接受一个 `Prompt` 参数，允许您传入使用 `Prompt` 的非流式 API 创建的 `Prompt` 实例。
- `prompt(String content)`: 这是一个类似于前一个重载方法的便捷方法。它接受用户输入的文本内容。

### ChatClient 响应

`ChatClient` API 提供了多种使用 Fluent API 格式化 AI 模型响应的方法。

#### 返回 ChatResponse

AI 模型返回的响应是一个结构丰富的响应，类型为 `ChatResponse`。它包含响应生成方式的元数据，并且可以包含多个响应(称为 "代")，每个响应都有自己的元数据。元数据包括用于生成响应的 Token 数量（每个 Token 大约是单词的四分之三）。此信息至关重要，因为托管 AI 模型会根据每次请求使用的 Token 数量收费。

下面的示例通过在 `call()` 方法之后调用 `chatResponse()` 来返回包含元数据的 `ChatResponse` 对象。
```
ChatResponse chatResponse = chatClient.prompt()
    .user("Tell me a joke")
    .call()
    .chatResponse();
```

#### 返回一个实体

您通常需要返回一个由返回的字符串映射而来的实体类，`entity()` 方法提供了此功能。

例如，给定以下 Java 记录：
```
record ActorFilms(String actor, List<String> movies) {}
```

您可以使用 `entity()` 方法轻松地将 AI 模型的输出映射到此记录，如下所示：
```
ActorFilms actorFilms = chatClient.prompt()
    .user("Generate the filmgraphy for a random actor.")
    .call()
    .entity(ActorFilms.class);
```

此外还，还有一个重载的实体方法，其签名是 `entity(ParameterizedTypeReference<T> type)`，允许您指定诸如泛型列表之类的类型：
```
List<ActorFilms> actorFilms = chatClient.prompt()
    .user("Generate the filmgraphy for a random actor.")
    .call()
    .entity(new ParameterizedTypeReference<List<ActorFilms>>(){});
```

##### 可靠性开关：EntityParamSpec

所有 `entity()` 重载都接受一个可选的 `Consumer<EntityParamSpec>`，它支持两种独立的、可组合的行为：
- `validateSchema()` - 根据实体模式验证 JSON 响应，并在失败时自动重试并提供错误反馈
- `userProviderStructuredOutput()` - 将模式作为 API 级约束而不是提示文本发送给提供程序。

```
ActorFilms actorFilms = chatClient.prompt()
    .user("Generate the filmgraphy for a random actor.")
    .call()
    .entity(ActorFilms.class, spec -> spec
        .userProviderStructuredOutput()
        .validateSchema());
```

有关这些开关，支持的提供商、限制和底层转换器 API 的完整详细信息，请参阅结构化输出参考。

#### 流式响应

`stream()` 方法可以让你获得异步响应，如下所示：
```
Flux<String> output = chatClient.prompt()
    .user("Generate the filmgraphy for a random actor.")
    .stream()
    .content();
```

您还可以使用 `Flux<ChatResponse>` 的 `chatRepsonse()` 方法流式传输 `ChatResponse`。

未来，我们还将提供一个便捷方法，允许您使用响应式 `stream()` 方法返回 Java 实体。在此之前，您应该使用结构化输出转换器显示转换聚合响应，如下所示。这也演示了流式 API 中参数的用法，我们将在文档的后续章节中详细讨论。
```
var converter = new BeanOutputConverter<>(new ParameterizedTypeReference<List<ActorFilms>>(){});

Flux<String> flux = chatClient.prompt()
    .user(u -> u.text("""
                Generate the filmgraphy for a random actor.
                {format}
            """)
            .param("format", this.converter.getFormat()))
    .stream()
    .content();

String content = flux.collectList().block().stream().collect(Collectors.joining());

List<ActorFilms> actorFilms = converter.convert(content);
```

### 提示模板

`ChatClient` 流式 API 允许您提供用户和系统文本作为模板，其中包含在运行时替换的变量。
```
String answer = ChatClient.create(chatModel).prompt()
    .user(u -> u
        .text("Tell me the names of 5 movies whose soundtrack was composed by {composer}")
        .param("composer", "John Williams"))
    .call()
    .content();
```

`ChatClient` 内部使用 `PromptTemplate` 类来处理用户和系统文本，并根据给定的 `TemplateRenderer` 实现，在运行时将变量替换为提供的值。默认情况下，Spring AI 使用 `StTemplateRenderer` 实现，该实现基于 `Terence Parr` 开发的开源 `StringTemplate` 引擎。

Spring AI 还提供了一个 `NoOpTemplateRenderer`，用于不需要模板处理的情况。

> 直接在 `ChatClient` 上配置的 `TemplateRenderer`（通过 `.templateRenderer()`）仅适用于直接在 `ChatClient` 构建器链中定义的提示内容（例如：通过 `user()`、`system()`）。它不会影响 `QuestionAnswerAdvisor` 等顾问内部使用的模板，这些顾问有自己的模板自定义机制（请参阅"自定义顾问模板"）。

如果您希望使用不同的模板引擎，可以直接向 `ChatClient` 提供 `TemplateRenderer` 接口的自定义实现。您也可以继续使用默认的 `StTemplateRenderer`，但需要进行自定义配置。

例如，默认情况下，模板变量使用 `{}` 语法标识。如果您计划在提示符中包含 JSON，则可能需要使用不同的语法以避免与 JSON 语法冲突。例如，您能可以使用 `<` 和 `>` 分隔符。
```
String answer = ChatClient.create(chatModel).prompt()
    .user(u -> u
        .text("Tell me the names of 5 movies whose soundtrack was composed by <composer>")
        .param("composer", "John Williams"))
    .templateRenderer(StTemplateRenderer.builder().startDelimiterToken('<').endDelimiterToken('>').build())
    .call()
    .content();
```

### call() 返回值

在 `ChatClient` 上指定 `call()` 方法后，响应类型有几种不同的选项。
- `String content()`: 返回响应的字符串内容
- `ChatResponse chatResponse()`: 返回 `ChatResponse` 对象，其中包含多个生成以及有关响应的元数据，例如用于创建响应的令牌数
- `ChatClientResponse chatClientResponse()`: 返回一个 `ChatClientResponse` 对象，其中包含 `ChatResponse` 对象和 `ChatClient` 执行上下文，使您可以访问 `Advisor` 执行期间使用的其他数据（例如：在 RAG 流程中检索的相关文档）
- `entity()`: 返回 Java 类型
    - `entity(ParameterizedTypeReference<T> type)`: 用于返回实体类型的集合
    - `entity(Class<T> type)`: 用于返回特定实体类型
    - `entity(StructedOutputConverter<T> structedOutputConverter)`: 用于指定 `StructedOutputConverter` 的实例，以将字符串转换为实体类型
    - `entity(ParameterizedTypeReference<T> type, Consumer<EntityParamSpec>)`: 如上所示，带有可选的 `EntityParamSpec` 配置
    - `entity(Class<T> type, Consumer<EntityParamSpec>)`: 如上所示，带有可选的 `EntityParamSpec` 配置
    - `entity(StructedOutputConverter<T> structedOutputConverter, Consumer<EntityParamSpec>)`: 如上所示，带有可选的 `EntityParamSpec` 配置
- `responseEntity()`: 同时返回 `ChatResponse` 对象和 Java 类型。当您需要在一次调用中同时获取完整的 AI 模型响应（包含元数据和生成信息）以及结构化的输出实例时，此功能非常有用。
    - `responseEntity(Class<T> type)`: 用于返回包含完整 `ChatResponse` 对象和特定实体类型的 `ResponseEntity`
    - `responseEntity(Class<T> type, Consumer<EntityParamSpec>)`: 如上所示，带有可选的 `EntityParamSpec` 配置
    - `responseEntity(ParameterizedTypeReference<T> type)`: 用于返回一个包含完整 `ChatResponse` 对象和实体类型集合的 `ResponseEntity`
    - `responseEntity(ParameterizedTypeReference<T> type, Consumer<EntityParamSpec>)`: 如上所示，带有可选的 `EntityParamSpec` 配置
    - `responseEntity(StructedOutputConverter<T> structedOutputConverter)`: 用于返回一个 `ResponseEntity`，其中包含完整的 `ChatResponse` 对象和使用指定的 `StructedOutputConverter` 转换的实体
    - `responseEntity(StructedOutputConverter<T> structedOutputConverter, Consumer<EntityParamSpec>)`: 如上所示，带有可选的 `EntityParamSpec` 配置

你也可以调用 `stream()` 而不是 `call()` 方法。

> 调用 `call()` 方法并不会真正触发 AI 模型执行。它只是指示 Spring AI 使用同步调用还是流式调用。实际的 AI 模型调用发生在调用 `content()`、`chatResponse()` 和 `responseEntity()` 等方法时。

### stream() 返回值

在 ChatClient 中指定 stream() 方法后，响应类型有以下几个选项：
- `Flux<String> content()`: 返回 AI 模型生成的字符串的 `Flux`
- `Flux<ChatResponse> chatResponse()`: 返回 `ChatResponse` 对象的 `Flux`，其中包含有关响应的附加元数据
- `Flux<ChatClientResponse> chatClientResponse`: 返回一个 `chatClientResponse` 对象的 `Flux`，其中包含 `ChatResponse` 对象和 `ChatClient` 执行上下文，使您可以访问 `Advisor` 执行期间使用的其他数据（例如：在 RAG 流程中检索的相关文档）

### 消息元数据

ChatClient 支持向用户消息和系统消息添加元数据。元数据提供有关消息的额外上下文和信息，可供 AI 模型或下游处理使用。

#### 添加元数据到用户信息

你可以使用 `metadata()` 方法向用户消息添加元数据：
```
// 添加单个元数据键值对
String response = chatClient.prompt()
    .user(u -> u.text("What's the weather like?")
        .metadata("messageId", "msg-123")
        .metadata("userId", "user-456")
        .metadata("priority", "high"))
    .call()
    .content();

// 一次性添加多个元数据条目
Map<String, Object> userMetadata = Map.of(
    "messageId", "msg-123",
    "userId", "user-456",
    "timestamp", System.currentTimeMillis()
);

String response = chatClient.prompt()
    .user(u -> u.text("What's the weather like?")
        .metadata(userMeatadata))
    .call()
    .content();
```

#### 添加元数据到系统信息

同样，你也可以向系统消息添加元数据：
```
// 添加单个元数据键值对
String response = chatClient.prompt()
    .system(s -> s.text("You are a helpful assistant.")
        .metadata("version", "1.0")
        .metadata("model", "gpt-4"))
    .user("Tell me a joke")
    .call()
    .content();
```

#### 默认元数据支持

你还可以在 ChatClient 构建器级别配置默认元数据：
```
@Configuration
class Config {
    @Bean
    ChatClient chatClient(ChatClient.Builder builder) {
        return builder
            .defaultSystem(s -> s.text("You are a helpful assistant.")
                .metadata("assistantType", "general")
                .metadata("version", "1.0"))
            .defaultUser(u -> u.text("Default user context")
                .metadata("sessionId", "default-session"))
            .build();
    }
}
```

#### 元数据验证

ChatClient 会验证元数据以确保数据完整性：
- 元数据键不能为空或空值
- 元数据值不能为空
- 传递 Map 时，键和值都不能包含空元素
```
// 以下将抛出 IllegalArgumentException
chatClient.prompt()
    .user(u -> u.text("Hello")
            .metadata(null, "value")) // 非法：null key
    .call()
    .content();

// 以下也将抛出 IllegalArgumentException
chatClient.prompt()
    .user(u -> u.text("Hello")
            .metadata("key", null)) // 非法：null value
    .call()
    .content();
```

#### 访问元数据

元数据包含在生成的 UserMessage 和 SystemMessage 对象中，可以通过消息的 `getMetadata()` 方法访问。这在处理 `Advisor` 系统中的消息或查看对话历史记录时尤其有用。

### 使用默认值

在 `@Configuration` 类中创建带有默认系统文本的 `ChatClient` 可以简化运行时代码。通过设置默认值，您只需要在调用 `ChatClient` 时指定用户文本，无需在运行时代码路径中为每个请求设置系统文本。

#### 默认系统文本

在以下实例中，我们将系统文本配置为始终以海盗的声音回复。为了避免在运行时代码中重复系统文本，我们将在 `@Configuration` 类中创建一个 `ChatClient` 实例。
```
@Configuration
class Config {
    @Bean
    ChatClient chatClient(ChatClient.Builder builder) {
        return builder
            .defaultSystem("You are a friendly chat bot that answers question in the voice of a Pirate")
            .build();
    }
}
```

然后 `@RestController` 调用它:
```
@RestController
class AIController {
    private final ChatClient chatClient;

    AIController(ChatClient chatClient) {
        this.chatClient = chatClient;
    }

    @GetMapping("/ai/sample")
    public Map<String, String> completion(@RequestParam(value = "message", defaultValue = "Tell me a joke") String message) {
        return Map.of("completion", this.chatClient.prompt().user(message).call().content());
    }
}
```

当通过 curl 调用应用程序端点时，结果如下：
```
> curl localhost:8080/ai/sample
{"completion": "Why did the pirate go to the comedy club? To hear some arr-rated jokes! Arrr, matey!"}
```

#### 带参数的默认系统文本

在以下示例中，我们将使用系统文本的占位符来指定运行时（而不是设计时）完成的语言。
```
@Configuration
class Config {
    @Bean
    ChatClient chatClient(ChatClient.Builder builder) {
        return builder
            .defaultSystem("You are a friendly chat bot that answers question in the voice of a {voice}")
            .build();
    }
}
```
```
@RestController
class AIController {
    private final ChatClient chatClient;

    AIController(ChatClient chatClient) {
        this.chatClient = chatClient;
    }

    @GetMapping("/ai")
    public Map<String, String> completion(@RequestParam(value = "message", defaultValue = "Tell me a joke") String message, String voice) {
        return Map.of("completion", this.chatClient.prompt()
            .system(sp -> sp.param("voice", voice))
            .user(message)
            .call()
            .content());
    }
}
```

通过 httpie 调用应用程序端点时，结果如下：
```
http localhost:8080/ai voice='Robert DeNiro'
{
    "completion": "You talkin' to me? Okay, here's a joke for ya: Why couldn't the bicycle stand up by itself? Because it was two tired! Classic, right?"
}
```

#### 其他默认值

在 `ChatClient.Builder` 级别，您可以指定默认提示配置。
- `defaultOptions(ChatOptions chatOptions)`: 传入 `ChatOptions` 类中定义的可移植选项，或模型特定的选项，例如 `OpenAiChatOptions` 中的选项。有关模型特定 `ChatOptions` 实现的更多信息，请参阅 JavaDocs。
- `defaultTools(Object... tools)`: 注册一个或多个默认工具，这些工具将可供每个请求使用。接受 `ToolCallbackback`、`ToolCallbackProvider` 或带有 `@Tool` 注解方法的 POJO 等异构对象。
- `defaultToolContext(Map<String, Object> toolContext)`: 设置工具执行的默认上下文。
-  `defaultSystem(String text)`, `defaultSystem(Resource tezt)`, `defaultSystem(Consumer<PromptSystemSpec> systemSpecConsumer)`: 这些方法允许您定义默认系统文本
-  `defaultUser(String text)`, `defaultUser(Resource tezt)`, `defaultUser(Consumer<UserSpec> userSpecConsumer)`: 这些方法允许您定义用户文本。`Consumer<UserSpec>` 允许您使用 lambda 表达式来指定用户文本和任何默认参数
-  `defaultTemplateRenderer(TemplateRenderer templateRenderer)`: 设置提示模板的默认 `TemplateRenderer`
-  `defaultAdvisor(Advisor... advisor)`, `defaultAdvisor(List<Advisor> advisor)`: Advisors 允许用于创建提示的数据。`QuestionAnswerAdvisor` 实现通过在提示中添加与用户文本相关的上下文信息，支持检索增强生成模式。
-  `defaultAdvisor(Consumer<AdvisorSpec> advisorSpecConsumer)`: 此方法允许你定义一个 `Consumer`，并使用 `AdvisorSpec` 配置多个 `Advisor`。`Advisor` 可以修改用于创建最终提示的数据。`Consumer<AdvisorSpec>` 允许你指定一个 lambda 表达式来添加 `Advisor`，例如 `QuestionAnswerAdvisor` 实现通过在提示中添加与用户文本相关的上下文信息，支持检索增强生成模式。

你可以在运行时使用相应的方法（不带 default 前缀）来覆盖这些默认值。
- `options(ChatOptions.Builder optionsCustomizer)`
- `tools(Object... tools)`
- `toolContext(Map<String, Object> toolContext)`
- `messages(Message... messages)`, `messages(List<Message> messages)`
- `system(String text)`, `system(Resource text)`, `system(Consumer<PromptSystemSpec> systemSpecConsumer)`
- `user(String text)`, `user(Resource text)`, `user(Consumer<UserSpec> userSpecConsumer)`
- `templateRenderer(TemplateRenderer templateRenderer)`
- `advisors(Advisor... advisor)`, `advisors(List<Advisor> advisors)`
- `advisors(Consumer<AdvisorSpec> advisorSpecConsumer)`

### 修改 ChatClient

你可以使用 `mutate()` 方法创建一个新的 `ChatClient`（ 或 `ChatClientRequestSpec`），并将设置从现有的 `ChatClient` 复制过来：
- 在 `ChatClient` 中：`Builder.mutate()` 返回一个使用客户端默认设置初始化的 `ChatClient.Builder`
- 在 `ChatClientRequestSpec` 中：`Builder.mutate()` 返回一个请求的当前设置初始化的 `ChatClient.Builder`

这对于创建衍生客户端或请求而无需重新定义所有选项非常有用。