<p align="center">
<b style="font-size: 32px;">Meteor</b>
<br>
<i>一门编译型、静态类型的现代编程语言</i>
</p>

___
[![License: MIT](https://img.shields.io/badge/License-MIT-brightgreen.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-0.4.1-brightgreen.svg)](https://github.com/alinalihassan/pyLesma/blob/master/LICENSE.md)

**Meteor** 是一门编译型、静态类型、命令式和面向对象的编程语言，注重表达力、优雅和简洁，同时不牺牲性能。

> 本项目基于 [pyLesma](https://github.com/alinalihassan/pyLesma) 进行开发，感谢原作者 Alin Ali Hassan 的开源贡献。

## 特性

### 核心特性
- **高性能** - 基于 LLVM 后端，享受业界领先的编译优化
- **编译执行** - 支持 AOT（提前编译）和 JIT（即时编译）两种模式
- **静态类型** - 编译期类型检查，更早发现错误
- **简洁语法** - Python 风格的缩进语法，代码清晰易读

### 丰富的类型系统
- **基础类型** - `int`, `float`, `bool`, `str`
- **大整数 (bigint)** - 任意精度整数，突破 64 位限制
- **高精度小数 (decimal)** - 精确的十进制运算，适合金融计算
- **数值类型 (number)** - 可存放任意数值类型的联合类型
- **动态类型 (dynamic)** - Python 风格，可存放任意类型
- **集合类型** - `list`, `tuple`, 支持泛型
- **枚举与类** - `enum`, `class`, 支持继承

### 类型转换
- 自动类型提升：`int` + `decimal` → `decimal`
- 显式类型转换：`as decimal`, `as bigint`
- 运行时类型分发：`dynamic` 和 `number` 类型

### 其他特性
- **函数** - 一等公民，支持匿名函数
- **运算符重载** - 自定义类型的运算行为
- **defer 语句** - 延迟执行，资源管理更简单
- **FFI** - 外部函数接口，调用 C 库

## 性能 Benchmark

### 大整数 Fibonacci：Meteor vs C

计算第 **10,000,000** 个斐波那契数（约 **209 万位**十进制数字），使用 Fast Doubling 算法 O(log n)：

| 版本 | 代码行数 | 运行时间 | 相对速度 |
|------|----------|----------|----------|
| **Meteor** | ~40 行 | 54.0s | 1.00x |
| **C (gcc -O3)** | ~280 行 | 48.8s | 1.11x |

> **结论**：Meteor 达到了高度优化 C 代码 **90%** 的性能，但代码量仅为 **1/7**。

#### Meteor 代码（简洁优雅）
```
def fib_fast(n: int) -> bigint
    if n == 0
        return 0
    if n == 1
        return 1
    a: bigint = 0
    b: bigint = 1
    i: int = 30
    started: bool = false
    while i >= 0
        bit: int = (n >> i) and 1
        if bit == 1
            started = true
        if started
            two_b: bigint = b + b
            c: bigint = a * (two_b - a)
            d: bigint = a * a + b * b
            if bit == 0
                a = c
                b = d
            else
                a = d
                b = c + d
        i = i - 1
    return a
```

C 语言实现需要手写 BigInt 结构体、内存管理、加/减/乘法函数、打印优化等约 280 行代码。

## 示例

### Hello World
```
print("Hello, Meteor!")
```

### 变量与类型
```
let x: int = 42
let pi: float = 3.14159
let name: str = "Meteor"
let flag: bool = true
```

### 大整数运算
```
let big: bigint = 12345678901234567890
let result = big * big
print(result)
```

### 高精度小数
```
let price: decimal = 19.99
let quantity: decimal = 3
let total = price * quantity
print(total)  # 输出: 5.997e1
```

### 动态类型
```
let arr: list[dynamic] = []
arr.append(42)
arr.append(3.14)
arr.append("hello")
arr.append(true)
```

### 类与继承
```
class Animal
    def speak(self)
        print("...")

class Dog(Animal)
    def speak(self)
        print("Woof!")
```

## 安装

### 依赖
- Python 3.8+
- LLVM 11.x
- Clang（AOT 编译需要）

### 安装步骤
```bash
# 克隆仓库
git clone https://github.com/your-repo/meteor

# 安装依赖
pip install -r requirements.txt

# (可选) 安装 Clang 用于 AOT 编译
# Ubuntu/Debian:
sudo apt install clang -y
# Windows: 安装 LLVM 并添加到 PATH
```

## 使用

### 运行程序 (JIT)
```bash
python src/meteor.py run your_program.met
```

### 编译程序 (AOT)
```bash
python src/meteor.py compile your_program.met
python src/meteor.py compile -o output your_program.met
```

### 输出 LLVM IR
```bash
python src/meteor.py compile -l your_program.met
```

### 调试模式
```bash
python src/meteor.py run -d your_program.met
```

### 帮助
```bash
python src/meteor.py -h
```

## 文件扩展名

Meteor 源文件使用 `.met` 扩展名。

## 致谢

本项目基于 [pyLesma](https://github.com/alinalihassan/pyLesma) 开发，原项目由 Alin Ali Hassan 创建。我们在其基础上进行了扩展和改进，添加了 bigint、decimal、number、dynamic 等新类型支持。

## 许可证

MIT License
