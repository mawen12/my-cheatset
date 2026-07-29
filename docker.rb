cheatsheet do
    title 'Docker 中文指南'
    docset_file_name 'Docker'
    keyword 'docker'
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
        id 'attach 附加到正在运行的容器'

        entry do
            command '--detach-keys'
            name '覆盖用于分离容器的按键序列'
        end
        entry do
            command '--help'
            name '输出帮助信息'
        end
        entry do
            command '--no-stdin'
            name '不要附加到 STDIN'
        end
        entry do
            command '--sig-proxy'
            name '将所有接收到的信号转发到该进程（默认为 true）'
        end
    end

    category do
        id 'build 从 Dockerfile 构建一个镜像'

        entry do
            command '--build-arg'
            name '设置 build-time 变量，默认为 []'
        end
        entry do
            command '--cgroup-parent'
            name '用于容器的父级 cgroup，可选'
        end
        entry do
            command '--cpu-period'
            name '限制 CPU CFS（完全公平调度器）周期'
        end
        entry do
            command '--cpu-quota'
            name '限制 CPU CFS（完全公平调度器）配额'
        end
        entry do
            command '-c'
            name 'int，CPU 份额（相对权重）'
        end
        entry do
            command '--cpuset-cpus'
            name '允许执行的CPU（0-3，0,1）'
        end
        entry do
            command '--cpusset-mems'
            name '运行执行的内存（0-3，0,1）'
        end
        entry do
            command '--disable-content-trust'
            name '跳过镜像验证，默认为 true'
        end
        entry do
            command '-f'
            name 'string，Dockerfile 的名称，默认为 PATH/Dockerfile'
        end
        entry do
            command '--force-rm'
            name '总是移除中间层的容器'
        end
        entry do
            command '--help'
            name '输出帮助信息'
        end
        entry do
            command '--isolation'
            name '容器隔离技术'
        end
        entry do
            command '--label'
            name '设置镜像的元信息，默认为 []'
        end
        entry do
            command '-m'
            name 'string，内存限制'
        end
        entry do
            command '--memory-swap'
            name '交换空间限制等于内存+交换空间，设置为 -1 为启用无限制的交换空间'
        end
        entry do
            command '--no-cache'
            name '当构建镜像时不使用缓存'
        end
        entry do
            command '--pull'
            name '总是尝试拉取新版本的镜像'
        end
        entry do
            command '-q'
            name '抑制构建输出，并在成功时打印镜像 ID'
        end
        entry do
            command '--rm'
            name '在成功构建后移除中间层的容器，默认为 true'
        end
        entry do
            command '--shm-size'
            name '/dev/shm 的大小，默认值为 64MB'
        end
        entry do
            command '-t'
            name '以 name:tag 格式的名称和可选标签，默认为 []'
        end
        entry do
            command '--ulimit'
            name 'ulimit 选项，默认为 []'
        end
    end

    category do
        id 'commit 从容器的变更中创建新的镜像'

        entry do
            command '-a'
            name '作者，比如："John Hanninal Smith <hannible@a-team.com>"'
        end
        entry do
            command '-C'
            name '将 Dockerfile 指令应用于所创建的镜像，默认为 []'
        end
        entry do
            command '--help'
            name '输出帮助信息'
        end
        entry do
            command '-m'
            name '提交信息'
        end
        entry do
            command '-p'
            name '提交期间暂停容器，默认为 true'
        end
    end

    category do
        id 'cp 在容器和本地文件系统之间复制文件和目录'

        entry do
            command '-L'
            name '始终跟随 SRC_PATH 的符号路径'
        end
        entry do
            command '--help'
            name '输出帮助信息'
        end
    end

    category do
        id 'create 创建新的容器'

        entry do
            command '--add-host'
            name '添加一组自定义的 host-IP 的映射，默认为 []'
        end
        entry do
            command '-a'
            name '附加到 STDIN、STDOUT 或 STDERR，默认为 []'
        end
        entry do
            command '--blkio-weight'
            name '阻塞 IO（相对权重），在 10 到 1000 之间'
        end
        entry do
            command '--blkio-weight-device'
            name '阻塞 IO 权重（相对设备权重），在 10 到 1000 之间'
        end
        entry do
            command '--cap-add'
            name '添加 Linux 能力，默认为 []'
        end
        entry do
            command '--cap-drop'
            name '丢弃 Linux 能力，默认为 []'
        end
        entry do
            command '--cgroup-parent'
            name '设置容器的父级 cgroup，可选'
        end
        entry do
            command '--cidfile'
            name '写入容器的ID到文件'
        end
        entry do
            command '--cpu-percent'
            name 'CPU 百分比，仅限 Windows'
        end
        entry do
            command '--cpu-period'
            name '限制 CPU CFS（完全公平调度器）周期'
        end
        entry do
            command '--cpu-quota'
            name '限制 CPU CFS（完全公平调度器）配额'
        end
        entry do
            command '-c'
            name 'int，CPU 份额（相对权重）'
        end
        entry do
            command '--cpuset-cpus'
            name '允许执行的CPU（0-3，0,1）'
        end
        entry do
            command '--cpusset-mems'
            name '运行执行的内存（0-3，0,1）'
        end
        entry do
            command '--device'
            name '添加主机设备到容器，默认为 []'
        end
        entry do
            command '--device-read-bps'
            name '限制从设备读取的速率（每秒字节数），默认为 []'
        end
        entry do
            command '--device-read-iops'
            name '限制从设备读取的速率（每秒 IO），默认为 []'
        end
        entry do
            command '--device-write-bps'
            name '限制写入到设备的速率（每秒字节数），默认为 []'
        end
        entry do
            command '--device-write-iops'
            name '限制写入到设备的速率（每秒 IO），默认为 []'
        end
        entry do
            command '--disable-content-trust'
            name '跳过镜像验证，默认为 true'
        end
        entry do
            command '--dns'
            name '设置自定义的 DNS 服务器，默认为 []'
        end
        entry do
            command '--dns-opt'
            name '设置 DNS 选项，默认为 []'
        end
        entry do
            command '--dns-search'
            name '设置自定义的 DNS 搜索的域名，默认为 []'
        end
        entry do
            command '--entrypoint'
            name '覆盖镜像默认的 ENTRYPOINT'
        end
        entry do
            command '-e'
            name '设置环境变量，默认为 []'
        end
        entry do
            command '--env-file'
            name '读取包含环境变量的文件，默认为 []'
        end
        entry do
            command '--expose'
            name '暴露一个或一个范围的端口，默认为 []'
        end
        entry do
            command '--group-add'
            name '添加加入的额外组，默认为 []'
        end
        entry do
            command '--health-cmd'
            name '用于检查健康的命令'
        end
        entry do
            command '--health-interval'
            name '运行检查的间隔'
        end
        entry do
            command '--health-retries'
            name '需达到连续失败次数才会报告为不健康状态'
        end
        entry do
            command '--health-timeout'
            name '允许单次检查运行的最长时间'
        end
        entry do
            command '--help'
            name '输出帮助信息'
        end
        entry do
            command '-h'
            name '容器主机名称'
        end
        entry do
            command '-i'
            name '保持 STDIN 打开，即使没有附加'
        end
        entry do
            command '--io-maxbandwidth'
            name '用于系统设备的最大 IO 带宽限制，仅 Widnows'
        end
        entry do
            command '--io-maxiops'
            name '用于系统设备的最大 IOps 限制，仅 Windows'
        end
        entry do
            command '--ip'
            name '容器 IPv4 地址，例如：172.30.100.104'
        end
        entry do
            command '--ip6'
            name '容器 IPv6 地址，例如：2001:db8::33'
        end
        entry do
            command '--ipc'
            name '使用的 IPC 命令空间'
        end
        entry do
            command '--isolation'
            name '容器隔离技术'
        end
        entry do
            command '--kernel-memory'
            name '内核内存限制'
        end
        entry do
            command '-l'
            name '设置到容器的元数据，默认为 []'
        end
        entry do
            command '--label-file'
            name '读入一个按行分隔的标签文件，默认为 []'
        end
        entry do
            command '--link'
            name '添加连接到另一个容器，默认为 []'
        end
        entry do
            command '--link-local-ip'
            name '容器 IPv4/IPv6 链接本地地址，默认为 []'
        end
        entry do
            command '--log-driver'
            name '容器的日志驱动'
        end
        entry do
            command '--log-opt'
            name '日志驱动选项，默认为 []'
        end
        entry do
            command '--mac-address'
            name '容器 MAC 地址，例如：92:d0:c6:a0:29:33'
        end
        entry do
            command '-m'
            name 'string，内存限制'
        end
        entry do
            command '--memory-reservation'
            name '内存软限制'
        end
        entry do
            command '--memory-swap'
            name '交换空间限制等于内存+交换空间，设置为 -1 为启用无限制的交换空间'
        end
        entry do
            command '--memory-swappiness'
            name '调整容器内容 swappiness 值，从0到100，默认 -1'
        end
        entry do
            command '--name'
            name '容器名称'
        end
        entry do
            command '--net'
            name '链接容器到网络，默认为 default'
        end
        entry do
            command '--net-alias'
            name '为容器添加网络范围内的别名，默认为 []'
        end
        entry do
            command '--no-healthcheck'
            name '禁用任何容器指定的 HEALTHCHECK'
        end
        entry do
            command '--oom-kill-disable'
            name '禁用 OOM Killer'
        end
        entry do
            command '--oom-score-adj'
            name '调整宿主机的 OOM 偏好值，-1000 到 1000'
        end
        entry do
            command '--pid'
            name '使用的 PID 命令空间'
        end
        entry do
            command '--pids-limit'
            name '调整容器的 pid 限制，设置为 -1 代表不限制'
        end
        entry do
            command '--privileged'
            name '向吃容器授予扩展权限'
        end
        entry do
            command '-p'
            name '发布容器的端口到宿主机，默认为 []'
        end
        entry do
            command '-P'
            name '发布所有暴露的端口到宿主机的随机端口'
        end
        entry do
            command '--read-only'
            name '绑定容器的根文件系统为只读'
        end
        entry do
            command '--restart'
            name '当容器退出时的重启策略，默认为 no'
        end
        entry do
            command '--runtime'
            name '用于此容器的运行时'
        end
        entry do
            command '--security-opt'
            name '安全选项，默认为 []'
        end
        entry do
            command '--shm-size'
            name '/dev/shm 的大小，默认为 64MB'
        end
        entry do
            command '--stop-signal'
            name '停止容器的指令，默认为 SIGTERM'
        end
        entry do
            command '--storage-opt'
            name '设置每个容器的存储驱动选项，默认为 []'
        end
        entry do
            command '--sysctl'
            name 'Sysctl 选项，默认为 map[]'
        end
        entry do
            command '--tmpfs'
            name '绑定一个 tmpfs 目录，默认为 []'
        end
        entry do
            command '-t'
            name '分配伪终端'
        end
        entry do
            command '-ulimit'
            name 'Ulimit 选项，默认为 []'
        end
        entry do
            command '-u'
            name '用户名或 UID，格式为 <name|uid>[:<group|gid>]'
        end
        entry do
            command '--userns'
            name '使用的用户命令空间'
        end
        entry do
            command '--uts'
            name '使用 UTS 命名空间'
        end
        entry do
            command '-v'
            name '绑定挂载卷，默认为 []'
        end
        entry do
            command '--volumn-driver'
            name '容器的卷驱动'
        end
        entry do
            command '--volumns-from'
            name '挂载指定容器的卷，默认为 []'
        end
        entry do
            command '-w'
            name '容器内的工作目录'
        end
    end

    category do
        id 'deploy 创建并更新 stack'

        entry do
            command '-f'
            name 'Bundle 酷劲，默认为 STACK.dsb'
        end
        entry do
            command '--help'
            name '输出帮助信息'
        end
    end

    category do
        id 'diff 检查容器文件系统上的变更'

        entry do
            command '--help'
            name '输出帮助信息'
        end
    end

    category do
        id 'events 从服务器上获取实时事件'

        entry do
            command '-f'
            name '基于提供的条件过滤输出'
        end
        entry do
            command '--help'
            name '输出帮助信息'
        end
        entry do
            command '--since'
            name '展示创建于该时间之后的事件'
        end
        entry do
            command '--until'
            name '持续流式传输事件，直至该时间戳'
        end
    end

    category do
        id 'exec 在一个运行中的容器内运行命令'
    end

    category do
        id 'export 将容器的文件系统导出为 tar 归档文件'

        entry do
            command '--help'
            name '输出帮助信息'
        end
        entry do
            command '-o'
            name '写入到文件，而不是 STDOUT'
        end
    end

    category do
        id 'history 展示镜像历史'

        entry do
            command '--help'
            name '输出帮助信息'
        end
        entry do
            command '-H'
            name '以人类可读的格式输出大小和日期'
        end
        entry do
            command '--no-trunc'
            name '不要截断输出'
        end
        entry do
            command '-q'
            name '仅展示 ID 数字'
        end
    end

    category do
        id 'images 列出镜像'

        entry do
            command '-a'
            name '展示所有镜像，默认隐藏中间层的镜像'
        end
        entry do
            command '--digests'
            name '展示摘要'
        end
        entry do
            command '-f'
            name '基于提供的条件过滤输出，默认为 []'
        end
        entry do
            command '--format'
            name '使用 Go 模板美化输出镜像'
        end
        entry do
            command '--help'
            name '输出帮助信息'
        end
        entry do
            command '--no-trunc'
            name '不要截断输出'
        end
        entry do
            command '-q'
            name '仅展示 ID 数字'
        end
    end

    category do
        id 'import 从 tarball 导入内容来创建文件系统镜像'

        entry do
            command '-C'
            name '应用 Dockerfile 指令来创建镜像，默认为 []'
        end
        entry do
            command '--help'
            name '输出帮助信息'
        end
        entry do
            command '-m'
            name '设置导入镜像的提交信息'
        end
    end

    category do
        id 'info 展示系统范围的信息'
    end

    category do
        id 'inspect 返回容器/镜像或任务的低级信息'
    end

    category do
        id 'kill 杀掉一个或多个运行中的容器'

        entry do
            command '--help'
            name '输出帮助信息'
        end
        entry do
            command '-s'
            name '发送到容器的信号，默认为 KILL'
        end
    end

    category do
        id 'load 从 tar 归档文件或 STDIN 加载镜像'

        entry do
            command '--help'
            name '输出帮助信息'
        end
        entry do
            command '-i'
            name '从规范文件读取，而不是 STDIN'
        end
        entry do
            command '-q'
            name '抑制加载输出'
        end
    end

    category do
        id 'login 登录到 Docker registry'

        entry do
            command '--help'
            name '输出帮助信息'
        end
        entry do
            command '-p'
            name '密码'
        end
        entry do
            command '-u'
            name '用户名'
        end
    end
    
    category do
        id 'logout 登出'

        entry do
            command '--help'
            name '输出帮助信息'
        end
    end

    category do
        id 'logs 获取容器的日志'

        entry do
            command '--details'
            name '显式提供给日志的额外详细信息'
        end
        entry do
            command '-f'
            name '跟随日志输出'
        end
        entry do
            command '--help'
            name '输出帮助信息'
        end
        entry do
            command '--since'
            name '输出从指定时间戳开始的日志'
        end
        entry do
            command '--tail'
            name '展示从日志末尾显式的行数，默认为 all'
        end
        entry do
            command '-t'
            name '显式时间戳'
        end
    end

    category do
        id 'network 管理 Docker 网络'

        entry do
            command '--help'
            name '输出帮助信息'
        end
    end

    category do
        id 'node 管理 Docker Swarm 节点'

        entry do
            command '--help'
            name '输出帮助信息'
        end
    end

    category do
        id 'pause 暂停一个或多个容器的所有进程'

        entry do
            command '--help'
            name '输出帮助信息'
        end
    end

    category do
        id 'plugin 管理 Docker 插件'

        entry do
            command '--help'
            name '输出帮助信息'
        end
    end

    category do
        id 'port 列出容器的端口映射或特定映射'

        entry do
            command '--help'
            name '输出帮助信息'
        end
    end

    category do
        id 'ps 列出容器'

        entry do
            command '-n'
            name 'int，展示最多 n 个创建的容器，包含所有状态，默认为 -1'
        end
        entry do
            command '-a'
            name '展示所有容器，默认展示运行中'
        end
        entry do
            command '-f'
            name '基于提供的条件过滤输出，默认为 []'
        end
        entry do
            command '--format'
            name '使用 Go 模板美化输出'
        end
        entry do
            command '--help'
            name '输出帮助信息'
        end
        entry do
            command '-l'
            name '展示最近创建的容器，包含所有状态'
        end
        entry do
            command '--no-trunc'
            name '不要截断输出'
        end
        entry do
            command '-q'
            name '仅展示数字 ID'
        end
        entry do
            command '-s'
            name '展示文件大小'
        end
    end

    category do
        id 'pull 从 Docker registry 拉取镜像或仓库'

        entry do
            command '-a'
            name '下载该仓库中所有已打上标签的镜像'
        end
        entry do
            command '--disable-content-trust'
            name '跳过镜像验证，默认为 true'
        end
        entry do
            command '--help'
            name '输出帮助信息'
        end
    end

    category do
        id 'push 推送镜像或仓库到 Docker registry'

        entry do
            command '--disable-content-trust'
            name '跳过镜像验证，默认为 true'
        end
        entry do
            command '--help'
            name '输出帮助信息'
        end
    end

    category do
        id 'rename 对容器重命名'

        entry do
            command '--help'
            name '输出帮助信息'
        end
    end

    category do
        id 'restart 对容器重启'

        entry do
            command '--help'
            name '输出帮助信息'
        end
        entry do
            command '-t'
            name 'int，在 kill 容器前等待停止的秒数，默认为 10'
        end
    end

    category do
        id 'rm 移除一个或多个容器'

        entry do
            command '-f'
            name '强制移除运行中的容器，使用 SIGKILL'
        end
        entry do
            command '--help'
            name '输出帮助信息'
        end
        entry do
            command '-l'
            name '移除特定的链接'
        end
        entry do
            command '-v'
            name '移除与容器关联的卷'
        end
    end

    category do
        id 'rmi 移除一个或多个镜像'

        entry do
            command '-f'
            name '强制移除镜像'
        end
        entry do
            command '--help'
            name '输出帮助信息'
        end
        entry do
            command '--no-prune'
            name '不要删除未标记的父级'
        end
    end

    category do
        id 'run 在一个新容器上运行命令'

        entry do
            command '--add-host'
            name '添加一组自定义的 host-IP 的映射，默认为 []'
        end
        entry do
            command '-a'
            name '附加到 STDIN、STDOUT 或 STDERR，默认为 []'
        end
        entry do
            command '--blkio-weight'
            name '阻塞 IO（相对权重），在 10 到 1000 之间'
        end
        entry do
            command '--blkio-weight-device'
            name '阻塞 IO 权重（相对设备权重），在 10 到 1000 之间'
        end
        entry do
            command '--cap-add'
            name '添加 Linux 能力，默认为 []'
        end
        entry do
            command '--cap-drop'
            name '丢弃 Linux 能力，默认为 []'
        end
        entry do
            command '--cgroup-parent'
            name '设置容器的父级 cgroup，可选'
        end
        entry do
            command '--cidfile'
            name '写入容器的ID到文件'
        end
        entry do
            command '--cpu-percent'
            name 'CPU 百分比，仅限 Windows'
        end
        entry do
            command '--cpu-period'
            name '限制 CPU CFS（完全公平调度器）周期'
        end
        entry do
            command '--cpu-quota'
            name '限制 CPU CFS（完全公平调度器）配额'
        end
        entry do
            command '-c'
            name 'int，CPU 份额（相对权重）'
        end
        entry do
            command '--cpuset-cpus'
            name '允许执行的CPU（0-3，0,1）'
        end
        entry do
            command '--cpusset-mems'
            name '运行执行的内存（0-3，0,1）'
        end
        entry do
            command '-d'
            name '在后台运行容器，并输出容器 ID'
        end
        entry do
            command '--detach-keys'
            name '覆盖用于分离容器的 key 序列'
        end
        entry do
            command '--device'
            name '添加主机设备到容器，默认为 []'
        end
        entry do
            command '--device-read-bps'
            name '限制从设备读取的速率（每秒字节数），默认为 []'
        end
        entry do
            command '--device-read-iops'
            name '限制从设备读取的速率（每秒 IO），默认为 []'
        end
        entry do
            command '--device-write-bps'
            name '限制写入到设备的速率（每秒字节数），默认为 []'
        end
        entry do
            command '--device-write-iops'
            name '限制写入到设备的速率（每秒 IO），默认为 []'
        end
        entry do
            command '--disable-content-trust'
            name '跳过镜像验证，默认为 true'
        end
        entry do
            command '--dns'
            name '设置自定义的 DNS 服务器，默认为 []'
        end
        entry do
            command '--dns-opt'
            name '设置 DNS 选项，默认为 []'
        end
        entry do
            command '--dns-search'
            name '设置自定义的 DNS 搜索的域名，默认为 []'
        end
        entry do
            command '--entrypoint'
            name '覆盖镜像默认的 ENTRYPOINT'
        end
        entry do
            command '-e'
            name '设置环境变量，默认为 []'
        end
        entry do
            command '--env-file'
            name '读取包含环境变量的文件，默认为 []'
        end
        entry do
            command '--expose'
            name '暴露一个或一个范围的端口，默认为 []'
        end
        entry do
            command '--group-add'
            name '添加加入的额外组，默认为 []'
        end
        entry do
            command '--health-cmd'
            name '用于检查健康的命令'
        end
        entry do
            command '--health-interval'
            name '运行检查的间隔'
        end
        entry do
            command '--health-retries'
            name '需达到连续失败次数才会报告为不健康状态'
        end
        entry do
            command '--health-timeout'
            name '允许单次检查运行的最长时间'
        end
        entry do
            command '--help'
            name '输出帮助信息'
        end
        entry do
            command '-h'
            name '容器主机名称'
        end
        entry do
            command '-i'
            name '保持 STDIN 打开，即使没有附加'
        end
        entry do
            command '--io-maxbandwidth'
            name '用于系统设备的最大 IO 带宽限制，仅 Widnows'
        end
        entry do
            command '--io-maxiops'
            name '用于系统设备的最大 IOps 限制，仅 Windows'
        end
        entry do
            command '--ip'
            name '容器 IPv4 地址，例如：172.30.100.104'
        end
        entry do
            command '--ip6'
            name '容器 IPv6 地址，例如：2001:db8::33'
        end
        entry do
            command '--ipc'
            name '使用的 IPC 命令空间'
        end
        entry do
            command '--isolation'
            name '容器隔离技术'
        end
        entry do
            command '--kernel-memory'
            name '内核内存限制'
        end
        entry do
            command '-l'
            name '设置到容器的元数据，默认为 []'
        end
        entry do
            command '--label-file'
            name '读入一个按行分隔的标签文件，默认为 []'
        end
        entry do
            command '--link'
            name '添加连接到另一个容器，默认为 []'
        end
        entry do
            command '--link-local-ip'
            name '容器 IPv4/IPv6 链接本地地址，默认为 []'
        end
        entry do
            command '--log-driver'
            name '容器的日志驱动'
        end
        entry do
            command '--log-opt'
            name '日志驱动选项，默认为 []'
        end
        entry do
            command '--mac-address'
            name '容器 MAC 地址，例如：92:d0:c6:a0:29:33'
        end
        entry do
            command '-m'
            name 'string，内存限制'
        end
        entry do
            command '--memory-reservation'
            name '内存软限制'
        end
        entry do
            command '--memory-swap'
            name '交换空间限制等于内存+交换空间，设置为 -1 为启用无限制的交换空间'
        end
        entry do
            command '--memory-swappiness'
            name '调整容器内容 swappiness 值，从0到100，默认 -1'
        end
        entry do
            command '--name'
            name '容器名称'
        end
        entry do
            command '--net'
            name '链接容器到网络，默认为 default'
        end
        entry do
            command '--net-alias'
            name '为容器添加网络范围内的别名，默认为 []'
        end
        entry do
            command '--no-healthcheck'
            name '禁用任何容器指定的 HEALTHCHECK'
        end
        entry do
            command '--oom-kill-disable'
            name '禁用 OOM Killer'
        end
        entry do
            command '--oom-score-adj'
            name '调整宿主机的 OOM 偏好值，-1000 到 1000'
        end
        entry do
            command '--pid'
            name '使用的 PID 命令空间'
        end
        entry do
            command '--pids-limit'
            name '调整容器的 pid 限制，设置为 -1 代表不限制'
        end
        entry do
            command '--privileged'
            name '向吃容器授予扩展权限'
        end
        entry do
            command '-p'
            name '发布容器的端口到宿主机，默认为 []'
        end
        entry do
            command '-P'
            name '发布所有暴露的端口到宿主机的随机端口'
        end
        entry do
            command '--read-only'
            name '绑定容器的根文件系统为只读'
        end
        entry do
            command '--restart'
            name '当容器退出时的重启策略，默认为 no'
        end
        entry do
            command '--rm'
            name '当容器已经存在时，自动移除'
        end
        entry do
            command '--runtime'
            name '用于此容器的运行时'
        end
        entry do
            command '--security-opt'
            name '安全选项，默认为 []'
        end
        entry do
            command '--shm-size'
            name '/dev/shm 的大小，默认为 64MB'
        end
        entry do
            command '--sig-proxy'
            name '代理接收发送给进程的信号，默认为 true'
        end
        entry do
            command '--stop-signal'
            name '停止容器的指令，默认为 SIGTERM'
        end
        entry do
            command '--storage-opt'
            name '设置每个容器的存储驱动选项，默认为 []'
        end
        entry do
            command '--sysctl'
            name 'Sysctl 选项，默认为 map[]'
        end
        entry do
            command '--tmpfs'
            name '绑定一个 tmpfs 目录，默认为 []'
        end
        entry do
            command '-t'
            name '分配伪终端'
        end
        entry do
            command '-ulimit'
            name 'Ulimit 选项，默认为 []'
        end
        entry do
            command '-u'
            name '用户名或 UID，格式为 <name|uid>[:<group|gid>]'
        end
        entry do
            command '--userns'
            name '使用的用户命令空间'
        end
        entry do
            command '--uts'
            name '使用 UTS 命名空间'
        end
        entry do
            command '-v'
            name '绑定挂载卷，默认为 []'
        end
        entry do
            command '--volumn-driver'
            name '容器的卷驱动'
        end
        entry do
            command '--volumns-from'
            name '挂载指定容器的卷，默认为 []'
        end
        entry do
            command '-w'
            name '容器内的工作目录'
        end
    end

    category do
        id 'save 保存一个或多个镜像到 tar 归档文件，默认传递到 STDOUT'

        entry do
            command '--help'
            name '输出帮助信息'
        end
        entry do
            command '-o'
            name '写入到文件，而不是 STDOUT'
        end
    end

    category do
        id 'search 从 Docker Hub 中搜索镜像'

        entry do
            command '-f'
            name '基于给定条件过滤输出，默认为 []'
        end
        entry do
            command '--help'
            name '输出帮助信息'
        end
        entry do
            command '--limit'
            name '搜索结果最大数量，默认为 25'
        end
        entry do
            command '--no-trunc'
            name '不要截断输出'
        end
    end

    category do
        id 'service 管理 Docker services'

        entry do
            command '--help'
            name '输出帮助信息'
        end
    end

    category do
        id 'stack 管理 Docker stacks'

        entry do
            command '--help'
            name '输出帮助信息'
        end
    end

    category do
        id 'start 启动一个或多个停止的容器'

        entry do
            command '-a'
            name '附加到 STDOUT/STDERR，并重定向信号'
        end
        entry do
            command '--detach-keys'
            name '覆盖用于分离容器的 key 序列'
        end
        entry do
            command '--help'
            name '输出帮助信息'
        end
        entry do
            command '-i'
            name '附加到容器的 STDIN'
        end
    end

    category do
        id 'stats 启动一个或多个停止的容器'

        entry do
            command '-a'
            name '展示所有的容器，默认仅运行中'
        end
        entry do
            command '--help'
            name '输出帮助信息'
        end
        entry do
            command '--no-stream'
            name '禁用流式传输，仅获取首次结果'
        end
    end

    category do
        id 'stop 停止一个或多个停止的容器'

        entry do
            command '--help'
            name '输出帮助信息'
        end
        entry do
            command '-t'
            name 'int，在 kill 容器前等待停止的秒数，默认为 10'
        end
    end

    category do
        id 'swarm 管理 Docker swarm'

        entry do
            command '--help'
            name '输出帮助信息'
        end
    end

    category do
        id 'tag 将镜像标记并存入仓库'

        entry do
            command '--help'
            name '输出帮助信息'
        end
    end

    category do
        id 'top 展示容器的运行中进程'

        entry do
            command '--help'
            name '输出帮助信息'
        end
    end

    category do
        id 'unpause 取消暂停一个或多个容器内的所有进程'

        entry do
            command '--help'
            name '输出帮助信息'
        end
    end

    category do
        id 'update 更新一个或多个容器的配置'
    end

    category do
        id 'version 展示 Docker 的版本信息'

        entry do
            command '-f'
            name '使用给定的 Go 模板来格式化输出'
        end
        entry do
            command '--help'
            name '输出帮助信息'
        end
    end

    category do
        id 'volume 展示 Docker volumes'

        entry do
            command '--help'
            name '输出帮助信息'
        end
    end

    category do
        id 'wait 阻塞直到容器停止，然后打印它的退出码'

        entry do
            command '--help'
            name '输出帮助信息'
        end
    end

    category do
        id '集群'

        entry do
            name '主从架构'
            notes <<-'END'
                ```bash
                # slave 执行
                replicaof <master-host> <master-port>
                ```
            END
        end
    end

    category do
        id '快速启动'

        entry do
            name 'Redis'
            notes <<-'END'
                ```bash
                docker pull redis:latest
                docker run -d --name redis -p 6379:6379 redis:latest
                ```
            END
        end
        entry do
            name 'MongoDB'
            notes <<-'END'
                ```bash
                docker pull mongodb/mongodb-community-server:latest
                docker run -d --name mongodb -p 27017:27017 mongodb/mongodb-community-server:latest
                ```
            END
        end
    end
end