cheatsheet do
    title ''
    docset_file_name ''
    keyword ''

    category do
        id '概念'

        entry do
            command 'Resource'
            name 'Java 应用程序中的任何内容，能够被 Sentinel 保护起来'
        end
        entry do
            command 'Rule'
            name '围绕 Resource 的实时状态设定的规则'
        end
        entry do
            command 'RT'
            name 'Response Time，代表一次请求花了多久'
        end
        entry do
            command 'QPS'
            name  'Queries Per Second，单位时间来了多少请求'
        end
        entry do
            command  'Thread Count'
            name '当前同时有多少请求正在执行，并发线程数'
        end
        entry do
            name 'QPS vs Thread Count vs RT'
            notes <<-'END'
                ```
                QPS 衡量了**速度**，Thread Count 衡量了同时进行多少个。

                QPS = 100
                Thread Count = 20

                > 每秒进入 100 个请求，同时有20个请求正在执行

                Thread Count ~= QPS X RT
                ```
            END
        end
        entry do
            command 'Entry'
            name 'Resource 在 Sentinel 中的表示，每个资源都对应一个名称以及一个 Entry'
        end
        entry do
            command 'Node'
            name 'Resource 在 Sentinel 中的统计信息'
        end
        entry do
            command 'NodeSelectorSlot'
            name '负责收集资源的路径，并将这些资源的调用路径，以树状结构存储起来，用于根据调用路径来限流降级'
        end
        entry do
            command 'ClusterBuilderSlot'
            name '用于存储资源的统计信息以及调用者信息，例如该资源的RT、QPS、Thread Count等，这些信息将用作多维度限流、降级的依据'
        end
        entry do
            command 'StatisticSlot'
            name '用于记录、统计不同维度的 runtime 指标监控信息'
        end
        entry do
            command 'FlowSlot'
            name '根据预设的限流规则以及前面的 slot 统计的状态来进行流量控制'
        end
        entry do
            command 'AuthoritySlot'
            name '根据配置的黑白名单和调用来源信息，来做黑白名单控制'
        end
        entry do
            command 'DegradeSlot'
            name '针对资源的平均响应时间(RT)以及异常比率，来决定资源是否在接下来的时间被自动熔断'
        end
        entry do
            command 'SystemSlot'
            name '通过系统状态，例如 load1 等，来控制总的入口流量'
        end
    end

    category do
        id 'Code Example'

        entry do
            name '抛出异常'
            notes <<-'END'
                // 使用 try-with-resources 特性来自动退出
                // 资源名可以使用任意业务语义的字符串，接口名或其它唯一标识的字符串
                try (Entry entry = SphU.entry(resourceName)) {
                    // 被保护的业务逻辑
                    // do something  here...
                } catch (BlockException e) {
                    // 资源访问被阻止，被限流或被降级
                    // 在此处进行相应的处理操作
                }
            END
        end
        entry do
            name '布尔值'
            notes <<-'END'
                // 资源名可以使用任意业务语义的字符串，接口名或其它唯一标识的字符串
                if (SphO.entry(resourceName)) {
                    // 务必保证 finally 会被执行
                    try {
                        // 被保护的业务逻辑
                        // do something  here...
                    } finally  {
                        SphO.exit();
                    }
                } else {
                    // 资源访问被阻止，被限流或被降级
                    // 在此处进行相应的处理操作
                }
            END
        end
        entry do
            name '注解方式'
            notes <<-'END'
                // 原本的业务方法
                @SentinelResource(blockHandler = "blockHandlerForGetUser")
                public User getUserById(String id) {
                    throw new RuntimeException("getUserById command failed")
                }

                // blockHandler 函数，原方法调用被限流/降级/系统保护的时候调用
                public User blockHandlerForGetUser(String id, BlockException ex) {
                    return new User("admin");
                }
            END
        end
        entry do
            name '异步调用'
            notes <<-'END'
                try {
                    AsyncEntry entry = SphU.asyncEntry(resourceName);

                    // 异步调用
                    doAsync(userId, result -> {
                        try {
                            // 在此处处理异步调用的结果
                        } finally {
                            // 在回调结束后调用 exit
                            entry.exit()
                        }
                    })
                } catch (BlockException ex) {
                    // 资源访问被阻止，被限流或被降级
                    // 在此处进行相应的处理操作
                }
            END
        end
        entry do
            name '调用链路'
            notes <<-'END'
                请求
                ↓
                SphU.entry
                │
                ├ ① 创建 Entry
                │
                ├ ② NodeSelectorSlot
                │
                ├ ③ ClusterBuilderSlot
                │
                ├ ④ StatisticSlot
                │
                ├ ⑤ FlowSlot
                │       └ QPS限流
                │       └ 并发数限流
                │       └ 预热、排队等   
                │
                ├ ⑤ DegradeSlot
                │       ↓
                │       熔断降级
                │
                ├ ⑤ SystemSlot
                │       ↓
                │       系统负载保护              
                ↓
                业务代码
            END
        end
    end

    category do
        id 'Rule'

        entry do
            command 'FlowRule'
            name '流量控制规则'
            notes <<-'END'
                面向入站流量：
                根据预设规则，结合前面的 `NodeSelectorSlot`, `ClusterNodeBuilderSlot`, `StatisticSlot` 统计出来的实时信息。
                针对一个资源可以设置多个限流规则，限流规则的组成：

                - resource: 限流规则的作用对象
                - count: 限流阈值
                - grade: 限流阈值类型 0-Thread Count 1-QPS
                - strategy: 限流规则触发后的流量控制执行策略
                    - CONTROL_BEHAVIOR_DEFAULT: 直接拒绝，这是默认方式
                    - CONTROL_BEHAVIOR_WARM_UP: 让通过的流量缓慢增加，在一定时间内逐渐增加到阈值上限
                    - CONTROL_BEHAVOIR_RATE_LIMITER: 匀速器，严格控制请求通过的间隔时间，其对应的是漏桶算法，主要解决突发流量的问题
            END
        end
        entry do
            command 'DegradeRule'
            name '熔断降级规则'
            notes <<-'END'
                面向出站流量：

                支持三种策略：
                    - SLOW_REQUEST_RATIO: 以慢调用比例作为阈值，设置允许的慢调用RT (即最大响应时间)，请求的响应时间大于该值则统计为慢调用
                    - ERROR_RATIO: 当单位时间内的请求数大于设置的最小请求数，且异常比例大于阈值时，接下来的请求会自动被熔断，经过熔断时长后熔断器会进入 HALF_OPEN 状态，若接下来的一个请求成功，则结束熔断，否则会被再次熔断。
                    - ERROR_COUNT: 当单位时间内的请求数大于设置的最小请求数，且异常数大于阈值时，接下来的请求会自动被熔断，经过熔断时长后熔断器会进入 HALF_OPEN 状态，若接下来的一个请求成功，则结束熔断，否则会被再次熔断。

                对于异常类的统计，需要排除 Sentinel 本身的BlockException，如果是手动使用 SphU.entry 的场景，还需要 Tracer.trace 该异常，确保异常数、异常比例被正确统计

                降级规则组成：

                - resource: 降级规则的作用对象
                - grade: 熔断策略，慢调用比例、异常比例、异常数
                - count: 慢调用比例下为临界RT，异常比例或异常数下对应的阈值
                - timeWindow: 熔断时长，单位为秒
                - minRequestAmount: 熔断触发的最小请求数
                - statIntervalMs: 统计时长，单位为毫秒
                - slowRatioThreshold: 慢调用比例阈值
            END
        end
        entry do
            command 'SystemRule'
            name '系统保护规则'
            notes <<-'END'

            END
        end
        entry do
            command 'AuthorityRule'
            name '访问控制规则'
            notes ''
        end
        entry do
            command 'ParamFlowRule'
            name '热点规则'
            notes ''
        end
    end

    category do
        id '日志'

        entry do
            name '拦截日志'
            notes <<-'END'
                位于 ${user.home}/logs/csp/sentinel-block.log 中

                记录了触发限流、熔断降级、系统保护的秒级拦截详细信息。

                2026-08-27 10:47:03|1|commonPay,FlowException,default,,|62,0

                时间戳|该秒发生的第一个资源|资源名称,拦截的原因,生效规则的调用来源,被拦截资源的调用者,|被拦截的数量,无意义可忽略
            END
        end
        entry do
            name '监控日志'
            notes <<-'END'
                
            END
        end
    end

    category do
        id 'Flow'

        entry do
            name 'FlowException'
            notes <<-'END'
                当执行 `SphU#entry` 时抛出 `FlowExcetion` 异常，该类是 `BlockException` 的子类。
            END
        end
    end

    category do
        id '限流器'

        header '算法'
        header '核心思想'
        header '突发流量'
        header '精确度'
        header '分布式'
        header '典型场景'

        entry do
            name '固定窗口 Fixed Window'
            td_notes '每个时间窗口限制 N 次'
            td_notes '较好'
            td_notes '低'
            td_notes '容易'
            td_notes '简单 API 限流'
        end
        entry do
            name '滑动窗口 Sliding Window'
            td_notes '统计最近一段时间请求数'
            td_notes '较好'
            td_notes '较高'
            td_notes '容易'
            td_notes 'API/QPS限流'
        end
        entry do
            name '滑动日志 Sliding Log'
            td_notes '保存每个请求时间戳'
            td_notes '好'
            td_notes '很高'
            td_notes '较难'
            td_notes '高精度限流'
        end
        entry do
            name '令牌桶 Token Bucket'
            td_notes '按速率产生令牌，请求消耗令牌'
            td_notes '很好'
            td_notes '高'
            td_notes '容易'
            td_notes 'API、网关'
        end
        entry do
            name '漏桶 Leaky Bucket'
            td_notes '请求进入队列，以固定速率流出'
            td_notes '差'
            td_notes '高'
            td_notes '容易'
            td_notes '流量整形'
        end
        entry do
            name '并发数 Semaphore'
            td_notes '同时只允许 N 个请求执行'
            td_notes '不适用'
            td_notes '高'
            td_notes '较难'
            td_notes '数据库/线程池保护'
        end
        entry do
            name '自适应限流'
            td_notes '根据RT、CPU、负载动态调整'
            td_notes '动态'
            td_notes '高'
            td_notes '较复杂'
            td_notes '微服务/高负载系统'
        end
    end
end