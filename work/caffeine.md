# 主页

Caffine 是一个高性能的 Java 缓存库，可提供接近最优的命中率。

`Cache` 与 `ConcurrentMap` 类似，但并不完全相同。最根本的区别在于，`ConcurrentMap` 会持久化添加到其中的元素，直到被显式删除。而 `Cache` 通常会配置为自动驱逐条目，以限制其内存占用。在某些情况下，即使加载缓存（LoadingCache）或异步加载缓存（AsyncLoadingCache）不驱逐条目，它们也能发挥作用，因为它们具备自动缓存加载的功能。

Caffine 提供灵活的结构，可结合以下可选功能创建缓存：
- 自动将条目加载到缓存中，可选择异步加载
- 当超过基于频率和最近发生时间设定的最大值时，按大小进行驱逐
- 基于时间的条目过期时间，从上次访问或上次写入开始计算
- 当首次出现过期的条目请求时，异步刷新
- 键会自动包装在弱引用中
- 值会自动包装在弱引用或软引用中
- 驱逐（或以其他范式移除）条目的通知
- 写入操作传播到外部资源
- 缓存访问统计信息的累积

为了提升集成度，我们在扩展模块中提供了 `JSR-107 JCache` 和 `Guava` 适配器。`JSR-107` 标准化了一个基于 Java 6 的 API，旨在最大限度地减少厂商特定的代码，但代价是牺牲了一些功能和性能。`Guava` 的 `Cache` 是 `JSR-107` 的前身库，这些适配器提供了一种简便的迁移策略。示例部分提供了与其他库的集成示例。

欢迎贡献代码。请阅读设计文档、开发者设置指南和路线图。




# 缓存



## 填充

Caffeine 提供了四种类型的填充策略：手动、同步加载和异步变体。

### 手动

```java
Cache<Key, Graph> cache = Caffeine.newBuilder()
	.expireAfterWrite(20, TimeUnit.MINUTES)
	.maximumSize(10_000)
	.build();
	
// 查找条目，如果没有找到则返回 null
Graph graph = cache.getIfPresent(key);
// 如果条目不存在，则查找并计算该条目；如果无法计算，则返回 null
graph = cahce.get(key, k -> createExpensiveGraph(key));
// 插入或更新条目
cache.put(key, graph);
// 移除一个条目
cache.invalidate(key);
```

`Cache` 接口允许对检索、更新和使条目失效进行显示控制。

建议使用 `cache.get(key, k -> value)` 来原子地计算并插入缓冲中对应的值（如果缓存中不存在该值），否则返回缓存中已有的值。`cache.put(key, value)` 可以直接插入或更新条目，覆盖指定键对应的任何先前值。请注意，如果该条目无法计算，`cache.get` 可能会返回 `null`；如果计算失败，则会抛出异常。

也可以使用 `Cache.asMap()` 视图公开任何 `ConcurrentMap` 方法对缓存进行更改。

### Loading

```java
LoadingCache<Key, Graph> cache = Caffeine.newBuilder()
	.maximumSize(10_000)
	.expireAfterWrite(10, TimeUnit.MINUTES)
	.build(key -> createExpensiveGraph(key));
	
// 如果条目不存在，则查找并计算该条目；如果无法计算，则返回 null
Graph graph = cache.get(key);
// 查询并计算不存在的条目
Map<Key, Graph> graphs = cache.getAll(keys);
```

`LoadingCache` 是带有附加 `CacheLoader` 的 `Cache`。

可以使用 `getAll` 方法进行批量查找。默认情况下，`getAll` 会对缓存中不存在的每个键单独调用 `CacheLoder.load`。当批量检索比多次单独查找更高效时，你可以重写 `CacheLoader.loadAll` 方法来利用这一点。

请注意，你可以编写一个 `CacheLoader.loadAll` 实现，用于加载未被明确请求的键的值。例如，如果计算某个键组中任意键的值会得到该组中所有键的值，则 `loadAll` 可以同时加载该组中的值。

### 异步手动

```java
AsyncCache<Key, Graph> cache = Caffeine.newBuilder()
	.expireAfterWrite(10, TimeUnit.MINUTES)
	.maximumSize(10_000)
	.buildAsync();
	
// 查找条目，如果没有找到则返回 null
CompletableFuture<Graph> graph = cache.getIfPresent(key);
// 如果条目不存在，则查找并计算该条目；如果无法计算，则返回 null
graph = cahce.get(key, k -> createExpensiveGraph(key));
// 插入或更新条目
cache.put(key, graph);
// 移除一个条目
cache.synchronous().invalidate(key);
```

`AsyncCache` 是一种 `Cache` 变体，它在 `Executor` 上计算条目并返回一个  `CompletableFuture`。这使得缓存能够与流行的响应式编程模型结合使用。

`synchronous()` 视图提供了一个 `Cache`，其会阻塞，直到异步计算完成。

也可以使用 `AsyncCache.asMap()` 视图公开的任何 `ConcurrentMap` 方法对缓存进行更改。

默认执行器为  `ForkJoinPool.commonPool()`，可通过 `Caffeine.executor(Executor)` 进行覆盖。

### 异步 Loading

```java
AsyncLoadingCache<Key, Graph> cache = Caffeine.newBuilder()
	.maximumSize(10_000)
	.expireWriteAfter(10, TimeUnit.MINUTES)
	// 另一种方法：使用同步计算构建，然后将其包装成异步计算
	.buildAsync(key -> createExpensiveGraph(key));
	// 或者，使用返回 future 的异步计算来构建
	.buildAsync((key, executor) -> createExpensiveGraph(key, executor));
	
// 如果不存在，则查找并通过异步计算条目
CompletableFuture<Graph>  graph  = cache.get(key);
// 查找并异步计算不存在的条目
CompletableFuture<Map<Key, Graph>>  graph  = cache.getAll(keys);
```

`AsyncLoadingCache` 是一个带有附加 `AsyncCacheLoader` 的 `AsyncCache`。

当计算最好以同步方式实现时，应提供 `CacheLoader`。相反，当计算以异步方式实现并返回 `CompletableFutrue` 是， 应提供 `AsyncCacheLoader`。

可以使用 `getAll` 方式执行批量查找。默认情况下，`getAll` 会对缓存中不存在的每个键单独调用 `AsyncCacheLoader.asyncLoad`。当批量检索比多次单独查找更高效时，你可以重写 `AsyncCacheLoader.asyncLoadAll` 。

请注意，你可以编写一个 `AsyncCacheLoader.asyncLoadAll` 实现，用于加载未被明确请求的键的值。例如，如果计算某个组中任意键的值会得到该组中所有键的值，则 `asyncLoadAll` 可以同时加载该组中的其余键。



## 驱逐

Caffeine 提供三种类型的驱逐：基于大小的驱逐、基于时间的驱逐和 基于引用的驱逐。

### 基于大小

```java
// 根据缓存条目数进行驱逐
LoadingCache<Key, Graph> cache = Caffeine.newBuilder()
	.maximumSize(10_000)
	.build(key -> createExpensiveGraph(key));
	
// 根据缓存中顶点数量进行驱逐
LoadingCache<Key, Graph> cache = Caffeine.newBuilder()
	.maximumWeight(10_000)
	.weigher((Key key, Graph graph) -> graph.vertices().size())
	.build(key -> createExpensiveGraph(key));
```

如果你的缓存大小不应超过特定限制，请使用 `Caffeine.maximumSize(long)`。缓存会尝试清除近期未使用或使用频率很低的条目。

或者，如果不同的缓存条目具有不同的权重（例如，如果你的缓存值占用的内存量差异很大），你可以使用 `Caffeine.maximumWeight(long)`  指定最大缓存权重。除了与 `maximumSize` 相同的注意事项外，还要注意权重是在创建和更新条目时计算的，之后保持不变，并且在进行驱逐选择时不会使用相对权重。

### 基于时间

```java
// 根据固定到期策略进行驱逐
LoadingCache<Key, Graph> cache = Caffeine.newBuilder()
	.expireAfterAccess(5, TimeUnit.MINUTES)
	.build(key -> createExpensiveGraph(key));
LoadingCache<Key, Graph> cache = Caffeine.newBuilder()
	.expireAfterWrite(10, TimeUnit.MINUTES)
	.build(key -> createExpensiveGraph(key));

// 根据不同的到期策略进行驱逐
LoadingCache<Key, Graph> cache = Caffeine.newBuilder()
	.expireAfter(Expiry.creating((Key key, Graph graph) -> 
		Duration.between(Instant.now(), graph.creationDate().plusHours()5)))
	.build(key -> createExpensiveGraph(key));
```

Caffeine 提供了三种定时驱逐策略：
- `expireAfterAccess(long, TimeUnit)`: 在条目自上次被读取或写入以来经过了指定的时间后，使其过期。如果缓存数据绑定到会话因不活动而过期，则此功能非常有用。
- `expireAfterWrite(long, TimeUnit)`: 在条目创建或最近一次值替换后经过指定时间后，使其过期。 如果缓存数据在一段时间后变得陈旧，则此功能非常有用。
- `expireAfter(Expiry)`: 指定持续时间后，条目将过期。如果条目的失效时间由外部资源决定，则此功能非常有用。

过期操作会在写入期间定时维护，偶尔也会在读取期间进行维护。过期事件的调度和触发在均摊 O(1) 时间内完成。

为了实现缓存 及时过期，与其依赖其他缓存活动来触发例行维护，不如使用 `Scheduler` 接口和 `Caffeine.scheduler(Scheduler)` 方法在缓存构建器中指定一个调度线程。Java 9 及更高版本的用户可能更倾向于使用 `Scheduler.systemScheduler()` 来利用专用的系统级调度线程。

测试定时驱逐策略并不需要等到系统时钟时间结束。你可以使用 `Ticker` 接口和 `Caffeine.ticker(Ticker)` 方法在缓存构建器中指定时间源，而无需等待系统时钟。Guava 的测试库为此提供额一个方便的 `FakeTicker`。

### 基于引用

```java
// 当键和值都不是强可达时，驱逐该键或值
LoadingCache<Key, Graph> cache = Caffeine.newBuilder()
	.weakKeys()
	.weakValues()
	.build(key -> createExpensiveGraph(key));

// 当垃圾回收器需要释放内存时，将其驱逐
LoadingCache<Key, Graph> cache = Caffeine.newBuilder()
	.softValues()
	.build(key -> createExpensiveGraph(key));
```

Caffeine 允许你通过对键或值使用弱引用，对值使用软引用，来设置缓存以启用条目的垃圾回收。请注意，`AsyncCache` 不支持弱引用和软引用。

`Caffeine.weakKeys()` 使用弱引用存储键。这样，如果没有其他强引用指向这些键，就可以对条目进行垃圾回收。由于垃圾回收依赖于恒等性，因此整个缓存都会使用恒等性（==）来比较键，而不是使用 `equals`。

`Caffeine.weakValues()` 使用弱引用存储值。这样，如果没有其他强引用指向这些值，就可以对条目进行垃圾回收。由于垃圾回收依赖于恒等性，因此整个缓存都会使用恒等性（==）来比较值，而不是使用 `equals`。

`Caffeine.softValues()` 使用软引用存储值。软引用的对象会根据内存需求，以全局最近最少使用（LRU）的方式进行垃圾回收。由于使用软引用会影响性能，我们通常建议使用更可预测的最大缓存大小。使用 `softValues()` 会导致值之间的比较使用恒等运算符 `==` 而不是 `equals()`。



## 移除

术语：
- **eviction** 意味着因策略原因而被移除
- **invalidation** 意味着由调用方手动删除
- **removal** 是由于无效或驱逐造成的

### 显式移除

你可以随时显式地使缓存条目失效 ，而无需等待条目被清除。
```java
// 单个 key
cache.invalidate(key);
// 多个 key
cache.invalidateAll(keys);
// 全部 key
cache.invalidateAll();
```

### 移除监听器

```java
Cache<Key, Graph> cache = Caffeine.newBuilder()
	.evictionListener((Key key, Graph graph, RemovalCause cause) -> 
		System.out.printf("Key %s was evicted (%s)%n", key, cause))
	.removealListener((Key key, Graph graph, RemovalCause cause) -> 
		System.out.printf("Key %s was removed (%s)%n", key, cause))
	.build();
```

你可以通过 `Caffeine.removalListener(RemovalListener)` 为缓存指定一个移除监听器，以便在条目被移除时执行某些操作。这些操作使用 `Executor` 异步执行，默认的 Executor 是 `ForkJoinPool.commonPool()`，你可以通过 `Caffeine.executor(Executor)` 覆盖其他 Executor。

当操作必须与驱逐同步执行时，请该用 `Caffeine.evictionListener(RemovalListener)`。此监听器仅在 `RemovalCause.wasEvicted()` 为真时才会收到通知。对于显式移除操作，`Cache.asMap()` 提供了原子执行的计算方法。

请注意，`RemovalListener` 抛出的任何异常都会被记录（使用 `System.Logger`）并被忽略。



## 刷新

```java
LoadingCache<Key, Graph> cache = Caffeine.newBuilder()
	.maximumSize(10_000)
	.expireAfterWrite(Duration.ofMinutes(5))
	.refreshAfterWrite(Duration.ofMinutes(1))
	.build(key -> createExpensiveGraph(key));
```

刷新与驱逐并不完全相同。如 `LoadingCache.refresh(K)` 中所述，刷新键会异步加载该键的新值。在刷新键期间，旧值（如果有）仍然会被返回，这与驱逐不同，驱逐会强制检索操作等待新值加载完成。

与 `expireAfterWrite` 不同，`refreshAfterWrite` 会在指定的时间段后使键符合刷新条件 。例如，你可以再同一缓存中同时指定 `refreshAfterWrite` 和 `expireAfterWrite`，这样就不会在条目符合刷新条件时盲目重置其过期计时器。如果条目在符合刷新条件后未被查询，则允许其过期。

`CacheLoader`  可以通过重写 `CacheLoader.reload(K, V)` 来指定刷新时使用的智能行为，从而允许在计算新值时使用旧值。`coalescing-bulkloader-reactor` 示例演示了如何使用 `Reactor` 将多次重新加载累积到一个批处理请求中。



## 计算 

```
Cache<Key, Graph> cache = Caffeine.newBuilder()
	.evictionListener((Key key, Graph graph, RemovalCause cause) -> {
		// 原子性地拦截入口的驱逐	
	})
	.build();
	
cache.asMap().compute(key, (k, v) -> {
	Graph  graph = createExpensiveGraph(key);
	// 更新二级存储
	return graph;
});
```

Caffeine 为复杂的流程提供了扩展点，这些流程需要外部资源来观察给定键的更改顺序。对于手动操作，Map `compute` 方法允许在原子操作中执行逻辑，例如创建、更新或删除条目。当条目被自动删除时，`EvictionListener` 会扩展 Map `compute` 以执行自定义逻辑，这类条目操作意味着将阻止对该条目的后续修改操作 ，读取操作将返回先前的值，直到写入完成。

### 可能的应用场景

#### 写模式

计算可用于实现 `write-through` 或 `write-back` 模式缓存。

在 `write-through` 缓存中，操作是同步执行的，只有当写入操作完成后，缓存才会更新。这避免了资源和缓存作为独立原子操作进行更新时可能出现的竞争条件。

在 `write-back` 缓存中，对外部资源的操作是在缓存更新后异步执行的。这提高了写入吞吐量，但存在数据不一致的风险。例如，如果写入失败，缓存中可能会残留无效状态。这种方法可用于将写入操作延迟到特定时间、限制写入速率或批量执行写入操作。

`write-back` 扩展可以实现以下部分或全部功能：
- 批量处理和合并操作
- 将操作推迟到特定时间窗口
- 如果批次大小超过阈值，则在定期冲洗之前执行批次操作
- 如果操作尚未刷新，则从 `write-behind` 缓冲区加载数据
- 根据外部资源的特性处理重试、速率限制和并发问题

有关使用 `RxJava` 的简单示例，请参阅 `write-behind-rxjava`。

#### 分层

分层缓存从外部缓存加载和写入数据，该外部缓存由记录系统提供支持。这样就允许使用小型快速缓存，并在需要时回退到速度较慢的大型缓存。典型的缓存层包括堆外缓存、文件缓存和远程缓存。

受害者缓存是一种分层变体，其中被驱逐的条目会被写入辅助缓存。`EvictionListener` 的 `RemovalCause` 参数允许检查条目被移除的原因并做出相应的反应。

#### 同步监听器

同步监听器按照给定键的缓存操作发生的顺序接受事件通知。监听器可以阻塞缓存操作，也可以将事件排队等待异步执行。这种类型的监听器最常用于数据复制或构建分布式缓存。



## Interner

```java
Interner<String> interner = Interner.newStrongInterner();
String s1 = interner.intern(new String("value"));
String s2 = interner.intern(new String("value"));
assert s1 == s2;
```

`Interner` 对象返回给定元素的规范标识。当调用 `intern(e)` 方法时，如果 `interner` 对象中已经存在一个相等的实例（由 Object.equals 方法判断），则返回该实例。否则，将当前对象添加到 `interner` 对象中，并返回该实例。这种去重机制通常用于通过共享规范实例来减少内存使用。

```java
LoadingCache<Key, Graph> cache = Caffeine.newBuilder()
	.weakKeys()
	.build(key -> createExpensiveGraph(key));
Interner<Key> interner = Interner.newWeakInterner();

Key canonical = interner.intern(key);
Graph graph = cache.get(key);
```

`weak interner` 允许在不再有任何强引用指向被引用对象后，将其进行垃圾回收。这与 `Caffeine.weakKeys()` 不同，后者使用恒等比较（==）来比较键，而不是 `equals()`。可以通过缓存被引用键的值，并确保应用程序保留对该规范实例的强引用，来结合这两种方法。否则，如果缓存支持弱键的引用相等性，那么应用程序很可能会持有与映射所使用的键实例不同的实例，从而导致垃圾回收器过早地清除缓存条目。



## 统计数据

```
Cache<Key, Graph> cache = Caffeine.newBuilder()
	.maximumSize(10_000)
	.recordStats()
	.build();
```

通过使用 `Caffeine.recordStats()`， 你可以启用统计信息收集。`Cache.stats()` 方法返回一个 `CacheStats` 对象，其中包含诸如以下统计信息：
- `hitRate()`: 返回命中次数与请求次数的比例
- `evictionCount()`: 缓存驱逐的总数
- `averageLoadPenalty()`: 加载 新值所花费的平均时间

这些统计数据对于缓存调优至关重要，我们建议在对性能要求极高的应用程序中密切关注这些统计数据。

缓存统计信息可以通过拉取或推送的方式集成到报告系统中。拉取方式会定期调用 `Cache.stats()` 并记录最新的快照。推送方式则提供一个自定义的 `StatsCounter`，以便在缓存操作期间直接更新指标。

如果使用 `Dropwizard Metrics`，请参阅 `metrics-caffeine`。
如果使用 `Prometheus`，请参阅 `prometheus-java`。
不知道选哪个？请试试 `Micrometer` 集成。



## 规范

```java
CaffeineSpec spec = CaffeineSpec.parse(
	"maximumSize=1000, expireAfterWrite=10m, recordStats");
LoadingCache<Key, Graph> cache = Caffeine.from(spec)
	.weigher((Key key, Graph graph) -> graph.vertices().size())
	.build(key -> createExpensiveGraph(key));
```

`CaffeineSpec` 支持将简单的配置格式解析为 `Caffeine` 构建器。字符串语法是一些列以逗号分割的键或键值对。每个键或键值对对应一个构建方法。此格式不支持配置带有对象参数的构建器方法，例如 `removalListener`，这些方法必须在代码中配置。

该格式支持以下构建器方法。禁止将 `maximumSize` 与 `maximumWeight` 结合使用，也不允许将 `weakValues` 与 `sortValues` 结合使用。
- initialCapacity=[integer]: 设置 `Caffeine.initialCapacity`
- maximumSize=[long]: 设置 `Caffeine.maximumSize`
- maximumWeight=[long]: 设置 `Caffeine.maximumWeight`
- expireAfterAccess=[duration]:  设置 `Caffeine.expireAfterAccess`
- expireAfterWrite=[duration]: 设置 `Caffeine.expireAfterWrite`
- refreshAfterWrite=[duration]: 设置 `Caffeine.refreshAfterWrite`
- weakKeys: 设置 `Caffeine.weakKeys`
- weakValues: 设置 `Caffeine.weakValues`
- softValues: 设置 `Caffeine.softValues`
- recordStats: 设置 `Caffeine.recordStats`

持续时间可以使用一个整数后跟 "d"、"h"、"m" 或 "s" 之一来表示。分别代表天、小时、分钟或秒。或者，也可以提供给你 ISO-8601 格式字符串，该字符串由 `Duration.parse` 解析。出于缓存的目的，不支持负持续时间，否则会抛出异常。以下是两种格式的一些示例：

| 简单 | ISO-8601 | 描述 |
| --- | --- | --- |
| 50s | PT50S | 50 秒 |
| 11m | PT11M | 11 分钟 |
| 6h | PT6H | 6 小时 |
| 3d | P3D | 3 天 |
|  | P3DT3H4M | 3 天 3小时 4分钟 |
|  | -PT7H3M | -7 小时 -3 分钟（不支持） |



## 清理

默认情况下，Caffeine 不会在值过期后自动或立即执行清理和移除操作。相反，它会在写入操作后执行少量维护工作，或者在写入操作较少的情况下，偶尔在读取操作后执行维护工作。如果你的缓存吞吐量很高，则无需担心执行缓存维护来清理过期条目等操作，如果你的缓存读写操作很少，你可能希望利用如下所述的外部线程，再适当的时候调用 `Cache.cleanup()`。

```java
LoadingCache<Key, Graph> cache = Caffeine.newBuilder()
	.scheduler(Scheduler.systemScheduler())
	.expireAfterWrite(10, TimeUnit.MINUTES)
	.build(key -> createExpensiveGraph(key));
```

可以提供一个 `Scheduler`，以便及时删除过期条目。过期事件之间的调度会根据批处理情况进行调整，以尽量减少短时间内连续执行的操作。调度是尽力而为的，并不保证何时会删除过期条目。Java 9 及更高版本的用户可能倾向于使用 `Scheduler.systemScheduler()` 来利用专用的系统级调度线程。

```java
Cache<Key, Graph> caches = Caffeine.newBuilder().weakValues().build();
Cleaner cleaner = Cleaner.create();

cleaner.register(cache, caches::cleanUp);
cache.put(key, graph);
```

在 Java 9 及更高版本中，可以使用 `Cleaner` 来快速删除基于引用的条目（如果使用了 weakKeys、weakValues 或 softValues）。只需将键或值注册到 `Cleaner` 中，然后运行操作调用 `Cache.cleanUp()` 来触发维护例程即可。



## 策略

缓存支持的策略在构建时就已确定。运行时可以检查和调整此配置。策略是通过一个可选参数获取的，该参数指示缓存是否支持该功能。

### 基于大小

```java
cache.policy().eviction().ifPresent(eviction -> {
	eviction.setMaximum(2 * eviction.getMaximum());
});
```

如果缓存的权重有限制，则可以使用 `weightedSize()` 获取当前权重。这与 `Cache.estimatedSize()`不同，后者返回的是缓存条目的数量。

可以通过 `getMaximum()` 读取最大大小或权重，并使用 `setMaxmimum(long)` 进行调整。缓存会不断被驱逐 ，直到其大小会权重符合新的阈值。

如果需要保留或驱逐最有可能的条目子集，`hottest(int)` 和 `coldest(int)` 方法可以提供条目的有序快照。

### 基于时间

```java
cache.policy().expireAfterAccess().ifPresent(expiration -> ...);
cache.policy().expireAfterWrite().ifPresent(expiration -> ...);
cache.policy().expireVariably().ifPresent(expiration -> ...);
cache.policy().refreshAfterWrite().ifPresent(expiration -> ...);
```

`ageOf(key, TimeUnit)` 函数提供了从 `expireAfterAccess`、`expireAfterWrite` 或 `refreshAfterWrite` 策略的角度来看，条目已闲置的时间。最大空闲时间可以通过 `getExpiresAfter(TimeUnit)` 函数读取，并使用 `setExpiresAfter(long, TimeUnit)` 函数进行调整。

如果需要保留或驱逐最有可能的条目子集，`youngest(int)` 和 `oldest(int)` 方法可以提供条目的有序快照。


## 测试

```java
FakeTicker ticker = new FakeTicker(); // Guava 测试库
Cache<Key, Graph> cache = Caffeine.newBuilder()
  .expireAfterWrite(10, TimeUnit.MINUTES)
  .executor(Runnable::run)
  .ticker(ticker::read)
  .maximumSize(10)
  .build();

cache.put(key, graph);
ticker.advance(30, TimeUnit.MINUTES);
assertThat(cache.getIfPresent(key), is(nullValue()));
```

测试定时驱逐并不需要等到系统时钟时间结束。你可以使用 `Ticker` 接口和 `Caffeine.ticker(Ticker)` 方法在缓存构建器中指定时间源，而无需等待系统时钟。Guava 的测试库为此提供了一个方便的 `FakeTicker`。由于过期条目的移除是在维护周期内执行的，因此当测试依赖于驱逐操作时，请使用 `Cache.cleanUp()` 立即触发维护。

Caffeine 将周期性维护、移除通知和异步计算委托给 `Executor`。这样可以避免对调用者造成性能损失，从而提高更可预测的响应时间，并且默认使用 `ForkJoinPool.commonPool()`。你可以用 `Caffeine.executor(Executor)` 方法在缓存构建器中指定一个直接（同一线程）的 `Executor`，而无需等待异步任务完成。

我们推荐使用 `Awaitility` 进行多线程测试。



# 性能



## 设计



### 访问顺序队列

双向链表对哈希表中的所有条目进行排序。可以通过在哈希表中找到某个条目，然后操作其相邻元素，在 O(1) 时间内完成对该条目的操作。

访问顺序定义为条目的创建、更新或读取操作。最近最少使用（Least Recently Used）的条目位于列表头部，最近使用的条目位于列表尾部。这支持基于大小的区别（`maximumSize`）和基于空闲时间的驱逐（`expireAfterAccess`）。问题在于，每次访问都需要修改此列表，而修改本身无法高效地并发实现。

### 写顺序队列

写入顺序定义为条目的创建或更新。与访问顺序队列类似，写入顺序队列的操作时间复杂度为 O(1)。此队列用于实现生存时间过期（`expireAfterWrite`）。

### 分层计时器

这是一个时间感知型优先级队列，它使用哈希和双向链表在 O(1) 时间内执行操作。该队列用于可变过期时间（`expireAfter(Expiry)`）。

### 读缓冲区

典型的缓存会在每次操作时加锁，以确保访问队列中条目的重新排序安全。另一种方法是将每次重新排序操作存储在缓冲区中，然后分批应用更改。这可以看作是页面置换策略的预写式日志。当缓冲区满时，会尝试获取锁并执行待处理的操作，但如果锁已经被持有，则线程可以立即返回。

读缓冲区采用条带化环形缓冲区实现。条带用于减少竞争，每个线程通过特定的哈希值选择条带。环形缓冲区是一个固定大小的数组，这使其效率更高，并最大限度地减少了垃圾回收的开销。条带的数量可以根据争用检测算法动态增长。

### 写缓冲区

与读缓冲区类似，此缓冲区用于重放写入事件。读取缓冲区允许有损数据，因为这些事件用于优化驱逐策略的命中率。写入操作不能丢失，因此必须将其实现为高效的有界队列。由于写入缓冲区在填充后会优先清空，因此它通常保持为空或非常小。

缓冲区采用可增长的循环数据实现，其大小会不断调整，直至达到最大值。调整大小时，会分配一个新的数组并将其写入其中。之前的数组包含一个转发链接，供消费者遍历，之后旧数组即可被释放。通过这种分块机制，缓冲区初始大小较小，读写成本低，并且产生的垃圾量最少。当缓冲区已满且无法继续增长时，生产者会持续循环重试并尝试调度维护工作，但在短时间内放弃。这使得消费者线程能够优先处理数据，并通过重新驱逐策略中的写入操作来清空缓冲区。

### 锁定开销

传统缓存会在每次操作时锁定以执行少量工作，而 Caffeine 则将工作批量处理，并将开销分摊到多个线程上。这样可以分摊锁定带来的开销，而不是向传统缓存那样产生锁争用。这种维护开销会委托给配置的执行器。但如果任务被拒绝或使用了调用者运行策略，则也可能由用户线程执行。

批处理的优势在于，由于锁的独占性，缓冲区在任何给定时间都只能由单个线程清空。这使得可以使用更高效的基于多生产者/单消费者的缓冲区实现方案。此外，它还能更好地利用 CPU 缓存的效率，从而更好地适应硬件特性。

### 入口状态转换

当缓存未受排他锁保护时，一个挑战是操作可能会错误的顺序被记录和重放。由于竞争条件，创建-读取-更新-删除序列可能不会按相同的顺序存储在缓冲区中。要实现这一点，需要使用粗粒度锁，从而降低性能。

与并发数据结构中的常见做法一样，Caffeine 使用原子状态转换来解决这一难题。一个条目只有三种状态：存活、已退休和已死亡。存活状态意味着该条目同时存在于哈希表和访问/写入队列中。当条目从哈希表中移除时，它被标记为已退休，需要从队列中移除。此时，该条目被视为已死亡，并符合垃圾回收的条件。

### 灵活读和写

Caffeine 非常注重确保每一次易失性操作都能发挥最大效用。它并非着眼于语言本身的易失性读写操作，而是通过**内存屏障**从硬件层面进行分析。通过理解哪些屏障被触发，以及它们对硬件和数据可见性的影响，我们可以切实提升性能。

当锁保证了独占访问权限时，Caffeine 会使用宽松读取策略，因为锁获取的内存屏障提供了数据可见性。此外，当无论如何都会发生数据竞争时，例如在读取时检查条目是否过期以模拟缓存未命中，这种策略也是可以接受的。

Caffeine 对写入操作的处理方式与读取操作类似，都比较宽松。如果某个条目是在锁定状态下被独占写入的，那么写入操作可以利用解锁时释放的内存屏障。有时，允许写入时间存在偏差也是可以接受的，例如在读取条目时更新访问时间戳。

### 驱逐策略

Caffeine 使用 `Widnow TinyLfu`  策略来提供接近最优的命中率。访问队列被分为两个空间：一个准入窗口，如果 TinyLfu 策略接受该窗口，则会将其驱逐到主空间。TinyLfu 会估算窗口和主空间中目标条目的出现频率，并选择保留历史使用率最高的条目。频率计数存储在 4 位 `CountMinSketch` 中，每个缓存条目需要 8 字节才能保证准确性。这种配置使得缓存能够根据频率和最近使用情况在 O(1) 时间内以较小的占用空间进行驱逐。

#### 适应性

准入窗口和主空间的大小会根据工作负载特征动态调整。如果存在近期偏好，则倾向于使用较大的窗口；如果存在频率偏好，则倾向于使用较小的窗口。Caffeine 使用爬山算法来采样命中率，并进行调整和配置，以达到最佳平衡。

快速路径

当缓存容量低于其最大容量的 50% 时，缓存驱逐策略尚未完全启用。频率草图不会初始化以减少内存占用，因为缓存的阈值可能被人为地设置得过高。除非其他功能需要，否则不会记录访问操作，以避免读取缓冲区争用以及在清空缓存时重复执行访问操作。

#### HashDos 保护

当键具有相同的哈希码或哈希到相同的位置时，冲突可能被利用来降低性能。哈希表通过将链表降级为红黑树来解决这个问题。

针对 TinyLFU 的一种攻击方法是利用碰撞人为地提高被驱逐策略目标的估计频率。这会导致所有新达到的节点都被频率过滤器拒绝，从而导致缓存失效。一种解决方案是引入少量抖动，使决策具有不确定性。具体做法是随机允许 1%的被拒绝但频率适中的候选节点通过。

### 代码生成

由于配置选项众多，大多数字段仅在启用特定功能子集时才需要填写。如果所有字段默认都存在，则会增加缓存和每个条目的开销，造成资源浪费。通过代码生成最优实现，可以降低运行时内存开销，但代表是磁盘上的二进制文件更大。

这项技术具有用于算法优化的能力。例如，在构建缓存时，用于可以指定最合适自身用途的特性。移动应用可能更注重命中率而非并发性，而服务器应用则可能希望有以更高的内存开销为代价来获得更高的命中率，与其视图为所有用途寻找最佳平衡点，不如让用户意图来驱动算法选择。

### 装饰 Hash Map

缓存实现通过对 `ConcurrentHashMap` 进行装饰来添加所需功能。缓存和哈希表的并发算法各种都很复杂。通过将它们分开，可以轻松利用哈希表设计方面的进步，并避免使用粗锁来同时处理表和驱逐问题。

这种方法的代价是额外的运行时开销。与其将值封装起来以保存额外的元数据，不如将这些字段直接内联到表条目中。缺少封装可能会带来更快的路径，及通过单个表操作而不是多次映射调用和短暂的对象实例（例如 Lambda 表达式）。

之前的项目探索了两种方法：`ConcurrentLinkedHashMap` 使用的装饰器风格和 Guava 对哈希表进行分支的方法。不出所料，由于由此产生的设计过于复杂，分支的动机很少得以实现。



## 效率

`Least Recently Used` 是一种流行的驱逐策略，因为它简单易用，并在常见场景下命中率很高。然而，在典型的工作负载中，LRU 并非最优，在诸如全表扫描等情况下命中率可能很低。以下章节将对经过广泛评估的最佳替代方案进行比较。为简洁起见，本文仅谈论性能最佳的三种 O(1) 驱逐策略。这不包括基于 `Clock` 的策略，因为这类策略为了更好地适应并发环境，以 O(n) 的最坏情况时间复杂度为代价。

由于 `Window TinyLFU` 策略命中率高，内存占用低，因此 Caffeine 采用了该策略。

#### 自适应替换缓存（Adaptive Replacement Cache）

`ARC` 使用三个队列：一个用于存放仅访问过一次的元素的队列，一个用于存放多次访问的元素队列，以及一个用于存放已被驱逐但正在被监控的元素的非驻留队列。队列的最大容量会根据工作负载模式和缓存效率动态调整。

该策略实施起来很简单，但需要将缓存大小加倍才能保留被驱逐的键。此外，该策略已获得专利，未经 IBM 许可不得使用。

#### 低引用间近期集（Low Inter-reference Recency Set）

`LIRS` 根据引用间隔时间（IRR）对数据块进行组织，并将条目分为低引用间隔时间（LIR）和高引用间隔时间（HIR）两类。LIR 条目更倾向于保留在缓存中，而被驱逐的 HIR 条目可以保留为非驻留 HIR 条目。这样，非驻留 HIR 条目可以在缓存未命中后，不久被提升为 LIR 条目。

该策略实施起来很复杂，只有当缓存大小增加三倍以保留被驱逐的键时，才能达到最大效率。

#### Window TinyLfu

`W-TinyLfu` 使用小型准入 `LRU`，如果 `TinyLfu` 准入策略接受该小型 `LRU`，则会将其驱逐到大型 `Segmented LRU`。`TinyLfu` 依赖于频率草图来概率性地估计条目的历史使用情况。窗口机制使得该策略在条目出现近期使用率激增（否则会被拒绝）是仍然保持高的命中率。窗口大小与主空间大小的比值通过爬山算法自适应的确定。这种配置使缓存能够以较低的开销估计条目的频率和最近时间。

此实现使用 `4-Bit CountMinSketch`，每个缓存条目增长 8 字节以确保准确性。与 `ARC` 和 `LIRS` 不同，此策略不会保留已驱逐的键。

#### 结论

`Window TinyLfu` 策略提供了接近最优的命中率，性能可与 `ARC` 和 `LIRS` 相媲美。它在保持简洁性的同时，无需非驻留条目，且内存占用低。该策略在各种工作负载下均显著提升了 LRU 的性能，使其成为通用缓存的理想选择。



