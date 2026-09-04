cheatsheet do
    title ''
    docset_file_name ''
    keyword ''

    category do
        id 'GIN'

        entry do
            name '请求流程'
            notes <<-'END'
                ```
                Client
                │
                ├ ① http.Request
                │
                ├ ① net/http.Server
                │
                ├ ① http.Server.Serve()
                ↓
                Gin Engine
                │
                ├ ① Engine.ServeHTTP()
                │
                ├ ① Engine.handleHttpRequest()
                │   │
                │   ├ ① 解析 HTTP Method
                │   │
                │   ├ ① 获取 URL Path
                │   │
                │   └ ① Router Tree 匹配
                │
                ├ ① 匹配 HandlerChain
                │
                ├ ① Middlware...
                │
                ├ ① 业务 Handler
                │
                ├ ① Middleware 后置逻辑
                │
                ├ ① Http Response
                ↓
                Client
                ```
            END
        end
    end
end