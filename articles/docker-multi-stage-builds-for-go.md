# 背景

大多数 Go Docker 镜像的构建方式都不对。一个典型的 `FROM golang:1.22`  镜像大小超过 800MB。而你编译后的 Go 二进制文件可能只有 10~15 MB。本文将介绍如何使用多阶段构建来发布最小化、安全的镜像，并避免常见的陷阱。



# 问题

```dockerfile
// 不要这样做
FROM golang:1.22
WORKDIR /app
COPY . .
RUN go build -o server .
CMD ["./server"]
```

此镜像包含完整的 Go 工具链、构建缓存和源代码。结果：约 850 MB的镜像中包含约 840 MB 的生产环境不需要的内容。



# 基础多阶段修复

```dockerfile
# Stage 1：Build
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o server .

# Stage 2：Run
FROM alpine:3.19
RUN apk --no-cache add ca-certificates
COPY --from=builder /app/server /server
CMD ["./server"]
```

这样做可以达到约 20MB 的大小。但我们还可以做得更好，而且还有一些生产方面的问题需要解决。



# 生产环境 Dockerfile

```dockerfile
# syntax=docker/dockerfile:1

# ============= Step 1: Dependencies =============
FROM golang:1.22-alpine AS deps
WORKDIR /app
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod \
	go mod download && go mod verify

# ============= Step 2: Build =============
FROM golang:1.22-alpine AS builder
WORKDIR /app
# 拷贝缓存的模块
COPY --from=deps /go/pkg/mod /go/pkg/mod
# 拷贝源代码
COPY . .
# 构建时进行优化
ARG VERSION=dev
ARG COMMIT=unknown
RUN --mount=type=cache,target=/go/pkg/mod \
	--mount=type=cache,target=/root/.cache/go-build \
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
	go build \
		-ldflags="-s -w -X main.version=${VERSION} -X main.commit=${COMMIT}" \
		-trimpath \
		-o /server \
		./cmd/server
		
# ============= Step 3: Production =============
FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=builder /server /server
EXPOSE 8080
USE nonroot:nonroot
ENTRYPOINT ["/server"]
```

让我们来详细分析每个部件的作用的原因。



## 关键决策详解

### CGO_ENABLED=0

Go 可以链接 C 库（CGO）。禁用此功能会生成完全静态的二进制文件——不依赖 libc，没有共享库的问题，可以在任何 Linux 系统上运行。如果你需要 CGO（例如 SQLite、某些加密功能），则需要使用不同的基础镜像。

### -ldflags="-s -w"

`-s` 参数会移除符号表，`-w` 参数会移除 DWARF 调试信息。这两个参数可以共同将二进制文件大小减少 20~30%。你会丢失 `go tool pprof` 符号名称，但生产环境中的二进制文件通常不需要这些名称。

### -trimpath

从二进制文件移除本地文件路径。如果没有这一步，崩溃堆栈跟踪信息会泄露你的构建目录结构——这是一个小小的隐患。

### --mount=type=cache

Buidkit 缓存挂载功能会在构建过程中持久化 Go 模块缓存和构建缓存。首次构建会下载所有模块；后续构建则会重用缓存。对于一个包含 200 个依赖项的项目，这可以将构建时间从 90 秒缩短到 15 秒。



## Distroless vs Alpine vs Scratch

```dockerfile
# 选项 1：scratch（最小，大约 12MB）
FROM scratch
COPY --from=builder /etc/ssl/certs/ca-cerificates.crt /etc/ssl/certs
COPY --from=builder /server server

# 选项 2：distroless（推荐，大约 14MB）
FROM gcr.io/distroless/static-debian12:nonroot

# 选项 3：alpine（大约 22 MB）
FROM alpine:3.19
RUN apk --no-cache add ca-cerificates
```

### Scratch

没有 shell、没有工具、没有用户——只有你的二进制文件。调试很困难（无法进入容器 `exec`）。

### Distroless

增加了 CA 证书、时区数据、`nonroot` 用户和 `/tmp` 目录。但仍然没有 shell 或包管理器。这对于大多数生产服务来说都是最佳选择。

### Alpine

添加了 shell、包管理器和 musl libc。当需要在生产环境中调试容器或有 CGO 依赖项时，可以使用它。



## 非 root 用户

```dockerfile
USER nonroot:nonroot
```

切勿以 `root` 用户身份运行容器。Distroless 提供了一个 `nonroot` 用户（UID 65532）。如果使用 Scratch：

```dockerfile
FROM scratch
COPY --from=builder /etc/passwd /etc/passwd
USER 65532:65532
```



## 处理静态文件和配置

如果你的 Go 二进制文件需要提供静态文件或读取配置：

```dockerfile
FROM gcr.io/distroless/static-debian12:nonroot
# 拷贝二进制文件
COPY --from=builder /server /server
# 拷贝静态文件（嵌入二进制文件更好，但有时需要文件）
COPY --from=builder /app/static /static
COPY --from=builder /app/migrations /migrations
EXPOSE 8080
USE nonroot:nonroot
ENTRYPOINT ["/server"]
```

更好的方案：

```go
//go:embed static/*
var staticFiles embed.FS

//go:embed migrations/*.sql
var migrations embed.FS
```

现在你的二进制文件是独立的了。无需复制文件，也不用担心路径错误。



# CI/CD 集成

使用来自 Git 的版本信息进行构建。

```bash
docker build \
	--build-tag VERSION=$(git describe --tags --always) \
	--build-tag COMMIT=$(git rev-parse --short HEAD) \
	-t myapp:$(git describe --tags --always)
	.
```

在你的 `main.go` 中：

```go
var (
	version = "dev"
  commit 	= "unknown"
)

func main() {
  slog.Info("starting server", "version", version, "commit", commit)
  // ...
}
```



# Orchestrators 健康检查

```bash
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
	CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health | exit 1
```

对于 Distroless（没有 `wget`），请在你的 Go 二进制文件中实现健康检查：

```go
http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
  w.WriteHeader(http.StatusOK)
  w.Write([]byte("ok"))
})
```

让 Kubernetes/ECS  直接探测端点。



# 多架构构建

同时支持 AMD64 和 ARM64：

```bash
docker buildx create --name multiarch --use
docker buildx build \
	--platform linux/amd64,linux/arm64 \
	--build-tag VERSION=$(git describe --tags) \
	-t myregistry/myapp:latest \
	--push \
	.
```

更新你的 Dockerfile 以使用构建参数：

```dockerfile
ARG TARGETOS TARGETARCH
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARHC=${TARGETARCH} \
	go build -ldflags="-s -w" -trimpath -o /server ./cmd/server
```

Docker 在多平台构建过程中会自动设置 `TARGETOS` 和 `TARGETARCH`。

# 安全扫描

```dockerfile
# 使用 trivy 扫描
trivy image myapp:latest

# 使用 grype 扫描
grype myapp:latest
```

Distroless 和 Scratch 镜像通常没有 CVE 漏洞，因为无需扫描任何内容——没有操作系统软件包，也没有库文件。Alpine 镜像通常会在 musl 或 busybox 中发现一些低危漏洞。



# 大小比较

| 基础镜像          | Go 二进制 | 总镜像  | CVE 数量 |
| ----------------- | --------- | ------- | -------- |
| golang:1.22       | 15 MB     | ~850 MB | 100+     |
| alpine:3.19       | 15 MB     | ~22 MB  | 0~3      |
| distroless/static | 12 MB     | ~14 MB  | 0        |
| scratch           | 12 MB     | ~12 MB  | 0        |

使用 `-ldflags="-s -w"` 时，二进制文件会更小（15 MB ~  12 MB）。



# 常见错误

## 1. 复制 go.sum 但未复制 go.mod

Docker 层缓存同时作用于 `go.sum` 和 `go.mod`。请在下载 `go.mod` 之前复制这两个文件。

## 2. 没有将依赖项下载与构建分开

如果在下载模块之前复制所有源代码，则每次代码更改都会使模块缓存层失效。

## 3. 忘记配置 CA 证书

TLS 连接会静默失败或出现难以理解的错误。Distroless 版本已包含 CA 证书，而 Scratch 和 Alpine 版本则需要手动配置。

## 4. 架构选择错误

务必显示设置 `GOOS` 和 `GOARCH`。即使你的 CI 平台是 ARM，目标平台也可能是 AMD64。

## 5. 将 .git 添加到构建上下文

将 `.git` 添加到 `.dockerignore` 文件中。庞大的 git 历史记录可能会给构建上下文增加数百 MB 的空间。

```dockerignore
#.dockerignore
.git
*.md
docs/
**/*_test.go
```



# 总结

生产环境的 Go Docker 镜像应小于 15 MB，以非 root 用户运行，并且除了你的二进制文件及其所需的证书之外，不应该包含任何其他内容。多阶段构建使这一切变得简单——一个阶段用于构建，一个阶段用于运行。构建缓存标志（`--mount=type-cache`）可以 保持迭代速度。

对于大多数服务，建议先使用 Distroless。如果只需要最基本的功能，则直接使用 Scratch。只有在需要 shell 进行调试时才使用 Alpine。