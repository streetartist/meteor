# 数组无限循环 Bug 分析与修复

## 1. 问题现象
在于 Meteor 语言中执行如下代码时：
```meteor
arr = [1, 2, 3]
for x in arr
    print(x)
```
程序会进入无限循环，并输出随机的垃圾值（garbage values），导致程序无法正常终止。

## 2. 错误原因分析
经过排查，问题的根源在于**数组的存储和传递方式**。

### 问题细节：
1. **值语义 (Value Semantics) 问题**：
   - 在修复前，Meteor 编译器在处理数组赋值（如 `arr = ...`）时，尝试将整个数组结构体（包含头部、大小、容量、数据指针）**按值拷贝**到栈上。
   - `define_array` 函数返回的是加载后的数组结构体值 (`self.load(array_ptr)`).
   - `visit_assign` 试图将这个结构体值存储到局部变量 `arr` 中。

2. **拷贝失败**：
   - 调试显示，`define_array` 内部创建的堆上数组是正确的（Size=3）。
   - 但是，`for` 循环中读取到的 `arr` 变量（位于栈上）的 Size 却是 0。
   - 这表明从堆到栈的结构体拷贝过程出现了问题，或者 LLVM IR 在处理这种复杂结构体的 Store/Load 操作时未能正确保留数据。导致循环的终止条件（`arr.length`）读取到的是 0 或垃圾值，从而引发逻辑错误。

## 3. 修复方案
我们通过将数组改为**引用语义 (Reference Semantics)** 来修复此问题，这与大多数现代编程语言（如 Java, Python）中处理对象的方式一致。

### 修复步骤：
1. **修改 `define_array` 和 `define_tuple`**：
   - 不再返回数组结构体的值，而是直接返回指向堆上数组结构体的**指针** (`array_ptr`).
   - 代码变更示例：
     ```python
     # 修复前
     return self.load(array_ptr)
     
     # 修复后
     return array_ptr
     ```

2. **更新 `visit_for`**：
   -由于 `arr` 变量现在存储的是一个指针（指向数组结构体），在使用它获取数组长度或元素之前，需要先进行**解引用 (Dereference)**。
   - 代码变更示例：
     ```python
     # 获取迭代器指针
     iterator_ptr = self.search_scopes(node.iterator.value)
     # 加载指针指向的实际数组对象
     iterator = self.load(iterator_ptr)
     ```

3. **更新 `visit_range`**：
   -同样将 Range 创建的数组也改为返回指针，保持一致性。

## 4. 验证结果
修复后，运行 `tests/meteor/array_for.met` 测试用例：
```
1
2
3
```
输出正确，且程序正常退出。无限循环问题已解决。
