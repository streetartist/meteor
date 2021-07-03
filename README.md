# meteor

[中文](https://github.com/streetartist/meteor/READMEzh.md)

Meteor program language.A fast and easy language

# Meteor 语言

一个快速简单的编程语言

**Meteor** 是一种编译、静态类型、命令式和面向对象的编程语言，专注于表现力、优雅和简单性，同时不牺牲性能。编译器是用 Python 编写的，使用 LLVM 作为后端。

## 特征
- **它很快**，通过LLVM优化，它永远不会强迫你为了性能付出额外的努力
- **它可编译** 有 AOT 和 JIT，因此您可以决定是只想直接运行它，还是编译它并在没有依赖的情况下分发您的项目。二进制文件大小也很重要，一个 Hello World 示例程序大约为8kb
- **它是静态类型的**，您不需要猜测变量的类型，并且可以利用编译时检查、自动完成等
- **它简单而富有表现力** 因为代码应该易于阅读，不需要您猜测它的作用

## 影响
- Python
- Lesma
- Gone

## 安装
您可以在 [**Releases** 正在编写 ]() 中获取最新版本并开始使用它。 Meteor 目前正在测试中，只为 Unix 提供二进制文件。操作系统和架构之间的兼容性并不难实现，但目前根本不是优先事项。

Windows 也支持，但如果你想编译 Meteor 代码（需要安装 clang，但目前没有测试），你需要做额外的工作， Unicode 字符可能存在问题，但所有测试都通过了，一切似乎都可以工作。

如果您的平台不受官方支持，则需要自行构建。

## 文档

- [文档（正在编写）]()

## 构建

为了构建 Meteor，您至少需要安装 [Python 3.6](https://www.python.org/)。它目前仅在 Linux 上进行了测试。它当前使用 clang 编译生成的目标文件，因此您需要安装它，但仅运行文件不需要 clang。

克隆：
```bash
git clone https://github.com/streetartist/meteor
```

安装需求库
```bash
sudo apt install clang -y
pip install -r requirements.txt
```

完毕！现在你可以运行编译器或解释器，写一个测试文件并运行。文档中有示例。
```bash
正在
```

或者安装 pytest 并自己运行单元测试
```bash
pytest
```

如需高级用法或帮助，请参阅 CLI 帮助菜单
```bash
正在
```

### 示例
```py
# Hello World
print('Hello World')
print('🍌')
print('夜のコンサートは最高でした。')

a_number: int # Initialize an Integer

# Binary, Hex and Octal numbers supported
bin_num = 0b101010
octo_num = 0o1272
hex_num = 0x1272

π: float = 3.14 # Support for utf-8 variable names
number = 23 # Type Inference, int in this case
number = number + 5 // 2 ^ 3 # Number operations
number+=5 # Operating Assignment

still_inf = inf - 999999 # Still infinity

question = 'what\'s going on' # Escaping

things = [1, 2, 3] # List, mutable
same_things = 0..4 # Same as before, defaults as a list
other_things = (1.5, 9.5) # Tuple, immutable
stuff = {'first_name': 'Samus', 'last_name': 'Aran'} # Dictionary
other_stuff: list<int> = [] # Empty Array of ints

print(things[1 + 1])

if number > 23
	print('greater than 23')
else if number == 23
	print('equals 23')
else
	print('less than 23')

if false \ # Continuing statement onto next line
	and true

	print('They are not the same')

for x in 0..40 # For loop using a range
	print(x * 2)

for item in things # Iterate over objects
	print(item)

while number > 1
	number -= 1
	print(number)

if 2 in things
	print('yes')

if 2 not in things
	print('no')

odd_even = 1

# No implicit fallthrough (in other words, implicit break)
switch odd_even
	case 1
		fallthrough # Go to the next case
	case 3
		print('Odd number')
	default
		print("Any number")
		print(odd_even)
	case 4
		print('Even number')

# Function Return notation
def fib(n: int) -> int
	a = 0
	b = 1
	for _ in 0..n
		prev_a = a
		a = b
		b = prev_a + b
	return a

def fib_rec(n: int) -> int
	if n == 0
		return 0
	if n == 1
		return 1
	return fib_rec(n - 1) + fib_rec(n - 2)

def factorial(n: int = 5) -> int
	if n <= 1
		return 1
	return n * factorial(n - 1)

# Assign anonymous function to a variable
myfunc = def (x: int, y: int) -> int
	if x > y
		return x + y
	else
		return x * y

print(myfunc(2, 3))
bar = myfunc
print(bar(3,4))

# Type operators using `as` and `is`
my_var: int128 = 101
my_another_var: int64 = my_var as int64

if my_var is int64
	print("That's not true")
else if my_var as int64 is int64
	print("That works")

# Type Declaration
type fInt = func<int> -> int

def do_stuff(x: int, callback: fInt) -> int
	x ^= 2
	x = callback(x)
	return x

num = do_stuff(3,
	def (y: int) -> int
		y += 7
		return y
)

print(
	num
)

# Closure
def start_at(x: int) -> fInt
	def increment_by(y: int) -> int
		return x + y
	return increment_by

start_at_5 = start_at(5)
start_at_27 = start_at(27)

print(start_at_5(4))
print(start_at_27(15))

# User input
age: int = input('How old are you?')

# String Interpolation
print('Wow! You are {age} years old?!')

# Operator Overloading
def operator - (x: int, y:int) -> int  # Two parameters overloads binary operations
	return x + 3

def operator - (x: int) -> int  # One parameters overloads binary operations
	return 0 - x + 1

# Extern functions (FFI)
def extern abs(x: int) -> int # from C's stdlib

print(abs(-5.0 as int)) # ints are int64 by default in Lesma, they're int32 in C

# or you can just let Lesma convert between "compatible" types such as numbers
print(abs(-5.0))

# Named parameters and defaults
def optional_params(x: int, y: int32 = 5, z: double = 9) -> int
	# Lesma takes care of casting the return type between "compatible" types
	return x + z

optional_params(5, z=11)

def defer_demo()
    defer print("World!")
    print("Hello")

defer_demo() # prints Hello World!

# Enums
enum Color
	GREEN
	RED
	BLUE
	YELLOW

x: Colors = Color.GREEN
print(x == Color.GREEN)

# Structs
struct Circle
	radius: int
	x: int
	y: int = 4

cir: Circle = Circle(radius=5, x=2)

print(cir.radius)

# Classes
class Vehicle
	# Constructor
	def new(year: int, color: str)
		self.year = year
		self._color = color

# Inheritance
class Car: Vehicle
	def new(year: int, color='green', hatchback=false)
		self.hatchback = hatchback
		super.Vehicle(year, color)

	def print_year() -> void
		print('This car was made in {self.year}')

ford = Car(1992)

print(ford.hatchback)
ford.print_year()

# Generics

# Skip the type and assign a unique generic type for each parameter
def basicGeneric(a, b)
	print(a)
	print(b)

# Using <T> notation the compiler makes sure the types used match if repeated among parameters and/or return type
def typedGeneric<T>(a: T, b: T) -> T
	return a

# Types can have constraints, and the constraints can be Traits, Classes, Structs or Enums
def complexGeneric<T: AdditionTrait>(a: T, b: T) -> T
	return a + b
```

