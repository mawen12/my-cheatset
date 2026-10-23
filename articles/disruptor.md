# 主页

LMAX Distribuptor 是一个高性能的线程间消息传递库。它源于 LMAX 对并发性、性能和非阻塞算法的研究。如今已经成为其交易所基础设施的核心组成部分。



## 使用 Disruptor



### 介绍

Disruptor 是一个提供并发环形缓冲区数据结构的库。它的设计目的是在异步事件处理架构中提供低延迟、高吞吐量的工作队列。

为了了解 Disruptor 的优势，我们可以将其与一个用途相似且广为人知的机制进行比较。对于 Disruptor 而言，这个机制就是 Java  的 `BlockingQueue`。与队列类似，Disruptor 的用途是在同一进程内的线程之间移动数据（例如消息或事件）。然而， Disruptor 提供了一些关键特性，使其区别于队列。这些特性包括：

- 广播事件到消费者，并带有消费者依赖关系图
- 预先分配事件内存
- 可选的无锁



#### 核心概念

在了解 Disruptor 的工作原理之前，有必要先定义一些将在文档和代码中用到的术语。对于熟悉领域驱动设计（DDD）的人来说，可以把这些术语理解为 Disruptor 领域的通用语言。

- **Ring Buffer**: Ring Buffer 通常被认为是 Disruptor 的核心组件。然而，从 3.0 版本开始，Ring Buffer 仅负责存储和更新流经 Disruptor 的数据（事件）。对于某些高级用例，用户甚至可以完全替换它。
- **Sequence**: Disruptor 使用 `Sequence` 来标识特定组件的执行进度。每个消费者（事件处理器）以及 Disruptor 自身都维护一个 `Sequence`。大部分并发代码依赖于这些序列值的移动，因此 `Sequence` 支持 `AtomicLong` 的许多现有特性。实际上，两者之间唯一的真正区别在于，`Sequence` 包含额外的功能，以防止 `Sequence` 与其他值之间发生虚假共享。
- **Sequencer**: 序列器是 Disruptor 的真正核心。该接口的两种实现方式（单生产者和多生产者）实现了所有并发算法，以确保生产者和消费者之间数据传递的快速、正确性。
- **Sequencer Barrier**: 序列器生成一个序列屏障，其中包含对序列器自身发布的主 `Sequence` 以及所有依赖消费者的序列的引用。它包含用于确定是否有任何事件可供功能消费者处理的逻辑。
- **Wait Strategy**: 等待策略决定了消费者如何等待生产者将事件放入 Disruptor 中。更多详情请参见关于可选无锁机制的部分。
- **Event**: 生产者传递给消费者的数据单元。事件没有特定的代码表示，因为它完全由用户定义。
- **Event Processor**: 用于处理来自 Disruptor 的事件的主事件循环，并拥有消费者序列的所有权。它有一个名为 `BatchEventProcessor` 的单一表示形式，其中包含事件循环的高效实现，并将回调到用户提供的 `EventHandler` 接口的实现。
- **Event Handler**: 由用户实现的接口，代表 Disruptor 的消费者。
- **Producer**: 这是调用 Disruptor 将事件加入队列的用户代码。这个概念在代码中也没有体现。

为了更好地理解这些要素，下面举例说明 LMAX 如何在其高性能核心服务（如何交易所）中使用 Disruptor。



#### 广播事件

这是队列与 Disruptor 之间最大的行为差异。

当多个消费者监听同一个 Disruptor 时，它会将所有事件发布给所有消费者。相比之下，队列只会将单个事件发送给单个消费者。当需要对同一数据执行多个并发操作时，可以利用 Disruptor 的这种行为。

> LMAX 的典型操作示例包含三个操作：- 日志记录（将输入数据写入持久日志文件）、- 复制（将输入数据发送到另一台机器，以确保数据有远程副本）、- 业务逻辑（实际处理工作）。
>
> 如图1所示，有三个事件处理程序（`JournalConsumer`、`ReplicationConsumer` 和 `ApplicationConsumer`）正在监听 Disruptor。每个事件处理程序都会接收 Disruptor 中所有可用的消息（顺序相同）。这使得每个消费者可以并行执行任务。



#### 消费者依赖关系图

为了支持并行处理行为在实际应用中的实现，必须支持消费者之间的协调。以上述示例为例，必须阻止业务逻辑消费者在日志记录和复制消费者完成其任务之前继续执行。我们将此概念称为**门禁**（或者更准确地说，该功能是一种**门禁**形式）。

**门禁**发生在两个地方：

- 首先，我们需要确保生产者不会超出消费者的数量。这可以通过调用 `RingBuffer.addGatingConsumers()` 将相关的消费者添加到 Disruptor 中来实现。
- 其次，前面提到的情况是通过构建一个包含来自必须先完成处理的组件的序列的序列屏障来实现的。

如图1所示，有3个消费者正在监听来自 `RingBuffer` 的事件。本例中包含一个依赖关系图。

`ApplicationConsumer` 依赖于 `JournalConsumer` 和 `ReplicationConsumer`。这意味着 `JournalConsumer` 和 `ReplicationConsumer` 可以彼此并行运行。这种依赖关系可以通过 `ApplicationConsumer` 的 `SequenceBarrier` 和 `JournalConsumer` 和 `ReplicationConsumer` 的 `Sequence` 之间的连接来体现。

值得注意的是 `Sequencer` 和消费者之间的关系。它的一个作用是确保发布不会超出 `RingBuffer` 的大小。为此，下游消费者的序列号都不能小于 `RingBuffer` 序列号减去 `RingBuffer` 的大小。

然而，利用依赖关系图可以实现一种有趣的优化。由于 `ApplicationConsumer` 的序列号保证小于或等于 `JournalConsumer` 和 `ReplicationConsumer`  的序列号（这是依赖关系所保证的），因此 `Sequencer` 只需查看 `ApplicationConsumer` 的序列号即可。更一般地说，`Sequencer`  只需要知道依赖树中叶节点（即消费者）的序列号即可。



#### 事件预分配

Disruptor 的目标之一是使其能够在低延迟环境下使用。在低延迟系统中，必须减少或消除内存分配。在基于 Java 的系统中，其目的是减少因垃圾回收而导致的停顿次数。

为了支持此功能，用户可以预先分配 Disruptor 中事件所需的存储空间。在构建过程中，用户会提供`EventFactory`，该 `EventFactory` 将在 Disruptor 的 `RingBuffer` 中为每个条目调用。当向 Disruptor 发布新数据时，API 允许用户获取已构建的对象，以便他们可以调用该存储对象的方法或更新其字段。Disruptor 保证，只要这些操作正确实现，它们就是并发安全的。



#### 可选无锁 

为了实现低延迟，另一个关键的实现细节是广泛使用无锁算法来实现 Disruptor。所有内存可见性和正确性保证都通过内存屏障和或比较交换（`compare-and-swap`）操作来实现。

> 只有在 `BlockingWaitStrategy` 中才需要实际的锁。
>
> 这样做仅仅是为了使用**条件**判断，以便在等待新事件到达时，可以将正在执行任务的线程暂停。许多低延迟系统都会使用**忙等待**来避免使用条件判断可能带来的抖动；然而，过多的系统忙等待操作会导致性能显著下降，尤其是在 CPU 资源严重受限的情况下，例如虚拟化环境中的 Web 服务器。



### 入门

#### 获取 Disruptor

Disruptor jar 可以从 Maven Central 获取，并可从那里集成到你选择的依赖管理器中。

#### 基本生产和消费

为了更好地理解 Disruptor，我们将考虑一个非常简单且人为设计的例子。我们将从生产者向消费者传递一个长整型值，消费者只需打印出该值即可。

目前，针对 Disruptor 的生产者和消费者，存在几种不同的书写风格。虽然它们本质上都大同小异，但每种风格之间可能存在一些细微差别，下文将对此进行探讨。

首先，我们先定义一个`Event`，该事件将承载数据，并且在 以下所有示例中都是通用的。

示例 `LongEvent`

```java
public class LongEvent {
  private long value;
  
  public void set(long value) {
    this.value = value;
  }
  
  @Override
  public String toString() {
    return "LongEvent{" + "value=" + value + '}';
  }
}
```

为了让 Disruptor 预先分配这些事件，我们需要一个 `EventFactory` 来执行构造操作。这可以是方法引用，例如 `LongEvent::new`，也可以是 `EventFactory` 接口的显式实现：

示例 `LongEventFactory`

```java
public class LongEventFactory implements EventFactory<LongEvent> {
  @Override
  public LongEvent newInstance() {
    return new LongEvent();
  }
}
```

定义好事件后，我们需要创建一个事件消费者来处理这些事件。例如，我们将创建一个 `EventHandler`，将值打印到控制台。

示例 `LongEventHandler`

```java
public class LongEventHandler impelments EventHandler<LongEvent> {
  @Override
  public void onEvent(LongEvent event, long sequence, boolean endOfBatch) {
    	System.out.println("Event: " + event);
  }
}
```

最后，我们需要这些事件的来源。为简单起见，我们假设数据来自某种I/O设备，例如网络或文件，并以 `ByteBuffer` 的形式存在。

#### 发布

##### 使用 Lambdas

自 Disruptor 3.0 版本起，即可使用 Lambda 风格的 API 编写发布器。这是首选方案，它简化了其他方案的复杂性。

**使用 Lambda 发布时间**

```java
import com.lmax.disruptor.dsl.Disruptor;
import com.lmax.disruptor.RingBuffer;
import com.lmax.disruptor.examples.longevent.LongEvent;
import com.lmax.disruptor.util.DaemonThreadFactory;
import java.nio.ByteBuffer;

public class LongEventMain {
  public static void main(String[] args) throws Exception {
    int bufferrSize = 1024; ①
    
    Disruptor<LongEvent> disruptor = new Disruptor<>(LongEvent::new, bufferSize, DaemonThreadFactory.INSTANCE); ②
    
    disruptor.handleEventWith((event, sequence, endOfBatch) ->
    	System.out.println("Event: " + event)); ③
    disruptor.start(); ④
    
    RingBuffer<LongEvent> ringBuffer = disruptor.getRingBuffer(); ⑤
    ByteBuffer bb = ByteBuffer.allocate(8);
    for (long l = 0; true; l++) {
      bb.putLong(0, l);
      ringBuffer.publishEvent((event, sequence, buffer) -> event.set(buffer.getLong(0)), bb);
      Thread.sleep(1000);
    }
  }
}
```

1. 指定 `RingBuffer` 的大小，必须为 2的幂
2. 构造 Disruptor
3. 连接处理器
4. 启动 Disruptor，启动所有线程运行
5. 从 Disruptor 获取用于发布的 `RingBuffer`

> 请注意，`publishEvent()` 使用的 lambda 表达式仅引用传入的参数。
>
> 如果我们把这段代码写成这样：
>
> **捕获 lambda 函数的示例**
>
> ```java
> ByteBuffer bb = ByteBuffer.allocate(8);
> for (long l = 0; true; l++) {
>   bb.putLong(0, l);
>   ringBuffer.publishEvent((event, sequence) -> event.set(bb.getLong(0)));
>   Thread.sleep(1000);
> }
> ```
>
> 这将创建一个捕获 lambda 表达式，这意味着在将 lambda 表达式传递给 `publishEvent()` 调用时，需要实例化一个对象来保存 `ByteBuffer` bb 变量。这会产生额外的（不必要的）垃圾，因此 ，如果需要降低垃圾回收压力，则应优先使用将参数直接传递给 lambda 表达式的调用方式。

鉴于可以使用方法引用来代替匿名 Lambda 表达式，可以将示例重写如下：

```java
import com.lmax.disruptor.dsl.Disruptor;
import com.lmax.disruptor.RingBuffer;
import com.lmax.disruptor.examples.longevent.LongEvent;
import com.lmax.disruptor.util.DaemonThreadFactory;
import java.nio.ByteBuffer;

public class LongEventMain {
  public static void handleEvent(LongEvent event, long sequence, boolean endOfBatch) {
		System.out.println("Event: " + event);    	
  }
  
  public static void translate(LongEvent event, long sequence, ByteBuffer buffer) {
    event.set(buffer.getLong(0));
  }
  
  public static void main(String[] args) throws Exception {
    int bufferrSize = 1024;
    
    Disruptor<LongEvent> disruptor = new Disruptor<>(LongEvent::new, bufferSize, DaemonThreadFactory.INSTANCE);
    
    disruptor.handleEventWith(LongEventMain::handleEvent);
    disruptor.start();
    
    RingBuffer<LongEvent> ringBuffer = disruptor.getRingBuffer();
    ByteBuffer bb = ByteBuffer.allocate(8);
    for (long l = 0; true; l++) {
      bb.putLong(0, l);
      ringBuffer.publishEvent(LongEventMain::translate, bb);
      Thread.sleep(1000);
    }
  }
}
```

###### 使用翻译器

在 3.0 版本之前，发布消息的首选方式是通过事件发布器/事件转换器接口：

示例 `LongEventProducer`

```java
import com.lmax.disruptor.RingBuffer;
import com.lmax.disruptor.EventTranslatorOneArg;

import java.nio.ByteBuffer;

public class LongEventProducer {
  private final RingBuffer<LongEvent> ringBuffer;
  
  public LongEventProducer(RingBuffer<LongEvent> ringBuffer) {
    this.ringBuffer = ringBuffer;
  }
  
  private static final EventTranslatorOneArg<LongEvent, ByteBuffer> TRANSLATOR = 
    new EventTranslatorOneArg<LongEvent, ByteBuffer>() {
    	@Override
    	public void translateTo(LongEvent event, long sequence, ByteBuffer bb) {
        event.set(bb.getLong(0));
      };
  }
  
  public void onData(ByteBuffer bb) {
    ringBuffer.publishEvent(TRANSLATOR, bb);
  }
}
```

这种方法使用了多个额外的类（例如 handler、translator），而这些类在使用 lambda 表达式时并非显式必需。其优点在于，可以将翻译器代码提取到一个单独的类中，从而便于进行单元测试。

Disruptor 提供了一系列不同的接口（`EventTranslator`、`EventTranslationOneArg`、`EventTranslationTwoArg`等），可以通过实现这些接口来提供转换器。这样做的目的是允许将转换器表示为静态或 lambda 表达式（见上文）。转换方法的参数通过对 `RingBuffer` 的调用传递给转换器。

##### 使用旧版 API 发布

我们还可以采用一种更"原始"的方法：

旧版示例 **LongEventProducer**

```java
import com.lmax.disruptor.RingBuffer;
import com.lmax.disruptor.examples.longevent.LongEvent;

import java.nio.ByteBuffer;

public class LongEventProducer {
  private final RingBuffer<LongEvent> ringBuffer;
  
  public LongEventProducer(RingBuffer<LongEvent> ringBuffer) {
    this.ringBuffer = ringBuffer;
  }
  
  public void onData(ByteBuffer bb) {
    long sequence = ringBuffer.next(); // ①
    try {
      LongEvent event = ringBuffer.get(sequence); // ②
      event.set(bb.getLong(0)); // ③
    } finally {
      ringBuffer.publish(sequence);
    }
  }
}
```

1. 获取下一个序列
2. 获取 Disruptor 中该序列的条目
3. 请填写数据

显而易见，事件发布比使用简单的队列要复杂得多。这是因为需要预先分配事件空间。它（在最底层）要求采用两阶段消息发布方法，即先在 `RingBuffer` 中声明槽位，然后发布可用数据。

> 此外，还需要将发布内容包裹在`try/finally` 代码块中。
>
> 如果我们在 `RingBuffer` 中声明一个槽位（调用 `RingBuffer#next()`），则必须发布此序列。否则，可能会导致 Disruptor 的状态损坏。
>
> 具体来说，在多生产者场景下，这将导致消费者停滞不前，且必须重启才能恢复。因此，建议使用 Lambda 函数或 `EventTranslator` API。

最后一步是将所有部件连接起来。虽然可以手动连接每个组件，但这可能很复杂，因此我们提供了一个 DSL（Domain-Sepcific Langauge，领域特定语言）来简化组装过程。

```java
import com.lmax.disruptor.RingBuffer;
import com.lmax.disruptor.dsl.Disruptor;
import com.lmax.disruptor.examples.longevent.LongEvent;
import com.lmax.disruptor.examples.longevnet.LongEventFactory;
import com.lmax.disruptor.examples.longevnet.LongEventHandler;
import com.lmax.disruptor.util.DaemonThreadFactory;

import java.nio.ByteBuffer;

public class LongEventMain {
	public static void main(String[] args) throws Exception {
  	LongEventFactory factory = new LongEventFactory();
    
    int bufferSize = 1024;
    Disruptor<LongEvent> disruptor = new Disruptor<>(factory, bufferSize, DaemonThreadFactory.INSTANCE);
    disruptor.handleEventWith(new LongEventHandler());
    disruptor.start();
    
    RingBuffer<LongEvent> ringBuffer = disruptor.getRingBuffer();
    LongEventProducer producer = new LongEventProducer(ringBuffer);
    ByteBuffer bb = ByteBuffer.allocate(8);
    for (long l = 0; true; l++) {
      bb.putLong(0, l);
      producer.onData(bb);
      Thread.sleep(1000);
    }
  }
}
```



#### 基础调优选项

上述方法在大多数部署场景下都能正常工作。但是，还有一些调优选项可以用来提升性能。

两种主要的调优方式是：

- 单生产者 vs 多生产者
- 其他等待策略

构建  Disruptor 时，这两个选项都会被设置 。

**调优 Disruptor**

```java
public class LongEventMain {
  public static void main(String[] args) {
    // ...
    Disruptor<LongEvent> disruptor = new Disruptor(
    	factory,
      bufferSize,
      DeamonThreadFactory.INSTANCE,
      ProducerType.SINGLE, // ①
      new BlockingWaitStrategy(); // ②
    )
    // ...
  }
}
```

1. 使用 `ProducerType#SINGLE` 来创建一个 `SingleProducerSequencer`；使用 `ProducerType#MULTI` 创建 `MultProducerSequencer`
2. 设置所需的 `WaitStrategy`

















## 开发 Disruptor

- 编译
- 代码标准



## 设计与实现

- 单生产者算法
- 多生产者算法



## 已知问题

