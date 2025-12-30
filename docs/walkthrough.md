# BigInt 内存优化方案

## 问题描述
在计算第 1,000,000 个斐波那契数时，程序占用了超过 10GB 的内存。经分析，主要原因有两点：
1.  **运算临时变量泄漏**：复杂的 BigInt 运算（如 Karatsuba 乘法）会创建大量临时对象（Intermediate variables），函数返回后未释放。
2.  **循环变量重定义泄漏**：在循环中重复声明变量（如 `c: bigint = a + b`）时，编译器生成的代码未正确释放上一轮循环分配的内存，导致内存持续累积。

## 解决方案

### 1. 修复底层运算泄漏 (`src/meteor/compiler/builtins.py`)
我们引入了手动内存管理机制：
-   **新增 `free_bigint` 函数**：用于释放 BigInt 对象及其内部数组的内存。
-   **从底层清理**：在以下内置函数中，在返回结果前手动释放所有中间产生的临时变量：
    -   `define_bigint_mul` (Karatsuba乘法)：单次递归调用清理约 14 个临时变量。
    -   `define_bigint_div` / `define_bigint_mod`：清理除法过程中产生的临时商和余数。
    -   `define_print_bigint`：清理打印时产生的十进制转换数组。

### 2. 修复循环重定义泄漏 (`src/meteor/compiler/code_generator.py`)
我们修改了编译器生成的代码逻辑，使其能安全地复用或释放循环变量：
-   **零初始化 (`get_entry_alloca`)**：强制所有 BigInt 变量在函数入口处初始化为 `NULL`。
-   **无条件释放 (`visit_vardecl`)**：修改变量声明逻辑。现在，每次对变量赋值前，都会**无条件检查**其指针是否非空。如果非空（说明是循环中的上一轮残留数据），则先释放旧内存，再进行赋值。

## 验证结果
运行 `tests/meteor/fib_bigint.met` 计算第 1,000,000 个斐波那契数：
-   **结果**：程序成功运行并输出结果。
-   **内存**：内存占用大幅降低，不再随循环次数线性增长。

## 关键代码变更
-   `src/meteor/compiler/builtins.py`: 添加 `define_free_bigint`, 修改 `mul`, `div`, `mod`, `print`。
-   `src/meteor/compiler/code_generator.py`: 修改 `visit_vardecl` 和 `get_entry_alloca`。
