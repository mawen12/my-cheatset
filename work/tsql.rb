cheatsheet do
    title ''
    docset_file_name ''
    keyword ''

    category do
        id '术语'

        entry do
            name '节点'
            notes <<-'END'
                Set或称为数据节点、分片。基于MySQL数据库主从协议联结成若干组。
                Set 是分布式实例中最小数据单元。一个分布式实例是由N个Set组成，
                每个Set 中存有不同范围的数据，所有set 加到一起是一份全量的数据
            END
        end
        entry do
            name 'SQL 引擎'
            notes <<-'END'
            也称为Proxy或网关。在TDSQL中位于接入层的位置，承接应用数据库请求，
            负责路由转发、SQL分析、读写分离等；SQL引擎无主备之分，本身无状态，
            一般采用多节点部署分担请求压力。
            END
        end
        entry do
            name 'OLTP'
            notes 'Online transaction processing 联机事务处理'
        end
        entry do
            name 'HTAP'
            notes 'Hybrid transaction/analytical processing混合事务、分析处理'
        end
        entry do
            name 'OLAP'
            notes 'Online analytical processing 联机分析处理'
        end
        entry do
            name 'TDSQL 集群'
            notes '一组物理机组成的分布式数据库集群。一个集群有独立的管控组件，以及proxy和数据节点'
        end
        entry do
            name 'Set'
            notes '一主多从组成的一份数据，一个set可以存放一个分片数据，也可以存储多个分片数据'
        end
        entry do
            name 'TDSQL 分布式实例'
            notes '即Group_Shard，数据经过分片后，分布在n个set 上面，每个set一主多从。也可以简称为shard。一个分布式实例有多个主分片'
        end
        entry do
            name 'TDSQL 集中式实例'
            notes '有数据都在一个set上。一个集中式实例只有一个主副本，以及多个从副本'
        end
        entry do
            name '单片表'
            notes '即单表，用于存储一些无需分片的表，通常该表的数据全量存在第一个节点中'
        end
        entry do
            name '广播表'
            notes '又名复制表，该表的所有操作都将广播到所有节点中，每个节点都有该表的全量数据，常用于业务系统的配置表等'
        end
        entry do
            name '分片'
            notes '是一种水平拆分数据表的方式。分片表在物理上，把一个表的数据水平拆分成多个子表，存放在不同的物理节点服务器上。分片表在逻辑上是一张表'
        end
        entry do
            name '分片键'
            notes '决定数据水平拆分维度的表字段'
        end
        entry do
            name '分区'
            notes '分区是将特定条件的数据进行分区处理，逻辑上数据还在同一表内，但是表的物理存储文件分开，是提高单表容量的一种方法'
        end
        entry do
            name '副本'
            notes '由一个MySQL进程承载（即单个节点上的MySQL实例）的分片'
        end
    end

    category do
        id '设计规范'

        entry do
            name '分片表'
            notes '根据创建表时指定的分片键和拆分算法自动将数据落入对应的节点，以此来减少单表的数据压力和单库容量的压力，并使数据获得水平扩展的能力'
        end
        entry do
            name '分区'
            notes '在分片基础上，对数据进一步分成许多小子集。以增强单表数据的承载量并保证单表查询性能。分区可以进一步提高单表的可操作性，可以根据分区更容易的维护数据。例如日期分区、对于历史数据清理有很大帮助'
        end
        entry do
            name '单片表'
            notes '存储一些小型数据的表'
        end
        entry do
            name '广播表'
            notes '常用语业务系统的配置表'
        end
        entry do
            name '热温冷库'
            notes '对于在线数据库，访问频率高，推荐设计热表和温表。对于不太访问，超过一定年限的历史数据，将历史数据迁移至另一数据库实例或者物理集群中，降低在线分布式数据库的压力，降低在线库集群硬件需求'
        end
        entry do
            name '读写分离'
            notes '根据实际需求和运行情况决定，对数据一致性要求不高的查询、历史数据的查询、统计、复杂SQL、长耗时的SQL操作可考虑读写分离'
        end
    end

    category do
        id '注意点'

        entry do
            name '禁止项'
            notes <<-'END'
                - 不在TDSQL数据库端做运算,比如: md5(), sha()等
                - 不在数据库中存储图片
                - 不适用未经验证的、不明确的新功能
                - OLTP 应用避免大事务,OLTP 和 OLAP 应用分离,不要再 OLTP 数据库上进行全文检索、统计查询等操作
                - 数据库应用账号只允许访问应用数据库，常规情况应用账号只需要 select、insert、update、delete、create、drop、alter、index、show databases 权限

                集中表设计
                - 活跃表中禁止使用 blob、text、varchar(>255)等大字段
                - 不使用外键做数据一致性保证，从业务上控制
                - 禁止使用 MySQL 已有的关键字
            END
        end
        entry do
            name '强制项'
            notes <<-'END'
                - 应用需要有失败重连，可以使用连接池工具如 druid 之类
                - 对于有连接池的前端程序，必须根据业务需要配置初始化、最小、最大连接数、超时时间以及连接回收机制
                - 使用单独线程定期检查连接是否可用
                - 定期发送 test query 保证连接可用
                - 数据库连接密码必须加密存放
                - 对于财务货币数据，禁止使用float和double浮点类型，这两种浮点类型无法确保精度，很容易产生误差。建议使用 DECIMAL 类型或者将对应金额转换成分或厘，使用整数类型（如int或bigint）去存储

                分布式表设计

                - 对于分布式式实例，应用单表数据量超过10万就要分片，否则只会存放在第一个set，造成第一个set数据空间和性能存在瓶颈
                - 广播表只适用于表数据量小，且需要经常和其他分片表关联；大表和频繁变更的表不允许使用广播表
                - 单表主要用于一些小型数据，且和其他无关联的表，一般情况禁止使用

                分片键设计

                - 分片键的选取应考虑分片键不会被更新，大部分的语句都会包含该字段，该字段会使各个分表中的数据分配比较平均
            END
        end
        entry do
            name '建议项'
            notes <<-'END'
                - 新项目上线或旧项目重构前，一定要做数据量、访问量、数据增量、访问增长的评估，预先评估哪些表会是性能瓶颈，如果访问量大，需要合理的前端架构，缓存应用数据减少数据库压力
                - 一个数据表中，如果有部分字段需要频繁更新，二其他字段不需要，那么建议把它们拆分到不同表中，以提升更新的频率
                - 程序端日志必须记录连接数据库的标准 MySQL 错误号以及所连接的数据库信息（比如 IP 和 PORT，数据库应用名），用于后续排查错误
                - 使用TDSQL提供的JDBC驱动
                - 采用只读账号的方式实现读写分离

                数据库设计

                - TDSQL 服务器默认使用 InnoDB，字符集默认 uft8mb4，排序默认 uft8mb4_bin，所有 sql 语句不需要显示指定，使用 tdsql 默认值即可。
                - 同一个数据库中所有表、字段必须使用相同的字符集，应保证应用程序连接、数据库、表、字段字符集一致
                - 库的名称必须控制在 32 个字符以内
                - 必须统一用英文小写字母命名数据库名，不得使用中文命名，不得使用符号（下划线除外）
                - 不同应用应放到不同 db 中
                - 库的名称格式：业务系统名称_子系统名，同一模块使用的表名尽量使用统一前缀
                - 单个非分布式实例的数据库容量不大于2T
                
                集中式表设计

                - 表名 <= 32 个字符，只能使用字母小写、数字和_
                - 表必须有主键且主键禁止被更新
                - 必须有表级别 comment
                - 多个表中同一类型与含义字段类型与属性必须相同
                - 对重要数据 userid、orderid 等业务关键特性数据，除了从应用层面控制数据唯一性，从数据库层面增加唯一性检查，最终保证数据完整性
                - 备份表名称格式：原表名_年月日，例如 test_20210510
                - 表包含创建时间字段 create_time 和最后更新时间字段 update_time
                - 单表记录数在 1000w~2000w行，最好不超过 2000w行，如果主键是多个字符串类型字段组成的复合主键或者存在复杂查询的话，单表的记录数最好不超过2000w

                分布式表设计

                - 业务模型表：分片表或广播表
                - 业务流水表：分片表，以及二级分区
                - 参数表：单表，建议存放单独的集中式库
                - 日志表：分片表，以及二级分区

                分片键设计
            END
        end

        entry do
            name '分片键设计'
            notes <<-'END'
                数据分布：拆分后的数据是否能够均匀分布在不同数据库set上
                查询关联度：是否是DML语句中常用的或者必须的条件
                字段关联度：是否是表连接的主要关联字段
                字段属性：不适用 TIMESTAMP，字段长度小于255，不带有中文、大小写敏感等
                唯一约束性：分片键破坏了原来的主键和唯一索引的唯一性，因此业务系统是否能支持
                拆分方式：Hash、Range、List
            END
        end
    end

    category do
        id 'druid 连接配置'

        header '参数'
        header '推荐值'
        header '默认值'
        header '备注'

        entry do
            name 'druid.initialSize'
            td_notes '50'
            td_notes '0'
            td_notes '初始建立的连接数'
        end
        entry do
            name 'druid.minIdle'
            td_notes '50'
            td_notes '0'
            td_notes '最小连接池数量'
        end
        entry do
            name 'druid.maxActive'
            td_notes '2000'
            td_notes '8'
            td_notes '最大连接池数量'
        end
        entry do
            name 'druid.maxWait'
            td_notes '5000'
            td_notes '-1'
            td_notes '获取连接最大等待时间，单位毫秒'
        ENDentry do
            name 'druid.defaultAutoCommit'
            td_notes 'false'
            td_notes 'true'
            td_notes '初始的连接提交是否为自动提交'
        end
        entry do
            name 'druid.testWhileIdle'
            td_notes 'true'
            td_notes 'false'
            td_notes '是否回收空闲连接标志，不接受批处理，并且不验证连接性，空闲时间大于 timeBetweenEvictionRunsMillis 值时执行 validation'
        end
        entry do
            name 'druid.testOnBorrow'
            td_notes 'false'
            td_notes 'true'
            td_notes '申请连接时，执行 validationQuery 检查连接有效性，会影响性能'
        end
        entry do
            name 'druid.testOnReturn'
            td_notes 'false'
            td_notes 'false'
            td_notes '归还连接时，执行 validationQuery 检查连接有效性，会影响性能'
        end
        entry do
            name 'druid.validationQuery'
            td_notes 'SELECT 1 FROM dual'
            td_notes 'null'
            td_notes '检查连接有效性的 sql'
        end
        entry do
            name 'druid.timeBetweenEvictionRunsMillis'
            td_notes '60000'
            td_notes '60000'
            td_notes '有两种含义： Destroy线程检测所连接的时间值、空闲连接检查的判断依据'
        end
        entry do
            name 'druid.poolPrepareStatements'
            td_notes 'true'
            td_notes 'false'
            td_notes '是否缓存 preparedStatement，也就是PSCache，设置成大于0的数，表示开启PSCache，设置值越大，性能开销越大'
        end
        entry do
            name 'druid.maxOpenPreparedStatements'
            td_notes '200'
            td_notes '-1'
            td_notes '专用 PSCache，必须配置大小大于0，大于0时，自动触发 poolPrepareStatements=true'
        end
        entry do
            name 'druid.maxOpenPreparedStatements'
            td_notes '200'
            td_notes '-1'
            td_notes '专用 PSCache，必须配置大小大于0，大于0时，自动触发 poolPrepareStatements=true'
        end
        entry do
            name 'druid.maxOpenPreparedStatementPerConnectionSize'
            td_notes '200'
            td_notes '100'
            td_notes '指定每个连接对应的预编译语句（PreparedStatement）池的最大容量'
        end
        entry do
            name 'druid.removeAbandomdTimeoutMillis'
            td_notes '1800000'
            td_notes '300000'
            td_notes '连接泄露的判定超时时间（毫秒），超过此时长未归还的连接会被标记为泄露，并强制回收'
        end
        entry do
            name 'druid.keepAlive'
            td_notes 'true'
            td_notes 'false'
            td_notes '开启空闲连接保活机制'
        end
        entry do
            name 'druid.keepAliveBetweenTimeMillis'
            td_notes '900000'
            td_notes '60000'
            td_notes '空闲连接保活的间隔时间'
        end
    end

    category do
        id '数据库连接串'

        category do
            name 'jdbc:tdsql-mysql://${mysql_host}:${mysql_port}/{mysql_db}?connectTimeout=1000&socketTimeout=60000&characterEncoding=UTF-8&serverTimezone=Asia/Shanghai&useSSL=false&useLocalSessionStates=true&useCursorFetch=false&useServerPrepStmts=true&useConfigs=maxPerformance&rewriteBatchedStatements=true&allowMultiQueries=true&netTimeoutForStreamingResults=0'
        end
        category do
            name 'connectTimeout'
            notes '连接的超时时间，单位毫秒'
        end
        category do
            name 'socketTimeout'
            notes '操作的超时时间，单位毫秒'
        end
        category do
            name 'characterEncoding'
            notes '字符编码格式'
        end
        category do
            name 'serverTimezone'
            notes '时区设置'
        end
        category do
            name 'useSSL'
            notes '与数据库之间连接是否使用加密连接，内部网络建议设置false，一般有服务器身份验证的情况喜爱才可以开启'
        end
        category do
            name 'useLocalSessionStates'
            notes '配置启动程序是否可以使用autocommit，read_only 和 transaction isolation 的本地属性值，避免JDBC driver每次都去检查 server 端是否是 ReadOnly'
        end
        category do
            name 'useCursorFetch'
            notes '使用系统游标'
        end
        category do
            name 'useServerPrepStmts'
            notes '是否开启数据库预编译'
        end
        category do
            name 'prepStmtCacheSqlLimit'
            notes '预处理语句长度限制'
        end
        category do
            name 'rewriteBatchedStatement'
            notes '是否开启构造多值批量插入功能，用于保证 jdbc driver 可以批量执行 sql'
        end
        category do
            name 'allowMultiQueries'
            notes '该配置允许使用分号；来分割一条语句中的多个查询，实现多语句执行，分布式实例中必须开启网关参数gateway.mode.multi_query.open=1'
        end
        category do
            name 'cachePrepStmts'
            notes '是否开启缓存预处理语句的功能，如果开启，jdbc会缓存预处理 statement 信息，而不需要每次都重新发起编译，tdsql不建议开启该参数'
        end
        category do
            name 'useConfigs'
            notes '加载以逗号分割的配置属性列表，以指定特定场景的选项组合'
        end
        category do
            name 'netTimeoutForStreamingResults'
            notes '使用流式传输结果集功能时，驱动程序自动将 Session 参数 net_write_timeout 设置为什么值，单位为秒，数值0表示启动程序不会尝试调整该数值'
        end
    end

    category do
        id '序列'

        entry do
            name '查看序列'
            notes <<-'END'
                -- 查看全部序列
                /*proxy*/ show tdsql_sequences;

                -- 查看单个序列
                /*proxy*/ show create tdsql_sequence 库名.序列名;

                -- 系统表查询序列详情
                SELECT * FROM mysql.tdsql_sequences WHERE db = 库名;

                -- 获取下一个序列号
                SELECT tdsql_nextval(库名.序列名);

                -- 获取当前已生成的序列号
                SELECT tdsql_lastval(库名.序列名);
            END
        end
    end
end