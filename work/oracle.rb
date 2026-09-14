cheatsheet do
    title ''
    docset_file_name ''
    keyword ''

    category do
        id '序列'

        entry do
            name '查看序列定义'
            notes <<-'END'
                SELECT 
                    sequence_name as 序列名称,
                    min_value as 最小值,
                    max_value as 最大值,
                    increment_by as 步长,
                    cycle_flag as 是否循环,
                    order_flag as 是否按需生成,
                    cache_size as 缓存大小,
                    last_number as 下一个可用的序列值
                FROM user_sequences
                WHERE sequence_name = 'EPPS_QUERY_CORE_SERIAL_NO';
            END
        end
        entry do
            name '创建序列'
            notes <<-'END'
                CREATE SEQUENCE EPPS_QUERY_CORE_SERIAL_NO
                    MINVALUE 1
                    MAXVALUE 999999999999
                    START WITH 1
                    INCREMENT BY 1
                    CYCLE
                    CACHE 100;
            END
        end
        entry do
            name '修改序列的缓存'
            notes <<-'END'
                ALTER SEQUENCE EPPS_QUERY_CORE_SERIAL_NO CACHE 5000;
            END
        end
    end
end