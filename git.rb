cheatsheet do
    title 'Git 中文指南'
    docset_file_name 'Git'
    keyword 'git'

    category do
        id '创建'

        entry do
            name '克隆一个已经存在的仓库'
            notes "
              ```
              git clone ssh://user@domain.tld/repo.git
              ```"
        end
        entry do
            name '从现有仓库克隆一个独特的分支'
            notes <<-'END'
                ```bash
                git clone -b <branchname> --single-branch ssh://user@domain.tld/repo.git
                ```
            END
        end
        entry do
            name '递归克隆现有仓库及其所有子模块'
            notes <<-'END'
                ```bash
                git clone --recurse-submodules ssh://user@domain.tld/repo.git
                ```
            END
        end
        entry do
            name '创建一个本地仓库'
            notes <<-'END'
                ```bash
                git init
                ```
            END
        end
    end

    category do
        id '配置'

        entry do
            name '设置与您所有提交相关的名称'
            notes <<-'END'
                ```bash
                git config [--global] user.name <name>
                ```
            END
        end
        entry do
            name '设置与您所有提交相关的邮箱'
            notes <<-'END'
                ```bash
                git config [--global] user.email <email>
                ```
            END
        end
        entry do
            name '设置所有仓库的命令行输出颜色'
            notes <<-'END'
                ```bash
                git config --global color.ui auto
                ```
            END
        end
        entry do
            name '输出设置的名称（当前仓库或全局）'
            notes <<-'END'
                ```bash
                git config --global user.name
                ```
            END
        end
        entry do
            name '输出设置的邮箱（当前仓库或全局）'
            notes <<-'END'
                ```bash
                git config --global user.email
                ```
            END
        end
    end

    category do
        id '本地变更'

        entry do
            name '列出工作目录的变更文件'
            notes <<-'END'
                ```bash
                git status
                ```
            END
        end
        entry do
            name '列出跟踪文件的变更'
            notes <<-'END'
                ```bash
                git diff
                ```
            END
        end
        entry do
            name '将文件中的所有变更添加到下次提交'
            notes <<-'END'
                ```bash
                git add <file>
                ```
            END
        end
        entry do
            name '将所有变更添加到下次提交'
            notes <<-'END'
                ```bash
                git add .
                ```
            END
        end
        entry do
            name '以互动方式将更改添加到下次提交'
            notes <<-'END'
                ```bash
                git add -p <file>
                ```
            END
        end
        entry do
            name '将文件重命名并添加到下次提交'
            notes <<-'END'
                ```bash
                git mv <file> <new file name>
                ```
            END
        end
        entry do
            name '删除文件并添加到下次提交'
            notes <<-'END'
                ```bash
                git rm <file>
                ```
            END
        end
        entry do
            name '提交已追踪文件的所有本地变更'
            notes <<-'END'
                ```bash
                git commit -a
                ```
            END
        end
        entry do
            name '修改最后一次提交'
            notes <<-'END'
                ```bash
                git commit -amend
                ```
                注意：不应修改已发布的提交。
            END
        end
    end

    category do
        id '提交历史'

        entry do 
            name '展示所有提交'
            notes <<-'END'
                ```bash
                git log
                ```
            END
        end
        entry do 
            name '展示特定文件随时间的变化'
            notes <<-'END'
                ```bash
                git log -p <file>
                ```
            END
        end
        entry do 
            name '展示特定提交者随时间的变化'
            notes <<-'END'
                ```bash
                git log --author=<committer name>
                ```
                请注意：`<committer name>` 是一个模式，因此 `Ed` 会匹配 `Edward Smith`。如果模式不包含空格，则引号是可选的。
            END
        end
        entry do 
            name '在提交信息中查询特定的字符串'
            notes <<-'END'
                ```bash
                git log --grep=<string>
                ```
            END
        end
        entry do 
            name '检查该文件由谁在何时改了什么'
            notes <<-'END'
                ```bash
                git blame <file>
                ```
            END
        end
        entry do 
            name '暂时存储更改'
            notes <<-'END'
                ```bash
                git stash
                ```
            END
        end
        entry do 
            name '移除并恢复暂存的更改'
            notes <<-'END'
                ```bash
                git stash pop
                ```
            END
        end
        entry do 
            name '撤销之前的提交，并将变更保留在本地'
            notes <<-'END'
                ```bash
                git rm --cached <file>
                ```
            END
        end
    end

    category do
        id '分支与标记'

        entry do
            name '列出本地和远程的所有分支'
            notes <<-'END'
                ```bash
                git branch -a
                ```
                `a` 意为 all
            END
        end
        entry do
            name '列出远程的所有分支'
            notes <<-'END'
                ```bash
                git branch -r
                ```
                `r` 意为 remote
            END
        end
        entry do
            name '列出本地的所有分支'
            notes <<-'END'
                ```bash
                git branch
                ```
            END
        end
        entry do
            name '切换到给定分支的 HEAD'
            notes <<-'END'
                ```bash
                git checkout <branch>
                ```
            END
        end
        entry do
            name '基于当前分支的 HEAD 创建新的分支'
            notes <<-'END'
                ```bash
                git branch <new-branch>
                ```
            END
        end
        entry do
            name '基于远程分支创建一个新的追踪分支'
            notes <<-'END'
                ```bash
                git branch --track <new-branch> <remote-branch>
                ```
            END
        end
        entry do
            name '删除一个本地分支'
            notes <<-'END'
                ```bash
                go branch -d <branch>
                ```
            END
        end
        entry do
            name '删除一个远程分支'
            notes <<-'END'
                ```bash
                git push origin --delete <branch>
                ```
            END
        end
        entry do
            name '重命名本地分支'
            notes <<-'END'
                ```bash
                git branch -m <old name> <new name>
                ```
            END
        end
        entry do
            name '重命名远程分支'
            notes <<-'END'
                ```bash
                git push <remote> :<old name>
                git push <remote> <new name>
                ```
            END
        end
        entry do
            name '对当前提交打标记'
            notes <<-'END'
                ```bash
                git tag <tag-name>
                ```
            END
        end
    end

    category do
        id '更新与发布'

        entry do
            name '列出当前配置的所有远程节点'
            notes <<-'END'
                ```bash
                git remote -v
                ```
            END
        end
        entry do
            name '列出远程的详细信息'
            notes <<-'END'
                ```bash
                git remote show <remote>
                ```
            END
        end
        entry do
            name '添加一个新的远程仓库'
            notes <<-'END'
                ```bash
                git remote add <remote> <url>
                ```
            END
        end
        entry do
            name '重命名远程'
            notes <<-'END'
                ```bash
                git remote rename <old-name> <new-name>
                ```
            END
        end
        entry do
            name '从远程下载所有的变更，但是不合并到 HEAD'
            notes <<-'END'
                ```bash
                git fetch <remote>
                ```
            END
        end
        entry do
            name '从远程下载所有的变更，但是不合并到 HEAD，且清理远程上所有已删除的分支'
            notes <<-'END'
                ```bash
                git fetch -p <remote>
                ```
            END
        end
        entry do
            name '从远程下载所有变更，并直接合并到 HEAD'
            notes <<-'END'
                ```bash
                git pull <remote> <branch>
                ```
            END
        end
        entry do
            name '将本地变更推送到远程'
            notes <<-'END'
                ```bash
                git push <remote> <branch>
                ```
            END
        end
        entry do
            name '追踪一个远程仓库'
            notes <<-'END'
                ```bash
                git remote add --track <remote-branch> <remote> <url>
                ```
            END
        end
        entry do
            name '发布标记'
            notes <<-'END'
                ```bash
                git push --tags
                ```
            END
        end
    end

    category do
        id '合并与变基'

        entry do
            name '将目标分支合并到 HEAD'
            notes <<-'END'
                ```bash
                git merge <branch>
                ```
            END
        end
        entry do
            name '将 HEAD 变基到目标分支'
            notes <<-'END'
                ```bash
                git rebase <branch>
                ```
                请注意：你不应该对已发布的提交进行变基
            END
        end
        entry do
            name '中止变基'
            notes <<-'END'
                ```bash
                git rebase --abort
                ```
            END
        end
        entry do
            name '解决完冲突后继续变基'
            notes <<-'END'
                ```bash
                git rebase --continue
                ```
            END
        end
        entry do
            name '使用配置的合并工具解决冲突'
            notes <<-'END'
                ```bash
                git mergetool
                ```
            END
        end
        entry do
            name '使用你自己的编辑器收集解决冲突，并标记文件为冲突已解决'
            notes <<-'END'
                ```bash
                git add <resolved-file>
                git rm <resolved-file>
                ```
            END
        end
    end

    category do
        id '撤销'

        entry do
            name '丢弃当前工作目录中所有的本地变更'
            notes <<-'END'
                ```bash
                git reset --hard HEAD
                ```
            END
        end
        entry do
            name '丢弃特定文件中所有的本地变更'
            notes <<-'END'
                ```bash
                git checkout HEAD <file>
                ```
            END
        end
        entry do
            name '通过提交包含相反的新提交爱来回滚（revert）某个提交'
            notes <<-'END'
                ```bash
                git revert <commit>
                ```
            END
        end
        entry do
            name '从之前的提交中恢复特定的文件'
            notes <<-'END'
                ```bash
                git checkout <commit> <file>
                ```
            END
        end
        entry do
            name '将 HEAD 指针重置到之前的提交'
            notes <<-'END'
                * 丢弃本地变更：

                    ```bash
                    git reset --hard <commit>
                    ```

                * 将所有更改保留为为暂存的更改：

                    ```bash
                    git reset <commit>
                    ```

                * 保留未提交的本地修改：

                    ```bash
                    git reset --keep <commit>
                    ```
            END
        end
    end

    category do
        id '子模块'

        entry do
            name '列出当前配置的所有子模块'
            notes <<-'END'
                ```bash
                git submodule
                ```
                or
                ```bash
                git submodule status
                ```
            END
        end
        entry do
            name '展示子模块的信息'
            notes <<-'END'
                ```bash
                git remote show <remote>
                ```
            END
        end
        entry do
            name '添加一个新的子模块'
            notes <<-'END'
                请留意您选择的子模块的名称，如果选择 `/`，Git 会误以为您要删除该子模块，并试图将子模块目录中的所有文件添加进来。请务必不要在子模块名称后面加上 `/`。

                * 添加模块：

                    ```bash
                    git submodule add -b <branch> --name <name> <repository-path-or-url>
                    ```

                * 添加 `.gitmodule` 文件和子模块目录到父级项目的索引中

                * 在父级项目中提交上述文件
            END
        end
        entry do
            name '移除一个模块'
            notes <<-'END'
                ```bash
                git submodule deinit -f <submodule_path>
                ```
                ```bash
                rm -rf .git/modules/<submodule_path>
                ```
                ```bash
                git rm -f <submodule_path>
                ```
            END
        end
        entry do
            name '克隆带有子模块的项目'
            notes <<-'END'
                ```bash
                git clone --recurse-submodules ssh://user@domain.tld/repo.git
                ```
                或者
                正常克隆项目
                执行 `git submodule init` 来初始化子模块
                执行 `git submodule update` 来拉取子模块
            END
        end
        entry do
            name '查看子模块的所有变更'
            notes <<-'END'
                ```bash
                git diff --submodule
                ```
            END
        end
        entry do
            name '将子模块更新到各自分支上最新的变更'
            notes <<-'END'
                ```bash
                git submodule update --remote
                ```
            END
        end
        entry do
            name '将特定子模块更新到对应分支上最新的变更'
            notes <<-'END'
                ```bash
                git submodule update --remote <submodule-name>
                ```
            END
        end
        entry do
            name '仅在所有子模块都已经推送的情况，推送所有变更到父项目'
            notes <<-'END'
                ```bash
                git push --recurse-submodules=check
                ```
            END
        end
        entry do
            name '推送变更到子模块，然后推送变更到父项目'
            notes <<-'END'
                ```bash
                git push --recurse-submodules=on-demand
                ```
            END
        end
        entry do
            name '在每个模块上运行任意命令'
            notes <<-'END'
                ```bash
                git submodule foreach '<arbitrary-command-to-run>'
                ```
            END
        end
    end
end