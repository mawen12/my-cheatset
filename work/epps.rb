cheatsheet do
    title ''
    docset_file_name ''
    keyword ''
    
    category do
        id '支付层'

        entry do
            command '000401'
            name '贷记异步汇总额度管控查询/修改接口'
        end
        entry do
            command '000402'
            name '商户提现银联汇总记账明细查询接口'
        end
        entry do
            command '000403'
            name '商户提现银联汇总记账明细状态修改接口'
        end
        entry do
            command '830601'
            name '银联快捷支付签到接口'
        end
        entry do
            command '830602'
            name '银联快捷支付签退接口'
        end
        entry do
            command '830603'
            name '银联快捷支付退货接口'
        end
        entry do
            command '830604'
            name '银联快捷支付查证接口'
        end
        entry do
            command '830605'
            name '银联快捷支付借记终态通知'
        end
        entry do
            command '830606'
            name '银联快捷支付贷记终态通知'
        end
        entry do
            command '830608'
            name '银联协议支付签约触发短信'
        end
        entry do
            command '830609'
            name '银联协议支付签约接口'
        end
        entry do
            command '830610'
            name '银联协议支付解约接口'
        end
        entry do
            command '830611'
            name '银联协议支付接口'
        end
        entry do
            command '830690'
            name '银联快捷支付查证接口'
        end
        entry do
            command '880704'
            name '云闪付转账接口'
        end
        entry do
            command '920927'
            name ''
        end
        entry do
            command '960005'
            name '上游通知通道状态接口'
        end
        entry do
            command '970143'
            name '银联无跳转签约开通异步通知'
        end
        entry do
            command '970280'
            name '银联转发委托解除关系通知'
        end
        entry do
            command '970285'
            name '商户信贷还款签约触发短信'
        end
        entry do
            command '970286'
            name '商户信贷还款签约'
        end
        entry do
            command '970287'
            name '商户信贷还款解除签约关系'
        end
        entry do
            command '970288'
            name '商户信贷还款获取对账文件'
        end
        entry do
            command '970317'
            name '银联无跳转异步通知'
        end
        entry do
            command '970377'
            name '商户侧银联无跳转异步通知'
        end
        entry do
            command '970646'
            name '对公贷记对外输出接口订单查询'
        end
        entry do
            command '970647'
            name '对公贷记对外输出接口渠道查询'
        end
        entry do
            command '971331'
            name '银联订单支付订单受理'
        end
        entry do
            command '971332'
            name '银联订单支付订单取消'
        end
        entry do
            command '971333'
            name '银联订单支付订单状态查询'
        end
        entry do
            command '971341'
            name '订单支付（受理侧->EGS）接口'
        end
        entry do
            command '971342'
            name '订单支付取消（受理侧->EGS）接口'
        end
        entry do
            command '971343'
            name '订单支付查询（受理侧->EGS）接口'
        end
        entry do
            command '971344'
            name '订单支付交易状态通知接口'
        end
        entry do
            command '971346'
            name '订单支付受理侧订单状态通知商户接口'
        end
        entry do
            command '971347'
            name '订单支付商户信息配置接口'
        end
        entry do
            command '971348'
            name '商户信息配置查询接口'
        end
        entry do
            command '971351'
            name '银联订单支付账户侧 渠道查询账户订单支付交易明细'
        end
        entry do
            command '971352'
            name '银联订单支付账户侧授权支付'
        end
        entry do
            command '977899'
            name '行内发短信入口'
        end
        entry do
            command '980219'
            name '支付冲正接口'
        end
        entry do
            command '980281'
            name '手机银行充值交易'
        end
        entry do
            command '980285'
            name '小程序网贷还款'
        end
        entry do
            command '980288'
            name '商户信贷还款'
        end
        entry do
            command '980289'
            name '商户信贷还款退款'
        end
        entry do
            command '980290'
            name '商户信贷还款交易查询'
        end
        entry do
            command '980291'
            name '单笔代付接口'
            notes <<-'END'
                EsbAction.handle
                ↓
                T980291Service.action
                ↓
                OrdersMapper.selectList (订单防重)
                ↓
                UppsParamManager.getHvpsBankNo (行内转账检查)
                ↓
                ChannelRouteManager.getCreditChannels (路由试算) 
                ↓ channelName in (32000080711001 | 32000080711002 | 32000000008218)     ↓ channelName = nil         ↓ 
                detailChannel = ''                                                      detailChannel = '989041'    detailChannel = '989041' && SystemParamMapper.selectList
                ↓ 城商行                        ↓ 城商行
                processCbps1
                ↓
                sendToChannel (发资金通道)      


                
                | 通道层交易码 | 用途 | 对账交易 | 内部户对账 |
                | --- | --- | --- | --- |
                | 988221 | 江苏银联代付通道R0（快赎） | | |
                | 988222 | 江苏银联代付通道R0（快赎）查证 | | |
                | 980780 |  | | |
                | 989657 | 银联对私贷记通道R0 | | |
                | 989658 | 银联对私贷记通道R0查证 | | |
                | 989659 |  | | |
                | 988541 | 银联对公贷记通道R0 | | |
                | 988542 | 银联对公贷记通道R0查证 | | |
                | 710001 | 统一支付通道 | | |
                | 720031 | 统一支付通道查证 | | |
                | 720001 | 网联贷记通道 | | |
                | 720032 | 网联贷记通道查证 | | |
                | 989656 | 城商行贷记通道 | | |
                | 989660 | 城商行（直连）实时贷记查证 | | |
                | 989041 | 核心7641接口 | | |
                | 988129 | CBS核心系统查证 | | |
                | 991054 | 核心7665接口 | | |
                
            END
        end
        entry do
            command '980292'
            name '单笔代收接口'
        end
        entry do
            command '980293'
            name '单笔退款接口'
        end
        entry do
            command '980294'
            name '交易结果查询接口'
        end
        entry do
            command '980297'
            name ''
        end
        entry do
            command '980298'
            name ''
        end
        entry do
            command '980301'
            name '入账信息接口'
        end
        entry do
            command '980302'
            name '账户侧入账信息接口'
        end
        entry do
            command '980303'
            name '入账状态查询接口'
        end
        entry do
            command '980305'
            name ''
        end
        entry do
            command '980306'
            name ''
        end
        entry do
            command '980330'
            name ''
        end
        entry do
            command '980397'
            name '银联贷记业务退汇核心记账'
        end
        entry do
            command '980780'
            name '江苏银联代付-全渠道异步通知接口'
        end
        entry do
            command '980781'
            name '银联代收异步通知接口'
        end
        entry do
            command '980782'
            name '银联批量代收异步通知接口'
        end
        entry do
            command '980783'
            name '接受银联批量代收异步通知接口'
        end
        entry do
            command '980800'
            name '银行卡鉴权'
        end
        entry do
            command '981300'
            name '统一支付多通道合并'
        end
        entry do
            command '982203'
            name '贷记路由试算交易接口'
        end
        entry do
            command '982301'
            name '贷款还款接口'
        end
        entry do
            command '989557'
            name '网贷签约查询'
        end
        entry do
            command '989558'
            name '网贷签约发短信接口'
        end
        entry do
            command '989559'
            name '网贷签约接口'
        end
        entry do
            command '989570'
            name '签约查询接口'
        end
        entry do
            command '989571'
            name '签约发短信接口'
        end
        entry do
            command '989572'
            name '签约接口'
        end
        entry do
            command '989573'
            name '支付发短信接口'
        end
        entry do
            command '989574'
            name '查询手机银行资金归集计划'
        end
        entry do
            command '989575'
            name '开通、修改手机银行资金归集计划'
        end
        entry do
            command '989576'
            name '客户资金归集交易明细及汇总金额查询'
        end
        entry do
            command '989659'
            name '江苏银联对私贷记异步通知接口'
        end
        entry do
            command '989905'
            name '江苏银联入账信息异步通知接口'
        end
        entry do
            command '990281'
            name '手机银行资金归集代扣入金'
        end
        entry do
            command '990292'
            name '批量代收商户上传交易文件'
        end
        entry do
            command '990294'
            name '批量代收交易状态查询'
        end
        entry do
            command '990295'
            name '批量代收通知商户'
        end
    end

    category do
        id '查询层'

        entry do
            command '988550'
            name '银联单笔代收整笔（通道层）查证'
            notes <<-'END'

                EsbAction.handle
                ↓
                T988550Service.action
                ↓
                CapitalSerialManager.selectListByCapitalId
                │ capitalSerial.transState != 8 (非处理中)
                │ and capitalSerial.queryNum > 0 (剩余可用的查证次数)
                ↓ and capitalSerial.transDate + capitalSerial.transTime > now + 1hour (距离查证时间已经过了1小时)
                T988550Service.process
                ↓
                T988550Service.lookup → T988550Service.sendToEgs988550
                ↓
                T988550Service.dblookup → CapitalSerialManager.count
            END
        end
        entry do
            command '988554'
            name '单笔代收支付层查证交易'
            notes <<-'END'

                EsbAction.handle
                ↓
                T988554Service.action
                ↓
                OrdersManager.selectOneByPrimaryKey
                ↓ order.orderStatus == 2 (处理中)
                CapitalSerialManager.selectByFrontCapitalSerial
                ↓ capitalSerial.transState != 8 (非处理中) or capitalSerial == nil
                OrdersManager.updateByKeyAndStatus
            END
        end
        entry do
            command '989602'
            name '一键查卡'
            notes <<-'END'
                根据传递的用户信息，查询用户名下银行卡

                EsbAction.handle
                ↓
                T989602Service.action
                ↓
                AsyncService.asyncAllList
                ↓ thread-1                      ↓ thread-2                      ↓ thread-3
                CoreChannelManager.sendQ734     CoreChanneManager.send5883      CPPChannelManager.sendDH012  
                ↓                               ↓                               ↓
                EcifChannelManager.send0265     CPPChannelManager.send5810      CPPChannelManager.sendDH008
                └───────────────────────────────┴───────────────────────────────┘
            END
        end
    end

    category do
        id '路由试算，本质是获取 channelName'

        entry do
            name '代码处理'
            notes <<-'END'
                EsbAction.handle
                ↓
                TxxxService.action
                ↓
                TranscodeChannelRelManager.list
                ↓
                ChannelCapitalChannelManager.list
                ↓
                CapitalChannelManager.selectByCapitalChannelId 
            END
        end
        entry do
            name '交易码定位资金通道，即交易渠道关系'
            notes <<-'END'
                ```sql
                -- 存在 1对多 映射关系，且使用 extfld1 来维护匹配规则
                SELECT transcode,capital_channel_id,extfld1 FROM TRANSCODE_CHANNEL_REL WHERE transcode = ?
                ```
            END
        end
        entry do
            name 'BUSINESS_ID 映射 channelNo'
            notes <<-'END'
                ```markdown
                | BUSIESS_ID | ChannelNo |
                | --- | --- |
                | 110 | a |
                | 870 | w |
                | 876 | d |
                | 482 | b |
                | 873 | y |
                | 690 | e |
                | 871 | k |
                | 487 | h |
                | 869 | 5 |
                ```
            END
        end
        entry do
            name '交易渠道+资金通道过滤，即资金通道与渠道关系'
            notes <<-'END'
                ```sql
                SELECT * FROM CHANNEL_CAPITALCHANNEL WHERE (captial_channel_id = ? AND channelno = ?); -- 0 
                ```
            END
        end
    end
end