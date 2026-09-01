cheatsheet do
    title ''
    docset_file_name ''
    keyword ''

    category do
        id 'classloader'

        entry do
            name '查看应用的 classloader 的继承树、urls、类加载信息'
        end
        entry do
            command '-l'
            name '按类加载实例进行统计'
            notes <<-'END'
                $ classloader -l
            END
        end
        entry do
            command '-t'
            name '打印所有 ClassLoader 的继承树'
            notes <<-'END'
                $ classloader -t
            END
        end
        entry do
            command '-a'
            name '列出所有 ClassLoader 加载的类，**请谨慎使用**'
            notes <<-'END'
                $ classloader -a

            END
        end
        entry do
            command '-c <hashcode>'
            name '传递 ClassLoader 的哈希值，查找实际的 urls'
            notes <<-'END'
                $ classloader -c 3d4eac69
            END
        end
        entry do
            command '--classLoaderClass <classLoaderClass>'
            name '传递 ClassLoader 类完全限定名，查找实际的 urls'
            notes <<-'END'
                $ classloader --classLoaderClass sun.misc.Launcher$AppClassLoader
            END
        end
        entry do
            command '-r <resource name>'
            name '传递资源的路径名称，查找实际的 urls'
            notes <<-'END'
                $ classloader -r java/lang/String.class
            END
        end
        entry do
            command '--load <class>'
            name '传递资源的路径名称，进行类加载'
            notes <<-'END'
                $ classloader -r java/lang/String.class
            END
        end
    end

    category do
        id ''

        entry do
            
        end
    end
end