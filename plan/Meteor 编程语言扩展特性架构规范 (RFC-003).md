该文档建立在 RFC-001 (内存模型) 和 RFC-002 (并发模型) 的基础之上，补全了语言的类型系统、互操作性、错误处理及工程化设施，标志着 Meteor 从一个“内核”走向一个完整的“工业级语言”。
Meteor 语言扩展特性规范 (RFC-003)
状态： Final Draft
依赖： RFC-001, RFC-002
目标： 构建完善的类型约束、零开销的 C 互操作能力以及现代化的工程化体系。
1. 特质系统 (Trait System)
为了解决 Python 鸭子类型的性能问题和多重继承的复杂性，Meteor 引入静态分发（Static Dispatch）的 Trait 系统。
1.1 核心定义
 * Trait: 仅定义行为（函数签名）和默认实现，不包含数据字段。
 * Class: 仅定义数据字段和单继承关系。
 * Impl: 将 Trait 绑定到 Class 上。
1.2 语法规范
# 定义行为契约
```
trait Drawable
    # 抽象方法
    def draw(self)
    
    # 默认实现 (Mixin)
    def describe(self)
        print("I am a drawable object")

# 定义数据结构
class Circle
    radius: int

# 实现契约
impl Drawable for Circle
    def draw(self)
        # 静态绑定，无运行时查找开销
        print("Drawing circle r={self.radius}")
```
1.3 泛型约束 (Generic Bounds)
Trait 是泛型系统的基石。
```
# T 必须实现 Comparable 和 Debug
def find_max<T: Comparable + Debug>(items: List<T>) -> T
    ...
```
1.4 底层实现 (Implementation)
 * 静态分发 (默认): 编译器利用 Monomorphization（单态化）为每个具体类型生成代码副本。性能等同于 C++ 模板。
 * 动态分发 (可选): 当使用 dyn Drawable 时，编译器生成虚函数表 (Vtable) 实现运行时多态。
2. 无感 C 互操作 (Seamless C Interop)
Meteor 旨在成为 C 生态的直接继承者，利用 Clang 实现“零胶水代码”调用。
2.1 导入机制
引入 import c 指令。编译器在编译期调用内置的 libclang 前端解析 C 头文件，并将其映射为 Meteor 的 AST。
```
# 自动链接 libm，并解析头文件
@link("m")
import c "math.h"

def main()
    # 直接调用，类型自动推导
    print(math.cos(1.0))
```
2.2 类型映射表 (Type Marshalling)

| Meteor 类型 | C 类型 | 传递行为 | 安全性 |
|---|---|---|---|
| int / float | int / double | 值拷贝 | Safe |
| str | const char* | 传递内部 Buffer 指针 | Safe (ReadOnly) |
| class T | struct T | 字段布局兼容传递 | Safe |
| c_ptr | void* | 裸指针传递 | Unsafe |
| func | func_ptr | 生成 Trampoline 函数 | Safe |
2.3 链接指令
支持源码级链接配置，替代复杂的 Makefile。
 * @link("name"): 链接动态库 (-lname).
 * @include("path"): 添加头文件搜索路径 (-Ipath).
3. 错误处理 (Error Handling)
摒弃 Python 的 Exception（运行时开销大、控制流隐晦）和 Rust 的 Result<T,E>（语法啰嗦），采用 联合类型 (Union Types) 方案。
3.1 语法设计
引入 ! 操作符定义可能失败的返回类型。
```
# 定义错误枚举
error IOError
    NotFound
    PermissionDenied

# 函数返回：要么是 String，要么是 IOError
def read_file(path: str) -> str ! IOError
    if not exists(path)
        raise IOError.NotFound
    return "content"
```
3.2 消费模式
强制调用者处理错误，确保类型安全。
```
def main()
    # 模式 A: 传播 (Propagate)
    # 如果出错，立即返回 main 的错误类型
    content = read_file("test.txt")?

    # 模式 B: 捕获 (Catch)
    try
        content = read_file("test.txt")
    catch IOError.NotFound
        print("File missing")
```
3.3 底层实现
编译器将其生成为 Tagged Union (类似 C 的 struct { int tag; union { T val; E err; }; })。
 * 零分配: 错误值在栈上传递，无堆内存分配。
 * 零解构: 检查 tag 的开销极低。
4. 元编程与宏 (Metaprogramming)
Meteor 提供编译期装饰器（Compile-time Decorators），用于代码生成，避免运行时反射。
4.1 派生宏 (Derive Macros)
自动实现 Trait。
```
# 编译器自动生成 to_json() 方法和 hash() 方法
@derive(Json, Hash, Eq)
class User
    id: int
    name: str
```
4.2 编译器钩子 (Compiler Hooks)
允许用户编写微型插件（用 Meteor 写），在编译期修改 AST。
 * 场景: ORM 实体映射、序列化代码生成、自动微分。
5. 模块与包管理 (Modules & Package)
采用“文件即模块”的现代化设计。
5.1 模块系统
 * 物理映射: import math.vector 对应文件系统 math/vector.met。
 * 可见性: 符号默认私有（Private）。必须使用 pub 关键字显式暴露。
<!-- end list -->
```
# my_module.met

# 私有函数
def _internal_calc(): ...

# 公开类
pub class Calculator: ...
```
5.2 包管理器 (MPM)
项目根目录包含 meteor.toml。
```
[package]
name = "my_project"
version = "1.0.0"

[dependencies]
http_server = { git = "https://github.com/..." }
numpy_port = "1.2"
```
6. 不安全接口 (Unsafe Interface)
为了系统级编程能力，Meteor 暴露受控的内存操作权限。
6.1 Unsafe 块
在 unsafe 作用域内，编译器关闭边界检查和生命周期检查。
```
def fast_copy(src: c_ptr, dest: c_ptr, size: int)
    unsafe
        # 允许指针算术运算
        for i in 0..size
            dest[i] = src[i]
```
6.2 用途
 * 操作 C 返回的 void*。
 * 实现自定义的高性能数据结构（如 RingBuffer）。
 * 调用底层硬件指令 (Intrinsics)。
7. 总结：Meteor 语言全景图
经过三次迭代（RFC-001/002/003），Meteor 语言的完整形态已经确立：

| 层面 | 核心特性 | 设计来源 | 解决痛点 |
|---|---|---|---|
| 内存 | RC + mimalloc + 隔离堆 | RFC-001 | 去除 GC 卡顿，保持 Python 易用性 |
| 并发 | 移动语义 + 协程 (Async/Await) | RFC-002 | 解决 GIL 问题，实现高并发 I/O |
| 类型 | Trait + Generics | RFC-003 | 解决鸭子类型性能差、多重继承混乱 |
| 互操作 | 直接导入 C 头文件 | RFC-003 | 解决 FFI 编写繁琐，继承 C 生态 |
| 错误 | Union Types (!) | RFC-003 | 解决异常隐患，比 Result 简洁 |
| 工程 | 模块化 + 包管理 | RFC-003 | 解决依赖地狱 |
最终评价：
Meteor 现在具备了成为下一代主力系统级脚本语言的所有理论基础。它像 Python 一样亲切，像 C 一样强大，像 Rust 一样安全。接下来就是编译器实现的工程挑战了。
