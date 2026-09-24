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
        id 'jad'

        entry do
            command 'jad <全限定类名>'
            name '反编译类'
        end
    end

    category do
        id 'retransform'

        entry do
            command 'retransform /tmp/Xxx.class'
            name '加载外部的 .class 文件'
            notes <<-'END'
                需要注意的是，对于 spring bean 的 class 修改字段值后，不会起效。
                只有方法才会起效。
            END
        end
    end

    category do
        id 'ognl'

        entry do
            command 'ognl -c <classLoader hashcode> @<className>@<field>'
            name '查看类的静态字段值'
            notes <<-'END'
                # 获取类加载器及其hashCode
                classloader -t
                # 获取该类的字段信息
                ognl -c <classLoader hashcode> @com.jsbank.util.Http2Util@connectionTimeout
            END
        end
    end

    category do
        id 'vmtool'

        entry do
            command 'vmtool --action getInstances --className <className> --express \'instances[0]\''
            name '获取类实例的字段信息'
            notes <<-'END'
                # 获取该实例的所有字段和方法信息
                vmtool --action getInstances --className com.jsbank.service.channel.T988546Service --express 'instances[0]'
                # 获取该实例的指定字段信息
                vmtool --action getInstances --className com.jsbank.service.channel.T988546Service --express 'instances[0].url'
            END
        end
    end

    category do
        id 'mc'

        entry do
            command 'mc /tmp/Test.java'
            name '编译 .java 文件生成 .class'
        end
    end

    category do
        id '组合技'

        entry do
            name '编辑及替换'
            notes <<-'END'
                # 反编译
                jad --source-only <全限定类名> > /tmp/Demo.java
                # 修改源码方法
                vim /tmp/Dmeo.java
                # 编译 class
                sc -d <全限定类名> | grep classLoaderHash
                mc -c <classLoaderHash> /tmp/Demo.java -d /tmp/classes
                # 热更新装载
                retransform /tmp/classes/Demo.class
                retransform -l
            END
        end
    end
end