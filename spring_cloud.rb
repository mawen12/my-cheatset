cheatsheet do
    title 'Spring Cloud'
    docset_file_name 'Spring_Cloud'
    keyword 'spring cloud'
    source ''

    category do
        id 'Components'

        header '名称'
        header 'Spring Cloud 组件'
        header '常见替代/配套'

        entry do
            name '服务注册'
            td_notes 'Spring Cloud Eureka'
            td_notes 'Nacos / Consul / K8s'
        end
        entry do
            name '服务发现'
            td_notes 'Spring Cloud Eureka'
            td_notes 'Nacos / Consul / K8s'
        end
        entry do
            name '配置中心'
            td_notes 'Config'
            td_notes 'Nacos / Apollo'
        end
        entry do
            name '服务调用'
            td_notes 'OpenFeign'
            td_notes 'WebClient'
        end
        entry do
            name '负载均衡'
            td_notes 'LoadBalancer'
            td_notes 'K8s Service'
        end
        entry do
            name '网关'
            td_notes 'Gateway'
            td_notes 'Kong / APISIX'
        end
        entry do
            name '熔断'
            td_notes 'CircuitBreaker'
            td_notes 'Resilience4j'
        end
        entry do
            name '限流'
            td_notes '-'
            td_notes 'Sentinel'
        end
        entry do
            name '消息'
            td_notes 'Stream'
            td_notes 'Kafka / RabbitMQ'
        end
        entry do
            name '事件广播'
            td_notes 'Bus'
            td_notes 'Kafka / RabbitMQ'
        end
        entry do
            name '链路追踪'
            td_notes 'Micrometer Tracing'
            td_notes 'OpenTelemetry'
        end
        entry do
            name '契约测试'
            td_notes 'Spring Cloud Contract'
            td_notes '-'
        end
        entry do
            name 'Kubernetes'
            td_notes 'Cloud Kubernetes'
            td_notes 'Kubernetes 原生能力'
        end
    end

    category do
        id 'Eureka'

        entry do
            name '@EnableEurekaServer'
            notes <<-'END'
                ```
                @EnableEurekaServer
                │
                ├ @Import(EurekaServerMarkerConfiguration)
                │
                ├ EurekaServerMarkerConfiguration
                │
                └ EurekaServerAutoConfiguration
                ```
            END
        end
    end

    category do
        id 'Config'

        entry do
            name '@EnableConfigServer'
            notes <<-'END'
                ```
                @EnableConfigServer
                │
                ├ @Import(ConfigServerConfiguration)
                │
                ├ ConfigServerConfiguration
                │
                └ ConfigServerAutoConfiguration
                ```
            END
        end
    end

    category do
        id 'Gateway'

        entry do
            name '@EnableDiscoveryClient'
            notes <<-'END'
                ```
                @EnableDiscoveryClient
                │
                ├ @Import(EnableDiscoveryClientImportSelector)
                │
                ├ EnableDiscoveryClientImportSelector.selectImports()
                │
                └ AutoServiceRegistrationConfiguration
                ```
            END
        end
    end

    category do
        id 'Admin Server'

        entry do
            name '@EnableAdminServer'
            notes <<-'END'
                ```
                @EnableAdminServer
                │
                ├ @Import(AdminServerMarkerConfiguration)
                │
                ├ AdminServerMarkerConfiguration
                │
                └ AdminServerAutoConfiguration
                ```
            END
        end
    end
end