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
            name '@Async 扫描注册'
            notes <<-'END'
                @EnableAsync
                ↓
                识别创建的 Bean 中带有 @Async 方法
                ↓
                BeanPostProcessor
                ↓
                AsyncAnnotationBeanPostProcessor
                ↓
                创建 Proxy
            END
        end
        entry do
            name '@Async 方法调用'
            notes <<-'END'
                调用方法
                ↓
                Spring AOP Proxy
                ↓
                AsyncExecutionInterceptor
                ↓
                TaskExecutor
                ↓
                ThreadPoolExecutor
                ↓
                BlockingQueue
                ↓
                Worker Thread
                ↓
                目标方法
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