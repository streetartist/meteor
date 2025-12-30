# 编译器隐式类型转换修复：BigInt 返回值类型不匹配问题

## 1. 问题描述
在编译 `fib_fast.met` 时，函数尝试返回整数常量（如 `return 0`）：

```meteor
def fib_fast(n: int) -> bigint
    if n == 0
        return 0  # 触发错误
```

编译器报错：
`TypeError: cannot store %"bigint"* to %"bigint"*: mismatching types`

## 2. 原因分析
这是由于编译器内部在处理隐式类型转换（Implicit Cast）时的逻辑缺陷导致的：

1.  **转换过程**：编译器识别到需要将 `int` (0) 转换为 `bigint`，调用了 `int_to_bigint` 函数。
2.  **类型差异**：
    *   `int_to_bigint` 返回的是一个**指针** (`bigint*`)，指向新创建的 BigInt 对象。
    *   函数返回槽 (`RET_VAR`) 期望的是一个**值** (`bigint` 结构体)。
3.  **冲突**：原本的 `visit_return` 逻辑直接尝试将这个指针 `store` 到返回槽中。LLVM IR 规则禁止将 `Type*` 存储到 `Type` 类型的内存区域，因此报错。

## 3. 修复方案 (`src/meteor/compiler/code_generator.py`)

修改 `visit_return` 方法，增加“指针自动解引用”逻辑：

```python
def visit_return(self, node):
    val = self.visit(node.value)
    if val.type != ir.VoidType():
        # 1. 尝试常规转换
        val = self.comp_cast(val, self.search_scopes(RET_VAR).type.pointee, node)
        
        # 2. 【新增逻辑】检查指针 vs 值
        # 如果转换后拿到的是指针，但目标需要的是值，则进行 Load 操作
        dest_type = self.search_scopes(RET_VAR).type.pointee
        if isinstance(val.type, ir.PointerType) and val.type.pointee == dest_type:
            val = self.builder.load(val)
            
        # 3. 存储返回值
        self.store(val, RET_VAR)
```

## 4. 结果
修复后，编译器能够正确处理返回 `int` 字面量到 `bigint` 函数的情况，自动完成 `int -> bigint* -> bigint` 的转换和加载过程。
