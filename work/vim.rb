cheatsheet do
    title ''
    docset_file_name ''
    keyword ''

    category do
        id '连贯'

        entry do
            name '配置'
            notes <<-'END'
                ```bash
                $ vim ~/.vimrc

                set number  " 显示绝对行号（便于通过 `:行号` 或 `行号G` 定位） "
                set relativecat " 显示相对行号（便于用 `k`/`j` 上下精准跳跃） "
                ```
            END
        end
        entry do
            name '跳转行'
            notes <<-'END'
                普通模式：

                - 行号G
                - 行号gg
                - :行号

                插入模式：

                - Esc 切换到普通模式
                - Ctrl+o 切换到临时普通模式执行

                可视模式：

                - 行号G
                - :行号
            END
        end
        entry do
            name 'Mark 标记定位与跳转'
            notes <<-'END'
                ```
                普通模式：

                - ma（当当前位置标记为a,支持a-z）
                - 'a（单引号，跳转到标记a所在的行首）
                - a（反引号，精准跳转到标记a所在的行列位置）
                ```
            END
        end
        entry do
            name '页面滚动与屏内定位'
            notes <<-'END'
                - zz: 将当前行置于屏幕正中央
                - zt: 将当前行置于屏幕顶端
                - zb: 将当前行置于屏幕底端
                - H / M / L: 光标分别跳转到当前屏幕的顶部(High)、中部(Middle)、底部(Low)
            END
        end
        entry do
            name '换行'
            notes <<-'END'
                普通模式：
                
                - o: 在下方生成新行
                - O: 在上方生成新行

                插入模式：

                - Ctrl+o 切换到临时普通模式执行
            END
        end
        entry do
            name '上下移动行'
            notes <<-'END'
                普通模式：
                    
                - :m -2 上移一行
                - :m 1 下移一行

                插入模式：

                - Ctrl+o 切换到临时普通模式执行
            END
        end
        entry do
            name '行'
            notes <<-'END'
                普通模式：

                - 0: 绝对行首
                - Shift+6: 非空字符行首
                - Shift+4: 行尾 


                插入模式：

                - Ctrl+o 切换到临时普通模式执行
            END
        end
    end
end