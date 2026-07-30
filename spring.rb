cheatsheet do
    title 'Spring 中文指南 TODO'
    docset_file_name 'Spring'
    keyword 'spring'
    style '
        code {
            border: none;
            white-space: pre;
        }
        
        code::before, code::after {
            content: "";
        }

        tr {
            border-bottom: 2px dashed #b8b8b8;
        }
    '

    category do
        id '释义'

        entry do
            command 'IOC'
            name '反转控制（Inversion of Control）'
        end
        entry do
            command 'AOP'
            name '面向切面编程（Aspect-oriented Programming）'
        end
    end

    category do
        id 'Annotation'
    end

    category do
        id 'Bean Scope'
        
        entry do
            command 'singleton'
            name '单例，一个 Bean Definition 在每个 IOC 容器中仅有一个实例，默认值'
        end
        entry do
            command 'prototype'
            name '原形，一个 Bean Definition 可以存在任意个实例'
        end
        entry do
            command 'request'
            name '请求，对于同一个 Bean Definition，每个 Http 请求都会创建一个属于该请求的实例。需要 IOC 容器为 Web'
        end
        entry do
            command 'response'
            name '响应，对于同一个 Bean Definition，每个 Http 响应都会创建一个属于该响应的实例。需要 IOC 容器为 Web'
        end
        entry do
            command 'session'
            name '会话，对于同一个 Bean Definition，每个 Http 响应都会创建一个属于该响应的实例。需要 IOC 容器为 Web'
        end
        entry do
            command 'application'
            name '应用，对于同一个 Bean Definition，在每个 Web 应用中仅有一个实例，需要 IOC 容器为 Web'
        end
        entry do
            command 'websocket'
            name 'Websocket，对于同一个 Bean Definition，在每个 Web 应用中仅有一个实例，需要 IOC 容器为 Web'
        end
    end

    category do
        id 'AOP'

        entry do
            command '@annotation'
            name '匹配方法上带有注定的注解'
            notes <<-'END'
                ```java
                // 匹配带有 @Transactional 注解的方法
                @Pointcut("@anotation(org.springframework.transaction.annotation.Transactional)")
                ```
            END
        end
        entry do
            command 'execution'
            name '匹配方法'
            notes <<-'END'
                ```java
                // 匹配任何 public 方法
                @Pointcut("execution(public * *(..))")

                // 匹配任何 set 前缀的方法 
                @Pointcut("execution(* set*.*(..))")

                // 匹配任何 AccountService 接口中的方法
                @Pointcut("execution(* com.xyz.service.AccountService.*(..))")

                // 匹配任何在 com.xyz.service 包中的方法
                @Pointcut("execution(* com.xyz.service.*.*(..))")

                // 匹配任何在 com.xyz.service 包及子包中的方法
                @Pointcut("execution(* com.xyz.service..*.*(..))")

                // 严格匹配满足方法签名的方法execution
                @Pointcut("execution(public com.xyz.Response com.xyz.service.XyzService.handle(com.xyz.Request))")
                ```
            END
        end
        entry do
            command 'within'
            name '匹配包'
            notes <<-'END'
                ```java
                // 匹配 com.xyz.service 包中的方法
                @Pointcut("within(com.xyz.service.*)")

                // 匹配 com.xyz.service 包及子包中的方法
                @Pointcut("within(com.xyz.service..*)")
                ```
            END
        end
        entry do
            command 'this'
            name '匹配 Spring Bean 类型'
            notes <<-'END'
                ```java
                // 匹配 Spring Bean 类型为 com.xyz.service.AccountService 的方法 
                @Pointcut("this(com.xyz.service.AccountService)")
                ```
            END
        end
        entry do
            command 'target'
            name '匹配运行时对象的类型上的注解'
            notes <<-'END'
                ```java
                // 匹配运行时对象上实现了 com.xyz.service.AccountService 接口的方法
                @Pointcut("target(com.xyz.service.AccountService)")
                ```
            END
        end
        entry do
            command 'args'
            name '匹配方法参数'
            notes <<-'END'
                ```java
                // 匹配只有一个参数，且参数类型为 java.io.Serializable 的方法
                @Pointcut("args(java.io.Serializable)")
                ```
            END
        end
        entry do
            command '@target'
            name '匹配运行时对象的类型上的注解'
            notes <<-'END'
                ```java
                // 匹配运行时对象上使用了 @Transactional 注解的方法
                @Pointcut("@target(org.springframework.transaction.annotation.Transactional)")
                ```
            END
        end
        entry do
            command '@args'
            name '匹配参数数量，且参数上使用了对应的注解'
            notes <<-'END'
                ```java
                // 匹配只有一个参数，且参数上使用了 @Classified 
                @Pointcut("@args(com.xyz.security.Classified)")
                ```
            END
        end
        entry do
            command '@within'
            name '匹配目标类上是否有注解'
            notes <<-'END'
                ```java
                // 匹配带有 @Transactional 目标类
                @Pointcut("@within(org.springframework.transaction.annotation.Transactional)")
                ```
            END
        end
    end

    
end