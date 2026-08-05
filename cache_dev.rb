cheatsheet do
    title 'Cache Dev'
    docset_file_name 'Cache_dev'
    keyword 'cache'
    source 'cache'
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
        id '异常场景'

        entry do
            name '缓存雪崩'
            notes <<-'END'
                缓存中同一时间内大量键过期，接下来一大波请求都落在了数据库中导致连接异常。

                解决方案：
                    - 互斥锁排队
                    - 缓存预热
                    - 双层缓存策略（原始缓存、拷贝缓存）
            END
        end
        entry do
            name '缓存击穿'
            notes <<-'END'
                缓存中没有但是数据库中有的数据，一般是缓存时间到期，这是由于并发用户特别多，同时读缓存没读到数据，
                同时去数据库取，造成数据库压力瞬间增大。

                解决方案：
                    - 设置热点数据永不过期
                    - 使用互斥锁排队
                    - 缓存屏障
            END
        end
        entry do
            name '缓存穿透'
            notes <<-'END'
                访问的数据在缓存和数据库中都没有，而且该数据被不断请求，导致数据库压力过大。

                解决方案：
                    - 缓存空对象
                    - 布隆过滤器
            END
        end
        entry do
            name '缓存预热'
            notes <<-'END'
                在系统上线后，将相关的缓存数据直接加载到缓存系统，这样就可以避免在用户请求的时候，先查询数据库，再将数据缓存的问题。

                解决方案：
                    - 数据量不大的时候，工程启动的时候进行加载缓存动作
                    - 数据量大的时候，设置一个定时任务脚本，进行缓存的刷新
                    - 数据量太大的时候，优先保证热点数据进行提前加载到缓存
            END
        end
        entry do
            name '缓存降级'
            notes <<-'END'
                在缓存失效或者缓存服务挂掉的情况下，我们也不去访问数据库。而是直接把内存部分数据或者直接返回默认数据。
            END
        end
    end

    category do
        id 'Structural patterns'
    end

    category do
        id 'Behavioral patterns'
    end
end