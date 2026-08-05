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
        id '时间复杂度'

        entry do
            command 'O(1)'
            name '常数阶'
        end
        entry do
            command 'O(logn)'
            name '对数阶'
        end
        entry do
            command 'O(n)'
            name '线形阶'
        end
        entry do
            command 'O(nlogn)'
            name '线形对数阶'
        end
        entry do
            command 'O(n2)'
            name '平方阶'
        end
        entry do
            command 'O(2n)'
            name '指数阶'
        end
        entry do
            command 'O(n!)'
            name '阶乘阶'
        end
    end

    category do
        id '空间复杂度'

        entry do
            command 'O(1)'
            name '常数阶'
        end
        entry do
            command 'O(logn)'
            name '对数阶'
        end
        entry do
            command 'O(n)'
            name '线性阶'
        end
        entry do
            command 'O(n2)'
            name '平方阶'
        end
        entry do
            command 'O(2n)'
            name '指数阶'
        end
    end

    category do
        id '数据结构'

        entry do
            command 'Array'
            name '数组，数据按照一定顺序排列，是线性的。'
            notes <<-'END'
                元素被存储在连续的内存空间中。通过给定数组内存地址和某个元素的索引，变可以直接访问该元素。
                
                数组的首个元素索引为0，**索引本质上是内存地址的偏移量**。
                
                元素内存地址 = 数组内存地址 + 元素长度 * 元素索引。访问随机元素的为 O(1) 。
                
                由于元素之间是连续的，没有额外的空间，因此插入元素需要将该元素之后的元素都向后移动一位，并且导致尾部元素的丢失。
                删除元素这需要将之后的元素都往前移动一位。这两个操作平均时间复杂度为O(N)。
            END
        end
        entry do
            command 'LinkedList'
            name '链表，数据按照一定顺序排列，是线性的'
            notes <<-'END'
                每个元素都是一个节点，各个节点之间通过引用相连接。

                在两个相邻节点插入元素，仅需要改变两个节点引用指针即可，时间复杂度为 O(1)。

                删除节点仅需改变一个节点的引用指针。
            END
        end
        entry do
            command 'Stack'
            name '栈，线性'
        end
        entry do
            command 'Queue'
            name '队列，线性'
        end
        entry do
            command 'Hash'
            name '哈希表，非线性'
        end
        entry do
            command 'Tree'
            name '树，非线性，数据从顶部向下按层次排列，表现出祖先与后代之间的派生关系'
        end
        entry do
            command 'Heap'
            name '堆，非线性'
        end
        entry do
            command 'Graph'
            name '图，非线性，由节点和边构成，反映复杂的网络关系'
        end
    end

    category do
        id '基本数据类型'

        entry do
            name 'byte'
            notes <<-'END'
                整数，占用1字节 = 8bit，表示 -2<sup>7</sup> ~ 2<sup>7</sup>-1，即 -128～127
            END
        end
        entry do
            name 'short'
            notes <<-'END'
                整数，占用2字节 = 2 * 8bit，表示 -2<sup>15</sup> ~ 2<sup>15</sup>-1
            END
        end
        entry do
            name 'int'
            notes <<-'END'
                整数，占用4字节 = 4 * 8bit，表示 -2<sup>31</sup> ~ 2<sup>31</sup>-1
            END
        end
        entry do
            name 'long'
            notes <<-'END'
                整数，占用8字节 = 8 * 8bit，表示 -2<sup>63</sup> ~ 2<sup>63</sup>-1
            END
        end
        entry do
            name 'float'
            notes <<-'END'
                浮点数，占用4字节 = 4 * 8bit，表示 1.175 * 10<sup>-38</sup> ~ 3.403 * 10<sup>-38</sup>
            END
        end
        entry do
            name 'double'
            notes <<-'END'
                浮点数，占用4字节 = 8 * 8bit，表示 2.225 * 10<sup>-308</sup> ~ 1.798 * 10<sup>308</sup>
            END
        end
        entry do
            name 'bool'
            notes <<-'END'
                布尔，占用1字节，表示 false / true
            END
        end
    end

    category do
        id '数字编码'

        entry do
            name '原码'
            notes <<-'END'
                将数字的二进制表示的最高位视为符号位，其中0表示正数，1表示负数，其余位表示数字的值。
            END
        end
        entry do
            name '反码'
            notes <<-'END'
                正数的反码与原码相同，负数的反码是对其原码除符号外的所有位取反。
            END
        end
        entry do
            name '补码'
            notes <<-'END'
                正数的补码与其原码相同，负数的补码是在其反码的基础上加1。
            END
        end
        entry do
            name '浮点数编码'
            notes <<-'END'
                根据 IEEE 754 标准，32-bit 长度的 float 由一下三个部分构成。

                - 符号位 S: 占 1 位，对应 b31
                - 符号为 E: 占 8 位，对应 b30b29...b23
                - 分数位 N: 占 23 位，对应 b22b21...b0
            END
        end
    end

    category do
        id '字符编码'

        entry do
            name 'ASCII 字符集'
            notes <<-'END'
                美国标准信息交换代码（American Standard Code for Information Interchange），最早出现的字符集，
                使用7位二进制表示一个字符，最多能够表示128个不同的字符。
                主要内容包括：英文字母大小写、数字0-9、一些标点符号，以及一些控制字符（如换行符和制表符）。

                但是其仅能表示**英文**。
            END
        end
        entry do
            name 'GBK 字符集'
            notes <<-'END'
                GBK 前身是 GB2312，由中国国家标准总局于 1980 年发布，其中收录了 6763 个汉字，满足计算机处理汉字的需要，但是其无法处理部分罕见字和繁体字。
                GBK 扩展至 21886 个汉字，其中对于 ASCII 字符使用一个字节表示，汉字使用两个字节表示。
            END
        end
        entry do
            name 'Unicode 字符集'
            notes <<-'END'
                这是一个能够容纳100多万个字符，将世界范围内的所有语言和符号都收录其中，以解决跨语言环境和乱码问题。
                其本质上是一种通用字符集，但是存在一个问题，那就是如何将字符进行编码，以便系统能够识别字符在 Unicode 字符集中的位置？
            END
        end
        entry do
            name 'UTF-8 编码'
            notes <<-'END'
                UTF-8 编码就是用来解决 Uncode 字符集的编码问题，它是一种可变长度的编码，使用1到4字节表示一个字符，根据字符的复杂性而变，
                其中 ASCII 使用1字节，拉丁字母和希腊字母需要2字节，常用的中文字符需要3字节，其他的一些生僻字需要4字节。
            END
        end
    end

    category do
        id '存储设备'

        entry do
            command '硬盘'
            name '长期存储数据，包括操作系统、程序、文件等'
        end
        entry do
            command '内存'
            name '临时存储当前运行的程序和正在处理的数据'
        end
        entry do
            command '缓存'
            name '存储经常访问的数据和指令，减少CPU访问内存的次数'
        end
    end

    category do
        id '性能因素'

        entry do
            name '负载因子'
            notes <<-'END'
                哈希表的元素数量处以桶数量，用于衡量哈希冲突的严重性。
                也常作为哈希冲突的触发条件。
                例如在 Java 中，当负载因子超过 0.75 时，系统会自动将哈希表扩容至原先的2倍。
            END
        end
        entry do
            name '哈希冲突'
            notes <<-'END'
                哈希函数的作用是将所有 key 构成的输入空间映射到数组所有索引构成的输出空间。
                而输入空间往往远大于输出空间，因此，理论上一定存在多个输入对象相同输出的情况， 
                这就是哈希冲突。
            END
        end
        entry do
            name '链式地址'
            notes <<-'END'
                通过将存在冲突的元素使用链表结构保存，键值作为链表的节点，来解决哈希冲突。
            END
        end
        entry do 
            name '开放寻址'
            notes <<-'END'
                开放寻址（open addressing）不引入额外的数据结构，而是通过多次探测来处理哈希冲突。
                探测方式主要通过线性探测、平方探测和多次哈希等。
            END
        end
        entry do
            name '线性探测'
            notes <<-'END'
                采用固定长的线性搜索来探测。
                插入元素：通过哈希函数计算桶索引，若发现桶内已有元素，则从冲突位置向后线性遍历（步长通常为1），直至找到空桶，将元素插入其中。
                查找元素：若发现哈希冲突，则使用相同步长向后线性遍历，直到找到对应元素，返回 value 即可。如果遇到空桶，说明目标元素不在哈希表中，返回 None。
            END
        end
        entry do
            name ''
            notes <<-'END'

            END
        end
        entry do
            name ''
            notes <<-'END'

            END
        end
    end
end