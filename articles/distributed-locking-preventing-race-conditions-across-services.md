# 背景

每个后端工程师最终都会遇到这种情况：两个请求再同一毫秒内同时达到系统，突然间，客户被重复收费、座位被重复预定或者库存变成负数。在单体架构中，你或许可以用数据库事务或进程内互斥锁来解决问题。但在拥有多个服务实例的分布式系统中，你需要更强大的机制。你需要分布式锁。

本文将通过 TypeScript 和 Go 的生产机代码示例，深入探讨分布式锁的各种实用模式，从简单的 Redis `SET NX` 实例到 PostgreSQL 的建议锁，再到乐观锁并发控制机制。我们将介绍每种模式的优势、不足之处以及如何选择合适的模式。



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
- **PX（）**

