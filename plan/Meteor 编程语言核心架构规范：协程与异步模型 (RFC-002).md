本文档基于 Meteor 已经确立的 RC + 隔离堆 + 移动语义 内存架构，定义了一套高性能、无栈（Stackless）且内存安全的异步编程模型。
Meteor 语言架构设计规范：协程与异步 (RFC-002)
状态： Final Draft
依赖： RFC-001 (Memory Model)
目标： 实现类似 Node.js 的高并发 I/O 能力，同时保持类似 C/Rust 的零运行时开销（Zero-Cost Abstractions）。
1. 核心设计哲学
 * 无栈协程 (Stackless): 协程本质上是编译期生成的状态机对象，而非独立的执行栈。内存开销极低（仅数百字节），无需动态栈伸缩。
 * 单线程事件循环 (Thread-Local Loop): 每个隔离堆（Isolate）拥有独立的 I/O Reactor。协程默认不跨线程，避免锁竞争。
 * 引用计数协同 (RC Synergy): 利用 Meteor 的引用计数机制，自然解决 Rust 异步中复杂的 Pin 问题（因为对象地址固定，指针传递依然有效）。
 * 结构化并发 (Structured Concurrency): 强制协程在作用域内生命周期闭环，防止任务泄漏。
2. 编译器层：状态机降级 (State Machine Lowering)
Meteor 编译器将 async 函数转换为一个实现了 Future 接口的结构体（Class）。
2.1 源码示例
```
async def fetch_and_process(url: str) -> Data:
    print("Start")
    # 挂起点 1 (Suspend Point 1)
    raw = await http.get(url) 
    
    # 挂起点 2 (Suspend Point 2)
    # 可能抛出异常
    result = await decoder.decode(raw)
     
    return result
```
2.2 编译器生成的结构体 (伪代码)
编译器会分析函数的控制流图 (CFG)，提取所有跨越 await 点的局部变量，将其提升为结构体字段。
```
class FetchAndProcessStateMachine(Future):
    # 状态字段
    _state: int = 0
    
    # 参数与提升的局部变量 (保存在堆上)
    _url: str
    _raw: Response
    _result: Data
    
    # 子任务 (持有当前正在等待的 Future)
    _child_future: Future
    
    def poll(self, context: Context) -> PollResult:
        switch self._state:
            case 0:
                print("Start")
                self._child_future = http.get(self._url)
                self._state = 1
                return Pending # 立即返回，交出控制权

            case 1:
                # 检查子任务
                res = self._child_future.poll(context)
                if res is Pending: return Pending
                
                # 子任务完成，获取结果
                self._raw = res.value
                
                # 准备下一步
                self._child_future = decoder.decode(self._raw)
                self._state = 2
                return Pending
                
            case 2:
                res = self._child_future.poll(context)
                if res is Pending: return Pending
                
                # 最终结果
                self._result = res.value
                return Ready(self._result)
                
            case ERROR_STATE:
                # 异常处理逻辑...
```
2.3 内存优势
由于 Meteor 使用引用计数：
 * 这个 StateMachine 对象分配在堆上。
 * _url 等字段是对其他对象的引用（指针）。
 * 关键点： 即使 StateMachine 被移动（指针拷贝），内部字段指向的地址不变。因此，Meteor 不需要 Rust 的 Pin<P> 机制，大大降低了实现复杂度和用户心智负担。
3. 运行时层：事件循环与调度 (Runtime & Scheduling)
每个 Meteor 线程（Isolate）启动时初始化一个 Reactor。
3.1 核心组件
 * Executor (任务队列): 一个双端队列，存放所有处于 Ready 状态的顶层 Task。
 * Reactor (I/O 驱动): 基于 epoll (Linux), kqueue (macOS), IOCP (Windows)。
3.2 运行流程
 * Polling: 循环从 Executor 取出 Task，调用其 poll() 方法。
 * Suspending: 如果 poll() 返回 Pending，该 Task 暂停执行。
   * 如果是等待 I/O：将 Task 的句柄（Handle）注册到 Reactor。
   * 如果是等待子协程：父协程什么都不做，子协程完成后会唤醒父协程（通过 Waker）。
 * Parking: 当 Executor 为空时，线程进入休眠（阻塞在 epoll_wait），等待 I/O 事件唤醒。
4. 并发与并行模型 (Concurrency vs Parallelism)
Meteor 严格区分单线程的“异步”与多线程的“并行”。
4.1 异步 (Async) - 单线程并发
 * 关键字: async, await
 * 适用: I/O 密集型 (网络请求, 文件读写)。
 * 机制: 在同一个 Isolate 内的时间片轮转。无锁，无数据竞争。
4.2 并行 (Parallel) - 多线程计算
 * 关键字: spawn, Channel
 * 适用: CPU 密集型 (图像处理, 矩阵运算)。
 * 机制: 启动新的 Isolate，必须通过 Channel 移动数据。
4.3 桥接模式 (The Bridge)
如何在异步函数中等待繁重的 CPU 任务？使用 await channel.recv()。
```
# 主线程 (UI/IO)
async def handle_request(req):
    # 1. 准备数据
    data = await db.fetch(req.id)
    
    # 2. 启动 Worker 线程处理 (CPU 密集)
    ch = Channel()
    spawn worker_task(ch, owned data) # data 被移交
    
    # 3. 异步等待 Worker 结果
    # 主线程不会卡死，可以处理其他请求
    result = await ch.recv_async() 
    
    return result
```
5. 结构化并发 (Structured Concurrency)
为了防止“游离协程”导致的资源泄漏和异常吞没，Meteor 引入作用域控制。
5.1 任务作用域 (Task Scope)
```
async def main():
    print("Starting...")
    
    # 创建一个并发作用域
    # 只有当 scope 内所有 spawn 的任务都完成后，
    # 才会继续执行下一行
    await scope:
        # 并发执行两个任务
        scope.spawn(download("file1"))
        scope.spawn(download("file2"))
        
        # 如果其中一个抛出异常，scope 会自动取消另一个任务
        
    print("All downloads finished!")
```
5.2 取消机制 (Cancellation)
 * 原理: Future 接口有一个 cancel() 方法。
 * 传播: 当 Scope 被取消时，它会递归调用所有子 Future 的 cancel()。
 * I/O 响应: 底层 Reactor 收到 cancel 信号，从 epoll 中移除监听并关闭 socket。
6. 标准库设计 (Stdlib Design)
为了缓解“函数染色”问题，标准库采用“多态感知”设计。
6.1 智能 Map/Filter
标准库的高阶函数能自动识别回调类型。
```
# 同步回调
list.map(x -> x * 2) 
# -> 返回 List

# 异步回调
# 编译器推导：map 内部会使用 await，返回值变成 Future<List>
await list.map(async x -> await http.get(x)) 
```
6.2 顶层 Await (Top-level Await)
允许在脚本顶层直接使用 await，编译器自动将其包裹在隐式的 main 协程中并启动 Event Loop。
7. 异常处理 (Error Handling)
协程中的异常必须能够穿透状态机边界。
 * 状态机生成: 编译器生成状态机时，会维护一个 ExceptionTable。
 * 流程:
   * await 处抛出异常。
   * poll() 捕获异常。
   * 查找当前状态对应的 catch 块索引。
   * 状态机跳转到 CATCH_STATE。
   * 如果未捕获，异常向上传播给父 Future (设置父 Future 的结果为 Error)。
8. 总结
Meteor 的协程设计实现了以下工程平衡：

| 特性 | Meteor 方案 | 优势 |
|---|---|---|
| 内存开销 | 无栈状态机 (Stackless) | 极低，数千万协程仅需数 GB 内存 |
| 调度性能 | 单线程 Epoll | 无上下文切换开销，无锁竞争 |
| 易用性 | RC 自动管理 | 无需 Pin，无需生命周期标注 |
| 安全性 | 结构化并发 | 无任务泄漏，异常自动传播 |
这套设计使得 Meteor 能够胜任高并发网络服务（如 Web Server, Gateway）的开发，性能对标 Rust/C++，开发效率对标 Python/Node.js。
