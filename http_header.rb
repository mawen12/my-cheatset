cheatsheet do
    title 'HTML Status Codes 中文指南'
    docset_file_name 'HTML_Status_Code'
    keyword 'html'
    source_url 'https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers'
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
            command 'Accept'
            name '可接受的内容类型'
            notes <<-'END'
                ```bash
                Accept: text/plain
                ```
            END
        end
        entry do
            command 'Cache-Control'
            name '指定请求/响应链中所有缓存机制必须遵守的指令'
            notes <<-'END'
                ```bash
                Cache-Control: no-cache
                ```
            END
        end
        entry do
            command 'Connection'
            name '用户代理更倾向于哪种类型的连接'
            notes <<-'END'
                ```bash
                Connection: keep-alive
                ```
            END
        end
        entry do
            command 'Content-Length'
            name '请求体的长度，以 8-bit 字节为单位'
            notes <<-'END'
                ```bash
                Content-Length: 342
                ```
            END
        end
        entry do
            command 'Content-MD5'
            name '请求体内容的 Base64 编码二进制 MD5 总和'
            notes <<-'END'
                ```bash
                Content-MD5: Q2hlY2sgSW50ZWdyaXR5IQ==
                ```
            END
        end
        entry do
            command 'Content-Type'
            name '请求体的 MIME 类型，用于 `POST` 和 `PUT` 请求'
            notes <<-'END'
                ```bash
                Content-Type: application/json
                ```
            END
        end
        entry do
            command 'Date'
            name '消息的发送日期和时间，采用 EFC 2616 定义的 HTTP 日期格式'
            notes <<-'END'
                ```bash
                Date: Tue, 15 Nov 1994 08:12:31 GMT
                ```
            END
        end
        entry do
            command 'Pragma'
            name '实现特定标头，可能在请求-响应链的各个位置产生影响'
            notes <<-'END'
                ```bash
                Pragma: no-cache
                ```
            END
        end
        entry do
            command 'Warning'
            name '关于实体可能存在问题的通用警告'
            notes <<-'END'
                ```bash
                Warning: 199 Miscellaneous warning
                ```
            END
        end
    end

    category do
        id '请求'

        entry do
            command 'Accept-Charset'
            name '可接受的字符集'
            notes <<-'END'
                ```bash
                Accept-Charset: utf-8
                ```
            END
        end
        entry do
            command 'Accept-Datetime'
            name '可接受的时间'
            notes <<-'END'
                ```bash
                Accept-Datetime: Thu, 31 May 2007 20:35:00 GMT
                ```
            END
        end
        entry do
            command 'Accept-Encoding'
            name '可接受的编码列表'
            notes <<-'END'
                ```bash
                Accept-Encoding: gzip, deflate
                ```
            END
        end
        entry do
            command 'Accept-Language'
            name '可接受的编码列表'
            notes <<-'END'
                ```bash
                Accept-Encoding: gzip, deflate
                ```
            END
        end
        entry do
            command 'Authorization'
            name 'HTTP 身份认证凭据'
            notes <<-'END'
                ```bash
                Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==
                ```
            END
        end
        entry do
            command 'Cookie'
            name '服务器之前使用 `Set-Cookie` 发送的 HTTP Cookie'
            notes <<-'END'
                ```bash
                Cookie: $Version=1; Skin=new;
                ```
            END
        end
        entry do
            command 'Expect'
            name '表示客户端需要特定的服务器行为'
            notes <<-'END'
                ```bash
                Expect: 100-continue
                ```
            END
        end
        entry do
            command 'From'
            name '提出请求的用户的电子邮件地址'
            notes <<-'END'
                ```bash
                From: user@example.com
                ```
            END
        end
        entry do
            command 'Host'
            name '服务器的域名以及服务器监听的 TCP 端口号。'
            notes <<-'END'
                ```bash
                Host: en.wikipedia.org
                ```
            END
        end
        entry do
            command 'If-Match'
            name '仅当客户端提供的实体与服务器上的实体匹配是才执行操作。这主要是为了像 PUT 这样的方法，确保只有在资源自用户上次更新以来未被修改的情况下才进行更新'
            notes <<-'END'
                ```bash
                If-Match: "737060cd8c284d8af7ad3082f209582d"
                ```
            END
        end
        entry do
            command 'If-Modified-Since'
            name '如果内容未变更，则允许返回 `304 Not Modified` 状态码'
            notes <<-'END'
                ```bash
                If-Modified-Since: Sat, 29 Oct 1994 19:43:31 GMT
                ```
            END
        end
        entry do
            command 'If-None-Match'
            name '如果内容未变更，则允许返回 `304 Not Modified` 状态码'
            notes <<-'END'
                ```bash
                If-None-Match: "737060cd8c284d8af7ad3082f209582d"
                ```
            END
        end
        entry do
            command 'If-Range'
            name '如果实体内容为变更，则将缺失的部分返回，否则请返回整个实体'
            notes <<-'END'
                ```bash
                If-Range: "737060cd8c284d8af7ad3082f209582d"
                ```
            END
        end
        entry do
            command 'If-Unmodified-Since'
            name '仅当实体在指定时间后没有被更新时才会发送响应'
            notes <<-'END'
                ```bash
                If-Unmodified-Since: Sat, 29 Oct 1994 19:43:31 GMT
                ```
            END
        end
        entry do
            command 'Max-Forwards'
            name '限制消息可以被代理或网关转发最大次数'
            notes <<-'END'
                ```bash
                Max-Forwards: 10
                ```
            END
        end
        entry do
            command 'Origin'
            name '发起跨域资源共享请求，向服务器请求 `Access-Control-Allow-Origin` 标头'
            notes <<-'END'
                ```bash
                Origin: http://www.example-social-network.com
                ```
            END
        end
        entry do
            command 'Proxy-Authorization'
            name '连接代理的授权凭证'
            notes <<-'END'
                ```bash
                Proxy-Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==
                ```
            END
        end
        entry do
            command 'Range'
            name '仅请求实体的一部分，字节从0开始'
            notes <<-'END'
                ```bash
                Range: bytes=500-999
                ```
            END
        end
        entry do
            command 'Referer'
            name '这是用户点击链接后访问当前页面的前一个网页地址。'
            notes <<-'END'
                ```bash
                Referer: http://en.wikipedia.org/wiki/Main_Page
                ```
            END
        end
        entry do
            command 'TE'
            name '用户代理愿意接受的传输编码，可以使用与响应头 `Transfer-Encoding` 相同的编码值，外加 `trails`（与分块传输方法有关），以通知服务器在最后一个零大小的数据块之后预期接收额外的头部信息'
            notes <<-'END'
                ```bash
                TE: trailers, deflate
                ```
            END
        end
        entry do
            command 'User-Agent'
            name '用户代理字符串'
            notes <<-'END'
                ```bash
                User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.116 Safari/537.36
                ```
            END
        end
        entry do
            command 'Via'
            name '告知服务器发送请求所经过的代理服务器信息'
            notes <<-'END'
                ```bash
                Via: 1.0 fred, 1.1 example.com (Apache/1.1)
                ```
            END
        end
        entry do
            command 'X-Requested-With'
            name '主要用于识别 Ajax 请求，某些 JavaScript 框架会将此字段的值设置为 XMLHttpRequest'
            notes <<-'END'
                ```bash
                X-Requested-With: XMLHttpRequest
                ```
            END
        end
    end

    category do
        id '响应'

        entry do
            command 'Access-Control-Allow-Origin'
            name '指定哪些网站可以参与跨域资源共享'
            notes <<-'END'
                ```bash
                Access-Control-Allow-Origin: *
                ```
            END
        end
        entry do
            command 'Refresh'
            name '用于重定向，或在创建新资源时使用。此刷新操作将在5秒后进行重定向'
            notes <<-'END'
                ```bash
                Refresh: 5; url=http://www.w3.org/pub/WWW/People.html
                ```
            END
        end
        entry do
            command 'Expires'
            name '指示响应被视为过期的日期/时间'
            notes <<-'END'
                ```bash
                Expires: Thu, 01 Dec 1994 16:00:00 GMT
                ```
            END
        end
        entry do
            command 'Set-Cookie'
            name 'HTTP Cookie'
            notes <<-'END'
                ```bash
                Set-Cookie: UserID=JohnDoe; Max-Age=3600; Version=
                ```
            END
        end
        entry do
            command 'Age'
            name '对象在代理缓存中停留的时长（以秒为单位）'
            notes <<-'END'
                ```bash
                Age: 12
                ```
            END
        end
        entry do
            command 'Allow'
            name '针对指定资源的有效操作。用于 `405 Method Not Allowed` 响应'
            notes <<-'END'
                ```bash
                Allow: GET, HEAD
                ```
            END
        end
        entry do
            command 'Last-Modified'
            name '所请求对象的最后修改日期（采用 RFC 2616 定义的 HTTP 日期格式）'
            notes <<-'END'
                ```bash
                Last-Modified: Tue, 15 Nov 1994 12:45:26 GMT
                ```
            END
        end
        entry do
            command 'Proxy-Authenticate'
            name '请求身份验证以访问代理'
            notes <<-'END'
                ```bash
                Proxy-Authenticate: Basic
                ```
            END
        end
        entry do
            command 'Retry-After'
            name '如果某个实体暂时不可用，此指令会告知客户端稍后重试。其值可以是指定的时间段（以秒为单位）或 HTTP 日期'
            notes <<-'END'
                ```bash
                Retry-After: 120; Retry-After: Fri, 07 Nov 2014 23:59:59 GMT
                ```
            END
        end
        entry do
            command 'Server'
            name '服务器的名称'
            notes <<-'END'
                ```bash
                Server: Apache/2.4.1 (Unix)
                ```
            END
        end
        entry do
            command 'Trailer'
            name '所指定的头部字段集合存在于采用分块传输编码 chunked transfer-encoding 的消息的尾部中'
            notes <<-'END'
                ```bash
                Trailer: Max-Forwards
                ```
            END
        end
        entry do
            command 'Transfer-Encoding'
            name '用于将实体安全传输给用户的编码形式，目前定义方法包括：chunked、compress、deflate、gzip 和 identify'
            notes <<-'END'
                ```bash
                Transfer-Encoding: chunked
                ```
            END
        end
        entry do
            command 'Upgrade'
            name '告知服务器升级到另一个协议'
            notes <<-'END'
                ```bash
                Upgrade: HTTP/2.0, SHTTP/1.3, IRC/6.9, RTA/x11
                ```
            END
        end
        entry do
            command 'Vary'
            name '告知下游代理如何匹配后续请求的头部信息，以决定是使用缓存的响应，还是向源服务器请求新的响应'
            notes <<-'END'
                ```bash
                Vary: *
                ```
            END
        end
        entry do
            command 'WWW-Authenticate'
            name '指示访问所请求实体时应使用的身份验证方案'
            notes <<-'END'
                ```bash
                WWW-Authenticate: Basic
                ```
            END
        end
        entry do
            command 'Status'
            name '响应状态码'
            notes <<-'END'
                ```bash
                Status: 200 OK
                ```
            END
        end
    end 

end