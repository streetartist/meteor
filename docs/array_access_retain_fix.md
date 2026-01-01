# 数组访问引用计数修复

## 问题描述

**发现日期**: 2026-01-02  
**影响范围**: 所有从数组获取 managed 对象并赋值给变量的场景  
**严重程度**: 严重（内存安全漏洞）

### 症状

HTTP 服务器在处理多个请求时崩溃。调试发现：

1. 第一个请求正常处理，`route.pattern` 输出正确（如 `/`、`/hello`）
2. 第二个请求时，`route.pattern` 变成了垃圾数据（如 User-Agent 字符串）
3. 程序因内存损坏而崩溃

### 根本原因

当从数组获取对象赋值给变量时：

```meteor
route = self.routes[i]
```

编译器执行以下操作：

1. 调用 `Route.array.get()` 获取数组中对象的指针
2. 检查 `route` 变量的旧值是否非空
3. 如果非空，**release 旧值**（减少引用计数）
4. 存储新值到 `route` 变量

**问题**：步骤 1 没有 `retain` 获取的对象，但步骤 3 会 `release` 旧值。

当循环再次迭代或处理下一个请求时：
- `route` 变量的旧值（来自上次 `array.get`）被 release
- 由于 `array.get` 没有 retain，数组中对象的引用计数变为 0
- 对象被销毁，其内存被重用
- 数组仍持有悬空指针，导致 use-after-free

### 生成的 LLVM IR 分析

```llvm
; route = self.routes[i]
%.1019 = call ptr @Route.array.get(ptr %.1018, i64 %.1015)  ; 获取但没有 retain
%.1021 = load ptr, ptr %route, align 8                      ; 加载旧值
%.1022 = icmp ne ptr %.1021, null
br i1 %.1022, label %while.body.2.if, label %while.body.2.endif

while.body.2.if:
  ; 如果旧值非空，release 它
  br label %rc_release.2    ; <- 这里 release 了数组中的对象！

rc_destroy.2:
  call void @__destroy_Route__(ptr %.1021)  ; 对象被销毁
  call void @meteor_release(ptr %.1036)     ; 内存被释放

while.body.2.endif:
  store ptr %.1019, ptr %route, align 8     ; 存储新值
```

## 修复方案

在 `visit_collectionaccess` 中，当从数组获取 managed 对象时，增加引用计数。

### 修改文件

`src/meteor/compiler/code_generator.py`

### 修改内容

```python
# 修复前
if (hasattr(collection.type, 'pointee') and 
    hasattr(collection.type.pointee, 'pointee') and
    collection.type.pointee.pointee == array_struct):
    arr_ptr = self.load(collection)
    return self.call('{}.array.get'.format(type_name), [arr_ptr, key])

# 修复后
if (hasattr(collection.type, 'pointee') and 
    hasattr(collection.type.pointee, 'pointee') and
    collection.type.pointee.pointee == array_struct):
    arr_ptr = self.load(collection)
    result = self.call('{}.array.get'.format(type_name), [arr_ptr, key])
    # IMPORTANT: Retain the object when extracting from array
    # This prevents use-after-free when the variable is later reassigned
    if self.is_managed_type(result.type):
        self.rc_retain(result)
    return result
```

同样的修复应用于直接 pointee 匹配的情况（两处）。

## 引用计数语义

修复后的语义：

| 操作 | 引用计数变化 |
|------|-------------|
| `array.append(obj)` | obj 被 retain（数组持有引用）|
| `obj = array[i]` | obj 被 retain（变量持有引用）|
| `obj = new_value` | 旧 obj 被 release（变量放弃引用）|
| 变量离开作用域 | obj 被 release（变量放弃引用）|

这确保了：
- 数组中的对象至少有 1 个引用（来自数组）
- 赋值给变量后有 2 个引用（数组 + 变量）
- 变量重新赋值后回到 1 个引用（仅数组）
- 只有当数组也释放对象时，引用计数才会变为 0

## 测试验证

HTTP 服务器现在可以稳定处理多个请求：

```meteor
while true
    conn = c.meteor_http_server_accept(self.native_handle)
    # ... 处理请求 ...
    while i < self.routes.length()
        route = self.routes[i]  # 现在正确 retain
        if route.pattern == req.path
            route.handler(req, res)
            break
        i = i + 1
```

## 相关文档

- [array_loop_fix.md](array_loop_fix.md) - 循环中数组访问的另一个修复
- [memory_leak_postmortem.md](memory_leak_postmortem.md) - 内存泄漏事后分析
