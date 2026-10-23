# 背景

每个开发者都会经历这样的时刻：你写了一个简单的简单来检查 API  是否正常运行，结果六个月后，整个团队都依赖它。脚本不断添加各种标志、配置文件，突然间，你维护的这个工具就成了一个需要正式打包的工具。如果你也经历过这种情况，那么 Go 无疑是重构这个工具的最佳语言。

在本教程中，我们将构建 `healthcheck`——一个用于监控  API 健康端点、报告状态并以相应代码退出的 CLI 工具，以便集成到 CI/CD 环境中。我们将介绍如何使用 Cobra 搭建项目框架、如何使用 Viper 进行配置管理、测试策略以及如何通过 GoReleaser  和 Homebrew 进行分发。教程结束时，你将获得一套可复用的方案，用于将任何 CLI 工具部署到生产环境。



# 为什么选择 Go 来 开发命令行工具？

在编写任何一行代码之前，有必要了解为什么 Go 已成为命令行工具的事实标准语言。像 `kubectl`、`docker`、`gh`、`terraform` 和 `hugo` 这样的工具都是用 Go 编写的，这绝非偶然。

**单文件二进制分发**。Go 编译成静态链接的二进制文件，没有任何运行时依赖项。只需发布一个文件。无需 `pip install`，无需 `node_modules`，也无需 JVM。用户下载后即可运行。

**交叉编译非常简单**。只需在运行 `go build` 之前设置 `GOOS=linux GOARCH=amd64`，即可在 Mac 上生成 Linux 二进制文件。无需交叉编译工具链，也无需复杂的 Docker 配置 。

**启动速度极快**。Go 二进制文件只需几毫秒即可启动。相比之下，Python 或 Java 命令行工具仅加载解释器或 JVM 就需要数百毫秒。对于用户每天调用数十次的工具而言，这一点至关重要。

**强大的标准库**。HTTP 客户端、JSON 解析、文件 I/O、并发原语——Go 标准库涵盖了 CLI  工具所需的大部分功能，无需引入外部依赖项。



# 项目设置 

让我们初始化项目：

```bash
mkdir healthcheck && cd healthcheck
go mod init github.com/mawen12/healthcheck
```

按照我们将要使用的两个库：

```bash
go get github.com/spf13/cobra@latest
go get github.com/spf13/viper@latest
```

创建以下目录结构：

```
healthcheck/
	cmd/
		root.go
		check.go
		version.go
	internal/
		checker/
			checker.go
			checker_test.go
		config/
			config.go
	main.go
	go.mod
	go.sum
```

# 使用 Cobra 进行引导

Cobra 为命令、标志和帮助文本提供了一致的结构。从入口点开始：

```go
// main.go
package main

import "github.com/mawen12/healthcheck/cmd"

func main() {
  cmd.Execute()
}
```

现在定义 root 命令：

```go
// cmd/root.go
package cmd

import (
	"fmt"
  "os"
  
  "github.com/spf13/cobra"
  "github.com/spf13/viper"
)

var cfgFile string

var rootCmd := &cobra.Command{
  Use: 		"healthcheck",
  Short: 	"Monitor API health endpoints",
  Long: 	`healthcheck is a CLI tool that monitors API health endpoints, reports their status, and exists with appropriate codes for CI/CD integration.`,
}

func Execute() {
  if err := rootCmd.Execute(); err != nil {
    fmt.Fprintln(os.Stderr, err)
    os.Exit(1)
  }
}

func init() {
  cobra.OnInitialize(initConfig)
  rootCmd.PersistentFlags().StringVar(&cfgFile,"config", "", "config file (default is$HOME/.healthcheck.yaml)")
  rootCmd.PersistentFlags().IntP("timeout", "t", 5, "HTTP timeout in seconds")
  rootCmd.PersistentFlags().BoolP("verbose", "v", false, "enable verbose output")
  
  viper.BindPFlag("timeout", rootCmd.PersistentFlags().Lookup("timeout"))
  viper.BindPFlag("verbose", rootCmd.PersistentFlags().Lookup("verbose"))  
}

func initConfig() {
  if cfgFile != "" {
    viper.SetConfigFile(cfgFile)
  } else {
    home, err := os.UserHomeDir()
    cobra.CheckErr(err)
    
    viper.AddConfigPath(home)
    viper.AddConfigPath(".")
    viper.SetConfigType("yaml")
    viper.SetConfigName(".healthcheck")
  }
  
  viper.SetEnvPrefix("HEALTHCHECK")
  viper.AutomaticEnv()
  
  if err := viper.ReadInConfig(); err != nil {
    if viper.GetBool("verbose") {
      fmt.Fprintln(os.Stderr, "Using config file:", viper.ConfigFileUsed())
    }
  }
}
```

尽早添加 version 命令总是值得的。它使用户能够带着上下文信息报告错误，我们稍后会将其集成到 GoReleaser 中：

```go
// cmd/version.go
package cmd

import (
	"fmt"
  
  "github.com/spf13/cobra"
)

// 这些是在构建期间通过 ldflags 设置的
var (
	version = "dev"
  commit = "none"
  date = "unknown"
)

var versionCmd = &cobra.Command{
  Use: "version",
  Short: "Print version information",
  Run: func(cmd *cobra.Command, args []string) {
    fmt.Printf("healthcheck %s (commit: %s, built: %s)\n", version, commit, date)
  },
}

func init() {
  rootCmd.AddCommand(versionCmd)
}
```



# 使用 Viper 进行配置

当你的工具需要从多个来源读取配置时，Viper 的优势就显现出来了。它会将配置文件、环境变量和标志中的值合并，并明确区分优先级：标志会覆盖环境变量、环境变量又会覆盖配置文件。

在 `internal/config/config.go` 中定义配置结构：

```go
// internal/config/config.go
package config

import "github.com/spf13/viper"

type Endpoint struct {
  Name string `mapstruct:"name"`
  URL string `mapstruct:"url"`
  Method string `mapstruct:"method"`
  ExpectCode int `mapstruct:"expect_code"`
  ExpectBody string `mapstruct:"expect_body"`
}

type Config struct {
  Timeout int `mapstruct:"timeout"`
  Verbose bool `mapstruct:"verbose"`
  Endpoints []Endpoint `mapstruct:"endpoints"`
}

func Load() (*Config, error) {
  var cfg *Config
  if err := viper.Unmarshal(&cfg); err != nil {
    return nil, err
  }
  
  for i := range cfg.Endpoints {
    if cfg.Endpoints[i].Method == "" {
      cfg.Endpoints[i].Method = "GET"
    }
    if cfg.Endpoints[i].ExpectCode == 0 {
      cfg.Endpoints[i].ExpectCode = 200
    }
  }
  return &cfg, nil
}
```

以下是一个示例 `.healthcheck.yaml` 配置文件：

```yaml
timeout: 10
verbose: false
endpoints:
	- name: Production API
		url: https://api.example.com/health
		expect_code: 200
		expect_body: '"status": "ok"'
	- name: Staging API
		url: https://staging-api.example.com/health
		expect_code: 200
  - name: Auth Service
		url: https://auth.example.com/ping
		method: HEAD
		expect_code: 204
```

**注意**：Viper 的 `Unmarshal` 用的是  `mapstruct` 标签，而不是 `json` 或 `yaml` 标签。这几乎是第一次让所有人都兴奋不已。如果字段无法填充，请检查你的结构标签。



# 实现健康检查

核心逻辑位于 `internal/checker/checker.go` 中。我们将同时发出 HTTP 请求并收集结果。我们将同时发出 HTTP 请求并收集结果：

```go
// internal/checker/checker.go
package checker

import (
	"context"
  "fmt"
  "io"
  "net/http"
  "strings"
  "sync"
  "time"
)

type Endpoint struct {
  Name string
  URL string
  Method string
  ExpectCode int
  ExpectBody string
}

type Result struct {
 	Endpoint Endpoint
  Status int
  Duration time.Duration
  Body string
  Err error
  Healthy bool
}

type Checker struct {
  client *http.Client
  verbose bool
}

func New(timeout time.Duration, verbose bool) *Checker {
  return &Checker{
    client: &http.Client{
      Timeout: timeout,
    },
    verbose: verbose,
  }
}

func (c *Checker) CheckAll(ctx context.Context, endpoints []Endpoint) []Result {
  results := make([]Result, len(endpoints))
  var wg sync.WaitGroup
  
  for i, ep := range endpoints {
    wg.Add(1)
    go func(idx int, endpoint Endpoint) {
      defer wg.Done()
      results[idx] = c.check(ctx,  endpoint)
    }(i, ep)
  }
  
  wg.Wait()
  return results
}

func (c *Checker) check(ctx context.Context, ep Endpoint) Result {
  result := Result{Endpoint: ep}
  
  req, err := http.NewRequestWithContext(ctx, ep.Method, ep.URL, nil)
  if err != nil  {
    result.Err = fmt.Error("creating request: %w", err)
    return result
  }
  
  req.Header.Set("User-Agent", "healthcheck-cli/1.0")
  
  start = time.Now()
  resp, err := c.client.Do(req)
  result.Duration = time.Since(start)
  
  if err != nil {
    result.Err = fmt.Errorf("request failed: %w", err)
    return result
  }
  defer resp.Body.Close()
  
  result.Status = resp.StatusCode
  
  bodyBytes, err := io.ReadAll(io.LimitReader(resp.Body, 1<<20))
  if err != nil {
    result.Err = fmt.Errorf("reading body: %w", err)
    return result
  }
  result.Body = string(bodyBytes)
  
  result.Healthy = result.Status == ep.ExectCode
  if ep.ExpectBody != "" && !strings.Contains(result.Body, ep.ExpectBody) {
    result.Healthy = false
  }
 	
  return result
}

func (r *Result) Summary() string {
  icon = "OK"
  if !r.Healthy {
    icon = "FAIL"
  }
  if r.Err != nil {
    return fmt.Sprintf("[%s] %-25s  error: %v", "ERR ", r.Endpoint.Name, r.Err)
  }
  return fmt.Sprintf("[%s] %s-25s  status=%d time=%dms", icon, r.Endpoint.Name, r.Status, r.Duration.Milliseconds())
}
```

现在将其连接到 `check` 命令：

```go
// cmd/check.go
package cmd

import (
	"context"
  "fmt"
  "os"
  "time"
  
  "github.com/spf13/cobra"
  "github.com/spf13/viper"
  "github.com/mawen12/healthcheck/internal/checker"
  "github.com/mawen12/healthcheck/internal/config"
)

var checkCmd = &cobra.Command{
  Use: "check",
  Short: "Check all configured health endpoints",
  Long: `Sends HTTP requests to all configured endpoints and reports their health status.`,
  RunE: func(cmd *cobra.Command, args []string) error {
    cfg, err := config.Load()
    if err != nil {
      return fmt.Errorf("loading config: %w", err)
    }
    
    if len(cfg.Endpoints) == 0 {
      return fmt.Errorf("no endpoints configured, create a .healthcheck.yaml file or use --config")
    }
    
    timeout := time.Duration(cfg.Timeout) * time.Second
    c := checker.New(timeout, cfg.Verbose)
    
    endpoints := make([]checker.Endpoint, len(cfg.Endpoints))
    for i, ep := range cfg.Endpoints {
      endpoints[i] = checker.Endpoints{
        Name: ep.Name,
        URL: ep.URL,
        Method: ep.Method,
        ExpectCode: ep.ExpectCode,
        ExpcetBody: ep.ExpectBody,
      }
    }
    
    ctx, cancel := context.WithTimeout(context.Background(), timeout*5*time.Second)
    defer cancel()
    
    results := c.CheckAll(ctx, endpoints)
    
    // Print results
    unhealthy := 0
    for _, r := range results {
      fmt.Println(r.Summary())
      if !r.Healthy {
        unhealthy++
      }
    }
    
    fmt.Printf("\n%d/%d endpoints healthy\n", len(results)-unhealthy, len(results))
    
    if unhealthy > 0 {
      os.Exit(1)
    }
    return nil
  },
}

func init() {
  rootCmd.AddCommand(checkCmd)
  checkCmd.Flags().StringSliceP("url", "u", nil, "check a single URL (can be repeated)")
  
  viper.BindPFlag("urls", checkCmd.Flags().Lookup("url"))
}
```

现在你可以运行：

```bash
go run . check --config .healthcheck.yaml
```

输出类似于：

```
[OK]   Production API			status=200 time=142ms
[FAIL] Staging API				status=503 time=89ms
[OK]   Auth Service				status=204 time=34ms

2/3 endpoints healthy
```

如果某个端点不健康，则该工具将使用代码 `1` 退出。这使得将其集成到 CI 管道或 shell 脚本中变得很容易。


# 添加测试

没有测试的 CLI 工具是个累赘。让我们从两个层面测试这个检查器：使用 HTTP 测试服务器评估进行单元测试，以及针对结果评估逻辑的集成式测试。

```go
// internal/checker/checker_test.go
package checker

import (
	"context"
  "net/http"
  "net/http/httptest"
  "testing"
  "time"
)

func TestCheck_HealthyEndpoint(t *testing.T) {
  server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(http.StatusOK)
    w.Write([]byte(`{"status":"ok"}`))
  }))
  defer server.Close()
  
  c := New(5*time.Second,  false)
  
  ep := Endpoint{
    Name: "Test API",
    URL: server.URL,
    Method: "GET",
    ExpectCode: 200,
    ExpectBody: `"status":"ok"`,
  }
  
  result := c.Check(context.Background(), ep)
  
  if result.Err != nil {
    t.Fatalf("unexpected error: %v", result.Err)
  }
  if !result.Healthy {
    t.Errorf("expected healthy, got unhealthy (status=%d)", result.Status)
  }
  if result.Duration == 0 {
    t.Error("expected non-zero duration")
  }
}

func TestCheck_UnhealthyStatusCode(t *testing.T) {
   server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
    w.WriteHeader(http.StatusServiceUnavailable)
  }))
  defer server.Close()
  
  c := New(5*time.Second,  false)
  
  ep := Endpoint{
    Name: "Failing API",
    URL: server.URL,
    Method: "GET",
    ExpectCode: 200,
  }
  
  result := c.Check(context.Background(), ep)
  
  if result.Err != nil {
    t.Fatalf("unexpected error: %v", result.Err)
  }
  if result.Healthy {
    t.Error("expected unhealthy, got healthy")
  }
}

func TestCheck_BodyMismatch(t *testing.T) {
   server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
	 	w.WriteHeader(http.StatusOK)
    w.Write([]byte(`{"status":"dgraded"}`)) 
  }))
  defer server.Close()
  
  c := New(5*time.Second,  false)
  
  ep := Endpoint{
    Name: "Degraded API",
    URL: server.URL,
    Method: "GET",
    ExpectCode: 200,
    ExpectBody: `"status":"ok"`,
  }
  
  result := c.Check(context.Background(), ep)
  
  if result.Healthy {
    t.Error("expected unhealthy due to body mismatch")
  }
}

func TestCheck_Timeout(t *testing.T) {
   server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
     time.Sleep(2 * time.Second)
		 w.WriteHeader(http.StatusOK)
  }))
  defer server.Close()
  
  c := New(100*time.Millisecond,  false)
  
  ep := Endpoint{
    Name: "Slow API",
    URL: server.URL,
    Method: "GET",
    ExpectCode: 200,
  }
  
  result := c.Check(context.Background(), ep)
  
  if result.Err == nil {
    t.Error("expected timeout error")
  }
}

func TestCheck_Concurrent(t *testing.T) {
   callCount := 0
   server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
     callCount++
		 w.WriteHeader(http.StatusOK)
  }))
  defer server.Close()
  
  c := New(5*time.Second,  false)
  
  endpoints = []Endpoint{
    {Name: "EP1", URL: server.URL, Method: "GET", ExpectCode: 200},
    {Name: "EP2", URL: server.URL, Method: "GET", ExpectCode: 200},
    {Name: "EP3", URL: server.URL, Method: "GET", ExpectCode: 200},
  }
  
  results := c.CheckAll(context.Background(), endpoints)
  
  if len(results) != 3 {
    t.Fatalf("expected 3 results got %d", len(results))
  }
  for i, r := range results {
    if !r.Healthy  {
      t.Errorf("endpoint %d: expected healthy", i)
    }
  }
}

func TestCheck_Summary(t *testing.T) {  
  result := Result{
    Endpoint: Endpoint{Name: "test"},
    Status: 200,
    Duration: 200*time.Millisecond,
    Healthy: true,
  }
  
  summary := r.Summary()
  
  if summary == "" {
    t.Error("expected non-empty summary")
  }
}
```

运行它们：

```bash
go test ./.. -v -race
```

`-race` 标志对于 CLI 工具至关重要。由于我们在 `CheckAll` 中使用了 goroutines，因此竞争检测器会捕获那些可能仅在生产负载下才会出现的竞争数据。

**提示**：在 Go 中测试 HTTP 交互时，务必使用 `httptest.NewServer`。它会在本地机器上启动一个真实的 HTTP 服务器，则意味着你的测试可以实际运行 `net/http` 协议栈，包括连接池 、超时和头部解析，而无需访问外部服务。



# 使用 GoReleaser 进行跨平台构建

GoReleaser 可自动为每种操作系统/架构组合构建二进制文件、创建 Github 发布版本并生成校验和。在项目根目录下创建 `.goreleaser.yaml` 文件。

```yaml
# .goreleaser.yaml
version: 2
project_name: healthcheck

before:
	hooks:
		- go mod tidy
		- go test ./..

builds:
	- env:
			- CGO_ENABLED=0
		goos:
			- linux
			- darwin
			- windows
		goarch:
			- amd64
			- arm64
		ldflags:
			- -s -w
			- -X github.com/mawen12/healthcheck/cmd.version={{.version}}
			- -X github.com/mawen12/healthcheck/cmd.commit={{.Commit}}
			- -X github.com/mawen12/healthcheck/cmd.date={{.Date}}
		
archives:
	- format: tar.gz
		name_template: "{{ .ProjectName }}_{{ .Version }}_{{ .Os }}_{{ .Arch }}"
		format_overrides:
			- goos: windows
				format: zip

checksum:
	name_template: "checksums.txt"
	
changelog:
	sort: asc
	filters:
		exclude:
			- "^docs:"
			- "^test:"
			- "^chore:"
			
brews:
	- repository:
			owner: mawen12
			name: homebrew-tap
		directory: Formula
		homepage: "https://github.com/mawen12/healthcheck"
		description: "CLI tool to monitor API health endpoints"
		license: "MIT"
		test: |
			system "#{bin}/healthcheck", "version"
		install: |
			bin.install "healthcheck"
```

在这种配置下，有几点值得注意：

- **CGO_ENABLED=0** 可确保完全生成静态的二进制文件。否则，Go 可能会链接到系统 C 库，这会破坏交叉编译，并在最小化的 Docker 镜像上导致 "找不到" 的错误。
- `-s -w` **ldflags** 去除调试信息和 DWARF 符号，将二进制文件大小减少约 30%。
- **ldflags** 用于版本控制，在编译时注入构建元数据，这就是为什么我们的 `version.go` 使用 `var version = "dev"`——GoReleaser 将其替换为实际的 git 标签。

推送前请在本地进行测试：

```bash
goreleaser release --snapshot --clean
```

这会在 `dist/` 目录中创建二进制文件，但不会发布任何内容。

准备发布时，添加标签并推送：

```bash
git tag -a v1.0.0 -m "init release"
git push origin v1.0.0
```

如果你已将 GoReleaser 设置为 Github Action，则发布过程将完全自动。以下是工作流文件：

```yaml
# .github/workflows/release.yaml
name: Release
on:
	push:
		tags:
			- "v"
			
permissions:
	contents: write
	
jobs:
	goreleaser:
		runs-on: ubuntu-latest
		steps:
			- uses: actions/checkout@v4
				with:
					fetch-depth: 0
			- uses: actions/setup-go@v5
				with:
					go-version: "1.22"
			- uses: goreleaser/goreleaser-action@v5
				with:
					version: "-> v2"
					args: release --clean
				env:
					GTHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```



# 通过 Homebrew 分发

GoReleaser 的 `brews` 部分会自动处理 Homebrew 规则生成，但你需要先设置 tap 存储库。

1. 创建一个名为 `homebrew-tap` 的公共仓库
2. 将 `GITHUB_TOKEN` 密钥（或使用具有该存储库写入权限的细粒度 API）添加到主项目的存储库密钥中

GoReleaser 运行后，你的用户可以使用以下命令进行安装：

```bash
brew tap mawen12/tap
brew install healthcheck
```

**注意**：tap 仓库必须命名为 `homebrew-tap`（带有 `homebrew-` 前缀），`brew tap youruser/tap` 命令才能正常工作。如果仓库名称不同，用户需要指定完整的 URL。

对于非 Homebrew 用户，请提供从 Github 发布页面下载的安装说明：

```bash
# Linux/macOS one-liner
curl -sSL https://github.com/mawen12/healthcheck/releases/latest/download/healthcheck_$(uname -s)_$(uname -m).tar.gz | tar xz
sudo mv healthcheck /usr/local/bin/
```



# 实用技巧和注意事项

在构建和发布多个 Go CLI 工具之后，我总结了一些文档中没有提到的经验教训。

**请使用 `RunE` ，而不是 `Run`。**Cobra 命令可以使用 `Run`（不返回错误）或 `RunE`（返回错误）。请始终使用 `RunE`。这样可以 让 Cobra 以一致的方式处理错误格式，并避免分散的 `os.Exit` 调用，从而提高测试难度。

**请尊重退出代码。**成功返回退出代码 0，一般失败返回退出代码 1，使用错误返回退出代码 2。CI 工具、Shell 脚本和监控系统都依赖于这些代码。Cobra 已经将未知命令和错误标志的退出代码设置为 2——请勿覆盖此行为。

**支持 `--output json`。**即使你一开始使用人类可读的输出，也请尽早添加 JSON 输出。实现起来几乎不需要任何成本，但却能让你的工具更易于与 `jq`、监控仪表盘和其他自动化工具集成。

```go
type JSONOutput struct {
  Results []ResultJSON `json:"results"`
  Healthy int `json:"healthy"`
  Unhealthy int `json:"unhealthy"`
  Timestamp strng `json:"timestamp"`
}
```

**不要忽略信号。**长时间运行的检查应该能够优雅地处理 `SIGINT` 和 `SIGTERM` 信号。传递一个从 `signal.NotifyContext` 派生的上下文，以便干净利落地取消正在进行的情况。

```go
ctx, cancel := signal.NotifyContext(context.Background, os.Interrupt, syscall.SIGTERM)
defer cancel()
```

**锁定 CI 系统的 Go 版本。**Go 的向后兼容性非常好，但小版本之间的细微变化可能会导致测试不稳定。请在 CI 工作流程中锁定 Go 版本，并谨慎地进行更新。

**测试配置加载。**配置错误是用户反馈最多的问题之一。编写测试用例，从临时文件加载配置 ，并使用标志和环境变量验证合并后的结果。



# 总结

我们已经从一个空目录发展成为一个可用于生产环境的命令行工具，它具备完善的配置管理、并发 HTTP 检查、全面的测试、自动化的跨平台构建以及 Homebrew 分发功能。整个代码库不到 400 行代码。

每次构建新的 CLI 工具时，我都是使用这个模板：

1. Cobra 用于命令和标志
2. Viper 用于配置合并
3. `internal/` 用于业务逻辑，与 CLI 层解耦
4. 使用 `httptest` 服务器进行基于表格的测试
5. 使用 GoReleaser 用于构建和分发

这套技术栈的优势在于其可扩展性。无论你的工具是简单的健康检查器还是复杂的部署编排器，其结构都保持不变。`internal/` 包边界保证了你的逻辑可测试性，并且独立于 CLI 框架，因此你可以用其他工具替换 Cobra （或者将逻辑封装在 HTTP API 中），而无需重写核心代码。

开始动手吧！你的团队下一个必备工具只需执行一次 `go mod init` 操作即可。