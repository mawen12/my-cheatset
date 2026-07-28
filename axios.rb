cheatsheet do
    title 'Axios'
    docset_file_name 'axios'
    keyword 'axios'

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
                ```
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

                    // HTTP basic auth，此处会设置 Authorization 请求头，并覆盖该
                    auth: {
                        username: 'janedoe',
                        password: 's00pers3cret'
                    },

                    responseType: 'json',

                    xsrfCookieName: 'XSRF-TOKEN',

                    xsrfHeaderName: 'X-XSRF-TOKEN',

                    onUploadProgress: function (progressEvent) {
                    
                    },

                    onDownloadProgress: function (progressEvent) {
                    
                    },

                    maxContentLength: 2000,

                    validateStatus: function (status) {
                        return status >= 200 && status < 300;
                    },

                    maxRedirects: 5,

                    httpAgent: new http.Agent({ keepAlive: true }),
                    httpsAgent: new https.Agent({ keepAlive: true }),

                    // 定义 
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
end