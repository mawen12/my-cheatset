cheatsheet do
    title 'Vim 中文指南 TODO'
    docset_file_name 'Vim'
    keyword 'vim'

    category do
        id '帮助'

        entry do
            command ':help command'
            name '查找帮助'
            notes '例如 `:help v` 查找关于命令 `v` 的帮助文档，养成查找帮助文档的好习惯'
        end
    end

    category do
        id '退出 Vim'

        entry do
            command ':q[uit]'
            name '退出 Vim'
            notes '操作在当文件有更改时会失败。'
        end
        entry do
            command ':q[uit]!'
            name '忽略更改并退出 Vim'
        end
        entry do
            command ':qa'
            name '退出所有打开的文件'
            notes '`a` 意为 all'
        end
        entry do
            command ':wq'
            name '保存并退出 Vim'
            notes '`w` 意为 write'
        end
        entry do
            command ':wqa'
            name '保存并退出所有文件'
        end
        entry do
            command ':wq!'
            name '强制保存并退出 Vim'
        end
        entry do
            command ':wq {file}'
            name '保存当前文件到 `{file}`，文件如果在编辑的话会失败'
        end
        entry do
            command ':wq! {file}'
            name '强制保存当前文件到 `{file}`'
        end
        entry do
            command ':[range]wq[!]'
            name '只保存指定行范围的内容并且退出'
            notes '例如 `1,2wq!` 表示只表存第一和第二行的内容，其他的删除，然后退出'
        end
        entry do
            command 'ZZ'
            name '保存并且强制退出 Vim'
            notes '等同于 `wq!`'
        end
        entry do
            command 'ZQ'
            name '强制退出不保存'
            notes '等同于 `q!`'
        end
    end

    category do
        id '编辑文件'

        entry do
            command ':e[dit]'
            name '编辑（重新载入）当前文件'
            notes '当文件被另一个用户重新保存时，`:e` 命令会重新从文件系统加载文件'
        end
        entry do
            command ':e[dit]!'
            name '强制编辑（重新载入）当前文件'
            notes '忽略当前更改，强制从文件系统重新加载文件，当需要忽略当前更改时有用'
        end
        entry do
            command ':e[dit] {file}'
            name '编辑 `{file}`'
        end
        entry do
            command ':e[dit]! {file}'
            name '编辑 `{file}`'
            notes '忽略当前文件的更改，强制编辑 `{file}`'
        end
        entry do
            command ':gf'
            name '编辑光标下文件名所代表的文件'
            notes '助记：goto file'
        end
    end

    category do
        id '插入文本'

        entry do
            command 'a'
            name '在光标后开始插入'
        end
        entry do
            command 'A'
            name '在光标所在行尾开始插入'
        end
        entry do
            command 'i'
            name '在光标前开始插入'
        end
        entry do
            command 'I'
            name '在光标所在行头开始插入'
        end
        entry do
            command 'o'
            name '在当前光标下新起一行开始编辑'
        end
        entry do
            command 'O'
            name '在当前光标上新起一行开始编辑'
        end
    end

    category do
        id '插入文件'

        entry do
            command ':r[ead] [name]'
            name '读取并插入 `[name]` 的文件内容到当前光标下'
            notes '例如 `:r sys.log` 将 sys.log 的内容插入到当前光标下'
        end
        entry do
            command ':r[ead] !{cmd}'
            name '执行命令并且将命令的标准输出插入到当前光标下'
            notes '例如 `:r !date` 把当前日期插入到当前光标下一行'
        end
    end

    category do
        id '删除文本'

        entry do
            command 'x'
            name '删除光标之后的字符'
        end
        entry do
            command '<DEL>'
            command 'X'
            name '删除光标之前的字符'
        end
        entry do
            command 'd{motion}'
            name '删除 `{motion} 所代表范围内的文本`'
            notes '例如 `dw` 删除光标所在单词中光标以及后面的单词；`daw` 删除光标所在的单词'
        end
        entry do
            command '[count]dd'
            name '删除光标及以下一共 `[count]` 行，如不指定 `[count]` 则删除光标所在行'
        end
        entry do
            command 'D'
            name '删除光标所在行后面的字符'
            notes '相当于 `d$`'
        end
        entry do
            command '{Visual}x'
            name '在可视化模式下删除选中的字符'
            notes '查看可视化模式下的文本选择类目'
        end
        entry do
            command '{Visual}x'
            command '{Visual}d'
            name '在可视化模式下删除选中的字符'
            notes '查看可视化模式下的文本选择类目'
        end
        entry do
            command '{Visual}CTRL-H'
            command '{Visual}<BS>'
            name '在选择模式下删除选中的文本, `gh` 进入选择模式'
        end
        entry do
            command '{Visual}X'
            command '{Visual}D'
            name '在可视化模式下删除选中的行'
        end
        entry do
            command ':[range]d[elete]'
            name '删除 `[range]` 范围内的行'
            notes '默认情况下删除当前光标所在行，例如 `:2d` 删除第二行，`:2,3d` 删除第二到第三行'
        end
        entry do
            command ':[range]d[elete] {count}'
            name '从指定范围开始删除 `{count}` 行'
            notes '例如 `:2d 10` 从第二行开始删除十行'
        end
    end

    category do
        id '变更/替换文本'

        entry do
            command 'r{char}'
            name '用 `{char}` 替换光标下的字符'
            notes '`r` 意为 replace'
        end
        entry do
            command 'R'
            name '进入插入模式，但是对于输入是替换而不是插入'
            notes '例如按 `R` 后输入1234，如果插入的位置原本有字符，那么原来的字符会被替换成1234，行的长度不会增加'
        end
        entry do
            command '~'
            name '切换光标所在字符的大小写，并且光标向右移'
            notes '可以在光标出连续将后面的字符的大小写更改'
        end
        entry do
            command 'g~{motion}'
            name '替换 `{motion}` 范围内的文本大小写'
        end
        entry do
            command '{Visual}~'
            name '切换选中文本的大小写'
        end
        entry do
            command '{Visual}U'
            name '切换选中文本到大写'
        end
        entry do
            command 'SHIFT+I+<comment char>+ESC+ESC'
            name '块插入'
            notes '按 `CTRL+V` 进入块选择，选择完之后按照上述操作输入想插入的字符'
        end
        entry do
            command 'X'
            name '块删除'
            notes '按 `CTRL+V` 进入块选择，然后 `x` 删除选中的字符，这就是列模式中的删除'
        end
    end
end