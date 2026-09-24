cheatsheet do
    title ''
    docset_file_name ''
    keyword ''

    category do
        id '查看数据'

        entry do
            command '<metric_name>'
            name '查看最近统计的数值'
        end
        entry do
            command '<metric_name> offset <time>'
            name '查看往前推 <time> 的时间点的值'
        end
        entry do
            command '<metric_name>[<time>]'
            name '查看当前时间往前time至当前时间的区间内值'
        end
        entry do
            command 'max_over_time(<metric_name>[<time>])'
            name '查看当前时间往前time至当前时间的区间内最大值'
        end
        entry do
            command 'min_over_time(<metric_name>[<time>])'
            name '查看当前时间往前time至当前时间的区间内最大值'
        end
        entry do
            command 'avg_over_time(<metric_name>[<time>])'
            name '查看当前时间往前time至当前时间的区间内平均值'
        end
        entry do
            command '<metric_name>{<label>=~"value1|value2"}'
            name '查看同一指标的同一标签的多个值'
        end
    end
end