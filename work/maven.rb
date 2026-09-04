cheatsheet do
    title ''
    docset_file_name ''
    keyword ''
    
    category do
        id '阶段'
        
        entry do
            name 'clean'
            notes '删除 target 目录'
        end
        entry do
            name 'validate'
            notes '验证项目结构是否正确'
        end
        entry do
            name 'compile'
            notes '编译源代码'
        end
        entry do
            name 'test'
            notes '运行单元测试'
        end
        entry do
            name 'package'
            notes '将编译好的代码打包'
        end
        entry do
            name 'verify'
            notes '运行集成测试或质量检查'
        end
        entry do
            name 'install'
            notes '将打包好的构件安装到本地 Maven 仓库'
        end
        entry do
            name 'site'
            notes '生成并发布项目的文档站点'
        end
        entry do
            name 'deploy'
            notes '将最终的构件复制/上传到远程 Maven 私服'
        end
    end

    category do
        id '打包'

        entry do
            name '对多模块中单独模块进行打包'
            notes 'mvn package -pl <module-name> -am'
        end
    end
end