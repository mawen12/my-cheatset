# 附录



## 通用应用属性


### Server 属性

| 名称 | 描述 | 默认值 |
| ---| --- | --- |
| `server.tomcat.accept-count` | 当所有可能的请求处理线程都在使用时，传入连接请求的最大队列长度 | 100 |
| `server.tomcat.accesslog.buffered` |  | |
| `server.tomcat.accesslog.check-exists` |  | |
| `server.tomcat.accesslog.condition-if` |  | |
| `server.tomcat.accesslog.condition-unless` |  | |
| `server.tomcat.accesslog.directory` |  | |
| `server.tomcat.accesslog.enabled` |  | |
| `server.tomcat.accesslog.encoding` |  | |
| `server.tomcat.accesslog.file-date-format` |  | |
| `server.tomcat.accesslog.ipv6-canonical` |  | |
| `server.tomcat.accesslog.locale` |  | |
| `server.tomcat.accesslog.max-days` |  | |
| `server.tomcat.accesslog.pattern` |  | |
| `server.tomcat.accesslog.prefix` |  | |
| `server.tomcat.accesslog.rename-on-rotate` |  | |
| `server.tomcat.accesslog.request-attribute-enabled` |  | |
| `server.tomcat.accesslog.rotate` |  | |
| `server.tomcat.accesslog.suffix` |  | |
| `server.tomcat.additional-tld-skip-patterns` |  | |
| `server.tomcat.background-processor-delay` |  | |
| `server.tomcat.basedir` |  | |
| `server.tomcat.connection-timeout` | 连接器在接受连接后，等待请求 URI 行出现的时间 | |
| `server.tomcat.keep-alive-timeout` | 连接关闭前需要等待一段时间才能收到下一个 HTTP 请求。如果未设置，则使用 `connectionTimeout`。如果设置为-1，则不会超时 | |
| `server.tomcat.max-connections` | 服务器在任何给定时间接受和处理的最大连接数。达到此限制后，操作系统仍可能根据 `acceptCount` 属性接受连接 | 8192 |
| `server.tomcat.max-http-form-post-size` |  | |
| `server.tomcat.max-http-response-header-size` |  | |
| `server.tomcat.max-keep-alive-requests` |  | |
| `server.tomcat.max-parameter-count` |  | |
| `server.tomcat.max-part-count` |  | |
| `server.tomcat.max-part-header-size` |  | |
| `server.tomcat.max-swallow-size` |  | |
| `server.tomcat.mbeanregistry.enabled` |  | |
| `server.tomcat.processor-cache` |  | |
| `server.tomcat.redirect-context-root` |  | |
| `server.tomcat.relaxed-path-chars` |  | |
| `server.tomcat.relaxed-query-charts` |  | |
| `server.tomcat.remoteip.host-header` |  | |
| `server.tomcat.remoteip.internal-proxies` |  | |
| `server.tomcat.remoteip.port-header` |  | |
| `server.tomcat.remoteip.protocol-header` |  | |
| `server.tomcat.remoteip.protocol-header-https-value` |  | |
| `server.tomcat.remoteip.remote-ip-header` |  | |
| `server.tomcat.remoteip.trusted-proxies` |  | |
| `server.tomcat.resource.allow-caching` |  | |
| `server.tomcat.resource.cache-max-size` |  | |
| `server.tomcat.resource.cache-ttl` |  | |
| `server.tomcat.threads.max` | 工作线程的最大数量。如果启用了虚拟线程，则此设置无效 | 200 |
| `server.tomcat.threads.max-queue-capacity` | 线程池后备队列的最大容量。此设置仅在值大于0是生效 | 2147483647 |
| `server.tomcat.threads.min-spare` | 最小工作线程数。启用虚拟线程后无效。 | 10 |
| `server.tomcat.uri-encoding` |  | |
| `server.tomcat.use-apr` |  | |
| `server.tomcat.use-relative-redirects` |  | |
