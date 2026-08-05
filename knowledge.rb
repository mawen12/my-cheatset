cheatsheet do
    title 'Knowledge'
    docset_file_name 'Knowledge'
    keyword 'knowledge'
    introduction '知识库'
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
        id 'Encoding'

        entry do
            command 'Base64'
            name '将不可读的二进制数据与可读字符相互转换的过程'
        end
        entry do
            command 'HEX'
            name '十六进制编码，将不可读的二进制数据与可读字符相互转换的过程'
        end
    end

    category do
        id 'OSI(Open System Interconnection，开放系统互联) 模型'

        entry do
            command 'Application'
            name '应用层'
            notes <<-'END'
                面向应用程序，为其提供网络服务。
                
                基本单位为：数据（Data）。
                
                常见协议有：
                
                - HTTP
                - HTTPS
                - FTP
                - SMTP
                - DNS
                - WebSocket
            END
        end
        entry do
            command 'Presentation'
            name '表示层'
            notes <<-'END'
                提供数据格式转换、加密、压缩。
                
                基本单位为：数据（Data）。
                
                常见协议有：

                - TLS/SSL
                - JPEG
                - JSON
                - XML
                - 编码转换
            END
        end
        entry do
            command 'Session'
            name '会话层'
            notes <<-'END'
                建立、维护、管理通信会话。
                
                基本单位为：数据（Data）。
                
                常见协议有：

                - RPC
                - NetBIOS
                - Session 管理
            END
        end
        entry do
            command 'Transport'
            name '传输层'
            notes <<-'END'
                端到端通信，可靠传输、流量控制。
                
                基本单位为：段（Segment）。
                
                常见协议有：

                - TCP
                - UDP
                - QUIC
            END
        end
        entry do
            command 'Network'
            name '网络层'
            notes <<-'END'
                IP寻址、路由选择。
                
                基本单位为：包（Packet）。
                
                常见协议有：

                - IP
                - ICMP
                - OSPF
                - BGP
            END
        end
        entry do
            command 'Data Link'
            name '数据链路层'
            notes <<-'END'
                MAC 寻址、局域网传输、错误检测。
                
                基本单位为：帧（Frame）。
                
                常见协议有：

                - Ethernet
                - ARP
                - VLAN
                - WiFi
            END
        end
        entry do
            command 'Physical'
            name '物理层'
            notes <<-'END'
                比特流传输、电信号/光信号。
                
                基础单位为：比特（Bit）。
                
                常见协议有：

                - 网线
                - 光纤
                - 无线电
                - Hub
            END
        end
    end

    category do
        id 'Protocol'

        entry do
            command 'HTTP'
            name '超文本传输协议（Hypertext Transfer Protocol）'
            notes <<-'END'
                是一种用于分布式、协作式和超媒体信息系统的**应用层**协议。

                是客户端和服务端之间请求和应答的标准，其下层协议使用TCP/IP作为其传输层。
            END
        end
        entry do
            command 'HTTPS'
            name '超文本传输安全协定（Hypertext Transfer Protocol Secure）'
            notes <<-'END'
                是一种通过计算机网络进行安全通信的**应用层**协议。
                
                HTTPS 经由 HTTP 进行通信，利用 TLS 加密数据包。

                其又被称为：HTTP over TLS、HTTP over SSL 或 HTTP Secure。
            END
        end
        entry do
            command 'FTP'
            name '文件传输协议（File Transfer Protocol）'
            notes <<-'END'
                是一种客户端和服务器间通过计算机网络的传输**文件**的**应用层**协议。
            END
        end
        entry do
            command 'SMTP'
            name '简单邮件传输协议（Simple Mail Transfer Protocol）'
            notes <<-'END'
                是一种客户端和服务器间通过计算机网络的传输**电子邮件**的**应用层**协议。

                此处需要使用电子客户端和邮件服务器。
            END
        end
        entry do
            command 'WebSocket'
            name '网络套接字'
            notes <<-'END'
                是一种客户端和服务端键通过计算机网络的进行**双向通信**的**应用层**协议。
            END
        end
        entry do
            command 'TCP'
            name '传输控制协议（Transmission Control Protocol）'
            notes <<-'END'
                是一种面向连接的、可靠的、基于字节流的**传输层**协议。TCP 协议运行划分为三个阶段：

                - 连接建立（Connection establishment）
                - 数据传送（Data transfer）
                - 连接终止（Connection termination）
            END
        end
        entry do
            command 'UDP'
            name '用户数据报协议（User Datagram Protocol）'
            notes <<-'END'
                是一种无需建立连接、直接发送和接收数据的**传输层**协议。
            END
        end
        entry do
            command 'IP'
            name '网络协议（Internet Protocol）'
            notes <<-'END'
                是一种根据数据包标头中的 IP 地址将数据包从源主机传递到目标主机**网络层**协议。
            END
        end
    end

    category do
        id 'Technology'

        entry do
            command 'DNS'
            name '域名系统（Domain Name System）'
            notes <<-'END'
                是一种将域名和IP地址相互映射的分布式数据库。其使用 TCP 和 UDP 端口 53。

                常见的资源记录（Resource Record）有：

                - 主机记录（A 记录）：用于名称解析的重要记录，将特定的主机名映射到对应主机的 IP 地址上。
                - 别名记录（CNAME 记录）：将某个别名指向到某个 A 记录上，这样就不需要为新名字创建一条新的 A 记录。
                - IPv6主机记录（AAAA 记录）：与 A 记录对应，将特定的主机名映射到一个主机的 IPv6 地址上。
                - 服务位置记录（SRV 记录）：定义提供特定服务的服务器的位置，如 hostname、port 等。
                - 域名服务记录（NS 记录）：指定该域名由哪个 DNS 服务器来解析。
                - NAPTR记录：提供了正则表达式方式去映射一个域名。
            END
        end
        entry do
            command 'CDN'
            name '内容分发网络（Network Delivery Network）'
            notes <<-'END'
                是一种通过互联网相互链接的电脑网络系统，利用最靠近每位用户的服务器，更快、更可靠地将音乐、图片、影片、应用程序及其他文件发送给用户，来提供低成本的网络内容给用户。
            END
        end
    end

    category do
        id 'Performance'

        entry do
            command ''
        end
    end
end