cheatsheet do
    title ''
    docset_file_name ''
    keyword ''

    category do
        id 'Redis'

        entry do
            name 'Standalone'
            notes <<-'END'
                # 基于 redis.tar.gz
                ```
                # unzip and make
                tar -zxvf redis.tar.gz
                cd redis/src
                export BUILD_TLS=yes BUILD_WITH_MODULES=yes INSTALL_RUST_TOOLCHAIN=yes DISABLE_WERRORS=yes
                make -j "$(nproc)" all
                # run
                ./src/redis-server redis-full.conf
                ```
            END
        end
    end
end