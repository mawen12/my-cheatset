cheatsheet do
    title 'Axios'
    docset_file_name 'axios'
    keyword 'axios'
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
        id '通用'

        entry do
            name 'GET 请求'
            notes <<-'END'
                ```javascript
                // Make a request for a user with a given ID
                axios.get('/user?ID=12345')
                    .then(function (response) {
                        console.log(response);
                    })
                    .catch(function (error) {
                        console.log(error);
                    });

                // Optionally the request above could also be done as
                axios.get('/user', {
                    params: {
                        ID: 12345
                    }
                })
                .then(function (response) {
                    console.log(response);
                })  
                .catch(function (error) {
                    console.log(error);
                });
                ```
            END
        end

        entry do
            name 'POST 请求'
            notes <<-'END'
                ```javascript
                axios.post('/user', {
                    firstName: 'Fred',
                    lastName: 'Flintstone'                
                })
                .then(function (response) {
                    console.log(response);
                })
                .catch(function (error) {
                    console.log(error);
                });
                ```
            END
        end
        
        entry do
            name '多个并发请求'
            notes <<-'END'
                ```javascript
                function getUserAcount() {
                    return axios.get('/user/12345')
                }
                function getUserPermissions() {
                    return axios.get('/user/12345/permissions')
                }   
                axios.all([getUserAccount(), getUserPermissions()])
                    .then(axios.spread(function (acct, perms) {
                        // Both requests are now complete
                    }))
                ```
            END
        end

        entry do
            name 'POST 请求配置'
            notes <<-'END'
                ```javascript
                    axios({
                        method: 'post',
                        url: '/user/12345',
                        data: {
                            firstName: 'Fred',
                            lastName: 'Flintstone'                
                        }
                    });
                ```
            END
        end

        entry do
            name 'GET 请求配置'
            notes <<-'END'
                ```javascript
                axios({
                    method: 'post',
                    url: 'http://bit.ly/2mTM3nY',
                    responseType: 'stream'
                })
                    .then(function (response) {
                        response.data.pipe(fs.createWriteStream('ada_lovelace.jpg'))
                    });
                ```
            END
        end

        entry do
            name '创建实例'
            notes <<-'END'
                ```javascript
                var instance = axios.create({
                    baseURL: 'https://some-domain.com/api/',
                    timeout: 1000,
                    headers: { 'X-Custom-Header': 'foobar' }
                });
                ```
            END
        end
    end

    category do
        id 'API'

        entry do
            name '请求方法别名'
            notes <<-'END'
                ```javascript
                axios.request(config)
                axios.get(url[, config])
                axios.delete(url[, config])
                axios.head(url[, config])
                axios.options(url[, config])
                axios.post(url[, data[, config]])
                axios.put(url[, data[, config]])
                axios.patch(url[, data[, config]])
                ```
            END
        end
        entry do
            name '并发'
            notes <<-'END'
                ```javascript
                axios.all(iterable)
                axios.spread(callback)
                ```
            END
        end
        entry do
            name '实例方法'
            notes <<-'END'
                ```javascript
                axios#create([config])
                axios#request([config])
                axios#get(url[, config])
                axios#delete(url[, config])
                axios#head(url[, config])
                axios#options(url[, config])
                axios#post(url[, data[, config]])
                axios#put(url[, data[, config]])
                axios#patch(url[, data[, config]])
                ```
            END
        end
    end

    category do
        id '请求配置'

        entry do
            name '请求选项'
            notes <<-'END'
                ```javascript
                {
                    // 用于请求的服务器路径
                    url: '/user',

                    // 请求方法
                    method: 'get', // default

                    // 如果 url 不是绝对路径，则作为 url 的前缀。
                    // 通过为 axios 实例设置 baseURL 便可以便捷的对 url 使用相对路径
                    baseURL: 'https://some-domain.com/api/',

                    // 允许在发送到服务器之前改变请求数据，仅对 PUT、POST、PATCH 请求有效，
                    // 数组中最后一个函数必须返回 string 或 Buffer 的实例：ArrayBuffer、FormData、Stream
                    // 支持对 headers 进行编辑
                    transformRequest: [function (data, headers) {

                        return data;
                    }],

                    // 允许在响应被传递给 then/catch 之前进行修改
                    transformResponse: [function (data) {

                        return data;
                    }],

                    // 自定义的请求头
                    headers: {'X-Requested-With': 'XMLHttpRequest'},

                    // 与请求一起传递的 URL 参数，必须是一个普通对象或 URLSearchParams
                    params: {
                        ID: 12345
                    },

                    // 可选的函数，用于对 params 进行序列化
                    // 参考：https://www.npmjs.com/package/qs, http://api.jquery.com/jquery.param/
                    paramsSerializer: function(params) {
                        return Qs.stringify(params, {arrayFormat: 'brackets'})
                    },

                    // 请求体，仅对 PUT、POST、PATCH 有效。
                    // 如果没有设置 transformRequest，那么必须为以下类型之一：
                    // string、plain object、ArrayBuffer、ArrayBufferView、URLSearchParams、
                    // 仅用于浏览器：FormData、File、Blob
                    // 仅用于 Node：Stream、Buffer
                    data: {
                        firstName: 'Fred'
                    },

                    // 指定请求超时时间，单位为毫秒
                    // 如果请求超过该时间，其会被中止
                    timeout: 1000,

                    // 指示是否应该对跨域访问控制请求（Cross-site Access-Control）使用凭证
                    withCredentials: false,

                    // 允许自定义请求处理以便测试更加容易，返回一个 Promise 并提供有效的响应（lib/adapters/README.md）
                    adapter: function (config) {
                    
                    },

                    // HTTP basic auth，此处会设置 Authorization 请求头，并覆盖已经存在的
                    auth: {
                        username: 'janedoe',
                        password: 's00pers3cret'
                    },

                    // 指示服务端响应的内容类型，选项有：arrayBuffer、blob、document、json、text、stream
                    responseType: 'json', // default

                    // 携带 xsrf token 的 cookie 名称
                    xsrfCookieName: 'XSRF-TOKEN', // default

                    // 携带 xsrf token 的请求头名称
                    xsrfHeaderName: 'X-XSRF-TOKEN', // default

                    // 允许用于处理上传进度的事件
                    onUploadProgress: function (progressEvent) {
                    
                    },

                    // 允许用于处理下载进度的事件
                    onDownloadProgress: function (progressEvent) {
                    
                    },

                    // 定义了 HTTP 响应体内容的最大大小
                    maxContentLength: 2000,

                    // 定义了是否根据指定 HTTP 响应状态码来解析或拒绝
                    // 如果返回 true/null/undefined 则 Promise 将被解析，否则会被拒绝
                    validateStatus: function (status) {
                        return status >= 200 && status < 300; // default
                    },

                    // 定义 node.js 中最大重定向次数，如果设置为0，则不允许重定向
                    maxRedirects: 5,

                    // 在 node.js 中执行 http/https 请求时要使用的 agent
                    // 允许添加类似于 keepAlive 这些默认未被启用的选项
                    httpAgent: new http.Agent({ keepAlive: true }),
                    httpsAgent: new https.Agent({ keepAlive: true }),

                    // 定义代理服务器的主机名和端口以及认证信息
                    // 可以传递 false 来禁用代理，忽略环境变量
                    // auth 将会被用于生成 Proxy-Authorization 请求头，并覆盖已经存在的
                    proxy: {
                        host: '127.0.0.1',
                        port: 9000,
                        auth: {
                            username: 'mikeymike',
                            password: 'rapunz3l'
                        }
                    },

                    // 指定用于取消请求的 cancel token
                    cancelToken: new CancelToken(function (cancel) {
                    
                    })
                }
                ```
            END
        end
    end

    category do
        id '响应结构'

        entry do
            name '响应'
            notes <<-'END'
                ```javascript
                {
                    // 服务端返回ide响应
                    data: {},

                    // 服务端的 HTTP 响应状态码
                    status: 200,

                    // 服务端的 HTTP 响应状态信息
                    statusText: 'OK',

                    // 服务端响应头，所有响应头名称都采用小写
                    headers: {},

                    // 提供给 axios 请求的配置
                    config: {},

                    // 与响应相关的请求
                    request: {}
                }
                ```
            END
        end
        entry do
            name '响应示例'
            notes <<-'END'
                ```javascript
                axios.get('/user/12345')
                    .then(function(response) {
                        console.log(response.data)
                        console.log(response.status)
                        console.log(response.statusText)
                        console.log(response.headers)
                        console.log(response.config)
                    })
                ```
            END
        end
    end

    category do
        id '默认配置'

        entry do
            name '全局'
            notes <<-'END'
                ```javascript
                axios.defaults.baseURL = 'https://api.example.com'
                axios.defaults.headers.common['Authorization'] = AUTH_TOKEN
                axios.defaults.headers.post['Content-Type'] = 'application/x-www-form-urlencoded'
                ```
            END
        end
        entry do
            name '实例'
            notes <<-'END'
                ```javascript
                var instance = axios.create({
                    baseURL: 'https://api/example.com'
                });

                instance.defaults.headers.common['Authorization'] = AUTH_TOKEN;
                ```
            END
        end
        entry do
            name '配置顺序'
            notes <<-'END'
                ```javascript
                // 使用默认配置创建
                var instance = axios.create();

                // 显式指定，此时为 2s
                instance.defaults.timeout = 2000;

                // 覆盖显式指定，此时为 5s
                instance.get('/longRequest', {
                    timeout: 5000
                })
                ```
            END
        end
    end

    category do
        id '拦截器'

        entry do
            name '请求与响应'
            notes <<-'END'
                ```javascript
                // 添加请求拦截器
                axios.interceptors.request.use(function (config) {
                    return config;
                }, function (error) { // 处理请求错误
                    return Promise.reject(error);
                });

                // 添加响应拦截器
                axios.interceptors.response.use(function (response) {
                    return response;
                }, function (error) { // 处理响应错误
                    return Promise.reject(error);
                });
                ```
            END
        end
        entry do
            name '移除拦截器'
            notes <<-'END'
                ```javascript
                var myInterceptor = axios.interceptors.request.use(function() {});
                axios.interceptors.request.eject(myInterceptor);
                ```
            END
        end
        entry do
            name '自定义拦截器'
            notes <<-'END'
                ```javascript
                var instance = axios.create();
                instance.interceptors.request.use(function() {/*...*/})
                ```
            END
        end
    end

    category do
        id '处理错误'

        entry do
            name '捕获错误'
            notes <<-'END'
                ```javascript
                axios.get('/user/12345')
                    .catch(function (error) {
                        if (error.response) { // 请求已发出，服务端返回非2xx的错误码
                            console.log(error.response.data);
                            console.log(error.response.status);
                            console.log(error.response.headers);
                        } else if (error.request) { // 请求被发出，但是尚未收到任何响应
                            // request 在浏览器中是 XMLHttpRequest，在 node.js 中是 http.ClientRequest
                            console.log(error.request);
                        } else {
                            // 在设置 request 期间发生的错误
                            console.log('Error', error.message)    
                        }
                        console.log(config);
                    });
                ```
            END
        end
        entry do
            name '自定义 HTTP 状态码错误'
            notes <<-'END'
                ```javascript
                axios.get('/user/12345', {
                    validateStatus: function (status) {
                        // 仅当响应状态码小于 500 时才会拒绝
                        return status < 500;
                    }
                })
                ```
            END
        end
    end

    category do
        id '取消'

        entry do
            name '使用取消 token 来取消请求'
            notes <<-'END'
                ```javascript
                var CancelToken = axios.CancelToken;
                var source = CancelToken.source();

                axios.get('/user/12345', {
                    cancelToken: source.token
                }).catch(function (thrown) {
                    if (axios.isCancel(thrown)) {
                        console.log('Request canceled', thrown.message);    
                    } else {
                        // handle error    
                    }
                });

                axios.post('/user/12345', {
                    name: 'new name'
                }, {
                    cancelToken: source.token
                })

                // 取消请求
                source.cancel('Operation canceled by the user')
                ```
            END
        end
        entry do
            name '创建取消 token'
            notes <<-'END'
                ```javascript
                var CancelToken = axios.CancelToken;
                var cancel;

                axios.get('/user/12345', {
                    cancelToken: new CancelToken(function executor(c) {
                        // executor 函数接收一个 cancel 函数作为参数
                        cancel = c;
                    })
                });

                // 取消请求
                cancel();
                ```
            END
        end
    end


end