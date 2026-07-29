cheatsheet do
    title 'JVM 中文指南 TODO'
    docset_file_name 'Jvm'
    keyword 'jvm'
    source_url 'https://www.oracle.com/java/technologies/javase/vmoptions-jsp.html'

    category do
        id '行为选项'

        entry do
            command '-XX:-AllowUserSignalHandlers'
            name '如果应用程序安装了信号处理系统，请不要报错。仅限于 Solaris 和 Linux 系统'
        end
        entry do
            command '-XX:-DisableExplicitGC'
            name '启用 `System.gc()`，如果设置了 `-XX:+DisableExplicitGC` 则代表关闭'   
        end
        entry do
            command '-XX:PreBlockSpin=10'
            name '配合 -XX:+UseSpinning 的自旋计数变量，在进入操作系统线程同步代码前，允许的最大自旋数量'   
        end
        entry do
            command '-XX:+ScavengeBeforeFullGC'
            name '在进行 Full GC 之前务必进行一次年轻代 GC'   
        end
        entry do
            command '-XX:UseConcMarkSweepGC'
            name '为老年代启用并发标记的采集（Concurrent Mark-Sweep collection）'   
        end
        entry do
            command '-XX:UseGCOverheadLimit'
            name '使用策略限制虚拟机在跑出 OutOfMemory 错误之前用于 GC 的时间比例'   
        end
        entry do
            command '-XX:-UseParallelGC'
            name '使用并行垃圾收集进行垃圾回收'   
        end
        entry do
            command '-XX:-UseParallelOldGC'
            name '使用并行垃圾收集进行完整的垃圾回收，该选项会自动开启 -XX:-UseParallelGC'   
        end
        entry do
            command '-XX:-UseSerialGC'
            name '使用串行垃圾回收'   
        end
    end

    category do
        id 'G1 垃圾收集选项'

        entry do
            command '-XX:+UseG1GC'
            name '使用 G1 垃圾收集器'
        end
        entry do
            command '-XX:MaxGCPauseMillis=n'
            name '设置最大 GC 停顿时间，这是一个非强制设置，JVM 会尽力达成'
        end
        entry do
            command '-XX:InitiatingHeapOccupancyPercent=n'
            name '启动并发垃圾回收周期所需的堆内存占用百分比，此参数基于整个堆内存占用率，而非某一代内存占用率。值为 0 代表执行常量垃圾回收周期，默认为 45'
        end
        entry do
            command '-XX:NewRatio=n'
            name '老年代/新生代的大小比例，默认为 2'
        end
        entry do
            command '-XX:SurvivorRatio=n'
            name 'Eden/Survivor 的大小比例，默认为 8'
        end
        entry do
            command '-XX:MaxTenuringThreshold=n'
            name '任期门槛的最大值，默认为 15'
        end
        entry do
            command '-XX:ParallelGCThreads=n'
            name '设置用于垃圾收集的并行阶段的线程数量'
        end
        entry do
            command '-XX:ConcGCThreads=n'
            name '设置垃圾收集器将使用的线程数量'
        end
        entry do
            command '-XX:G1ReservePercent=n'
            name '设置预留的堆内存上限，以降低升级失败的可能性，默认为 10'
        end
        entry do
            command '-XX:G1HeapRegionSize=n'
            name 'G1 将 Java 堆内存划分为大小均匀的区域，此参数设置各个子区域的大小，默认值根据对大小合理确定，最小值为 1MB，最大值为 32MB'
        end
    end

    category do
        id '性能选项'

        entry do
            command ''
            name ''
        end
    end

    category do
        id '调试选项'

        entry do
            command '-XX:+AggressiveOpts'
            name '启用将在后续版本中默认启用的性能优化编译器优化'
        end
        entry do
            command '-XX:CompileThreshold=10000'
            name '编译前调用方法调用/分支的次数，[-client: 1500]'
        end
        entry do
            command '-XX:LargePageSizeInBytes=4m'
            name '设置用于Java堆的大页大小'
        end
        entry do
            command '-XX:MaxHeapFreeRatio=70'
            name 'GC 后堆内存剩余空间的最大百分比，以避免内存收缩'
        end
        entry do
            command '-XX:MaxNewSize=size'
            name '新生代的最大字节数'
        end
        entry do
            command '-XX:MaxPermSize=64m'
            name '永生代的大小'
        end
        entry do
            command '-XX:MinHeapFreeRatio=40'
            name 'GC 后堆内存剩余空间的最小百分比，以避免内存扩展'
        end
        entry do
            command '-XX:NewRatio=2'
            name ''
        end
        entry do
            command '-XX:NewSize=2m'
            name ''
        end
        entry do
            command '-XX:ReservedCodeCacheSize=32m'
            name ''
        end
        entry do
            command '-XX:SurvivorRatio=8'
            name ''
        end
        entry do
            command '-XX:TargetSurvivorRatio=50'
            name ''
        end
        entry do
            command '-XX:ThreadStackSize=512'
            name ''
        end
        entry do
            command '-XX:+UseBiasedLocking'
            name ''
        end
        entry do
            command '-XX:+UseFastAccessorMethods'
            name ''
        end
        entry do
            command '-XX:-UseISM'
            name ''
        end
        entry do
            command '-XX:+UseLargePages'
            name ''
        end
        entry do
            command '-XX:+UseMPSS'
            name ''
        end
        entry do
            command '-XX:+UseStringCache'
            name ''
        end
        entry do
            command '-XX:AllocatePrefetchLines=1'
            name ''
        end
        entry do
            command '-XX:AllocatePrefetchStyle=1'
            name ''
        end
        entry do
            command '-XX:+UseCompressedStrings'
            name ''
        end
        entry do
            command '-XX:+OptimizeStringConcat'
            name ''
        end
    end

    category do
        id '调试选项'

        entry do
            command ''
            name ''
        end
        entry do
            command ''
            name ''
        end
        entry do
            command ''
            name ''
        end
        entry do
            command ''
            name ''
        end
        entry do
            command ''
            name ''
        end
        entry do
            command ''
            name ''
        end
        entry do
            command ''
            name ''
        end
        entry do
            command ''
            name ''
        end
        entry do
            command ''
            name ''
        end
        entry do
            command ''
            name ''
        end
        entry do
            command ''
            name ''
        end
        entry do
            command ''
            name ''
        end
        entry do
            command ''
            name ''
        end
        entry do
            command ''
            name ''
        end
    end
end