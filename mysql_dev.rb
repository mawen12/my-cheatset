cheatsheet do
    title 'MySQL Dev'
    docset_file_name 'MySQL_dev'
    keyword 'mysql dev'
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
        id 'information schema'

        entry do
            name '开启 performance_schema'
            notes <<-'END'
                [mysqld]
                performance_schema=ON
            END
        end
    end

    category do
        id 'performance schema'

        entry do
            name '读取'
            notes <<-'END'
                
            END
        end
    end
end