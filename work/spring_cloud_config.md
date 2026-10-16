# 总览

Spring Cloud Config 为分布式系统中的外部化配置提供服务器端和客户端支持。借助 Config Server，你可以集中管理应用程序在所有环境中的外部属性。客户端和服务器端的概念与 Spring 的 `Environment` 和 `PropertySource` 抽象完全对应，因此，它们非常适合 Spring 应用程序，但也可用于任何语言编写的任何应用程序。随着应用程序的部署和更新，Config Server 可以更好地管理应用程序的外部属性。当应用程序从开发环境迁移到测试环境再到生产环境时，你可以管理这些环境之间的配置，确保应用程序在迁移时拥有运行时所需的一切。服务器存储后端的默认实现使用 Git，因此可以轻松支持配置环境的标记版本，并且可以被各种内容管理工具访问。添加替代方案并将其与 Spring 配置集成起来也很容易。



## 功能

Spring Cloud Server 功能：

- 用于外部配置的基于资源的 HTTP API（名称-值对或等效的 YAML 内容）
- 对属性值进行加密和解密（对称或非对称）
- 使用 `@EnableConfigServer` 可以轻松嵌入到 Spring Boot 应用程序中

Config Client 功能（用于 Spring 应用）：

- 绑定到 Config Server 并使用远程属性源初始化 Spring `Environment`
- 对属性值进行加密和解密（对称或非对称）



## 入门

只要 Spring Boot Actuator 和 Spring Config Client 位于类路径中，任何 Spring Boot 应用程序都会尝试通过 `http://localhost:8888` 连接 Config Server，这是 `spring.cloud.config.uri` 的默认值。如果你想要更改此默认值，可以在 `bootstrap.[yml | properties]` 文件中设置 `spring.cloud.config.uri`，也可以通过系统属性或环境变量进行设置。

```java
@Configuration
@EnableAutoConfiguration
@RestController
public class Application {
  @Value("${config.name}")
  String name = "World";
  
  @RequestMapping("/")
  public String home() {
    return "Hello " + name;
  }
  
  public static void main(String[] args) {
    SpringApplication.run(Application.class, args);
  }
}
```

示例中的 `config.name` 值（或你以 Spring Boot 常规方式绑定的任何其他值）可以来自本地配置或远程 Config Server。默认情况下，Config Server 的配置优先，要查看这一点，请查看应用程序中的 `/env` 端点并查看 `configServer` 属性的来源。

要运行你自己的服务器，请使用 `spring-cloud-config-server` 依赖项和 `@EnableConfigServer` 注解。如果你设置 `spring.config.name=configserver`，应用程序将在 8888 端口运行，并从示例存储库提供数据。你需要 `spring.cloud.config.server.git.uri` 来定位满足你自身需求的配置数据（默认情况下，它是 Git 存储库的位置，也可以是本地文件 URL）。



# 介绍

Spring Cloud Config 为分布式系统中的外部化配置提供服务器端和客户端支持。借助 Config Server，你可以集中管理应用程序在所有环境中的外部属性。客户端和服务器端的概念与 Spring 的 `Environment` 和 `PropertySource` 抽象完全对应，因此，它们非常适合 Spring 应用程序，但也可用于任何语言编写的任何应用程序。随着应用程序的部署和更新，Config Server 可以更好地管理应用程序的外部属性。当应用程序从开发环境迁移到测试环境再到生产环境时，你可以管理这些环境之间的配置，确保应用程序在迁移时拥有运行时所需的一切。服务器存储后端的默认实现使用 Git，因此可以轻松支持配置环境的标记版本，并且可以被各种内容管理工具访问。添加替代方案并将其与 Spring 配置集成起来也很容易。



# Spring Cloud Config Server

Spring Cloud Config Server 提供了一个基于 HTTP 资源的 API，用于外部配置（名称-值对等效的 YAML 内容）。该服务器可以通过使用 `@EnableConfigServer` 注解嵌入到 Spring Boot 应用程序中。因此，以下应用程序就是一个 Config Server：

*ConfigServer.java*

```java
@SpringBootApplication
@EnableConfigServer
public class ConfigServer {
  public static void main(String[] args) {
    SpringApplication.run(ConfigServer.class, args);
  }
}
```

与所有 Spring Boot 应用程序一样，它默认运行在 8080 端口，但你可以通过多种方式将其切换到更常用的 8888 端口。最简单的方法是使用 `sping.cloud.name=configserver` 启动它（Config Server jar 包中包含一个 `configserver.yml` 文件），这样还可以设置默认的配置仓库。另一种方法是使用你自己的 `application.properties` 文件，如下例所示：

*application.yml*

```properties
server.port=8888
spring.cloud.config.server.git.uri=file://${user.home}/config-repo
```

其中 `${user.home}/config-repo` 是一个包含 YAML 和属性文件的 git 仓库。

> 在 Windows 系统中，如果文件 URL 是带有驱动器前缀的绝对路径（例如 `/${user.home}/config-repo`），则需要在文件 URL 中添加额外的 `/`。

> 以下清单展示了创建前面示例中的 Git 仓库的步骤：
>
> ```bash
> $ cd $HOME
> $ mkdir config-repo
> $ cd config-repo
> $ git init .
> $ echo info.foo: bar > application.properties
> $ git add -A .
> $ git commit -m 'Add application.properties'
> ```

> 使用本地文件系统作为 Git 仓库仅用于测试。在生产环境中，你应该使用服务器来托管配置仓库。

> 如果配置仓库中只包含文本文件，那么初始克隆过程会非常快速高效。但如果存储二进制文件，尤其是大型二进制文件，则首次请求配置时可能会出现延迟，或者服务器可能会出现内存不足的错误。



## 环境仓库
Config Server 的配置数据应该存储在哪里？控制此行为的策略是 `EnvironmentRepository`，它提供 `Environment` 对象。此 `Environment` 是 Spring `Environment` 域的浅拷贝（主要特定包括 `propertySources`）。`Environment` 资源由三个变量参数化：
- `{application}`，它映射到客户端的 `spring.application.name`
- `{profile}`，它映射到客户端的 `spring.profiles.active`（逗号分割列表）
- `{label}`，是一个服务器端功能，用于标记一组 `版本化` 的配置文件。

仓库实现通常类似于 Spring Boot 应用程序，它会根据 `spring.config.name`（等于 `{application}` 参数）和 `spring.profiles.active`（等于 `{profile}` 参数）加载配置文件。配置文件的优先级规则也与常规 Spring Boot 应用程序相同：活动配置文件优于默认配置文件，并且，如果存在多个配置文件，则最后添加的配置文件生效（类似于向 `Map` 中添加条目）。

以下示例客户端应用程序具有以下引导配置：

```yaml
spring:
	application:
		name: foo
	profiles:
		active: dev,mysql
```

（与 Spring Boot 应用程序一样，这些属性也可以通过环境变量或命令行参数进行设置）。

如果存储库基于文件，服务器会根据 `application.yml` （所有客户端共享）和 `foo.yml`（`foo.yml` 优先级更高）创建一个环境。如果 YAML 文件中包含指向 Spring `profiles` 的文档，则这些 `profiles` 会优先应用（按配置列表的顺序）。如果存在特定于 `profile` 的 YAML（或属性）文件，这些配置也会优先于默认值应用。优先级越高，`PropertySource` 在 `Environment` 中列出的位置就越靠前。（这些规则同样适用于独立的 Spring Boot 应用程序）。

你可以将 `spring.cloud.config.server.accept-empty` 设置为 `false`，这样，如果找不到 `application`，服务器将返回 HTTP 404 状态码。默认情况下，此标志设置为 `true`。

> 你不能将 `spring.main.*` 属性放在远程 `EnvironmentRepository` 中。这些属性用于应用程序 初始化。

### Git 后端

`EnvironmentRepository` 的默认实现使用 Git 后端，这对于管理升级和物理环境以及审计变更 非常方便。要更改仓库位置，你可以在 Config Server（例如 `application.yml`）中设置 `spring.cloud.config.server.git.uri` 配置属性。如果使用 `file:`前缀进行设置，则应该可以从本地仓库工作，这些你就可以快速轻松地入门，而无需服务器。然而，在这种情况下，服务器直接操作本地仓库，而无需克隆它（即使本地仓库不是裸仓库也无关紧要，因为 Config Server 永远不会修改**远程**仓库）。为了扩展 Config Server 并实现高可用性，需要让所有服务器实例都指向同一个仓库，因此只有共享文件系统才能满足需求。即使在这种情况下，最好也使用 `ssh:` 协议来连接共享文件系统存储库，这样服务器可以克隆存储库并使用本地工作副本作为缓存。

此仓库实现将 HTTP 资源的`{label}` 参数映射到 Git 标签（提交 ID、分支名称或标签）。如果 Git 分支或标签名称包含斜杠（`/`），则应使用特殊字符串`({special-string})` 来指定 HTTP URL 中的标签（以避免与其他 URL 路径产生歧义）。例如，如果标签是 `foo/bar`，则替换斜杠后，标签将变为 `foo({special-string})bar`。特殊字符串 `({special-string})` 也可以应用于 `{application}` 参数。如果你使用 curl 等命令行客户端，请注意 URL 中的括号-你应该使用单引号（`''`）在 shell 中对其进行转义。

#### 跳过 SSL 证书验证

可以通过将`git.skipSslValidation` 属性设置为 `true`（默认为 `false`）来禁用 Config Server 对 Git 服务器 SSL 证书的验证。

```yaml
spring:
	cloud:
		config:
			server:
				git:
					uri: https://example.com/my/repo
					skipSslValidation: true
```

#### 设置连接超时

你可以配置 Config Server 等待获取 HTTP 或 SSH 连接的时间（以秒为单位）。使用 `git.timeout` 属性（默认为 `5`）：

```yaml
spring:
	cloud:
		config:
			server:
				git:
					uri: https://example.com/my/repo
					timeout: 4
```

#### Git URL 中的占位符

Spring Cloud Config Server 支持带有 `{application}` 和 `{profile}` 占位符的 Git 仓库 URL（如果需要，还可以包含 `{label}`，但请记住，标签无论如何都会作为 Git 标签应用）。因此，你可以使用类似于以下的结构来支持**每个应用程序一个仓库**的策略：

```yaml
spring:
	cloud:
		config:
			server:
				git:
					uri: https://github.com/myorg/\{application}
```

你还可以使用类似的模式，但使用 `{profile}` 来支持**每个 profile 一个存储库**策略。

此外，在 `{application}` 参数中使用特殊字符串 `（{special-string}）` 可以启用对多个组织的支持，如下例所示：

```yaml
spring:
	cloud:
		config:
			server:
				git:
					uri: https://github.com/\{application}
```

其中 `{application}` 在请求时以以下格式提供：`organization({special-string})application`。

#### 模式匹配与多存储库

Spring Cloud Config 还支持更复杂的需求，它可以通过匹配 `application` 和 `profile` 名称来实现。`pattern` 格式是一个以逗号分割的 `{application}/{profile}` 的名称列表，其中包含通配符（请注意，以通配符开头的 `pattern` 可能需要用引号括起来），如下例所示：

```yaml
spring:
	cloud:
		config:
			server:
				git:
					uri: https://github.com/spring-cloud-samples/config-repo
					repos:
						simple: https://github.com/sample/config-repo
						special:
							pattern: special*/dev*,*sepcial*/dev*
							uri: https://github.com/special/config-repo
						local:
							pattern: local*
							uri: file:/home/configsvc/config-repo
```

如果 `{application}/{profile}` 不匹配任何模式，则使用 `spring.cloud.config.server.git.uri` 下定义的默认 URI。在上面的示例中，**simple** 仓库的 `pattern`是 `simple/*`（它只匹配所有 `profile` 中名为 `simple` 的 `application`）。**local** 仓库匹配所有 `profile` 中所有以 `local` 开头的 `application` 名称（对于任何没有 `profile` 匹配的 `pattern`，都会自动添加 `/*` 后缀）。

> 简单示例中使用的 **一行式** 简写仅适用于仅需设置 URI 属性的情况。如果需要设置其他任何内容（凭据、模式等），则需要使用完整形式。

仓库中的 `pattern` 属性实际上是一个数组，因此你可以使用 YAML 数组（或属性文件中的 `[0]`、`[1]` 等后缀）绑定到多个 `pattern`。如果你要运行具有多个 `profile`的应用，则可能需要这样做，如下例所示：

```yaml
spring:
	cloud:
		config:
			server:
				git:
					uri: https://github.com/spring-cloud-samples/config-repo
					repos:
						development:
							pattern:
								- '*/development'
								- '*/staging'
							uri: https://github.com/development/config-repo
						staging:
							pattern:
								- '*/qa'
								- '*/production'
							uri: https://github.com/staging/config-repo
```

> Spring Cloud 会猜测，如果 `pattern` 中包含的 `profile` 不以 `*` 结尾，则表示你实际上是要匹配一个以该 `pattern` 开头的 `profiles` 列表（例如，`*/staging` 是 [`"*/staging"`，`"*/staging,*"`] 等的简写）。这种情况很常见，例如，你需要在本地运行 "development"，同时在远程运行 "cloud" `profile` 配置。

每个代码仓库都可以选择将配置文件存储在这些子目录中，并且可以指定 `search-paths` 来查找这些目录，以下示例展示了位于顶层目录的配置文件：

```yaml
spring:
	cloud:
		config:
			server:
				git:
					uri: https://github.com/spring-cloud-samples/config-repo
					search—paths:
						- foo
						- bar*
```

在前面的示例中，服务器会在顶层目录、`foo/` 子目录以及名称以 `bar` 开头的任何子目录中搜索配置文件。

默认情况下，服务器会在首次请求配置时克隆远程仓库。也可以将服务器配置为在启动时克隆仓库，如下面的顶级示例所示：

```yaml
spring:
	cloud:
		config:
			server:
				git:
					uri: https://git/common/config-repo.git
					repos:
						team-a:
							pattern: team-a-*
							cloneOnStart: true
							uri: https://git/team-a/config-repo.git
						team-b:
							pattern: team-b-*
							cloneOnStart: false
							uri: https://git/team-b/config-repo.git
						team-c:
							pattern: team-c-*
							uri: https://git/team-c/config-repo.git
```

在前面的例子中，服务器会在启动时克隆 `team-a` 的配置仓库，然后在接受任何请求。所有其他仓库只有在请求配置时才会被克隆。

> 设置在 Config Server 启动时克隆某个存储库有助于在 Config Server 启动时快速识别配置错误的配置源（例如无效的存储库 URI）。如果未为某个配置源启用 `cloneOnStart`，则 Config Server 可能在配置错误或无效的配置源的情况下成功启动，并且直到应用程序从该配置源请求配置时才会检测到错误。

#### 验证

要在远程存储库上使用 HTTP 基本身份验证，请分别添加 `username` 和 `password` 属性（不要添加到 URL 中），如下例所示：

```yaml
spring:
	cloud:
		config:
			server:
				git:
					uri: https://github.com/spring-cloud-samples/config-repo
					username: trolley
					password:	strongpassword
```

如果你不使用 HTTPS 和用户凭据，只要将密钥存储在默认目（`~/.ssh`）中，并且 URI 指向 SSH 位置（例如 `git@github.com:configuration/cloud-configuration`），SSH 也应该可以正常工作。重要的是，`~/.ssh/known.hosts` 文件中必须包含 Git 服务器的条目，并且该条目必须采用 `ssh-rsa` 格式。其他格式（例如 `ecdsa-sha2-nistp256`）不受支持。为避免出现意外情况，你应确保 `~/.ssh/known.hosts` 文件中只存在一个条目，并且该条目与你提供给 Config Server 的 URL 完全匹配。如果你在 URL 中使用了主机名，则 `known_hosts` 文件中需要包含该主机名（而不是 IP  地址）。该仓库是通过 JGit 访问的，因此你找到的任何相关文档都应该适用的。HTTPS 代理设置可以在 `~/.git/config` 中设置，或者（与任何其他 JVM 进程相同）使用系统属性（`-Dhttps.proxyHost` 和 `-Dhttps.proxyPort`）进行设置。

> 如果你不知道 `~/.git` 目录在哪里，请使用 `git config --global` 来操作设置（例如，`git config --global http.sslVerify false`）。

JGit 需要 PEM 格式的 RSA 密钥，以下是一个 `ssh-keygen`（来自 `openssh`）命令示例，它将生成正确格式的密钥：

```bash
ssh-keygen -m PEM -t rsa -b 4096 -f ~/config_server_deploy_key.rsa
```

> 使用 SSH 密钥时，预期的 SSH 私钥必须以 `-----BEGIN RSA PRIVATE KEY-----` 开头。如果密钥以 `-----BEGIN OPENSSH PRIVATE KEY-----` 开头，则服务器在启动 Config Server 时，RSA 密钥将无法加载，错误信息如下：
>
> ```
> - Error in object 'spring.cloud.config.server.git': codes [PrivateKeyIsValid.spring.cloud.config.server.git,PrivateKeyIsValid]; arguments [org.springframework.context.support.DefaultMessageSourceResolvable: codes [spring.cloud.config.server.git.,]; arguments []; default message []]; default message [Property 'spring.cloud.config.server.git.privateKey' is not a valid private key]
> ```

要纠正上述错误，必须将 RSA 密钥转换为 PEM 格式。上文提供了一个使用 openssh  生成正确格式新密钥的示例。

#### 使用 AWS CodeCommit 进行身份验证

Spring Cloud Config Server 也支持 AWS CodeCommit 身份验证。AWS CodeCommit 在命令行使用 Git 时会使用身份验证辅助函数。此辅助函数不与 JGit 库一起使用，因此，如果 Git URI 与 AWS CodeCommit 模式匹配，则会创建一个用于 AWS CodeCommit 的 JGit CredentialProvider。AWS CodeCommit URI 遵循以下模式：

```bash
https://git-codecommit.${AWS_REGION}.amazones.com/v1/repos/${repo}
```

如果你为 AWS CodeCommit URI 提供了用户名和密码，则它们必须是用于访问和存储库的 AWK accessKeyId 和 secretAccessKey。如果你未指定用户名和密码，则会使用默认凭证提供程序链检索 accessKeyId 和 secretAccessKey。

如果你的 Git URI 与 AWS CodeCommit URI 模式（如前所述）匹配，则必须在用户名和密码中或在默认凭证提供程序链支持的位置之一中提供有效的 AWS 凭证。AWS EC2 实例可以使用 IAM 角色来管理 EC2 实例。

> `software.amazon.awssdk:auth` jar 是一个可选依赖项。如果 `software.amazon.awssdk:auth` jar 不在你的类路径中，则无论 Git 服务器 URI 是什么，都不会创建 AWS 代码提交凭证提供程序。

#### 使用 Google Cloud Source 进行身份验证

Spring Cloud  Config Server 还支持对 Google Cloud Source 存储库进行身份验证。

如果你的 Git URI 使用 `http` 或 `https` 协议，且域名为 `source.developers.google.com`，则会使用 Google Cloud Source 凭据提供程序。Google Cloud Source 存储库 URI 的格式为 `source.developers.google.com/p/${GCP_PROJECT}/r/${REPO}`。要获取存储库的 URI，请在 Google Cloud Source 用户界面中点击 "clone"，然后选择 "Manually generataed credentials"。请勿生成任何凭据，只需复制显示的 URI 即可。

Google Cloud Source 凭据提供程序将使用 Google Cloud Platform 应用程序默认凭据。有关如何为系统创建应用程序默认凭据，请参阅 Google Cloud SDK 文档。此方法适用于开发环境中的用户账户和生产环境中服务账户。

> `com.google.auth:google-auth-library-oauth2-http` 是一个可选依赖项。如果 `google-auth-library-oauth2-http` jar 不在你的类路径中，则无论 Git 服务器 URI 是什么，都不会创建 Google Cloud Source 凭据提供程序。

#### 使用属性配置 Git SSH

默认情况下，Spring Cloud Config Server 使用 JGit 库在使用 SSH URI 连接到 Git 仓库时，会使用注入 `~/.ssh/known_hosts` 和 `/etc/ssh/ssh_config` 之类的 SSH 配置文件。在 Cloud Foundary 等云环境中，本地文件系统可能是临时的或不易访问的。对于这种情况，可以使用 Java 属性来设置 SSH 配置。要启用基于属性的 SSH 配置，需要设置 `spring.cloud.config.server.git.ignoreLocalSettings` 属性为 `true`，如下例所示：

```yaml
spring:
	cloud:
		config:
			server:
				git:
					uri: git@gitserver.com:team/repo1.git
					ignoreLocalSettings: true
					hostKey: someHostKey
					hostKeyAlgorithm: Ssh-rsa
					privateKey: |
                                  -----BEGIN OPENSSH PRIVATE KEY-----
                      b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAACFwAAAAdzc2gtcn
                      NhAAAAAwEAAQAAAgEAsXwAEzN92ZXfYXx7XdFlGsknWhdu/2hhZCZ488V2NJf5isLl91JM
                      hVCUoO1jRODGM0OwPok72Iwnko8Y40ssEAtSazKJIch1Oq1DYndXqU4K5s/e5TOB0fsQk9
                      qrjQ8J7t3rBV5M7J8Tprif64hYJdLg9POdU+Lth+6VZdqhh8ED0pC2UM5/f7nkkZfBERuo
                      qVJ97vFhwQGbi+RtaHmzS0dTUvyP5UVWK1mRm/Guq2rSifJ/xb9pOmYyr+b4lTZquR1GqE
                      zQPmX8tJccKJFmqjNywsg5TEFoId4Z8cvpFe1a3iMXrdVShvd4ce2tKo+VdKSaZTyhNs+6
                      4tYpKHevabx4edPdm9PmVchU06R8rtkp5imPqcJHKnpIF6KqlFBK8XSbYaJ32TSpI5UMtn
                      ym5A4khMqQTslAW+mHJHR+0NFve5M+nMyxpFI0fx5aZGSRqJZR2CNx61l2Uc2tqMQli761
                      V/Y6xNprVgZ5UTMNa8vojRvjgZc/TC9PxXCbzQW8luCCOotXocMHTNN7nJX4IZzEC+p3Ng
                      Q4JWNeunpkSZ5Amo+KKVu1W/SG8P+6Lq1CpNxcMtJDSHdgCPihOttEKZaQsxkAOK/UqufG
                      xjRxsmmbm7qg8z42QeP/n9rIvu+MPfUfzXghnAXtx/+WyOCaZKVvApPccrzrpC3EVhWRvo
                      8AAAdIkvtI/5L7SP8AAAAHc3NoLXJzYQAAAgEAsXwAEzN92ZXfYXx7XdFlGsknWhdu/2hh
                      ZCZ488V2NJf5isLl91JMhVCUoO1jRODGM0OwPok72Iwnko8Y40ssEAtSazKJIch1Oq1DYn
                      dXqU4K5s/e5TOB0fsQk9qrjQ8J7t3rBV5M7J8Tprif64hYJdLg9POdU+Lth+6VZdqhh8ED
                      0pC2UM5/f7nkkZfBERuoqVJ97vFhwQGbi+RtaHmzS0dTUvyP5UVWK1mRm/Guq2rSifJ/xb
                      9pOmYyr+b4lTZquR1GqEzQPmX8tJccKJFmqjNywsg5TEFoId4Z8cvpFe1a3iMXrdVShvd4
                      ce2tKo+VdKSaZTyhNs+64tYpKHevabx4edPdm9PmVchU06R8rtkp5imPqcJHKnpIF6KqlF
                      BK8XSbYaJ32TSpI5UMtnym5A4khMqQTslAW+mHJHR+0NFve5M+nMyxpFI0fx5aZGSRqJZR
                      2CNx61l2Uc2tqMQli761V/Y6xNprVgZ5UTMNa8vojRvjgZc/TC9PxXCbzQW8luCCOotXoc
                      MHTNN7nJX4IZzEC+p3NgQ4JWNeunpkSZ5Amo+KKVu1W/SG8P+6Lq1CpNxcMtJDSHdgCPih
                      OttEKZaQsxkAOK/UqufGxjRxsmmbm7qg8z42QeP/n9rIvu+MPfUfzXghnAXtx/+WyOCaZK
                      VvApPccrzrpC3EVhWRvo8AAAADAQABAAACAG+CH63woPYOcm0WP4//Gg2NKfsxU9yF4QKC
                      JWXKvuxmOzMSJlePzmHH8cl1u/OvYPceZOG1aPMxgz9SRmmvdfySkHKnKn8eKYD3EKoRnv
                      LRBIplOX45MSwTGCQ8s6GJPE1mAd26lIvpmfgacOcTH4aMCif70vG8Vk4b+KMojGn1O4iU
                      wObeBj7iNRfAB13PSdUv7c0svKT9dJOcrZyBMcNvCYvPAD0kpfHQcWpPmtU55RMkV2CPVP
                      aK9PeNHsroiH7LRPRCZmd9vhpcAiX+zEjM0CJOl6kwQtNcbmJ7IXNUT83WsG7X4uTHIFY7
                      5Jsj4NuK+zH1uLfuJVWVBgDVyU+SQZwBigI5FoaU1eJlKUBVwzhvFGvFJBPEH36nJLQkMh
                      l07U4dui/9v+e34Ua0YuB9GTJEIVChRWStWpoIBM3g3OaHVi4xGK7lgegapH+uFNgFXQpi
                      rypW/s6InJQs6s13KNDDsDME96/nQXMA1tQSZ/gSxEJeoWr4f/dnSWM3w/Bx5DrwKNrgNA
                      WnEHtO9r1CHCGwj7zB+ADTxsmmfMJVM9NVLTDPhNGRbpAj+jGaVXoYVRQA9R9yBjX3zmvi
                      snihaNWzCpVNADzzx78BHi/DUDcxMy2H9/RKlfMYHH1ktwsHBMXxyjf+8MupP8JMAYaQDq
                      Cy7NzOXgbt3Wt136gpAAABACULn5OV9nhihXkmxvrn3foEO846rIO0/8YBPjFbVcX/OG+d
                      3uxe+btW9wUVfwA9I/Tt7YD1AhceouVyHCwVfVStN4Kt78drFx3+FwsDnWt5KdueCRcdZ1
                      VaWKu6qQlK5d44M26xAYQ659rNxD0nty1WMgFt6kiEFYcU7OVTgbVtz80uszM0EKzlLykv
                      PuW+LNrnF+xcD2MGe67xiTzZ9/Uy1wPRvpnW8HIyXLZP3gAG4b68ENeNa5JDYeZ16jM++y
                      QFRGcVjppvSCHvTDQOGuQ0+xhLGcMwAqZhQ8FnneVF3ywdYgYcoPtXRen1VSIf8BPyF+p3
                      gIAROxU4LkxVZEAAAAEBAN0zpCoBvRqSIezmtOBg3HSoV5p62KYPXU6xNcUU2UzYmkbyxX
                      iKH/xtMJyU2NHouzuurxrwbc7QnypexZdZZC75XE4yiDANsiwOAYXnzJBSKUOE4q7cKitQ
                      pEf6Y22tj9agW7g743xt3R2Ny2TKgwAXAKHoutrk2R0uIG8gBlI12q3gYH6+VPVUM7Ro06
                      xyPSsHHJSiJpPLY7vjYRxwh09G1rKe02oAqP38TnAh4aEttbBomtEtSTwq5pbmy1UXjZwl
                      M71dbrxL5+yic5SO7LcXlYqiPOBBw+3Gpf1Cq6gdGRXG2SldnPlPn1GY7KdO6ma1POQrQh
                      krbmtf2tY9FP0AAAEBAM1nv+066pYI1N2yVFc+rF37CWfs3W+OdawLc/treCV12WtnnqAr
                      Jx/ZrkUg3NeXXSdhB3XRbS6zEllVjLzpATAs2Rrzgy4FlvOXixo4DGHmtnbGHwuKB0x35j
                      Dh3XemoWm+TaSbdD0qDTaHeKKyhJCHjYqSWT4PscLStziaC56sGz5ilCUb5UJYHs2zHau3
                      RPBQn5l35B/mJUOVZ0YGdKwpGDUtgEFQt5Mkyn93CmmT+JRqJPbQZbYQmEtBm/pAD7cW1C
                      hI8InylNxJd3UCe0dQ6HdEvxbM7eiHyhJy0r3UJydiE09nrQwnHhQqStg5Zm05YpjCTt33
                      DTET/Um4HXsAAAARMTE4MTk2MzAxMkBxcS5jb20BAg==
                      -----END OPENSSH PRIVATE KEY-----
```

下表描述了 SSH 配置属性。

*表1：SSH  配置属性*

| 属性名                     | 描述                                                         |
| -------------------------- | ------------------------------------------------------------ |
| `ignoreLocalSettings`      | 如果为 `true`，请使用基于属性而非基于文件的 SSH 配置。必须在 `spring.cloud.config.server.git.ignoreLocalSettings` 中定义，而不是在仓库定义中设置 |
| `privateKey`               | 有效的 SSH 私钥。如果 `ignoreLocalSettings` 为 `true` 且 Git URI 为 SSH 格式，则必须设置此项 |
| `hostKey`                  | 有效的 SSH 主机密钥，如果同时设置了 `hostKeyAlgorithm` ，则必须设置此项 |
| `hostKeyAlgorithm`         | 可以是 `ssh-dss`、`ssh-rsa`、`ssh-rd25519`、`ecdsa-sha2-nistp256`、`ecdsa-sha2-nistp384` 或 `ecdsa-sha2-nistp521` 之一。如果同时设置了 `hostKey`，则必须设置此项 |
| `strictHostKeyChecking`    | `true` 或 `false`，如果为 `false`，则忽略 `hostKey` 错误     |
| `knownHostsFile`           | 自定义 `.known_hosts` 文件的位置                             |
| `preferredAuthentications` | 覆盖服务器身份验证方法顺序，如果服务器在公钥方法之前启用了键盘交互式身份验证，则此操作应允许绕过登录提示 |

#### Git Search Paths 中的占位符

Spring Cloud Config Server 还支持带有 `{application}` 和 `{profile}`（如果需要，还可以有 `{label}`）占位符的搜索路径，如下例所示：

```yaml
spring:
	cloud:
		config:
			server:
				git:
					uri: https://github.com/spring-cloud-samples/config-repo
					search-paths: '\{application}'
```

上述命令会在仓库中搜索与目录（以及顶层目录）同名的文件。搜索路径中也支持通配符（任何匹配的目录都会被包含在搜索范围内）。

#### 强制拉取 Git 仓库

如前所述，如果本地副本被修改（例如，操作系统进程更改了文件夹内容），导致 Spring Cloud Config Server 无法从远程存储库更新本地副本，Spring Cloud Config Server 会克隆远程 git 存储库。

为了解决这个问题，Spring Cloud Config Server 提供了一个 `force-pull` 属性，当本地副本已损坏时，该属性会强制 Spring Cloud Config Server 从远程存储库拉取数据，如下例所示：

```yaml
spring:
	cloud:
		config:
			server:
				git:
					uri: https://github.com/spring-cloud-samples/config-repo
					force-pull: true
```

如果你有多个存储库，则可以为每个存储库配置 `force-pull` 属性，如下例所示：

```yaml
spring:
	cloud:
		config:
			server:
				git:
					uri: https://git/common/config-repo.git
					repos:
						team-a:
							pattern: team-a-*
							uri: https://git/team-a/config-repo.git
							force-pull: true
						team-b:
							pattern: team-b-*
							uri: https://git/team-b/config-repo.git
              force-pull: true
						team-c:
							pattern: team-c-*
							uri: https://git/team-c/config-repo.git
```

> `force-pull` 属性的默认值为 `false`。

#### 删除  Git 仓库中未跟踪的分支

由于 Spring Cloud Config Server 在将分支检出到本地仓库后（例如，通过标签获取属性）或保留远程 Git 仓库的副本，因此它会一直保留该分支，知道下次服务器重启（重启会创建一个新的本地仓库）。所以可能会出现这样的情况：远程分支被删除，但其本地副本仍然可用。如果  Spring Cloud Config Server 客户端服务启动时使用 `--spring.cloud.config.label=deleteRemoteBranch,master` 参数， 它会从 `deleteRemoteBranch` 本地分支获取属性，但不会cong `master`  分支获取属性。

为了保持本地仓库分支的整洁与远程仓库保持同步，可以设置 `deleteUntrackedBranches` 属性。这将使 Spring Cloud Config Server 强制删除本地仓库中未跟踪的分支。例如：

```yaml
spring:
	cloud:
		config:
			server:
				git:
					uri: https://github.com/spring-cloud-samples/config-repo
					deleteUntrackedBranches: true
```

> `deleteUntrackedBranches` 属性的默认值为 `false`。

#### Git 刷新频率

你可以使用 `spring.cloud.config.server.git.refreshRate`  来控制 Config Server 从 Git 后端获取更新配置数据的频率。此属性的值以秒为单位。默认值为 0，表示 Config Server 每次请求时都会从 Git 仓库获取最新的配置 。如果该值为负数，则不会刷新。

#### Git 后端不可用时的行为

理解 Config Server 在 Git 后端访问时的行为方式，对于规划弹性部署至关重要。

##### At Startup

默认情况下，Config Server 会在首次请求时（延迟克隆）克隆 Git 仓库，而不是在启动时就克隆。这意味着配置错误或无法访问的 Git URI 不会阻止服务器启动——错误只有在收到第一个配置请求时才显示。

为了及早发现仓库问题，请设置 `spring.cloud.config.server.git.cloneOnStart=true`。这样，服务器将在启动时尝试克隆仓库，如果仓库无法访问或配置错误，则会快速失败。

```yaml
spring:
	cloud:
		config:
			server:
				git:
					uri: https://github.com/my-org/config-repo
					clone-on-start: true
```

也可以使用健康指示器通过 `/actuator/health` 端点在启动后检测后端问题。

##### After a Successful Startup

Config Server 启动并克隆代码仓库后，会在磁盘上保留一份本地工作副本。如果远程 Git 后端在成功启动后不可用，Config Server 将继续从其本地工作副本提供配置服务。只要本地副本包含请求的分支和文件 ，客户端仍然可以收到 有效的响应。

如果将 `spring.cloud.config.server.git.refreshRate` 设置为正值（以秒为单位），服务器会定期尝试从远程仓库获取更新。当远程仓库宕机时，这些获取尝试会静默失败，本地副本将被奥驰上次获取的版本。一旦远程仓库回复可用，下一次 计划内或请求触发的获取操作就会成功，并将本地副本更新到最新版本 。

##### Local Copy Drift 和 Force Pull

如果本地工作副本与远程副本存在差异（例如，由于手动编辑或合并失败），后续的拉取操作可能无法覆盖冲突的本地更改。为确保本地副本始终与远程副本保持一致，请启用强制拉取：

```yaml
spring:
	cloud:
		config:
			server:
				git:
					uri: https://github.com/my-org/config-repo
					force-pull: true
```

启用 `force-pull` 后，Config Server 会在每次拉取使丢弃所有本地修改，并将工作副本重置为与远程仓库一致。有关详细信息，请参阅 Git 仓库中的强制拉取。

##### Effect on Client Refresh

当客户端应用程序触发了配置刷新（例如，通过 Spring Cloud Bus 的 `/actuator/refresh` 接口）且 Config Server 无法连接到 Git 后端时，Config Server 会从其本地工作副本（如果存在）返回配置。如果不存在本地副本（例如，服务器在 Git 后端宕机后重启，且启用了延迟克隆），Config Server 会向客户端返回错误，客户单应保留其当前配置。

#### 默认 Label

Git 的默认标签是 `main`。如果你没有设置 `spring.cloud.config.server.git.defaultLabel` 并且名为 `main` 的分支不存在，则 Config Server 默认还会尝试检出名为 `master` 的分支。如果你想禁用此备用分支行为，可以将 `spring.cloud.config.server.git.tryMaster` 设置为 `false`。

#### 在容器中使用 Git 运行 Config Server

如果在类似以下的容器中运行 Config Server 是遇到 `java.io.IOException` 异常：

```
2022-01-03 20:04:02,892 [tributeWriter-2] ERROR org.eclipse.jgit.util.FS$FileStoreAttributes.saveToConfig - Cannot save config file 'FileBasedConfig[/.config/jgit/config]'
java.io.IOException: Creating directories for /.config/jgit failed
```

你必须：

- 为用户在容器内提供一个可写的主目录
- 在容器内设置环境变量 `XDG_CONFIG_FILE`，使其指向 Java 进程具有写入权限的目录



### 版本控制后端文件系统使用

> 使用基于版本控制系统（git、svn）的后端时，文件会被检出或克隆到本地文件系统。默认情况下，它们会被放置在系统临时目录中，并以 `config-repo-` 为前缀。例如，在 Linux 系统中，它可能是 `/tmp/config-repo-<randomID>`。某些操作系统会定期清理临时目录。这可能会导致一些意外行为，例如属性丢失。为了避免这个问题，可以通过设置 `spring.cloud.config.server.git.basedir` 或 `spring.cloud.config.server.svn.basedir` 来更改 Config Server 使用的目录。

#### 本地路径加固

当版本控制后端（Git 或 SVN）访问本地文件系统时，会应用额外的检查来降低检查时/使用时（TOCTOU）风险和避免不必要的符号连接行为。这些缓解措施是对常规主机加固措施（文件系统权限、专用服务账户和非全局可写父目录）的补充，而非替代。

*file: 仓库 URI*

在 SCM 客户端打开文件仓库之前，服务器会解析配置的路径，并拒绝在仓库根目录或任何中间路径组合中找到的任何符号链接。路径的每个部分都会使用 `LinkOptions.NOFOLLOW_LINKS` 进行单独检查，因此将符号链接放置在父目录而不是叶子目录中并不能绕过此限制。对于 Git，还会额外验证仓库根目录中的 `.git` 条目是否为真实目录而非符号链接 。为所有 `file:` URI 配置具体的、非符号链接的目录路径。

*工作目录和基础目录（spring.cloud.config.server.[git/svn].basedir）*

当服务器克隆或检出到 `basedir` 目录时，它会准备一个空的叶子目录（包括删除该路径上的所有先前符号链接），然后使用独占的操作系统级目录创建操作来创建叶子目录，这样，如果路径被同时替换，则会报错，而不是静默地重定向 SCM 操作。递归删除过程中，旧内容会被移除，而不会跟踪目录符号链接。在调用 SCM 客户端之前，会立即重新验证已解析的 `basedir` 路径，以缩小并发路径替换的时间窗口。对于 SVN，每次更新操作之前还会重新验证工作目录及其 `.svn` 元数据目录。

*临时目录清理*

当 `basedir` 目录自动创建时（默认情况下，如果没有显式配置），JVM 会注册一个关闭钩子，以便在进程推出时将其删除。该钩子使用符号连接安全的递归删除；它不会跟踪目录符号链接，并且在继续操作之前会检查 `basedir` 目录本身是否已被符号链接替换。如果检测到符号链接被替换，则只会删除该符号链接；目标临时目录之外的文件不会受到影响。

#### 使用多个标签进行错误处理

如果向 Config Server 发出请求，且该请求包含多个标签，则 Config Server 将返回每个标签的属性源。但是，如果尝试获取其中一个标签时出错，则 Config Server 将返回错误，而不会尝试获取任何剩余标签。

如果你希望 Config Server 在标签无效时忽略任何错误，并在返回错误之前尝试所有标签，你可以设置 `spring.cloud.config.server.[git|svn].continue-on-multiple-label-failure=true`。



### 文件系统后端

Config Server 中还有一个**原生**配置文件，它不使用 Git，而是从本地类路径或文件系统加载配置文件（你可以使用 `spring.cloud.config.server.native.searchLocations` 指向任何静态 URL）。要使用原生配置文件，请使用 `spring.profiles.active=native` 启动 Config Server。

> 请记住，文件资源应使用 `file:` 前缀（默认情况下， 不使用前缀的路径通常是类路径）。与任何 Spring Boot 配置一样，你可以嵌入 `${}` 风格的环境变量占位符，但请记住，Windows 中的绝对路径需要额外添加一个 `/`（例如，`/${user.home}/config-repo`）。

> `searchLocations` 的默认值与本地 Spring Boot 应用程序相同（即 `[classpath:/, classpath:/config, file:./, file:./config]`）。这样不会将服务器上的 `application.properties` 文件暴露给所有客户端，因为服务器中存在的 任何属性源都会在发给客户端之前被移除。

> 文件系统后端非常适合快速入门和测试。但要在生产环境中使用，则需要确保文件系统可靠，并且在所有配置服务器实例之间共享。

`searchLocations` 可以包含 `{application}`、`{profile}` 和 `{label}` 的占位符。这样，你可以将路径中的目录分开，并选择适合你的策略（例如，每个应用程序一个子目录或者每个配置文件一个目录）。

如果你未在 `searchLocations` 中使用占位符，此存储库还会将 HTTP 资源的 `{label}` 参数附加到 `searchLocations` 的后缀，以便从每个搜索位置以及与标签同名的子目录加载属性文件（在 Spring `Environment` 中，带标签的属性优先）。因此，不适用占位符的默认行为与添加以 `{label}` 结尾的 `searchLocations` 相同。例如，`file:/tmp/config` 与 `file:/tmp/config,file:/tmp/config/{label}` 的效果相同。可以通过设置 `spring.cloud.config.server.native.addLabelLocations=false` 来禁用此行为。



### Vault 后端

Spring Cloud Config Server 也支持 Vault 作为后端。

> Vault 是一款用于安全访问 `secrets` 的工具。`secret` 是指任何需要严格控制访问权限的内容，例如 API 密钥、密码、证书和其他敏感信息。Vault 提供统一的接口来管理所有 `secrets`，同时提供严格的访问控制并记录详细的审计日志。

有关 Vault 的更多信息，请参阅 Vault 快速入门指南。

要使 Config Server 能够使用 Vault 后端 ，你可以使用 Vault 配置文件运行 Config Sever。例如，在 Config Server 的 `application.properties`  文件中，你可以添加 `spring.profiles.active=vault`。

> 默认情况下，Spring Cloud Config Server 使用基于 Token 的身份验证从 Vault 获取配置。Vault 还支持其他身份验证方法，例如 AppRole、LDAP、JWT、Cloud Foundary 和 Kubernetes Auth。要使用除 TOKEN 或 X-Config-Token 标头之外的任何身份验证方法，我们需要将 Spring Vault Core 添加到类路径中，以便 Config Server 可以将身份验证委托给该库。请将以下依赖项添加到你的 Config Server 应用程序中。
>
> *Maven（pom.xml）*
>
> ```xml
> <dependencies>
>   <dependency>
>   	<groupId>org.springframework.vault</groupId>
>     <artifaceId>spring-vault-core</artifaceId>
>   </dependency>
> </dependencies>
> ```
>
> *Gradle（build.gradle）*
>
> ```groovy
> dependencies {
> 	implementation "org.springframework.vault:spring-vault-core"
> }
> ```

默认情况下，Config Server 假定你的 Vault 服务器运行在 `127.0.0.1:8200`。他还假定后端名称为 `secret`，密钥为 `application`。所有这些默认设置都可以在 Config Server 的 `application.properties` 文件中进行配置。下表描述了可配置的 Vault 属性：

| 名称              | 默认值                                   |
| ----------------- | ---------------------------------------- |
| host              | 127.0.01                                 |
| port              | 8200                                     |
| scheme            | http                                     |
| backend           | secret                                   |
| fullKeyPath       | false                                    |
| defaultKey        | application                              |
| defaultLabel      | main（仅当 `enableLabel` 设置为 `true`） |
| enableLabel       | false                                    |
| profileSeparator  | ,                                        |
| kvVersion         | 1                                        |
| skipSslValidation | false                                    |
| timeout           | 5                                        |
| namespace         | null                                     |

> 上表中所有属性都必须以 `spring.cloud.config.server.vault` 为前缀，或者放置在复合配置的正确 Vault 部分中。

所有配置属性都可以再 `org.springframework.cloud.config.server.environment.VaultEnvironmentProperties`。

> Vault 0.10.0 引入了版本化 `key-value` 后端（`k/v`后端版本 2），其 API 与早期版本有所不同。它现在要求在挂载路径和实际上下文路径之间添加一个 `data/` 目录，并将密钥封装在数据对象中。设置 `spring.cloud.config.server.vault.kv-version=2` 生效。

Vault Enterprise 可选地支持 `X-Vault-Namespace` 标头，要将其发送到 Vault，请设置 `namespace` 属性。

Config Server 运行后，你可以向服务器发送 HTTP 请求，从 Vault 后端检索值。为此，你需要 Vault 服务器的令牌。

首先，将一些数据放入你的 Vaul 中，如下例所示：

```bash
$ vault kv put secret/application foo=bar baz=bam
$ vault kv put secret/myapp foo=myappsbar
```

其次，向 Config Server 发出一个 HTTP 请求以检索值，如下例所示：

```bash
$ curl -X "GET" "http://localhost:8888/myapp/default" -H "X-Config-Token: yourtoken"
```

你应该会看到类似以下内容的回复：

```json
{
  "name": "myapp",
  "profiles": [
    "default"
  ],
  "label": null,
  "version": null,
  "state": null,
  "propertySources": [
    {
      "name": "valut:myapp",
      "source": {
        "foo": "myappsbar"
      }
    },
    {
      "name": "valut:application",
      "source": {
        "baz": "bam",
        "foo": "bar",
      }
    }
  ]
}
```

客户端为 Config Server 与 Vault 通信提供必要身份验证的默认方式是设置 `X-Config-Token` 标头。但是，你也可以省略此标头，并在服务器端配置身份验证，方法是设置与 Spring Cloud Vault 相同的配置属性。要设置的属性是 `spring.cloud.config.server.vault.authentication`。它应该设置为受支持的身份验证方法之一。你可能还需要设置其他特定于你所用身份验证方法的属性，属性名称与 `spring.cloud.vault` 文档中描述的相同，但前缀改为 `spring.cloud.config.server.vault`。更多详情请参阅 Spring Cloud Vault 参考指南。

> 如果省略 `X-Config-Token` 标头并使用服务器属性属性设置身份验证，则 Config Server 应用程序需要额外依赖 Spring Vault 才能启动其他身份验证选项。有关如何添加此依赖项，请参阅 Spring Vault 参考指南。

#### 多属性源

使用 Vault 时，你可以为应用程序提供多个属性源。例如，假设你已将数据写入 Vault 中的以下路径：

```bash
secret/myApp.dev
secret/myApp
secret/application.dev
secret/application
```

写入 `secret/application` 目录的属性可供所有使用 Config Server 的应用程序访问。例如，名为 `myApp` 的应用程序可以访问写入 `secret/myApp` 和 `secret/application` 目录的所有属性。当 `myApp` 启用 `dev profile` 时，写入上述所有路径的属性都可供其访问，其中列表中第一个路径的属性优先级最高。

#### 消除复合属性来源的歧义

默认情况下，Config Server 会根据 Vault 键生成属性源名称，例如上例中的 `vault:myApp`。当复合 Vault 后端具有相同的 Vault 键时，Config Server 客户端会覆盖先前的属性源。

将 `fullKeyPath` 设置为 `true` 后，属性源将包含完整的后端路径，例如 `vault:secret/backendA/myApp` 和 `vault:secret/backendB/myApp`，从而防止覆盖前面的属性源。

```yaml
spring.cloud.config.server.composite:
	- type: vault
		fullKeyPath: true
		# ...
		backend: secret/backendA
	- type: vault
		fullKeyPath: true
		# ...
		backend: secret/backendB
```

#### 启用按标签搜索

默认情况下 ，Vault 后端在搜索密钥时不可使用标签。你可以通过将 `enableLabel` 功能标志设置未 `true` 来更改此设置，并且可以选择设置 `defaultLabel`。如果未提供 `defaultLabel`，则将使用 `main` 标签。

启用 `enableLabel` 功能标志后，Vault 中的密钥路径中必须始终包含所有三个部分（application 名称，profile 和 label）。因此，上一节中的示例，在启用该功能标志后，将如下所示：

```bash
secret/myApp,dev,myLabel
secret/myApp,default,myLabel				# default profile
secret/application,dev,myLabel			# default application name
secret/application,default,myLabel	# default application name and default profile
```

#### 解密属性源中 Vault Secrets

Spring Cloud Config Server 支持使用特殊的占位符前缀 `{vault}` 来解密 Vault 中的属性。此功能允许在运行时直接从 Vault 动态解析敏感的配置属性。

##### 配置步骤

所有与 Vault 集成相关的配置都应放在 `application.yml` 或 `application.properties` 文件中。以下是激活 Vault 配置文件、连接到 Vault 服务器以及使用 `{vault}` 前缀格式化属性所需的具体配置。

###### 启用 Vault Profile

为 Spring Cloud Config Server 激活 Vault Profile：

```yaml
spring:
	profiles:
		active: vault
```

###### Vault 配置

使用必要的身份验证详细信息设置与 Vault 服务器的连接：

```yaml
spring:
	cloud:
		config:
			server:
				vault:
					host: vault.example.com
					port: 8200
					scheme: https
					backend: secret
					defaultKey: application
					kvVersion: 2
					authentication: TOKEN
					token: ${VAULT_TOKEN}
					skipSslValidation: true
```

这些设置指定了 Vault 服务器地址、身份验证方法以及访问 Vault 所需的令牌。

###### 属性格式

使用 `{vault}` 前缀定义属性，以指定用于检索密钥的 Vault 路径和密钥：

```yaml
some:
	sensitive:
		value: '{vault:}:path/to/secret#key'
```

此格式直接映射到 Vault 中存储密钥的位置（`path/to/secret`）和要检索的特定密钥（`key`）。

##### 错误处理

如果 Config Server 在解密过程中遇到任何问题，例如路径错误、访问问题或密钥缺失，受影响的属性将被添加 `invalid` 前缀，其值将被设置为 `<n/a>`。这种方法类似于处理以 `{cipher}` 为前缀的属性，但它是专门针对与  Vault 集成而设计的，可在解密失败时提供清晰的反馈。



# 通过代理访问后端

Config Server 可以通过 HTTP 或 HTTPS 代理访问 Git 或 Vault 后端。此行为由 `proxy.http` 和 `proxy.https` 下的设置控制，分别针对 Git 和 Vault。这些设置是针对每个仓库的，因此，如何你使用的是复合环境仓库，则必须为复合环境中的每个后端单独配置代理配置。如何使用的网络需要为 HTTP 和 HTTPS URL 分别配置代理服务器，则可以同时配置 HTTP 和 HTTPS 代理设置：在这种情况下，`http` 访问将使用 HTTP 代理，`https` 访问将使用 HTTPS 代理。此外，你还可以通过应用程序和代理之间的代理定义协议，指定一个用于两种协议的代理。

下表描述了 HTTP 和 HTTPS 代理的代理配置属性。所有这些属性都必须以 `proxy.http` 或 `proxy.https` 为前缀。

*表1：代理配置属性*

| 属性名        | 描述                                                         |
| ------------- | ------------------------------------------------------------ |
| host          | 代理主机                                                     |
| port          | 访问代理的端口                                               |
| nonPorxyHosts | Config Server 应访问代理服务器之外的任何主机。如果同时提供了 `proxy.http.nonProxyHosts` 和 `proxy.https.nonProxyHosts` 的值，则使用 `proxy.http` 的值 |
| username      | 用于向代理服务器进行身份验证的用户名。如果同时提供了 `proxy.http.username` 和 `proxy.https.username` 的值，则使用 `proxy.http` 的值 |
| password      | 用于向代理服务器进行身份验证的密码。如果同时提供了 `proxy.http.password` 和 `proxy.https.password` 的值，则使用 `proxy.http` 的值 |

以下配置使用 HTTPS 代理访问 Git 存储库。

```yaml
spring:
	profiles:
		active: git
	cloud:
		config:
			server:
				git:
					uri: https://github.com/spring-cloud-samples/config-repo
					proxy:
						https:
							host: my-proxy.host.io
							port: '3128'
							username: myproxyusername
							password: myproxypassword
							nonProxyHosts: example.com
```



### 与所有应用程序共享配置

根据你采用的方法，所有应用程序之间的配置共享方式会有所不同，如下文所述：

- 基于文件的仓库
- Vault Server
- Credhub Server
- JDBC 仓库

#### 基于文件的仓库

对于基于文件（git、svn 和 native）的仓库，文件名以 `appplication*` 开头的资源（例如 `application.properties`、`application.yml`、`application-*.properties` 等）在所有客户端应用程序之间共享。你可以使用这些文件名的资源来配置全局默认值，并根据需要让应用程序特定的文件覆盖这些默认值。

属性覆盖功能还可以用于设置全局默认值，允许占位符应用程序在本地覆盖这些默认值。

> 使用 **native** profile（本地文件系统后端）时，你应该使用一个显示的 `searchLocations`，该位置不应该包含在服务器自身的配置中，否则，默认的搜索位置中的 `application` 资源将被移除，因为它们是服务器的一部分。

#### Vault Server

当使用 Vault 作为后端时，你可以通过将配置放在 `secret/application` 目录中，与所有应用程序共享配置。例如，如果你运行以下 Vault 命令，则所有使用该 Config Server 的应用程序都可以使用属性 `foo` 和 `baz`：

```bash
$ vault write secret/application foo=bar baz=bam
```

#### Credhub Server

当使用 Credhub 作为后端时，你可以通过将配置放在 `/application` 目录下或将其放置在应用程序的 `default profile` 中，与所有应用程序共享配置。例如，如果你运行以下 Credhub 命令，则所有使用该 Config Server 的应用程序都将可以使用 `shared.color1` 和 `shared.color2` 属性：

```bash
credhub set --name "/application/profile/master/shared" --type=json
// TODO 此处示例填写错误
value: {"shared.color1": "blue", "shared.color2": "red"}
```

```bash
credhub set --name "/my-app/default/master/more-shared" --type=json
// TODO 此处示例填写错误
value: {"shared.word1": "hello", "shared.word2": "world"}
```

#### JDBC Environment 仓库

要使用 JDBC 后端共享配置，请在数据库中插入记录，并将 application 列的值设置为 `application` ，以便所有客户端都能共享这些记录，然后，应用程序特定的属性可以覆盖这些共享配置，从而为应用程序提供灵活性和控制力。

```sql
INSERT INTO PROPERTIES (APPLICATION, PROFILE, LABEL, KEY, VALUE)
VALUES ('application', 'default', 'master', 'a.b.c', 'shared-value');
INSERT INTO PROPERTIES (APPLICATION, PROFILE, LABEL, KEY, VALUE)
VALUES ('myapp', 'prod', 'master', 'd.e.f', 'specific-value');
```

有关使用 JDBC 存储库进行设置和管理的详细示例，请参阅 `JdbcEnvironmentRepository` 实现和相关测试。






# Spring Cloud Config Client





# 可观测性