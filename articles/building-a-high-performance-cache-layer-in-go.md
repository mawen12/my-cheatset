# 背景

你的服务速度很慢，你添加了 Redis，速度确实提升了。但随后 Redis 又成了瓶颈——每个请求仍然需要进行一次网络往返，序列化开销不断累积，在高负载下，连接池争用导致的延迟峰值开始出现。

听起来是不是很熟悉？在本文中，我们将用 Go 构建一个 **两层缓存层**，它将本地内存缓存和 Redis 相结合，使用 `singleflight` 防止缓存争抢，并讨论生产环境中需要考虑的因素，这些因素将玩具缓存和久经考验的缓存区分开来。



# 为什么不直接使用 Redis？

Redis 非常出色，但它仍然需要通过网络跳转才能访问。对于典型的服务而言：

| 操作                    | 延迟     |
| ----------------------- | -------- |
| 本地内存读              | ~50ns    |
| Redis GET（相同可用区） | ~0.5-1ms |
| PostgreSQL 查询         | ~2-10ms  |

本地内存和 Redis 之间的性能差距高达 **10000x** 倍。这对于每秒读取数千次的热键来说，这至关重要。

本地缓存还为你提供：

- **零网络开销**——无序列化、无 TCP、无连接池
- **弹性**——即使 Redis 短暂宕机，你的服务也能保持响应
- **降低 Redis 负载**——命令减少意味着  Redis CPU 和网络使用率的降低

缺点是什么？本地缓存是针对每个实例的，可能提供过时的数据。我们会解决这两个问题。



# 第一层：带 TTL 的本地内存缓存

我们先从一个简单但有效的本地缓存开始。我们将使用 `sync.Map` 来实现并发访问，并使用后台 `goroutine` 来实现 TTL 淘汰。

```go
package cache

import (
	"sync"
  "time"
)

type entry struct {
  value 		any
  expiresAt time.Time
}

type LocalCache struct {
  data 		sync.Map
  maxSize int
  size 		int64
  mu 			sync.Mutex // 保证 size
}

func NewLocalCache(maxSize int, evictInterval time.Duration) *LocalCache {
  c := &LocalCache{maxSize: maxSize}
  go c.evictLoop(evictInterval)
  return c
}

func (c *LocalCache) Get(key string) (any, bool) {
  raw, ok := c.data.Load(key)
  if !ok {
    return nil, false
  }
  e := raw.(*entry)
  if time.Now().After(e.expiresAt) {
    c.data.Delete(key)
    c.decrSize()
    return nil, false
  }
  return e.value, true
}

func (c *LocalCache) Set(key string, value any, ttl time.Duration) {
  _, loaded := c.data.LoadOrStore(key, &entry{
    value: value,
    expiresAt: tiem.Now().Add(ttl),
  });
  if !loaded {
    c.incrSize()
  } else {
    c.data.Store(key, &entry{
      value: value,
	    expiresAt: tiem.Now().Add(ttl),
    })
  }
}

func (c *LocalCache) Delete(key string) {
  if _, loaded := c.data.LoadAndDelete(key); loaded {
    c.decrSize()
  }
}

func (c *LocalCache) evictLoop(interval time.Duration) {
  ticker := timew.NewTicker(interval)
  defer ticker.Stop()
  for range ticker.C {
    now := time.Now()
    c.data.Range(func(key, value any) bool {
      if now.After(value.(*entry).expiresAt) {
        c.data.Delete(key)
        c.decrSize()
      }
      return true
    })
  }
}

func (c *LocalCache) incrSize() {
  c.mu.Lock()
  c.size++
  c.mu.Unlock()
}

func (c *LocalCache) decrSize() {
  c.mu.Lock()
  c.size--
  c.mu.Unlock()
}
```

这样一来，我们就能在延迟加载和周期性过期的情况下实现 O(1) 的读写操作。`sync.Map` 针对缓存典型的读取密集型、写入稀少型模式进行了优化。

**为什么不使用带有 sync.RWMutex 的普通 Map 呢？** 对于已读取为主且包含大量  `goroutine` 的工作负载，`sync.Map` 可以完全避免读取路径上的锁争用。在写入密集型负载下，带有 `RWMutex` 的分片 `Map` 在性能上可能更优——但缓存几乎总是读取密集型的 。



# 第二层：带有 Cache-Aside Pattern 的双层缓存

现在让我们将本地缓存与 Redis 组合成一个两层系统。查找流程如下：

1. 检查本地缓存 -> 命中？立即返回
2. 检查 Redis -> 命中？回填本地缓存，返回
3. 调用加载器（DB、API 等） ->   填充两个缓存、返回

```go
package cache

import (
	"context"
  "fmt"
  "time"
  
  "github.com/redis/go-redis/v9"
)

type TieredCache struct {
  local 		*LocalCache
  redis 		*redis.Client
  localTTL 	time.Duration
  redisTTL 	time.Duration
}

func NewTieredCache(rc *redis.Client, localTTL, redisTTL time.Duration) {
  return &TieredCache{
    local: NewLocalCache(10000, 30*time.Second),
    redis: rc,
    localTTL: localTTL,
    redisTTL: redisTTL,
  }
}

func (tc *TieredCache) Get(ctx context.Context, key string) ([]byte, bool) {
  // Tier 1: local memory
  if val, ok := tc.local.Get(key); ok {
    return val.([]byte), true
  }
  // Tier 2: Redis
  val, err := tc.redis.Get(ctx, key).Bytes()
  if err == nil {
    tc.local.Set(key, val, tc.localTTL) // 回填 Tier 1
    return val, true
  }
  retrn nil, false
}

func (tc *TieredCache) Set(ctx context.Context, key string, value []byte) error {
  tc.local.Set(key, value, tc.localTTL)
  return tc.redis.Set(ctx, key, value, tc.redisTTL).Err()
}

// GetOrLoad 实现了完整的 cache-aside pattern
func (tc *TieredCache) GetOrLoad(ctx context.Context, key string, loader func(ctx context.Context) ([]byte, error)) ([]byte, error) {
  if val, ok := tc.Get(ctx, key); ok {
    return val, nil
  }
  val, err := loader(ctx)
  if err != nil {
    return nil, fmt.Errorf("loader for key %s:%v", key, err)
  }
  _, tc.Set(ctx, key, val) // 尽力而为的写入缓存
  return val, nil
}
```

使用方法干净：

```go
data, err := cache.GetOrLoad(ctx, "user:1234", func(ctx context.Context) {
  u, err := db.GetUser(ctx, 1234)
  if err != nil {
    return nil, err
  }
  return json.Marshal(u)
})
```

> **重要提示：** 本地 TTL 应短于 Redis TTL。一个好的初始值是本地 10~30 秒，Redis 5~15 分钟。这样既能减少跨实例的数据过期，又能确保绝大多数读取操作在本地完成。



# 利用 singleflight 阻止缓存击穿

`GetOrLoad` 方法存在一个严重问题。当一个热点键过期时，数百个 `goroutine` 会同时发现缓存未命中并全部调用 `loader`。这会导致缓存击穿——可能会使数据库崩溃。

Go 的 `golang.org/x/sync/singleflight` 会对同一键的并发调用进行去重，因此只有一个 `goroutine` 执行实际工作：

```go
import "golang.org/x/sync/singleflight"

type TieredCache struct {
  local 		*LocalCache
  redis 		*redis.Client
  localTTL 	time.Duration
  redisTTL 	time.Duration
  sf				singleflight.Group
}

func (tc *TieredCache) GetOrLoad(ctx context.Context, key string, loader func(ctx context.Context) ([]byte, error)) ([]byte, error) {
  if val, ok := tc.Get(ctx, key); ok {
    return val, nil
  }
  // 每个键只执行一个 goroutine；其他 goroutine 等待并共享结果
  result, err, shared := tc.sf.Do(key func() (any, error) {
    // 双重检查：另一个 goroutine 可能已经填充缓存，
    // 在我们等待 singleflight 的那段时间
   	if val, ok := tc.Get(ctx, key); ok {
      return val, nil
    } 
    
    val, err := loader(ctx)
    if err != nil {
      return nil, fmt.Errorf("loader for key %s:%v", key, err)
    }
    
    _, tc.Set(ctx, key, val)
	  return val, nil
  })
  
  _ = shared // 用于指标：高分享率 = 有效阻止了击穿事件发生
  return result.([]byte), nil
}
```

`Do` 语句内部的 **双重检查** 至关重要。在初始缓存未命中到获取 `singleflight` 槽位之间，另一个 `goroutine` 可能已经填充了缓存 。如果没有这一检查，每次查询事件仍然会进行一次冗余的数据库调用。



# 压力测试

测试设置：8 核机器，100 个并发 `goroutine`，10K 个采用 Zipfian 分布的唯一键（有些键比其他键更热门，就像真实流量一样）。

```go
func BenchmarkCacheTier(b *testing.B) {
  b.Run("redis-only", func(b *testing.B) {
    b.RunParallel(func(pb *testing.PB) {
      func pb.Next() {
        rdb.Get(ctx, zipfKey())
      }
    })
  })
  
  b.Run("local-only", func(b *testing.B) {
    b.RunParallel(func(pb *testing.PB) {
      func pb.Next() {
        local.Get(ctx, zipfKey())
      }
    })
  })
  
  b.Run("tiered", func(b *testing.B) {
    b.RunParallel(func(pb *testing.PB) {
      func pb.Next() {
        tiered.Get(ctx, zipfKey())
      }
    })
  })
}
```

 测试结果：

| 场景             | ops/sec    | p50   | p99   |
| ---------------- | ---------- | ----- | ----- |
| redis-only       | 85,000     | 0.6ms | 2.1ms |
| local-only       | 12,000,000 | 48ns  | 210ns |
| tiered（预热）   | 10,500,000 | 52ns  | 380ns |
| tiered（冷启动） | 78,000     | 0.7ms | 2.4ms |

在稳定状态下，分层缓存的运行速度接近本地缓存，因为热键位于 L1 层。对于冷路径进行额外的本地缓存未命中检查只会增加约 4ns 的开销，之后就会跳转到 Redis。

**缓存击穿测试 ：** 1000 个 goroutines 同时访问同一过期的键：

| 场景            | 数据库调用次数 | p99   |
| --------------- | -------------- | ----- |
| 无 singleflight | 1000           | 850ms |
| 有 singleflight | 1              | 12ms  |

这种差异非常显著，而且在实际负载下会更加严重。



# 生产方面的考虑



## 内存限制

无限制的本地缓存会导致进程内存溢出（OOM）。有两种解决办法：

1. **最大条目数量**——简单且可预测。当条目数已满时，移除最旧的条目。在 `Set` 中添加大小检查，并在需要移除顺序时使用像 `hashicorp/golang-lru/v2` 这样的 LRU 库。
2. **最大内存字节数**——更精确也更难计算。对于 `[]byte` 值，可以直接求和长度；对于任意类型，估算就变得复杂了。

初始设置最大内存访问数 + 较短的 TTL。通过 `runtime.MemStats` 监控并进行调整。



## 驱逐策略

基于 TTL 的驱逐机制通常就足够了。但如果你还想限制大小 ：

- **LRU**——默认选择。易于理解 ，适用于大多数访问模式。
- **LFU**——更适合严重倾斜的工作负载。但正确实现起来更复杂。
- **Random**——效果出奇地好，而且几乎免费。适用于访问模式难以预测的情况。

对于大多数服务而言，**LRU** + **LFU** 是最佳方案。



## 缓存失效

多实例一致性选项：

- **短的本地 TTL**——接受有限的过期时间（10~30秒）。这是最简单的方法，通常也足够了。
- **Redis Pub/Sub**——写入时发布事件；实例在本地订阅和驱逐。

```go
func (tc *TieredCache) Invalidate(ctx context.Context, key string) error {
  tc.local.Delete(key)
  tc.reids.Del(ctx, key)
  return tc.redis.Publish(ctx, "cache:invalidate", key).Err()
}

// 每一个实例在启动时订阅
func (tc *TieredCache)  SubscribeInvalidations(ctx context.Context) {
  sub := tc.redis.Subscribe(ctx, "cache:invalidate")
  go func() {
    for msg := range sub.Channel() {
      tc.local.Delete(msg,Payload)
    }
  }()
}
```



## 负缓存

缓存也会出现未命中。如果数据库中不存在某个键，请存储一个**哨兵值**以防止重复查找：

```go
var sentinel = []byte("__MISS__")

// 在 loader 中
if errors.Is(err, ErrNotFound) {
	_ = cache.Set(ctx, key, sentinel) // 较短的 TTL
	return nil, ErrNotFound
}
```

如果没有这个机制，不存在的键会在每次请求时生成数据库查询——攻击者可以利用这种模式。



## 监控

跟踪这些指标（暴露给 Prometheus、Datadog 等）。

-  **每层命中率**——本地热门路径命中率应该高达 80% 以上
- **Singleflight 共享率**——高=防止缓存击穿
- **缓存大小**——条目数和估计内存
- **loader 延迟**——你要保护系统免受其害

```go
type Metrics struct {
	LocalHits 	atomic.Int64
	LocalMisses atomic.Int64
	RedisHits 	atomic.Int64
	RedisMisses atomic.Int64
	SFShared 		atomic.Int64
}
```

通过显示各层级命中率的仪表盘。你可以立即了解缓存的复杂性是否物有所值。



# 完整架构

```
Request -> Local Cache (L1, ~50ns)
						│miss
					 Redis (L2, ~0.5ms)
					 	│miss
					 Singleflight dedup
					 	│
					 Database(~5ms)
					 	│
					 Populate L1 + L2
```

要点总结：

1. **两层架构优于单层架构**——本地处理热点读取，Redis 处理长尾数据和跨实例共享。
2. **singleflight 是不可或缺的**——如果没有它，负载下缓存过期就会就会引发数据库崩溃。
3. **短的本地 TTL**——10~30 秒可在新鲜度和命中率之间取得平衡。
4. **监控一切**——命中率、大小 、loader 延迟。缓存故障往往悄无声息。

先从简单版本入手。进行测量，然后只有在数据证明有必要时才增加复杂度。

