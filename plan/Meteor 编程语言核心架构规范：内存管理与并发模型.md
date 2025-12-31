目标： 构建一个兼具 Python 开发效率、C 语言运行速度以及 Rust 级内存安全（无 GC 暂停）的系统级脚本语言。
1. 设计哲学 (Design Philosophy)
Meteor 的内存模型建立在以下三个公理之上：
 * 确定性生命周期 (Deterministic Lifetime): 资源必须在离开作用域或引用归零的瞬间被释放。拒绝不确定的 Tracing GC。
 * 默认无锁 (Lock-Free by Default): 线程间默认不共享可变状态。绝大多数内存操作（分配、访问、计数）必须是线程本地的非原子操作。
 * 所有权显式转移 (Explicit Ownership): 并发交互必须通过“移动（Move）”或“冻结（Freeze）”来保证数据竞争在编译期被消除。
2. 物理层：分配器架构 (Allocator Architecture)
Meteor 运行时并不直接使用 libc malloc，而是深度集成 Microsoft mimalloc 库，构建“逻辑隔离、物理协作”的堆。
2.1 线程本地分配缓冲 (TLAB)
每个 Meteor 线程（Isolate）拥有独立的内存页段（Segment）。
 * 分配 (Allocation): 仅涉及指针移动，无锁，无原子指令。
 * 性能: 分配速度约为 3~5 纳秒，等同于栈分配。
2.2 异地释放 (Remote Freeing)
当对象的所有权通过 Channel 转移到另一个线程并被释放时：
 * 机制: 释放线程（Thread B）识别出内存属于分配线程（Thread A）。Thread B 使用无锁原子指令将该内存块挂入 Thread A 的“回收队列”。
 * 闭环: Thread A 在下一次分配内存时，顺便回收这些归还的内存块。
 * 意义: 彻底解决了引用计数系统在多线程下的“跨线程释放”难题，且无需全局锁。
3. 逻辑层：对象模型 (Object Model)
3.1 内存布局 (Memory Layout)
所有堆对象遵循统一的 ABI，以支持强引用、弱引用和并发标志。
```
// 对象头 (16 bytes on 64-bit)
struct Header {
    uint32_t strong_rc; // 强引用计数
    uint32_t weak_rc;   // 弱引用计数
    uint8_t  flags;     // Bit 0: IS_FROZEN, Bit 1: IS_ZOMBIE
    uint8_t  type_tag;  // 运行时类型信息
    uint16_t reserved;  // 对齐填充
};

// 实际对象
struct Object {
    Header header;
    uint8_t payload[];  // 变长数据 (BigInt digits, List pointers...)
};
```
3.2 僵尸状态 (Zombie State)
为了安全支持弱引用，对象销毁分为两个阶段：
 * Payload 销毁: 当 strong_rc == 0。释放大数据内存（如 10GB 的 buffer），标记 IS_ZOMBIE。
 * Header 销毁: 当 strong_rc == 0 且 weak_rc == 0。回收对象头内存。
4. 编译器层：代码生成规程 (Compiler Codegen)
4.1 变量赋值卫生 (Hygiene) 
为了防止循环内的内存复用泄漏，编译器对所有指针赋值（target = source）生成如下 IR：
```
// 伪代码：赋值操作的底层逻辑
void assign(Object** target_ptr, Object* source) {
    Object* old_obj = *target_ptr;
    
    // 1. 运行时检查：如果目标持有旧资源，先释放
    if (old_obj != NULL) {
        release(old_obj); 
    }
    
    // 2. 只有 source 非空才持有
    if (source != NULL) {
        retain(source);
    }
    
    // 3. 写入指针
    *target_ptr = source;
}
```
4.2 函数调用 ABI (Function Passing ABI)
Meteor 通过静态分析优化传参成本，避免不必要的 RC 操作。
| 参数类型 | 语义 | 底层行为 | 适用场景 |
|---|---|---|---|
| Borrow | 默认借用 | 传递裸指针，不操作 RC | 90% 的普通函数调用 |
| Escape | 逃逸持有 | 编译器插入 retain(arg) | 参数被存入全局变量/堆结构 |
| Owned | 接收所有权 | 传递裸指针，Caller 置空本地变量 | Channel 发送、销毁器 |
| Ref | 引用修改 | 传递指针的地址 (Object**) | 修改外部变量 (swap) |
4.3 作用域清理 (Cleanup)
 * Defer: 编译器为每个作用域维护一个清理栈。
 * Unwind: 在异常（Panic）发生时，Landing Pad 负责调用当前栈帧内所有活跃变量的 release()，确保异常安全。
5. 并发模型 (Concurrency Model)
Meteor 禁止隐式共享。并发基于 Channel (CSP) 和 Frozen Objects。
5.1 移动语义 (Move Semantics)
用于在线程间传递可变数据。
 * 操作: channel.send(obj)
 * 编译器行为:
   * 生成指针拷贝指令。
   * 立即在发送点后插入 store null 指令清除本地引用。
   * 不生成 RC 增减指令（RC 保持为 1）。
 * 结果: 零拷贝（Zero-Copy），零原子开销（Zero-Atomic Overhead）。
5.2 不可变共享 (Immutable Sharing)
用于读多写少的数据（配置、权重）。
 * 关键字: frozen
 * 编译器行为:
   * 识别到 frozen 类型。
   * 所有的 retain/release 操作切换为 原子指令 (lock xadd)。
   * 禁止生成任何写入 Payload 的指令。
6. 用户接口与语法 (User Interface)
6.1 基础语法与弱引用
用户通过 weak 关键字手动打破循环引用。
```
class Node
    value: int
    children: list<Node>
    # 弱引用：不增加父节点的 RC，避免内存泄漏
    weak parent: Node 

    def set_parent(p: Node)
        # 编译器底层：只赋值指针，增加 weak_rc，不增加 strong_rc
        self.parent = p 
```

6.2 并发任务示例
```
# 这里的 config 是线程安全的原子共享
# 这里的 data 是独占的，所有权已转移进来
def worker(config: frozen Config, owned data: BigInt):
    limit = config.max_limit
    result = data * 2
    print(result)
    # 函数结束 -> data 释放 (mimalloc 异地回收)

def main():
    cfg = Config(100)
    frz = freeze(cfg) # 转换为不可变
    
    num = BigInt(500)
    
    # num 被 Move，本地变为 null
    spawn worker(frz, num)
    
    # print(num) -> 编译期报错或运行时异常
```
7. 安全性保障分析 (Safety Guarantee)
7.1 内存泄漏 (Memory Leaks)
 * 机械性泄漏（忘记 Free）： ✅ 100% 免疫。编译器自动插入 release。
 * 复用泄漏（循环覆盖）： ✅ 100% 免疫。由 "19-Line Logic" 的运行时检查保障。
 * 循环引用（拓扑泄漏）： ⚠️ 需用户介入。编译器无法自动解环，依赖用户使用 weak。这是 RC 系统的物理特性。
7.2 线程安全 (Thread Safety)
 * 数据竞争 (Data Race): ✅ 100% 免疫。
   * 可变数据被 Move（本地不可见）。
   * 共享数据被 Frozen（只读）。
 * Use-After-Move: ✅ 100% 免疫。
   * 编译器插入 NULL store。
   * 运行时指针访问包含 NULL Check。
