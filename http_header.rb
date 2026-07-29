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
            notes '`Accept: text/plain`'
        end
        
    end

    category do
        id '请求'

        entry do
            command 'Accept-Charset'
            name '可接受的字符集'
            notes '`Accept-Charset: utf-8`'
        end
        entry do
            command 'Accept-Datetime'
            name '可接受的时间'
            notes '`Accept-Datetime: Thu, 31 May 2007 20:35:00 GMT`'
        end
        entry do
            command 'Accept-Encoding'
            name '可接受的编码列表'
            notes '`Accept-Encoding: gzip, deflate`'
        end
        entry do
            command 'Accept-Language'
            name '可接受的编码列表'
            notes '`Accept-Encoding: gzip, deflate`'
        end
        entry do
            command 'Authorization'
            name 'HTTP 身份认证凭据'
            notes '`Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==`'
        end
        entry do
            command 'Cache-Control'
            name '指定请求/响应链中所有缓存机制必须遵守的指令'
            notes '`Cache-Control: no-cache`'
        end
        entry do
            command 'Connection'
            name '用户代理更倾向于哪种类型的连接'
            notes '`Connection: keep-alive`'
        end
        entry do
            command 'Content-Length'
            name '请求体的长度，以 8-bit 字节为单位'
            notes '`Content-Length: 342`'
        end
        entry do
            command 'Content-MD5'
            name '请求体内容的 Base64 编码二进制 MD5 总和'
            notes '`Content-MD5: Q2hlY2sgSW50ZWdyaXR5IQ==`'
        end
        entry do
            command 'Content-Type'
            name '请求体的 MIME 类型，用于 `POST` 和 `PUT` 请求'
            notes '`Content-Type: application/json`'
        end
        entry do
            command 'Cookie'
            name '服务器之前使用 `Set-Cookie` 发送的 HTTP Cookie'
            notes '`Cookie: $Version=1; Skin=new;`'
        end
        entry do
            command 'Date'
            name '消息的发送日期和时间，采用 EFC 2616 定义的 HTTP 日期格式'
            notes '`Date: Tue, 15 Nov 1994 08:12:31 GMT`'
        end
        entry do
            command 'Expect'
            name '表示客户端需要特定的服务器行为'
            notes '`Expect: 100-continue`'
        end
        entry do
            command 'From'
            name '提出请求的用户的电子邮件地址'
            notes '`From: user@example.com`'
        end
        entry do
            command 'Host'
            name '服务器的域名以及服务器监听的 TCP 端口号。'
            notes '`Host: en.wikipedia.org`'
        end
        entry do
            command 'If-Match'
            name '仅当客户端提供的实体与服务器上的实体匹配是才执行操作。这主要是为了像 PUT 这样的方法，确保只有在资源自用户上次更新以来未被修改的情况下才进行更新'
            notes '`If-Match: "737060cd8c284d8af7ad3082f209582d"`'
        end
        entry do
            command 'If-Modified-Since'
            name '如果内容未变更，则允许返回 `304 Not Modified` 状态码'
            notes 'If-Modified-Since: Sat, 29 Oct 1994 19:43:31 GMT'
        end
        entry do
            command 'If-None-Match'
            name '如果内容未变更，则允许返回 `304 Not Modified` 状态码'
            notes '`If-None-Match: "737060cd8c284d8af7ad3082f209582d"`'
        end
        entry do
            command 'If-Range'
            name '如果实体内容为变更，则将缺失的部分返回，否则请返回整个实体'
            notes '`If-Range: "737060cd8c284d8af7ad3082f209582d"`'
        end
        entry do
            command 'If-Unmodified-Since'
            name '仅当实体在指定时间后没有被更新时才会发送响应'
            notes '`If-Unmodified-Since: Sat, 29 Oct 1994 19:43:31 GMT`'
        end
        entry do
            command 'Max-Forwards'
            name '限制消息可以被代理或网关转发最大次数'
            notes '`Max-Forwards: 10`'
        end
        entry do
            command 'Origin'
            name '发起跨域资源共享请求，向服务器请求 `Access-Control-Allow-Origin` 标头'
            notes '`Origin: http://www.example-social-network.com`'
        end
        entry do
            command 'Pragma'
            name '实现特定标头，可能在请求-响应链的各个位置产生影响'
            notes '`Pragma: no-cache`'
        end
        entry do
            command 'Proxy-Authorization'
            name '连接代理的授权凭证'
            notes '`Proxy-Authorization: Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ==`'
        end
        entry do
            command 'Range'
            name '仅请求实体的一部分，字节从0开始'
            notes '`Range: bytes=500-999`'
        end
        entry do
            command 'Referer'
            name '这是用户点击链接后访问当前页面的前一个网页地址。'
            notes '`Referer: http://en.wikipedia.org/wiki/Main_Page`'
        end
        entry do
            command 'TE'
            name ''
            notes ''
        end
        entry do
            command 'User-Agent'
            name ''
            notes ''
        end
        entry do
            command 'Via'
            name ''
            notes ''
        end
        entry do
            command 'Warning'
            name ''
            notes ''
        end
    end

    category do
        id '响应'

        entry do
            command ''
            name ''
            notes ''
        end
        entry do
            command ''
            name ''
            notes ''
        end
        entry do
            command ''
            name ''
            notes ''
        end
    end 

end