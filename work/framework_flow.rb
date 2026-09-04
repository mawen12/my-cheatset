cheatsheet do
    title ''
    docset_file_name ''
    keyword ''
    
    category do
        id 'MyBatis'

        entry do
            name 'Mapper 查询'
            notes <<-'END'
                xxxMapper.selectById(100)
                ↓
                MapperProxy.invoke()
                │
                ├ ① InvocationHandler
                ↓
                MapperMethod.execute()
                │
                ├ ① StatementId 
                │
                ├ ② MappedStatement
                ↓
                SqlSession.selectOne()
                ↓
                Executor.query()
                │
                ├ ② LocalCache
                ↓
                StatementHandler
                ↓
                ParameterHandler
                ↓
                JDBC PreparedStatement
                ↓
                Connection
                ↓
                Database
                ↓
                ResultSet
                ↓
                ResultSetHandler
            END
        end
    end

    category do
        id 'Java'

        entry do
            name '线程池任务提交'
            notes <<-'END'
                executor.execute(task)
                ↓
                ThreadPoolExecutor.execute()
                ↓
                当前线程数小于 corePoolSize
                ↓是               ↓否
                创建worker        workQueue.offer(task)
                ↓                 ↓  
                Work.run()        入队成功  
                ↓                 ↓是          ↓否  
                runWorker()       等待执行      当前线程数小于 maximumPoolSize
                ↓                              ↓是           ↓否
                task.run()                     创建 Worker   执行拒绝策略 
            END
        end
    end

    category do
        id 'Spring'

        entry do
            name 'Bean 扫描注册'
            notes <<-'END'
                ApplicationContext
                │
                ├ ① @Component
                │
                ├ ② Configuration
                │
                ├ ② Bean
                │
                ├ ② Service
                │
                ├ ② Controller
                │
                ├ ② Repository
                ↓  
                BeanDefinition
                ↓
                BeanDefinitionRegistry
                ↓
                BeanFactory
                ↓
                BeanPostProcessor
                ↓
                Bean 实例
                ↓
                SingletonObjects
            END
        end
        entry do
            name 'Spring Boot 启动'
            notes <<-'END'
                SpringApplication.run()
                ↓
                创建 SpringApplication
                │
                ├ ① primarySources
                │
                ├ ② 推断 ApplicationContext 类型 (WebApplicationType.deduceFromClasspath())
                │
                ├ ③ ApplicationContextFactory 
                │
                ├ ④ ApplicationListeners 
                │
                ├ ⑤ Initializers 
                │
                ├ ⑥ 推断 main 类
                ↓
                run()
                │
                ├ ① 加载 SpringApplicationRunListener
                │
                ├ ② 通知启动事件 ApplicationStartingEvent
                │
                ├ ③ 准备 Environment
                │
                ├ ④ 通知环境准备事件 ApplicationEnvironmentPreapredEvent
                │
                ├ ⑤ 创建 ApplicationContext 
                │
                ├ ⑥ 通知上下文初始化事件 ApplicationContextPreparedEvent
                │
                ├ ⑦ 准备 context 
                │
                ├ ⑧ 通知上下文初始化事件 ApplicationContextLoadedEvent
                │
                ├ ⑨ refresh() 
                │   │
                │   ├ ① BeanDefiniton 注册
                │   │
                │   ├ ② BeanFactoryPostProcessor
                │   │
                │   ├ ③ BeanPostProcessor
                │   │
                │   ├ ④ Bean 创建
                │   │
                │   └ ⑤ Web 容器启动 
                │
                ├ ⑩ 通知上下文已启动事件 ApplicationStartedEvent
                │
                ├ ⑩ ApplicationRunner / CommandLineRunner
                │
                ├ ⑩ 通知上下文就绪事件 ApplicationReadyEvent
                ↓
                启动完成
            END
        end
        entry do
            name '@Async 流程'
            notes <<-'END'
                ```
                阶段1 @EnableAsync
                │
                ├ ① @Import(AsyncConfigurationSelector)
                │
                ├ ② AsyncConfigurationSelector.selectImports()
                │
                ├ ③ ProxyAsyncConfiguration
                │
                ├ ④ AsyncAnnotationBeanPostProcessor
                │
                └ ③ AsyncAnnotationAdvisor
                    │
                    ├ advice: AnnotationAsyncExecutionInterceptor
                    │
                    └ pointcut: @Async/@Asynchronous match
                ```
                
                ```
                阶段2 @Async
                │
                ├ ① Spring Aop Proxy
                │
                ├ ② AsyncExecutionInterceptor.invoke()
                │
                ├ ③ AsyncExecutionInterceptor.determineAsyncExecutor() -> @Async(value="xxx") -> defaultExecutor 
                │
                └ ④ AsyncExecutionInterceptor.doSubmit()
                ```

                ```
                [调用者 Client]
                ↓
                [Spring AOP 代理类 Proxy]
                │
                ├ [AsyncExecutionInterceptor（拦截器）]
                │   │
                │   ├ 从 TaskExecutor 线程池获取线程
                │   │
                │   ├ 将原方法包裹为 Callable/Runnable 任务提交给线程池
                │   │
                │   └ 立即向调用者返回 Futrue/CompletableFutrue （或 void） 
                │
                ↓ (在异步线程中)
                [目标业务对象 Target] -> 执行真实逻辑
                ```
            END
        end
        entry do
            name '@Transactional 流程'
            notes <<-'END'
                ```
                阶段1 @EnableTransactionManagement
                │
                ├ ① @Import(TransactionManagementConfigurationSelector)
                │
                ├ ② TransactionManagementConfigurationSelector.selectImports()
                │
                ├ ③ ProxyTransactionManagementConfiguration
                │
                └ ④ BeanFactoryTransactionAttributeSourceAdvisor
                    │
                    ├ advice: TransactionInterceptor
                    │
                    └ pointcut: @Transactional

                阶段2 @Transactional
                │
                ├ ① Spring Aop Proxy
                │
                ├ ② TransactionInterceptor
                │
                ├ ② TransactionManager
                │   │
                │   ├ 创建事务
                │   │
                │   ├ 获取 Connection
                │   │
                │   └ 设置 autoCommit=false
                │
                └ ③ 目标方法
                    ↓ 正常      ↓ 异常
                    commit      rollback
                ```
            END
        end
        entry do
            name  '@Scheduling'
            notes <<-'END'
                ```
                阶段1 @EnableScheduling
                │
                ├ ① @Import(SchedulingConfiguration)
                │
                ├ ① SchedulingConfiguration
                │
                ├ ① SchedulingAnnotationBeanPostProcessor
                │
                ├ ① ScheduledTaskRegistrar

                ```
            END
        end
        entry do
            name 'Spring Security'
            notes <<-'END'
                ```
                HTTP Request
                ↓
                Tomcat
                ↓
                Servlet FilterChain
                ↓
                DelegatingFilterProxy
                ↓
                FilterChainProxy
                ↓
                SecurityFilterChain
                ↓
                DispatcherServlet
                │
                ├ ① SecurityContextHolderFilter
                │
                ├ ② HeaderWriterFilter
                │
                ├ ③ CsrfFilter
                │
                ├ ④ LogoutFilter
                │
                ├ ⑤ UsernamePasswordAuthenticationFilter
                │
                ├ ⑥ BearerTokenAuthenticationFilter
                │
                ├ ⑦ AnonymousAuthenticationFilter
                │
                ├ ⑧ ExceptionTranslationFilter
                │
                ├ ⑨ AuthorizationFilter
                ↓
                Controller
                ```
            END
        end

        
        entry do
            name '@Scheduled 扫描注册'
            notes <<-'END'
                识别创建的 Bean 中带有 @Scheduled 方法
                ↓
                ScheduledAnnotationBeanPostProcessor
                ↓
                创建 ScheduledTask
                ↓
                TaskScheduler
                ↓
                ScheduledExecutorService
                ↓
                等待触发时间
                ↓
                Worker Thread
                ↓
                execute()
            END
        end

        entry do
            name 'Spring Web 请求'
            notes <<-'END'
                浏览器
                ↓ HTTP Request
                Tomcat
                │
                ├ ① Connector
                │
                ├ ② HTTP Processor
                ↓
                Servlet
                ↓
                Filter
                ↓
                DispatcherServlet
                ↓
                HandlerMapping
                ↓
                HandlerExecutionChain
                ↓
                HandlerMethod
                ↓
                HandlerAdapter
                ↓
                RequestMappingHandlerAdapter
                ↓
                HandlerMethodArgumentResolver
                │
                ├ ① @PathVariable
                │
                ├ ② @RequestParam
                │
                ├ ③ @RequestBody
                │
                ├ ④ @RequestHeader
                ↓
                Controller
                ↓
                HandlerMethodReturnValueHandler
                ↓
                HttpMessageConverter
                ↓
                HttpServletResponse
                ↓
                Tomcat
                ↓
                Browser
            END
        end
        entry do
            name '@Transaction 执行'
            notes <<-'END'
                Spring AOP Proxy
                ↓
                TransactionInterceptor
                ↓
                TransactionManager
                │
                ├ ① 获取/创建事务
                │
                ├ ② 获取数据库 Connection
                │
                ├ ③ 设置 autoCommit=false
                ↓
                执行目标方法
                │
                ├ ① MyBatis
                │
                ├ ② JDBC
                ↓
                方法结束
                ↓正常       ↓异常
                commit()    rollback()
            END
        end
        entry do
            name '@EnableCaching 注册'
            notes <<-'END'
                xxxService
                ↓
                CacheInterceptor
                ↓
                生成 cacheKey
                ↓
                查询 Cache
                ↓ 未命中            ↓ 命中
                目标方法            直接返回
                ↓
                返回数据
                ↓
                写入 Cache
                ↓
                返回
            END
        end
        entry do
            name '@Cacheable 执行'
            notes <<-'END'
                xxxService
                ↓
                CacheInterceptor
                ↓
                生成 cacheKey
                ↓
                查询 Cache
                ↓ 未命中            ↓ 命中
                目标方法            直接返回
                ↓
                返回数据
                ↓
                写入 Cache
                ↓
                返回
            END
        end
    end

    category do
        id 'Spring Cloud'

        entry do
            name '@EnableEurekaServer'
            notes <<-'END'
                - 声明式架构开关
                - 

                ```
                阶段1 @EnableEurekaServer
                │
                ├ ① @Import(EurekaServerMarkerConfiguration)
                │
                ├ ① EurekaServerMarkerConfiguration.eurekaServerMarkerBean()
                │
                ├ ① EurekaServerAutoConfiguration
                │
                ├ ① EurekaServerInitializerConfiguration

                ```
            END
        end
    end

    category do
        id 'Kafka'

        entry do
            name '消息生产'
            notes <<-'END'
                Producer Client
                ↓
                KafkaProducer.send()
                ↓
                Serializer
                ↓
                Partitioner
                ↓
                RecordAccumulator
                ↓
                Sender Thread
                ↓
                NetworkClient
                ↓
                Broker
                ↓
                Leader Partition
                ↓
                Replica Sync
                ↓
                ACK Response
                ↓
                Producer Callback
            END
        end
        entry do
            name '消息消费'
            notes <<-'END'
                Cosumer
                ↓
                ConsumerCoordinator
                ↓
                JoinGroup
                ↓
                Partition Assignment
                ↓
                Fetch Request
                ↓
                Broker Leader Paritition
                ↓
                Fetch Response
                ↓
                Deserializer
                ↓
                ConsumerRecord
                ↓
                业务处理
                ↓
                Commit offset
            END
        end
    end
end