cheatsheet do
    title 'Awk 中文指南 TODO'
    docset_file_name 'Awk'
    keyword 'awk'
    source_url 'https://l-lin.github.io/unix/awk'
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
        id 'Cli'

        entry do
            command 'print'
            name '输出'
            notes <<-'END'
                ```
                awk '{ print }' <file>
                awk '{ print $1 }' <file>
                ```
            END
        end
        entry do
            command '$0'
            name '完整一行'
            notes <<-'END'
                ```
                awk '{ print $0 }' <file>
                ```
            END 
        end
        entry do
            command '$<N>'
            name '按空格拆分后的第一个元素'
            notes <<-'END'
                ```
                awk '{ print $1 }' <file>
                ```
            END
        end
        entry do
            command 'NF'
            name '按空格拆分后的元素数'
            notes <<-'END'
                ```
                awk '{ print $1,$2 }' <file>
                ```
            END
        end
        entry do
            command '$NF'
            name '按空格拆分后最后一个元素'
            notes <<-'END'
                ```
                awk '{ print $1 "," $2 }' <file>
                ```
            END
        end
        entry do
            command 'NR'
            name '当前行数'
            notes <<-'END'
                ```
                awk '{ print NR }' <file>
                ```
            END
        end
        entry do
            command '-F',''
            name '修改元素的拆分规则，从默认空格改为逗号'
            notes <<-'END'
                ```
                awk -F',' '{print $2}' <file>
                ```
            END
        end
        entry do
            command 'START {}'
            name '开始执行的代码块，且只执行一次'
            notes <<-'END'
                ```
                awk 'START {}' <file>
                ```
            END
        end
        entry do
            command 'END {}'
            name '最后执行的代码块，且只执行一次'
            notes <<-'END'
                ```
                awk 'END { print NR }' <file>
                ```
            END
        end
    end
end