# 背景

每个后端工程师最终都会遇到这种情况：两个请求再同一毫秒内同时达到系统，突然间，客户被重复收费、座位被重复预定或者库存变成负数。在单体架构中，你或许可以用数据库事务或进程内互斥锁来解决问题。但在拥有多个服务实例的分布式系统中，你需要更强大的机制。你需要分布式锁。

本文将通过 TypeScript 和 Go 的生产机代码示例，深入探讨分布式锁的各种实用模式，从简单的 Redis `SET NX` 实例到 PostgreSQL 的咨询锁，再到乐观锁并发控制机制。我们将介绍每种模式的优势、不足之处以及如何选择合适的模式。



# 为什么存在分布式锁？

假设一个支付服务在负载均衡后运行三个副本。用户点击 "支付" 按钮，网络出现故障导致请求重试。其中两个副本在几微秒内都读取到订单状态为 "待处理"，都会卡进行扣款，并将订单标记为 "已支付"。因此，客户会看到两笔扣款记录。

或者想象一下这样的活动预售系统。两个用户同时尝试预定最后一个座位。两个系统都查询了座位情况，都显示还有一个座位，于是都确定了预订。这样一来，你就卖出了一个根本不存在的座位。

这些并非理论上的极端情况。它们会在生产环境中大规模出现，并造成实实在在的经济损失。核心问题在于：**多个进程需要在缺乏共享内存空间的情况下协调对共享资源的访问**。

分布式锁实现了跨进程边界的互斥。同一时间只能有一个持有者获取锁。其他所有进程要么等待，要么快速失败。



# 基于 Redis 的锁：SET NX EX 模式

最简单且应用最广泛的分布式锁使用单个 Redis 实例和原子 SET 命令：

```typescript
import Redis from "ioredis";

const redis = new Redis(process.env.REDIS_URL);

interface LockResult {
  acquired: boolean
  release: () => Promise<boolean>;
}

async function acquireLock(
	key: string,
  ttlMs: number,
  ownerId: string
): Promise<LockResult> {
  const lockKey = `lock:${key}`;
  
  // SET NX 保证原子性——只有一个调用者会成功
  const result = await redis.set(lockKey, ownerId, "PX", ttlMs, "NX");
  
  if (result !== "OK") {
    return { acquired: false, release: async () => false };
  }
    
  const release = async (): Promise<boolean> => {
    const script = `
    	if redis.call("get", KEYS[1]) == ARGV[1] then
    		return redis.call("del", KEYS[1])
    	else
    		return 0
    	end
    `
    const removed = await redis.eval(script, 1, lockKey, ownerId)
    return removed === 1;
  }
  
  return { acquired: true, release };
}
```

在支付处理程序中的用法：

```typescript
import { randomUUID } from "crypto";

async function processPayment(orderId: string, amount: number) {
  const ownerId = randomUUID();
  const lock = await acquireLock(`payment:${orderId}`, 10_000, ownerId);
  
  if (!lock.acquired) {
    throw new Error("Payment already being processed");
  }
  
  try {
    const order = await db.orders.findById(orderId);
    if (order.status !== "pending") {
      return { status: "already_processed" };
    }
    
    const charge = await paymentGateway.charge(order.customerId, amount);
    await db.orders.update(orderId, {
      status: "paid",
      chargeId: charge.id,
    });
    
    return { status: "success", chargeId: charge.id };
  } finally {
    await lock.release();
  }
}
```

关键细节：

- **NX（不存在）**：使 SET 操作成为原子操作。只有一个调用者会赢得竞争机会。
- **PX（毫秒级过期时间）**：可防止持有者崩溃时出现死锁
- **Lua release 脚本**会在删除之前检查所有权。如果没有这一步骤，运行缓慢的进程 A 的锁可能会过期，进程 B 获取该锁，然后进程 A 完成并删除 B 的锁。
- **ownerID 必须每次申请时都唯一**，而不是每次流程都唯一，UUID 可以满足要求。

Go 语言中也存在相同的模式：

```go
package dlslock

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"time"
	
	"github.com/redis/go-redis/v9"
)

type Lock struct {
  client *redis.Client
  key 		string
  ownerID string
}

func Acquire(ctx context.Context, client *redis.Client, key string, ttl time.Duration) (*Lock, error) {
  ownerID := generateOwnerID()
  lockKey := "lock:" + key
  
  ok, err := client.SetNX(ctx, lockKey, ownerID, ttl).Result()
  if err != nil {
    return nil, err
  } 
  if !ok {
    return nil, ErrLockNotAcquired
  }
  
  return &Lock{ client: client, key: lockKey, ownerID: ownerID }, nil
}

var releaseScript = redis.NewScript(`
	if redis.call("get", KEYS[1]) == ARGV[1] then
		return redis.call("del", KEYS[1])
	else
		return 0
	end
`)

func (l *Lock) Release(ctx context.Context) error {
  result, err := releaseScript.Run(ctx, l.client, []string{l.key}, l.ownerID).Int64()
  if err != nil  {
    return err
  }
  if result == 0 {
    return ErrLockAlreadyReleased
  }
  return nil
}

func generateOwnerID() string {
  b := make([]byte, 16)
  rand.Read(b)
  return hex.EncodeToString(b)
}
```



## 局限性：单点故障

单个 Redis 实例意味着单点故障。如果 Redis 宕机，所有锁都会丢失。如果 Redis  故障转移到副本，尚未复制的锁也会丢失——这意味着两个进程可能同时持有 "同一个" 锁。

对于许多工作负载而言，这是可以接受的。如果你的锁使用数据库唯一性约束作为安全网来保护幂等性操作，那么在故障转义期间出现罕见的重复获取是可以容忍的。但对于金融交易，你需要更强大的安全措施。



## Redlock 算法

Martin Kleppmann 和 Salvatore Sanfilippo 就此展开了一场著名的辩论，但当需要比单个 Redis  节点提供的更强的保证时，Redlock 算法仍然是一个实用的选择。

Redlock 使用 N 个独立的 Redis 实例（通常为 5 个），并且需要多数票才能通过：

```typescript
import Redis from "ioredis";
import { randomUUID } from "crypto";

class Redlock {
  private nodes: Redis[];
  private quorum: number;
  
  constructor(urls: string[]) {
    this.nodes = urls.map((url) => new Redis(url));
    this.quorum = Math.floor(this.nodes.length / 2) + 1;
  }
  
  async acquire(
  	resource: string,
    ttlMs: number
  ): Promise<{ acquire: boolean, release: () => Promise<void> }> {
    const ownerId = randomUUID();
    const lockKey = `lock:${resource}`;
   	const startTime = Date.now();
      
    // 尝试并行获取所有节点上的数据
    const results = await Promise.allSettled(
    	this.nodes.map((node) => 
        node.set(lockKey, ownerId, "PX", ttlMs, "NX"))
    );
   
    const acquired = results.filter(
    	(r) => r.status === "fulfilled" && r.value === "OK"
    ).length;
      
    const elapsed = Date.now() - startTime;
    const remainingTtl = ttlMs - elapsed;
   	
    // 需要多数席位，并且剩余足够的 TTL 才能进行有效工作
   	if (acquired >= this.quorum && remainingTtl > ttlMs * 0.1) {
    	return {
        acquired: true,
        release: () => this.releaseAll(lockKey, ownerId),
      };
    }
      
    // 失败——释放我们已获取的资源
    await this.releaseAll(lockKey, ownerId);
    return { acquired: false, release: async () => false };
  }
 
  private async releaseAll(key: string, ownerId: string): Promise<void> {
    const script = `
    	if redis.call("get", KEYS[1]) == ARGV[1] then
    		return redis.call("del", KEYS[1])
    	else
    		return 0
    	end
    `;
    await Promise.allSettled(
      this.nodes.map((node) => node.eval(srcipt, 1, key, ownerId))
    );
  }
}
```

Redlock 的主要特性：

1. **基于法定人数**：能够容忍少数节点故障
2. **受时钟影响**：有效窗口会随着获取锁所花费的时间而缩短。如果获取锁的时间或长，则该锁的时间过长，则该锁被视为无效
3. **没有围栏**：即使 TTL 到期，慢锁持有者仍可能导致问题

实际上，大多数团队会使用久经考验的 `redlock` rpm 包或 Go 语言的 `redSync`，而不是自行开发。该算法对时间要求非常微秒，很容易出错。



## 使用心跳为锁续期

固定 TTL（生存时间）会造成一种矛盾：太短会导致锁定在工作完成之前过期；太长当持有者崩溃时，阻塞所有人。解决方案是自动续期——一种后台心跳机制，在持有者存活期间延长锁定时间：

```go
type RenewableLock struct {
  *Lock
  cancel 	context.CancelFunc
  done 		chan struct{}
}

func AcquireWithRenewval(ctx context.Context, clien *redis.Client, key string, ttl time.Duration)(*RenewableLock, error) {
  lock, err := Acquire(ctx, client, key, ttl)
  if err != nil {
    return nil, err
  }
  
  renewCtx, cancel := context.WithCancel(ctx)
  done := make(chan struct{})
  
  go func() {
    defer close(done)
    ticker := time.NewTicker(ttl / 3) // 在时间 1/3 的时候续期
    defer ticker.Stop()
    
    for {
      select {
      case <- renewCtx.Done():
        return
      case <- ticker.C:
        err := renew(renewCtx, client, lock.key. lock.ownerID, ttl)
        if err != nil {
          // 丢失锁，记录日志并退出
          return
        }
      }
    }
  }()
  
  return &RenewableLock{Lock: lock, cancel: cancel, done: done}, nil
}

var renewScript = redis.NewScript(`
	if redis.call("get", KEYS[1]) == ARGV[1] then
		return redis.call("pexpire", KEYS1[], ARGV[2])
	else
		return 0
	end
`)

func renew(ctx context.Context, client *redis.Client, key, ownerID string, ttl time.Duration) error {
  result, err := renewScript.Run(ctx, client, []string{key}, ownerID, ttl.Milliseconds()).Int64()
  if err != nil {
    return err
  }
  if result == 0 {
    return ErrLockAlreadyReleased
  }
  return nil
}

func (rl *RenewableLock) Release(ctx context.Context) error {
  rl.Cancel() // 停止 renewal goroutine
  <-rl.done // 等待完成
  return rl.Lock.Release(ctx)
}
```

TTL / 3 的续期间隔提供了两次重试机会，如果进程挂起或网络分区，心跳停止，锁自然过期。

这正是 Redission（Java）和许多生产环境中锁库的内部工作原理。



# PostgreSQL 咨询锁

如果你的系统已经依赖于 PostgreSQL,并且你的锁范围与数据库操作一致，那么咨询锁可以消除对外部基础设施的需求：

```typescript
import { Pool } from 'pg';

const pool = new Pool({ connectionString: process.env.DATABASE_URL });

// Session 级别的咨询锁 —— 持有直到显示释放或会话结束
async function withAdvisoryLock<T>(
	lockId: number,
  fn: () => Promise<T>,
): Promise<T> {
  const client = await pool.connect();
    
 	try {
 		// pg_try_advisory_lock 返回 true/false，从不阻塞
    const { rows } = await client.query(
    	"SELECT pg_try_advisory_lock($1) AS acquired",
      [lockId]
    );
    
    if (!rows[0].acquired) {
      throw new Error(`could not acquire advisory lock ${lockId}`);
    }
    
    try {
      return await fn();
    } finally {
      await client.query("SELECT pg_advisory_unlock($1)", [lockId]);
    }
 	} finally {
    client.release();
  }
}

// 用法：从业务标识符派生出稳定的锁 ID
func lockIdFromOrderId(orderId: string): number {
  let hash = 0;
  for (const char of orderId) {
    hash = (hash * 31 + char.charCodeAt(0)) | 0;
  }
  return Math.abs(hash);
}

// 处理带有咨询锁定保护的退款
await withAdvisoryLock(lockIdFromOrderId("order-789"), async () => {
  const order = await db.orders.findById("order-789");
  if (order.status === "refunded") return;
  await paymentGateway.refund(order.chargeId);
  await db.orders.update("order-789", { status: "refunded" });
});
```

PostgreSQL 还支持事务级咨询锁，这些锁会在提交、回滚时自动释放。

```sql
-- 在事务内部：事务结束时会被释放
SELECT pg_advisory_xact_lock(hashtext('booking:seat-42'));

-- 在同一笔交易中完成你的工作
UPDATE seats SET booked_by = 'user-123' WHERE id = 'seat-42' ADN booked_by IS NULL;
```

咨询锁优点：

- **无额外基础设施**，如果你已经在使用 Postgres，则会自动启用咨询锁
- **符合 ACID 标准**，事务级锁和数据变更自然集成
- **死锁检测**，Postgres 会自动检测并打破死循环

咨询锁限制：

- **绑定到单个  Postgres 实例**（或副本集中的主实例）。不支持跨数据库锁定
- **锁 ID 为 64 位整数**，对于基于字符串的资源标识符，需要采用一致的哈希方案
- **连接池交互**，如果使用会话级锁，已释放的连接返回连接池后仍会持有该锁，知道显式解锁为止


# 带版本列的乐观锁定

有时候根本不需要互斥，只需要检测冲突即可。乐观锁假设冲突很少发生，并在写入时进行检查：

```typescript
// Schema: orders 表有一个 version 字段，integer，默认为 1

async function updateOrderStatus(
	orderId: string,
  newStatus: string,
  expectedVersion: number
): Promise<boolean> {
	const result  = await db.query(
  	`UPDATE orders 
  		SET status = $1, version = version + 1, updated_at = now() 
  		WHERE id = $2 AND version = $3`,
    [newStatus, orderId, expectedVersion]
  );
    
  // 如果行没有受到影响，则说明其他人修改了顺序
  return result.rowCount === 1;
}

// 使用重试
async function processOrderWithRetry(
	orderId: string,
  maxRetries: 3
) {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    const order = await db.orders.findById(orderId);
    
    if (order.status !== "pending") {
      return { status: "already_processed" };
    }
    
    const updated = await updateOrderStatus(
    	orderId,
      "processing",
      order.version
    );
    
    if (updated) {
      // 我们赢得了竞争，继续执行业务逻辑
      await fulfillOrder(order);
      return { status: "success" }
    }
    
    // 检测到冲突，重新读取并重试
    await sleep(Math.pow(2, attempt) * 10); // 指数退避
  }
    
  throw new Error("Max Retries exceeded due to concurrent modifications");
}
```

使用 `database/sql` 的 Go 等效代码：

```go
func updateOrderStatus(ctx context.Context, db *sql.DB, orderID, newStaus string expectedVersion int) (bool, error) {
	result, err := db.ExecContextt(ctx,
		`UPDATE orders SET  status = $1, version = version + 1, updated_at = now()
		WHERE id = $2 AND version = $3`,
		newStatus, orderID, expectedVersion,
	)
	if err != nil {
		return false, err
	}
	
	rows, err := result.RowsAffected()
	return rows == 1, err
}
```

乐观锁定在以下情况下效果最佳：

- 冲突确实很少见（大多数请求涉及不同的资源）
- 可以安全地重试此操作
- 你想要大吞吐量——在正常情况下不需要任何锁获取开销

当竞争程度较高时，这种方法效果不佳，因为重试会级联并加剧负载 。

# Compare-and-Swap（CAS）模式

CAS 将乐观锁 推广到数据库之外。任何支持原子条件写入的系统都可以实现 CAS。以下是使用 DynamoDB 条件表达式的 CAS 模式：

```typescript
import { DynamoDBClient, UpdateItemCommand } from "@aws-sdk/client-dynamodb";

const ddb = new DynamoDBClient({});

async fuunction claimTask(taskId: string, workerId: string): Promise<boolean> {
  try {
  	await ddb.send(
  		new UpdateItemCommand({
  			TableName: "tasks",
  			Key: { id: { S: taskId }},
        UpdateExpression: 
					"SET #status = :claimed, worker_id = :worker, claimed_at = :now",
        ConditionExpression: "#status = :unclaimed",
        ExpressionAttributeNames: { "#status": "status" },
        ExpressionAttributeValues: {
          ":claimed": { S: "claimed" },
          ":unclaimed": { S: "unclaimed" },
          ":worker": { S: workerId },
          ":now": { S: new Date().toISOString() },
        },
			})
  	);
		return true;
	} catch (err: any) {
    if (err.name === "ConditionalCheckFailedException") {
      return false; // 有人声称拥有它
    }
    throw err;
  }
}
```

CAS 也是领导者选举、分布式状态机和共识协议的基础。Etcd、Zookeeper 和 Consul 都提供了可在数据中心内运行的 CAS 原语。


# Lock 争用和性能

锁会串行化访问。在争用的情况下，它们会成为瓶颈。以下是一些管理这种情况的实用策略：

1. **缩小锁定范围**。尽可能锁定最小的资源。如果可以锁定 "payments:order-123"，就不要锁定 "payments"。

   ```typescript
   // Bad: 全局锁
   await acquireLock("payment-processing", 10_000, ownerId);
   
   // Good: 按资源锁定
   await acquireLock(`payment:${orderId}`, 10_000, ownerId);
   ```

2. **缩短锁持续时间**。在锁外部执行 I/O 和计算操作。仅在关键状态转换时持有锁。

   ```typescript
   // 在锁外部进行验证和准备
   const validatePayment = await validatePaymentDetails(request);
   const idempotencyKey = deriveIdempotencyKey(request);
   
   // 仅对状态变更进行锁定
   const lock = awat acquireLock(`payment:${orderId}`, 5_000, ownerId);
   try {
     const order = await db.orders.findById(orderId);
     if (order.status !== "pending") return;
     await db.orders.update(orderId, { status: "paid"});
   } finally {
     await lock.release();
   }
   
   // 锁外部的后处理
   await sendReceipt(validatePayment);
   ```

3. **尽可能使用无锁设计**。幂等键、唯一约束和 CAS 通常可以完全消除对显示锁的需求。

4. **监控锁指标**。跟踪锁获取时间、保持时间、争用率和超时频率。锁等待时间的突然飙升通常表明存在设计问题，而不是需要更快的锁。

5. **设置严格的超时时间**。对于大多数 Web 请求，1~2 秒的锁获取超时时间会比较合适。如果等待时间过长，系统性能会下降，最好快速失败。


# 选择正确的方法

| 模式                 | 优势                   | 基础设施           | 一致性       |
| -------------------- | ---------------------- | ------------------ | ------------ |
| Redis SET  NX        | 通用，高吞吐量         | Redis              | 单节点耐久性 |
| Redlock              | 跨节点 Redis 安全性    | 5 Redis 节点       | 基于法定人数 |
| PG 咨询锁            | 以数据库为核心的工作流 | PostgreSQL         | ACID 保证    |
| 乐观锁               | 低竞争度读，写入次数少 | 任何数据库管理系统 | 每行 CAS     |
| CAS（DynamoDB/etcd） | 无服务器、多节点       | 托管服务           | 服务相关     |

决策框架：

1. **以乐观锁开始**——如果冲突很少发生操作可重试。它最简单，无需额外设置基础设施，并且扩展性最佳。
2. **使用 PostgreSQL 咨询锁**——如果你的关键代码段与数据库操作紧密相关，并且你已经在使用 PostgreSQL。事务级咨询锁尤其简洁高效。
3. **使用 Redis SET NX**——对于需要亚秒级锁获取且可以容忍 Redis 故障转移期间罕见的双重获取的通用式分布式协调。
4. **使用 Redlock 或 etcd/Consul**——只有当需要多个 节点上实现强大的互斥保证，并且双重执行的成本非常高昂是（例如金融交易、资源配置）
5. **多层架构组合**——最稳建的生产系统使用分布式锁进行分布式协调，并结合数据库约束作为作为安全网。分布式锁高效地处理正常情况；数据库约束则捕获边界情况。

```typescript
async function processPaymentSafely(orderId: string, amount: number) {
	// 第一层：分布式锁防止并发处理
	const lock = await acquireLock(`payment:${orderId}`, 10_000, randomUUID());
	if (!lock.acquired) throw new Error("payment in progress");
	
	try {
		// 第二层：数据库检查防止重复处理
		const order = await db.orders.findById(orderId);
		if (order.status !== "pending") return { status: "already_processed" };
		
		const charge = await paymentGateway.charge(order.customerId, amoutn);
	
		// 第三层：charge_id 的唯一约束防止重复记录
		await db.orders.update(orderId, {
			status: "paid",
			chargeId: charge.id, // schema 中的唯一约束
		});
		
		return { status: "success" };
	} finally {
		await lock.release();
	}
}
```

# 总结

分布式领域中，简单方案在 99% 的情况下都能奏效，但剩下的 1% 却可能造成不小的损失。使用带有适当所有者验证的 `SET NX EX` 模式可以应对大多数用例。如果已经使用了 Postgres，建议锁可以简化流程。当竞争程度较低时，乐观锁可以完全避免协调开销。

关键在于，锁只是手段，而非目的本身。你真正需要的是**并发环境下的正确性**。有时这意味着使用锁，有时这意味着使用幂等键、唯一约束或 CAS 操作。通常情况下，这意味着采用多层机制，以确保任何单一故障模式都不会导致错误行为。

从简单入手，衡量竞争情况，只有当数据需要时才增加复杂性。

