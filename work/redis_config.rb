cheatsheet do
    title ''
    docset_file_name ''
    keyword ''

    category do
        id 'INCLUDES'

        enty do
            command 'include /path/to/other.conf'
            name '支持多行以便导入多个外部配置，实现配置模板通用'
        end
    end

    category do
        id 'MODULES'

        enty do
            command 'loadmodule /path/to/other_module.so'
            name '支持多行以便导入多个模块，当模块加载失败时，redis则启动失败'
        end
    end

    category do
        id 'NETWORK'

        enty do
            command 'bind 192.168.1.100 10.0.0.1'
            name '指定redis监听外部主机的ip配置'
        end
        enty do
            command 'protected-mode yes/no'
            name '保护模式开关，默认开启，开启后仅接受 127.0.0.1 和 ::1 的ip'
        end
        enty do
            command 'port 6379'
            name '接受链接的特定端口'
        end
        enty do
            command 'tcp-backlog 511'
            name '在高rps(Request per second)环境中，要相应设置更高的值，避免拖慢客户端连接'
        end
        entry do
            command 'unixsocket /tmp/redis.sock'
            name '指定用于监听即将到来连接的 unix socket 路径'
        end
        entry do
            command 'unixsocketperm 700'
            name '指定用于监听即将到来连接的 unix socket 的权限'
        end
        entry do
            command 'timeout 0'
            name '指定客户端连接的存活时间，0代表禁用超时'
        end
        entry do
            command 'tcp-keepalive 300'
            name '是否需要复用tcp连接，通过使用 SO_KEEPALIVE 来发送TCP ACKS，0代表禁用'
        end
    end

    category do
        id 'TLS/SSL'

        entry do
            command 'tls-port 6379'
            name 'TLS/SSL 配置，需要同时显示设置 port 0'
        endentry do
            command 'tls-cert-file redis.crt'
            name '配置 x.509 验证文件用于客户端、master和集群节点的认证'
        end
        entry do
            command 'tls-key-file redis.key'
            name '配置 x.509 key 文件'
        end
        entry do
            command 'tls-dh-paras-file redis.dh'
            name '配置 DH 参数文件来开启 Diffie-Hellman key 交换'
        end
        entry do
            command 'tls-ca-cert-file ca.cert'
            name ''
        end
        entry do
            command 'tls-ca-cert-dir /etc/ssl/certs'
            name ''
        end
        entry do
            command 'tls-auth-clients no/optional'
            name ''
        end
        entry do
            command 'tls-replication yes'
            name ''
        end
        entry do
            command 'tls-cluster yes'
            name ''
        end
        entry do
            command 'tls-protocols "TLSv1.2 TLSv1.3"'
            name ''
        end
        entry do
            command 'tls-ciphers DEFAULT:!MEDIUM'
            name ''
        end
        entry do
            command 'tls-perfer-server-ciphers yes'
            name ''
        end
        entry do
            command 'tls-session-caching no'
            name ''
        end
        entry do
            command 'tls-session-cache-size 5000'
            name ''
        end
        entry do
            command 'tls-session-cache-timeout 60'
            name ''
        end
    end

    category do
        id 'GENERAL'

        entry do
            command 'daemonize no'
            name ''
        end
        entry do
            command 'supervised no'
            name ''
        end
        entry do
            command 'pidfile /var/run/redis_6379.pid'
            name ''
        end
        entry do
            command 'loglevel notice'
            name ''
        end
        entry do
            command 'syslog-enabled no'
            name ''
        end
        entry do
            command 'syslog-ident redis'
            name ''
        end
        entry do
            command 'syslog-facility local0'
            name ''
        end
        entry do
            command 'databases 16'
            name ''
        end
        entry do
            command 'always-show-logo yes'
            name ''
        end
    end

    category do
        id 'SNAPSHOTTING'

        entry do
            command 'save 900 1'
            name ''
        end
        entry do
            command 'save 300 10'
            name ''
        end
        entry do
            command 'save 60 10000'
            name ''
        end
        entry do
            command 'stop-writes-on-bgsave-error yes'
            name ''
        end
        entry do
            command 'rdbcompression yes'
            name ''
        end
        entry do
            command 'rdbchecksum yes'
            name ''
        end
        entry do
            command 'dbfilename dump.rdb'
            name ''
        end
        entry do
            command 'rdb-del-sync-files no'
            name ''
        end
        entry do
            command 'dir ./'
            name ''
        end
    end

    category do
        id 'REPLICATION'

        entry do
            command 'replicaof <masterip> <masterport>'
            name ''
        end
        entry do
            command 'masterauth <master-password>'
            name ''
        end
        entry do
            command 'masteruser <username>'
            name ''
        end
        entry do
            command 'replica-serve-stale-data yes'
            name ''
        end
        entry do
            command 'replica-read-only yes'
            name ''
        end
        entry do
            command 'repl-diskless-sync no'
            name ''
        end
        entry do
            command 'repl-diskless-sync-delay 5'
            name ''
        end
        entry do
            command 'repl-diskless-load disabled'
            name ''
        end
        entry do
            command 'repl-ping-replica-period 10'
            name ''
        end
        entry do
            command 'repl-timeout 60'
            name ''
        end
        entry do
            command 'repl-disable-tcp-nodelay no'
            name ''
        end
        entry do
            command 'repl-backlog-size 1mb'
            name ''
        end
        entry do
            command 'repl-backlog-ttl 3600'
            name ''
        end
        entry do
            command 'replica-priority 100'
            name ''
        end
        entry do
            command 'min-replicas-to-write 3'
            name ''
        end
        entry do
            command 'min-replica-max-lag 10'
            name ''
        end
        entry do
            command 'replica-announce-ip 5.5.5.5'
            name ''
        end
        entry do
            command 'replica-announce-port 1234'
            name ''
        end
    end

    category do
        id 'KEYS TRACKING'

        entry do
            command 'tracking-table-max-keys 1000000'
            name ''
        end
    end

    category do
        id 'SECURITY'

        entry do
            command 'acllog-max-len 128'
            name ''
        end
        entry do
            command 'aclfile /etc/redis/users.acl'
            name ''
        end
        entry do
            command 'requirepass foobared'
            name ''
        end
    end

    category do
        id 'CLIENTS'

        entry do
            command 'maxclients 10000'
            name ''
        end
    end

    category do
        id 'MEMORY MANAGEMENT'

        entry do
            command 'maxmemory <bytes>'
            name ''
        end
        entry do
            command 'maxmemory-policy noeviction|volatile-lru|allkeys-lru|volatile-lfu|allkeys-lfu|volatile-random|allkeys-random|volatile-ttl'
            name ''
        end
        entry do
            command 'maxmemory-samples 5'
            name ''
        end
        entry do
            command 'replica-ignore-maxmemory yes'
            name ''
        end
        entry do
            command 'active-expire-effort 1'
            name ''
        end
    end

    category do
        id 'LAZY FREEING'

        entry do
            command 'lazyfree-lazy-eviction no'
            name ''
        end
        entry do
            command 'lazyfree-lazy-expire no'
            name ''
        end
        entry do
            command 'lazyfree-lazy-server-del no'
            name ''
        end
        entry do
            command 'lazyfree-lazy-server-del no'
            name ''
        end
        entry do
            command 'replica-lazy-flush no'
            name ''
        end
        entry do
            command 'lazyfree-lazy-user-del no'
            name ''
        end
    end

    category do
        id 'THREADED I/O'

        entry do
            command 'io-threads 4'
            name ''
        end
        entry do
            command 'io-threads-do-reads no'
            name ''
        end
    end

    category do
        id 'KERNEL OOM CONTROL'

        entry do
            command 'oom-score-adj no'
            name ''
        end
        entry do
            command 'oom-score-adj-values 0 200 800'
            name ''
        end
    end

    category do
        id 'APPEND ONLY MODE'

        entry do
            command 'appendonly no'
            name ''
        end
        entry do
            command 'appendfilename "appendonly.aof"'
            name ''
        end
        entry do
            command 'appendfsync always|everysec|no'
            name ''
        end
        entry do
            command 'no-appendfsync-on-rewrite no'
            name ''
        end
        entry do
            command 'auto-aof-rewrite-percentage 100'
            name ''
        end
        entry do
            command 'auto-aof-rewrite-min-size 64mb'
            name ''
        end
        entry do
            command 'aof-load-truncated yes'
            name ''
        end
        entry do
            command 'aof-use-rdb-samples yes'
            name ''
        end
    end

    category do
        id 'LUA SCRIPTING'

        entry do
            command 'lua-time-limit 5000'
            name ''
        end
    end

    category do
        id 'REDIS CLUSTER'

        entry do
            command 'cluster-enabled yes'
            name ''
        end
        entry do
            command 'cluster-config-file nodes-6379.conf'
            name ''
        end
        entry do
            command 'cluster-node-timeout 15000'
            name ''
        end
        entry do
            command 'cluster-replica-validity-factor 10'
            name ''
        end
        entry do
            command 'cluster-migration-barrier 1'
            name ''
        end
        entry do
            command 'cluster-require-full-coverage yes'
            name ''
        end
        entry do
            command 'cluster-replica-no-failover no'
            name ''
        end
        entry do
            command 'cluster-allow-reads-when-down no'
            name ''
        end
    end

    category do
        id 'CLUSTER DOCKER/NAT Support'

        entry do
            command 'cluster-announce-ip 10.1.1.5'
            name ''
        end
        entry do
            command 'cluster-announce-port 6379'
            name ''
        end
        entry do
            command 'cluster-announce-bus-port 6380'
            name ''
        end
    end

    category do
        id 'SLOW LOG'

        entry do
            command 'slowlog-log-slower-than 10000'
            name ''
        end
        entry do
            command 'slowlog-max-len 128'
            name ''
        end
    end

    category do
        id 'LATENCY MONITOR'

        entry do
            command 'latency-monitor-threshold 0'
            name ''
        end
        entry do
            command 'slowlog-max-len 128'
            name ''
        end
    end

    category do
        id 'EVENT NOTIFICATION'

        entry do
            command 'notify-keyspace-events ""'
            name ''
        end
    end

    category do
        id 'GOPHER SERVER'

        entry do
            command 'gopher-enabled no'
            name ''
        end
    end

    category do
        id 'ADVANCED CONFIG'

        entry do
            command 'hash-max-ziplist-entries 512'
            name ''
        end
        entry do
            command 'hash-max-ziplist-value 64'
            name ''
        end
        entry do
            command 'list-max-ziplist-size -2'
            name ''
        end
        entry do
            command 'list-compress-depth 0'
            name ''
        end
        entry do
            command 'set-max-intset-entries 512'
            name ''
        end
        entry do
            command 'zset-max-ziplist-entries 128'
            name ''
        end
        entry do
            command 'zset-max-ziplist-value 64'
            name ''
        end
        entry do
            command 'hll-sparse-max-bytes 3000'
            name ''
        end
        entry do
            command 'stream-node-max-bytes 4096'
            name ''
        end
        entry do
            command 'stream-node-max-entries 100'
            name ''
        end
        entry do
            command 'activerehashing yes'
            name ''
        end
        entry do
            command 'client-output-buffer-limit normal 0 0 0'
            name ''
        end
        entry do
            command 'client-output-buffer-limit replica 256mb 64mb 60'
            name ''
        end
        entry do
            command 'client-output-buffer-limit pubsub 32mb 8mb 60'
            name ''
        end
        entry do
            command 'client-query-buffer-limit 1gb'
            name ''
        end
        entry do
            command 'proto-max-bulk-len 512mb'
            name ''
        end
        entry do
            command 'hz 100'
            name ''
        end
        entry do
            command 'dynamic-hz yes'
            name ''
        end
        entry do
            command 'aof-rewrite-incremental-fsync yes'
            name ''
        end
        entry do
            command 'rdb-save-incremental-fsync yes'
            name ''
        end
        entry do
            command 'lfu-log-factor 10'
            name ''
        end
        entry do
            command 'lfu-decay-time 1'
            name ''
        end
    end

    category do
        id 'ACTIVE DEFRAGMENTATION'

        entry do
            command 'activedefrag do'
            name ''
        end
        entry do
            command 'active-defrag-ignore-bytes 100mb'
            name ''
        end
        entry do
            command 'active-defrag-threshold-lower 10'
            name ''
        end
        entry do
            command 'active-defrag-threshold-upper 100'
            name ''
        end
        entry do
            command 'active-defrag-cycle-min 1'
            name ''
        end
        entry do
            command 'active-defrag-max-scan-fields 1000'
            name ''
        end
        entry do
            command 'jemalloc-bg-thread yes'
            name ''
        end
        entry do
            command 'server_cpulist 0-7:2'
            name ''
        end
        entry do
            command 'bio_cpulist 1,3'
            name ''
        end
        entry do
            command 'aof_rewrite_cpulist 8-11'
            name ''
        end
        entry do
            command 'bgsave_cpulist 1,10-11'
            name ''
        end
        entry do
            command 'ignore-wranings ARM64-COW-BUG'
            name ''
        end
    end
end