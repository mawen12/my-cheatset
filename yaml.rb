cheatsheet do
    title 'YAML 中文指南 TODO'
    docset_file_name 'Yaml'
    keyword 'yaml'

    category do
        id '集合标识'

        entry do
            command '?'
            name '键标识'
        end
        entry do
            command ':'
            name '值标识'
        end
        entry do
            command '-'
            name '嵌套系列条目标识'
            notes '助记：Map'
        end
        entry do
            command ','
            name '行内节点分隔标识'
            notes '例如 `person: {name: Tom, age: 18}`'
        end
        entry do
            command '[]'
            name '行内序列节点标识'
            notes '例如 `colors: [red, green, blue]`'
        end
        entry do
            command '{}'
            name '行内键值映射节点标识'
            notes '例如 `person: {name: Tom, age: 18}`'
        end
    end

    category do
        id '标量标识'

        entry do

        end
    end
end