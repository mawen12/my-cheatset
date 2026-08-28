cheatsheet do
    title ''
    docset_file_name ''
    keyword ''

    category do
        id 'SQL Execute'

        entry do
            name 'insert'
            notes <<-'END'
                Client
                ↓ INSERT SQL
                MySQL Server
                │
                ├ ① Connection (TCP -> MySQL Connection -> Authentication -> Authorization)
                │
                ├ ② SQL Parser (SQL -> AST)
                │
                ├ ③ Precheck / Privilege (Table 存在检查 -> Column 存在检查 -> Column 类型检查 -> Column 约束检查)
                │
                ├ ④ Query Exection
                ↓
                InnoDB
                │
                ├ ① Lock (加锁，检查主键是否存在，不存在的话，如果设置了 AUTO_INCREMENT，则申请 AUTO_INCREMENT Lock)
                │
                ├ ② Buffer Pool (找到对应的 Page，不写入磁盘，而是修改内存中的 Page，此时变为 Dirty Page)
                │
                ├ ③ Undo Log (支持事务回滚和 MVCC，当事务 rollback 时，能否删除对应的数据)
                │
                ├ ④ Redo Log (持久化机制，写入后持久化到磁盘上，当崩溃后恢复时，读取 Redo Log 执行 Redo 恢复数据页)
                │
                ├ ⑤ Binlog (数据同步机制，用于向 Slave 同步数据)
                │
                ├ ⑥ Commit
                ↓
                Binlog
                ↓
                Client OK
            END
        end
        entry do
            name 'update'
            notes <<-'END'
                Client
                ↓ UPDATE SQL
                MySQL Server
                │
                ├ ① Connection (TCP -> MySQL Connection -> Authentication -> Authorization)
                │
                ├ ② SQL Parser (SQL -> AST)
                │
                ├ ③ Precheck / Privilege (Table 存在检查 -> Column 存在检查 -> Column 类型检查 -> Column 约束检查)
                │
                ├ ④ Query Exection
                ↓
                InnoDB
                │
                ├ ① Locate Record (根据 WHERE 定位记录，基于给定的条件来确定 Scan 策略，可以基于索引或普通扫描全表)
                │
                ├ ② Lock (加锁，排它锁，X Lock，因此此处会出现 Lock Wait 的情况)
                │
                ├ ③ Buffer Pool (读取旧版本，修改记录)
                │
                ├ ④ Undo Log (支持事务回滚和 MVCC，当事务 rollback 时，能否恢复修改的数据)
                │
                ├ ⑤ Redo Log (持久化机制，写入后持久化到磁盘上，当崩溃后恢复时，读取 Redo Log 执行 Redo 恢复数据页)
                │
                ├ ⑥ 二级索引维护 (如果修改的字段在二级字段上，则需要修改聚簇索引，并维护索引树)
                │
                ├ ⑦ Commit
                ↓
                Binlog (数据同步机制，用于向 Slave 同步数据)
                ↓
                Client OK
            END
        end
        entry do
            name 'select'
            notes <<-'END'
                Client
                ↓ SELECT SQL
                MySQL Server
                │
                ├ ① Connection (TCP -> MySQL Connection -> Authentication -> Authorization)
                │
                ├ ② SQL Parser (SQL -> AST)
                │
                ├ ③ Precheck / Privilege (Table 存在检查 -> Column 存在检查 -> Column 类型检查 -> Column 约束检查)
                │
                ├ ④ Optimizer (优化器，决定数据访问方式：const、eq_ref、ref、range、index、ALL)
                │
                ├ ⑤ Executor
                ↓
                InnoDB
                │
                ├ ① B+Tree (当使用主键查找数据时，便从B+Tree中查找：Root -> Internal Node -> Leaf Page -> Record)
                │
                ├ ② Buffer Pool (查找 Page，检查数据是否已在内存中，如果不在则从内存中读取)
                │
                ├ ① MVCC (一致性非锁定读，不一定读取数据库当前物理 Page 中唯一的最新版本，基于当前事务决定看到哪个版本，旧的信息会从 Undo Log 中读取)
                │
                ├ ① Read (检查所需要的是否在当前索引中，当部分数据存在，其他不存在时，则需要回表查询)
                ↓
                Result Set
                ↓
                Client
            END
        end
        entry do
            name 'delete'
            notes <<-'END'
                Client
                ↓ DELETE SQL
                MySQL Server
                │
                ├ ① Connection (TCP -> MySQL Connection -> Authentication -> Authorization)
                │
                ├ ② SQL Parser (SQL -> AST)
                │
                ├ ③ Precheck / Privilege (语法检查 -> Table 是否存在 -> Column 是否存在 -> Column 类型是否合理)
                │
                ├ ④ Executor
                ↓
                InnoDB
                │
                ├ ① Locate Record (根据 WHERE 定位记录，基于给定的条件来确定 Scan 策略，可以基于索引或普通扫描全表)
                │
                ├ ② Lock (加锁，排它锁，X Lock，因此此处会出现 Lock Wait 的情况)
                │
                ├ ③ Undo Log (支持事务回滚和 MVCC，当事务 rollback 时，能否恢复删除的数据)
                │
                ├ ③ 二级索引 (删除二级索引记录)
                │
                ├ ④ Redo Log (持久化机制，写入后持久化到磁盘上，当崩溃后恢复时，读取 Redo Log 执行 Redo 执行删除逻辑)
                │
                ├ ⑤ Commit
                ↓
                Binlog (数据同步机制，用于向 Slave 同步数据)
                ↓
                Client OK
            END
        end
    end

    category do
        id 'Index'

        entry do
            name ''
            
        end
    end

    category do
        id 'Performance Schema'

        entry do
            name 'setup_actors'
            notes '哪些用户/host/thread 类型需要采集'
        end
        entry do
            name 'setup_consumers'
            notes '哪些事件结果需要保存'
        end
        entry do
            name 'setup_instruments'
            notes '采集哪些 Instrument'
        end
        entry do
            name 'setup_objects'
            notes '对哪些数据库对象进行采集'
        end
        entry do
            name 'setup_threads'
            notes 'Thread 相关采集配置'
        end
        entry do
            name 'cond_instances'
            notes '条件变量实例'
        end
        entry do
            name 'file_instances'
            notes '文件实例'
        end
        entry do
            name 'mutex_instances'
            notes 'Mutex 实例'
        end
        entry do
            name 'rwlock_instances'
            notes 'RWLock 实例'
        end
        entry do
            name 'socket_instances'
            notes 'Socket 实例'
        end
        entry do
            name 'events_statements_current'
            notes '每个线程正在执行的 SQL'
        end
        entry do
            name 'events_statements_history'
            notes '每个线程最近执行过的 SQL'
        end
        entry do
            name 'events_statements_history_long'
            notes '整个 MySQL 实例范围内的 SQL 历史'
        end
        entry do
            name 'prepared_statements_instances'
            notes 'Prepared Statement 信息'
        end
        entry do
            name 'events_statements_summary_by_digest'
            notes 'SQL 性能排名'
        end
        entry do
            name 'events_wait_summary_global_by_event_name'
            notes '等待事件排名'
        end
        entry do
            name 'events_stages_summary_global_by_event_name'
            notes 'SQL阶段排名'
        end
        entry do
            name 'table_io_waits_summary_by_table'
            notes '表 IO'
        end
        entry do
            name 'table_io_waits_summary_by_index_usage'
            notes '索引使用情况'
        end
    end
end