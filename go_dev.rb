cheatsheet do
    title 'Go Dev '
    docset_file_name 'Go_dev'
    keyword 'go dev'
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
        id 'flag'

        entry do
            name '读取'
            notes <<-'END'

            END
        end
    end

    category do
        id 'web'

        entry do

        end
    end

    category do
        id 'build'

        entry do
            command 'GOOS'
            name '用于指定不同的目标系统，支持 linux/windows/darwin/android/freebsd/ios/js/openbsd/plan9/solaris'
        end
        entry do
            command 'GOARCH'
            name '用于指定不同的系统架构，支持 amd64/arm64/386/riscv'
        end
        entry do
            command 'CGO_ENABLED'
            name '用于指定是否开启CGO，支持 0（禁用）/1（开启）'
        end
        entry do
            command '-mod=vendor'
            name '使用 vendor 目录作为依赖来源'
        end
        entry do
            command '-ldflags=\'-s\''
            name ''
        end
    end

    category do
        id '脚本自动化'

        entry do
            name '环境变量'
            notes <<-'END'
                ```.envrc
                # .envrc
                export key=value
                ```
            END
        end
        entry do
            name 'Makefile'
            notes <<-'END'
                ```makefile
                # include variables from the .envrc file
                include .envrc

                # ==================================================================================== #
                # HELPERS
                # ==================================================================================== #

                ## help: print this help message
                .PHONY: help
                help:
                    @echo 'Usage:'
                    @sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'

                .PHONY: confirm
                confirm:
                    @echo -n 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]

                # ==================================================================================== #
                # DEVELOPMENT
                # ==================================================================================== #

                ## run/api: run the cmd/api application
                .PHONY: run/api
                run/api:
                    go run ./cmd/api -db-dsn=${GREENLIGHT_DB_DSN} -jwt-secret=${JWT_SECRET}

                ## db/psql: connect to the database using psql
                .PHONY: db/psql
                db/psql:
                    psql ${GREENLIGHT_DB_DSN}

                ## db/migration/new name=$1: create a new database migration
                .PHONY: db/migration/new
                db/migration/new:
                    @echo 'Creating migration files for ${name}'
                    migrate create -seq -ext=.sql -dir=./migrations ${name}

                ## db/migration/up: apply app up database migrations
                .PHONY: db/migration/up
                db/migration/up: confirm
                    @echo 'Running up migrations...'
                    migrate -path ./migrations -database ${GREENLIGHT_DB_DSN} up

                # ==================================================================================== #
                # PRODUCTION
                # ==================================================================================== #

                production_host_ip = '206.189.95.27'

                ## production/connect: connect to the production server
                .PHONY: production/connect
                production/connect:
                    ssh greenlight@${production_host_ip}

                ## production/deploy/api: deploy the api to production
                .PHONY: production/deploy/api
                production/deploy/api:
                    rsync -P ./bin/linux_amd64/api greenlight@${production_host_ip}:~
                    rsync -rP --delete ./migrations greenlight@${production_host_ip}:~
                    rsync -P ./remote/production/api.service greenlight@${production_host_ip}:~
                    rsync -P ./remote/production/Caddyfile greenlight@${production_host_ip}:~
                    ssh -t greenlight@${production_host_ip} '\
                    migrate -path ~/migrations -database $$GREENLIGHT_DB_DSN up \
                    && sudo mv ~/api.service /etc/systemd/system/ \
                    && sudo systemctl enable api \
                    && sudo systemctl restart api \
                    && sudo mv ~/Caddyfile /etc/caddy \
                    && sudo systemctl reload caddy \
                    '

                # ==================================================================================== #
                # QUALITY CONTROL
                # ==================================================================================== #

                ## tidy: format all .go files and tidy module dependencies
                .PHONY: tidy
                tidy:
                    @echo 'Formatting .go files...'
                    go fmt ./...
                    @echo 'Tidying module dependencies'
                    go mod tidy
                    @echo 'Verifying and vendoring module dependencies...'
                    go mod verify
                    go mod vendor

                ## audit: run quality control checks
                audit:
                    @echo 'Checking module dependencies'
                    go mod tidy -diff
                    go mod verify
                    @echo 'Vetting code...'
                    go vet ./...
                    staticcheck ./...
                    @echo 'Running tests...'
                    go test -race -vet=off ./...

                # ==================================================================================== #
                # BUILD
                # ==================================================================================== #
                ## build/api: build the cmd/api application
                .PHONY: build/api
                build/api:
                    @echo 'Building cmd/api...'
                    go build -ldflags='-s' -o=./bin/api ./cmd/api
                    GOOS=linux GOARCH=amd64 go build -ldflags='-s' -o=./bin/linux_amd64/api ./cmd/api
                ```    
            END
        end
    end
end