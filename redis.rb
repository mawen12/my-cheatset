cheatsheet do
    title 'Redis 中文指南(TODO)'
    docset_file_name 'Redis'
    keyword 'redis'
    source_url ''
    introduction ''
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
        id 'Strings'

        entry do
            command 'APPEND'
            name '将值追加到键对应的值之后，时间复杂度：O(1)'
            notes <<-'END'
                APPEND key value

                ```bash
                $ SET message "Hello"
                $ APPEND message " World"
                ```
            END
        end
        entry do
            command 'BITCOUNT'
            name '统计字符串中值=1的Bit的数量总和，时间复杂度：O(N)'
            notes <<-'END'
                BITCOUNT key [start end [BYTE | BIT]]

                ```bash
                $ SET mykey "foobar"
                $ BITCOUNT myKey
                $ BITCOUNT myKey 1 1 BYTE
                $ BITCOUNT myKey 5 30 BIT
                ```
            END
        end
        entry do
            command 'BITOP'
            name '对多个键之间执行 bitwise 操作，并将结果保存到目标键中，时间复杂度：O(N)'
            notes <<-'END'
                BITOP <AND | OR | XOR | NOT | DIFF | DIFF1 | ANDOR | ONE> destkey key [key ...]

                ```bash
                $ BITFIELD key1 SET i8 #0 255
                $ BITFIELD key2 SET i8 #0 85
                $ BITOP AND dest key1 key2
                $ BITFIELD dest GET i8 #0  
                ```
            END
        end
        entry do
            command 'BITPOS'
            name '返回字符串中第一个被置为1或0的位置，时间复杂度为：O(N)'
            notes <<-'END'
                BITPOS key bit [start [end [BYTE | BIT]]]

                ```bash
                $ SET mykey "\xff\xf0\x00"
                $ BITPOS mykey 0
                ```
            END
        end
        entry do
            command 'DECR'
            name '将键对应的值-1，时间复杂度：O(1)'
            notes <<-'END'
                DECR key

                ```bash
                $ SET mykey "10"
                $ DECR mykey
                ```
            END
        end
        entry do
            command 'DECRBY'
            name '将键对应的值减去指定的量，时间复杂度：O(1)'
            notes <<-'END'
                DECRBY key decrement

                ```bash
                $ SET mykey "10"
                $ DECRBY mykey 3
                ```
            END
        end
        entry do
            command 'GET'
            name '读取键对应的值，时间复杂度：O(1)'
            notes <<-'END'
                GET key

                ```bash
                $ SET mykey "Hello"
                $ GET mykey
                ```
            END
        end
        entry do
            command 'GETBIT'
            name '返回键对应的字符串中指定偏移量的值，时间复杂度：O(1)'
            notes <<-'END'
                GETBIT key offset

                ```bash
                $ SETBIT mykey 7 1
                $ GETBIT mykey 0
                ```
            END
        end
        entry do
            command 'GETRANGE'
            name '返回键对应字符串中的子串，取值为[start, end]，时间复杂度：O(N)'
            notes <<-'END'
                GETRANGE key start end

                ```bash
                $ SET mykey "This is a string"
                $ GETRANGE mykey 0 3
                ```
            END
        end
        entry do
            command 'GETSET'
            name '设置键的值，并返回旧值，时间复杂度：O(1)'
            notes <<-'END'
                GETSET key value

                ```bash
                $ SET mykey "Hello"
                $ GETSET mykey "World"
                ```
            END
        end
        entry do
            command 'INCR'
            name '将键对应的值+1，时间复杂度：O(1)'
            notes <<-'END'
                INCR key

                ```bash
                $ SET mykey "10"
                $ INCR mykey
                ```
            END
        end
        entry do
            command 'INCRBY'
            name '将键对应的值加上指定的量，时间复杂度：O(1)'
            notes <<-'END'
                INCRBY key increment

                ```bash
                $ SET mykey "10"
                $ INCRBY mykey 3
                ```
            END
        end
        entry do
            command 'INCRBYFLOAT'
            name '将键对应值加上指定的浮点数，时间复杂度：O(1)'
            notes <<-'END'
                INCRBYFLOAT key increment
            
                ```bash
                $ SET mykey 10.50
                $ INCRBYFLOAT mykey 0.1
                ```
            END
        end
        entry do
            command 'MGET'
            name '返回指定键对应的所有值，时间复杂度：O(N)'
            notes <<-'END'
                MGET key [key ...]

                ```bash
                $ SET key1 "Hello" 
                $ SET key2 "World"
                $ MGET key1 key2 nonexisting
                ```
            END
        end
        entry do
            command 'MSET'
            name '设置指定的键和值，时间复杂度：O(N)'
            notes <<-'END'
                MSET key value [key value ...]

                ```bash
                $ MSET key1 "Hello" key2 "World"
                $ GET key1
                $ GET key2
                ```
            END
        end
        entry do
            command 'MSETNX'
            name '设置指定的键和值，跳过已经存在的键，时间复杂度：O(N)'
            notes <<-'END'
                MSETNX key value [key value ...]

                ```bash
                $ MSETNX key1 "Hello" key2 "there"
                $ MSETNX key2 "new" key3 "world"
                $ MGET key1 key2 key3
                ```
            END
        end
        entry do
            command 'PSETEX'
            name ''
            notes <<-'END'
                ```bash
                
                ```
            END
        end
        entry do
            command 'SET'
            name ''
            notes <<-'END'
                ```bash
                
                ```
            END
        end
        entry do
            command 'SETBIT'
            name ''
            notes <<-'END'
                ```bash
                
                ```
            END
        end
        entry do
            command 'SETEX'
            name ''
            notes <<-'END'
                ```bash
                
                ```
            END
        end
        entry do
            command 'SETNX'
            name ''
            notes <<-'END'
                ```bash
                
                ```
            END
        end
        entry do
            command 'SETRANGE'
            name ''
            notes <<-'END'
                ```bash
                
                ```
            END
        end
        entry do
            command 'SETLEN'
            name ''
            notes <<-'END'
                ```bash
                
                ```
            END
        end
    end

    category do
        id 'Hashes'

        entry do
            command ''
            name ''
            notes <<-'END'

            END
        end
    end

    category do
        id 'Sets'

        entry do
            command ''
            name ''
            notes <<-'END'

            END
        end
    end

    category do
        id 'Lists'

        entry do
            command ''
            name ''
            notes <<-'END'

            END
        end
    end

    category do
        id 'Sorted Sets'

        entry do
            command ''
            name ''
            notes <<-'END'

            END
        end
    end

    category do
        id 'Client/Server'

        entry do
            command ''
            name ''
            notes <<-'END'

            END
        end
    end

    category do
        id 'General'

        entry do
            command 'TTL'
            name '返回键剩余的存活时间，-2 代表键不存在，-1 代表键未设置过期时间'
            notes <<-'END'

            END
        end
        entry do
            command 'TIME'
            name '以两个元素列表的格式返回系统当前时间，第一个是Unix时间戳，第二个是当前秒内已过去的微秒数'
            notes <<-'END'

            END
        end
        entry do
            command 'TYPE'
            name '返回键对应值的类型，返回范围有：string、list、set、zset、hash、stream、vectorset'
            notes <<-'END'
                
            END
        end
    end
    
    category do
        id 'Script'

        entry do
            command ''
            name ''
            notes <<-'END'

            END
        end
    end

    category do
        id '限流示例'

        entry do
            name '固定窗口'
            notes <<-'END'
                ```
                -- 固定窗口限流器
                -- KEYS[1]: 限流器唯一标识
                -- ARGV[1]: 请求令牌数
                -- ARGV[2]: 窗口间隔

                local count = redis.call('INCR', KEYS[1])
                if count == 1 then
                    redis.call('EXPIRE', KEYS[1], ARGV[2])
                end
                local ttl = redis.call('TTL', KEYS[1])
                if ttl < 0 then
                    redis.call('EXPIRE', KEYS[1], ARGV[2])
                    ttl = redis.call('TTL', KEYS[1])
                end
                if count > tonumber(ARGV[1]) then
                    return {0, count, ttl}
                end
                return {1, count, ttl}
                ```
            END
        end
        entry do
            name '滑动窗口'
            notes <<-'END'
                
            END
        end
        entry do
            name '令牌桶'
            notes <<-'END'
                -- 令牌桶限流器
                -- KEYS[1]: 限流器唯一标识
                -- ARGV[1]: 请求令牌数 (通常为1)
                -- ARGV[2]: 令牌生成速率 (每秒)
                -- ARGV[3]: 桶容量

                local key = KEYS[1]
                local requested = tonumber(ARGV[1])
                local rate = tonumber(ARGV[2])
                local capacity = tonumber(ARGV[3])

                local now = redis.call('TIME')
                local nowInSeconds = tonumber(now[1])

                local bucket = redis.call('HMGET', key, 'tokens', 'last_time')
                local tokens = tonumber(bucket[1])
                local last_time = tonumber(bucket[2])

                if not tokens or not last_time then
                    tokens = capacity
                    last_time = nowInSeconds
                else
                    local elapsed = nowInSeconds - last_time
                    local add_tokens = elapsed * rate
                    tokens = math.min(capacity, tokens * add_tokens)    
                    last_time = nowInSeconds
                end
                
                local allowed = false
                if tokens > allowed then
                    tokens = tokens - allowed
                    allowed = true
                end

                redis.call('HMSET', key, 'tokens', tokens, 'last_time', last_time)
                redis.call('EXPIRE', key, math.ceil(capacity / rate) + 60)
                return allow and 1 or 0
            END
        end
    end
end