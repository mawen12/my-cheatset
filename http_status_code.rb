cheatsheet do
    title 'HTML Status Codes 中文指南'
    docset_file_name 'HTML_Status_Code'
    keyword 'html'
    source_url 'https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status'
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
        id '1xx Information'

        entry do
            command '100'
            name 'Continue'
            notes '这是一个临时响应，表明迄今为止的所有内容都是可行的，客户端应该继续请求，如果已经完成，则忽略它'
        end
        entry do
            command '101'
            name 'Switching protocols'
            notes '该代码是响应客户端的 `Upgrade` 请求头发送的，指明服务器即将切换的协议'
        end
        entry do
            command '102'
            name 'Processing'
            notes '该代码表示服务器已收到并正在处理该请求，但当前没有响应可用'
        end
        entry do
            command '103'
            name 'Early Hints'
            notes '此状态代码主要用于与 `Link` 连接头一起使用，已允许用户代理在服务器准备响应阶段时开始预加载 `preloading` 资源'
        end
    end

    category do
        id '2xx Success'

        entry do
            command '200'
            name 'OK'
            notes <<-'END'
                请求成功。成功的含义取决于 HTTP 方法：

                - `GET`：资源已被提取并在消息正文中传输
                - `HEAD`：代表响应头包含了，但是没有任何消息体
                - `PUT` 或 `POST`：描述动作结果的资源在消息体中传输
                - `TRACE`：消息正文包含服务器接收到的请求消息
                
            END
        end
        entry do
            command '201'
            name 'Created'
            notes '请求已完成，已创建新资源。主要被用于 `POST` 和 `PUT` 请求'
        end
        entry do
            command '202'
            name 'Accepted'
            notes '请求已被接受，但尚未处理完成。该状态码不能保证请求将被处理成功,通常用于另一个进程/服务器处理请求，或是批处理的场景'
        end
        entry do
            command '203'
            name 'Non-authoritative information'
            notes '此响应码代表返回的元数据与从源服务器提供的数据并不完全相同，而是从本地或第三方副本中收集。这主要用于镜像或备份的场景，除此之外应该使用 `200 OK`'
        end
        entry do
            command '204'
            name 'No content'
            notes '服务端成功处理请求，没有返回任何内容，但是请求头有用，用户代理可以使用新资源更新其缓存头。通常被用于 `DELETE` 请求'
        end
        entry do
            command '205'
            name 'Reset content'
            notes '与 `204` 类似，但是该响应要求请求者重置文档视图'
        end
        entry do
            command '206'
            name 'Partial content'
            notes '该响应码被用于当客户端请求某个资源的部分数据时的场景'
        end
        entry do
            command '207'
            name 'Multi-status'
            notes '适用于多个状态码，传递多个资源'
        end
        entry do
            command '208'
            name 'Already Reported'
            notes '在 `<dav:propstat> 元素标签中使用，以避免将同一个元素重复绑定到集合中`'
        end
        entry do
            command '226'
            name 'IM Used'
            notes '服务端以满足 `GET` 请求，响应即表示当前实例中一个或多个实例管理的结果'
        end
    end

    category do
        id '3xx Redirect'

        entry do
            command '300'
            name 'Multiple Choices'
            notes '客户端可以选择多种方案'
        end
        entry do
            command '301'
            name 'Moved Permanently'
            notes '该资源已迁移，所有后续请求均应引用其新的URL'
        end
        entry do
            command '302'
            name 'Found'
            notes 'HTTP 1.0 规范将此状态描述为临时重定向，但是主流浏览器对此状态的响应类似于303状态的行为，可以通过引用返回的 URI 来检索资源。'
        end
        entry do
            command '303'
            name 'See Other'
            notes '可以使用通过 GET 方法访问其他 URI 来获取资源。当收到 POST、PUT 或 DELETE 请求的响应时，通常可以认为服务器已成功处理请求，并将客户端重定向到一个信息端点'
        end
        entry do
            command '304'
            name 'Not Modified'
            notes '自 `If-Modified-Since` 或 `If-Match` 标头中指定的版本以来，该资源未被修改。因此，该资源不会在响应正文中返回。'
        end
        entry do
            command '305'
            name 'Use Proxy'
            notes 'HTTP 1.1，该资源只能通过代理访问，地址在响应中提供'
        end
        entry do
            command '306'
            name 'Switch Proxy'
            notes '已过期，意味着后续请求应该通过特定代理发送'
        end
        entry do
            command '307'
            name 'Termporary Redirect'
            notes 'HTTP 1.1，请求应该使用响应中提供的 URI 重新发送，但后续请求仍应调用原始 URI'
        end
        entry do
            command '308'
            name 'Permanent Redirect'
            notes '该请求及其后续请求均应使用响应中提供的 URI 重复发送，后续请求中不允许更改 HTTP 方法'
        end
    end

    category do
        id '4xx Client error'

        entry do
            command '400'
            name 'Bad Request'
            notes '由于请求语法错误，无法完成该请求'
        end
        entry do
            command '401'
            name 'Unauthorized'
            notes '请求者无权访问该资源。这与 403 错误类似，但用于预期需要身份验证但身份验证失败或未提供身份验证信息的场景'
        end
        entry do
            command '402'
            name 'Payment Required'
            notes '保留供将来使用，某些网络服务会将此作为客户端发送过多请求的指示'
        end
        entry do
            command '403'
            name 'Forbidden'
            notes '请求格式正确，但服务器拒绝提供所请求的资源。与 401 错误不同，身份认证不会改变服务器的响应'
        end
        entry do
            command '404'
            name 'Not Found'
            notes '资源未找到。这通常用作所有无效 URI 请求的兜底规则'
        end
        entry do
            command '405'
            name 'Method Not Allowed'
            notes '使用了不允许的方法请求资源。例如，当资源支持 GET 方法时，却使用 POST 方法请求资源'
        end
        entry do
            command '406'
            name 'Not Acceptable'
            notes '资源有效，但无法以请求中 `Accept` 标头指定的格式提供'
        end
        entry do
            command '407'
            name 'Proxy Authentication Required'
            notes '通过代理服务器进行身份验证后，请求才能得到处理'
        end
        entry do
            command '408'
            name 'Request Timeout'
            notes "此响应由一些服务器在空闲连接上发送，即使客户端之前没有任何请求。这意味着服务器想关闭这个未使用的连接。
            由于一些浏览器如 Chrome、Firefox 27+ 或 IE9,使用 HTTP 预连接机制来加速冲浪，所以这种响应被使用的更多。
            还要注意的是，有些服务器只是关闭了连接而没有发送此消息"
        end
        entry do
            command '409'
            name 'Conflict'
            notes '将请求与服务器的当前状态冲突时，将发送此响应'
        end
        entry do
            command '410'
            name 'Gone'
            notes '当请求的内容已从服务器中永久删除且没有转发地址时，将发送此响应。客户端需要删除缓存和指向资源的链接。HTTP 规范将此状态码用于有限时间的促销服务。'
        end
        entry do
            command '411'
            name 'Length Required'
            notes '服务端拒绝该请求，因为 `Content-Length` 标头未定义，但服务端需要此来解析请求体'
        end
        entry do
            command '412'
            name 'Precondition Failed'
            notes '客户端在其标头指出了服务器不满足的先决条件'
        end
        entry do
            command '413'
            name 'Content Too Large'
            notes '请求实体超过了服务器定义的限制。服务器可能会关闭连接，或在响应标头返回 `Retry-After`'
        end
        entry do
            command '414'
            name 'URI Too Long'
            notes '客户端请求的 URI 比服务器愿意接收的长度长'
        end
        entry do
            command '415'
            name 'Unsupported Media Type'
            notes '服务器不支持请求数据的媒体格式，因此服务器拒绝该请求'
        end
        entry do
            command '416'
            name 'Range Not Satisfiable'
            notes '无法满足请求标头中 `Range` 指定的范围，该范围可能超出了目标 URI 数据的大小'
        end
        entry do
            command '417'
            name 'Expectation Failed'
            notes '无法满足请求标头中 `Expect` 指示的期望'
        end
        entry do
            command '418'
            name "I'm a teapot"
            notes '服务器拒绝用茶煮咖啡'
        end
        entry do
            command '421'
            name 'Misdirected Request'
            notes '请求被重定向到无法生成响应的服务器'
        end
        entry do
            command '422'
            name 'Unprocessable Content'
            notes '请求格式正确，但由于语义错误而无法遵循'
        end
        entry do
            command '423'
            name 'Locked'
            notes '正在访问的资源已锁定'
        end
        entry do
            command '424'
            name 'Failed Dependency'
            notes '由于前一个请求失败，该请求失败'
        end
        entry do
            command '425'
            name 'Too Early'
            notes '表示服务器不愿冒险处理可能被重播的请求'
        end
        entry do
            command '426'
            name 'Upgrade Required'
            notes '服务器拒绝使用当前协议执行请求，但在客户端升级到其他协议后可能愿意这样做，响应标头 `Upgrade` 指示了所需的协议'
        end
        entry do
            command '428'
            name 'Precondition Required'
            notes '源服务器要求请求必须带有条件'
        end
        entry do
            command '429'
            name 'Too Many Requests'
            notes '用户在给定时间内发送过多的请求，超过了服务端的速率限制'
        end
        entry do
            command '431'
            name 'Request Header Fields Too Large'
            notes '服务器不愿处理请求，因为其请求标头长度太大，在减小请求标头字段后可以重新提交请求'
        end
        entry do
            command '451'
            name 'Unavailable For Legal Reasons'
            notes '用户代理请求了无法合法提供的资源，例如政府审查的网页'
        end
    end

    category do
        id '5xx Server error'

        entry do
            command '500'
            name 'Internal Server Error'
            notes '服务遇到了意外的错误'
        end
        entry do
            command '501'
            name 'Not Implemented'
            notes '服务器不支持该方法，无法处理'
        end
        entry do
            command '502'
            name 'Bad Gateway'
            notes '服务器作为网关需要得到一个处理这个请求的响应，但是得到一个错误的响应'
        end
        entry do
            command '503'
            name 'Service unavailable'
            notes '服务器没有准备好处理请求，通常是因为服务器因维护后重载而停机'
        end
        entry do
            command '504'
            name 'Gateway Timeout'
            notes '当服务器作为网关无法即时获得响应时，会给出此错误响应'
        end
        entry do
            command '505'
            name 'Http Version Not Supported'
            notes '服务器不支持请求中使用的 HTTP 版本'
        end
        entry do
            command '506'
            name 'Variant Also Negotiates'
            notes '服务器存在内部配置错误'
        end
        entry do
            command '507'
            name 'Insufficient Storage'
            notes '无法在资源上执行该方法，因为服务器无法存储成功完成此请求所需的表示'
        end
        entry do
            command '508'
            name 'Loop Detected'
            notes '服务器在处理请求时检测到无限循环'
        end
        entry do
            command '510'
            name 'Not Extended'
            notes '服务器需要对请求进行进一步扩展才能完成请求'
        end
        entry do
            command '511'
            name 'Network Authentication Requried'
            notes '客户端需要进行身份认证才能获得网络权限'
        end
    end
end