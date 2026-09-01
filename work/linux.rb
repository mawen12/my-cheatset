cheatsheet do
    title ''
    docset_file_name ''
    keyword ''

    category do
        id '基础配置'

        entry do
            command 'cat /etc/os-release'
            name '操作系统信息'
        end
        entry do
            command 'lscpu'
            name '查看CPU核心数'
        end
        entry do
            command 'free -h'
            name '查看内存'
        end
        entry do
            command 'df -h'
            name '查看磁盘'
        end
        entry do
            command 'ip addr'
            name '查看网卡'
        end
        entry do
            command 'ip route'
            name '查看路由'
        end
        entry do
            command 'px aux'
            name '查看运行中的进程'
            notes <<-'END'
                # 按 CPU 排序
                ps aux --sort=-%cpu | head

                # 按内存排序
                ps aux --sort=-%mem | head
            END
        end
        entry do
            command 'uptime'
            name '查看系统负载'
            notes <<-'END'
                # 查看系统启动时间
                uptime -s
            END
        end
        entry do
            command 'top -H -p <pid>'
            name '查看指定进程的线程使用率'
        end
        entry do
            command 'ss -antp | grep <pid>'
            name '查看指定进程的网络连接'
        end
        
        entry do
            command 'pidstat -d -p <pid> 1'
            name '每秒输出进程的磁盘使用信息'
        end
        entry do
            command 'pidstat -u -p <pid> 1'
            name '每秒输出进程的CPU'
        end
        entry do
            command 'pidstat -t -p <pid> 1'
            name '每秒输出进程的线程信息'
        end
    end

    category do
        id 'java'

        entry do
            command 'jps -lv'
            name '查看 Java 进程'
        end
        entry do
            command 'jcmd <pid> VM.command_line'
            name '查看 JVM 启动参数'
            notes <<-'END'
                # 查看 JVM 支持哪些命令
                jcmd <pid> help

                # 生成 Heap dump
                jcm <pid> GC.heap_dump /tmp/heap.hprof

                | command | 含义 |
                | --- | --- |
                | help | 帮助 |
                | VM.command_line | JVM 启动参数 |
                | VM.flags | JVM 参数 |
                | VM.system_properties | 系统属性 |
                | GC.heap_info | 堆内存 |
                | VM.uptime | JVM 启动时间 | 
                | GC.class_stats | 查看类统计 |
                | GC.class_histogram | 查看对象统计 |
                | Thread.print | 线程状态输出 |
            END
        end
        entry do
            command 'jmap --dump:format=b,file=/tmp/heap.hprof <pid>'
            name '生成 Heap dump'
        end
        entry do
            command 'jstat -gcutil <pid> 1000'
            name'每1000ms打印一次gc'
            notes <<-'END'
                | 标识 | 含义 |
                | --- | --- |
                | E | Eden |
                | O | Old |
                | YGC | Young GC 次数 |
                | YGCT | Young GC 总时间 |
                | FGC | Full GC 次数 |
                | FGCT | Full GC 总时间 |
            END
        end
        entry do
            command 'jstack <pid>'
            name '线程状态输出'
        end
    end

    category do 
        id ''

        
    end
end