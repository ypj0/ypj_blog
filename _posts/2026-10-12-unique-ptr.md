---
title: "[C++智能指针] unique_ptr"
date: 2026-10-12 10:00:00 +0800
categories: [现代C++]
tags: [现代C++]
---

## 独占所有权

`unique_ptr`最核心的语义是独占，这意味着在同一时刻，只有一个`unique_ptr`拥有对象的所有权，不能进行拷贝构造和拷贝赋值，只允许移动。

## make_unique(C++14)

C++11引入了`unique_ptr`但是没有提供`make_unique`，所以C++14之前我们只能先new一块空间，再构造`unique_ptr`。如果我们在这两个步骤中间不幸抛出了异常，那么资源就泄露了。而`make_unique`把分配和构造包装到一个函数调用汇总，不存在中间态，所以是异常安全的。

```c++
auto p1 = std::unique_ptr<Widget>(new Widget(42));
auto p2 = std::make_unique<Widget>(42);
```

但是`make_unique`有一个限制：它不支持自定义删除器，如果要自定义删除器的话，就必须直接构造`unique_ptr`。

## `unique_ptr`自定义删除器

`unique_ptr`的完整模板签名是：

```cpp
template<class T, Class Deleter = std::default_delete<T>>
class unique_ptr;
```

其中第二个模板参数就是删除器的类型，内部调用的是`delete/ delete[]`，但是我们可以替换为任何可以调用的对象，包括函数指针、lambda、函数对象，只要是`void operator()(T*)`的签名就行。

最常见的常见就是管理C API返回的资源：

```c++
//假设某个C API返回malloc分配的数组
extern "C" int* create_buffer(size_t size);
extern "C" void free_buffer(int* buf);

auto buffer = std::unique_ptr<int[], void(*)(int*)>(create_buffer(1024), [int* p]{free_buffer(p);});
```

这里我们传入一个无捕获的lambda，它可以隐式的转换为函数指针`void(*)(int*)`，所以类型匹配。这里我们没有用MMORPG的删除器，是因为它会调用`delete[]`,而我们返回的是`malloc`出来的数组，用`delete[]`是未定义行为。

这里`lambda`还有更简洁的写法：

```
// 1. 用decltype推导删除器类型
auto deleter = [](int* p) {free_buffer(p);};
std::unique_ptr<int[], decltype(deleter)> buffer(create_buffer(1024), deleter);

// 2. C++20 lambda 无捕获可以默认构造
std::unique_ptr<int[], decltype([](int* p) {free_buffer(p);})> buffer(create_buffer(1024));

// 3. 自定义一个deleter结构体(最佳实践、零开销)
struct FreeBufferDeleter {
	void operator()(int* p) const  { free_buffer(p); };
};

std::unique_ptr<int[], FreeBufferDeleter> buffer(create_buffer(1024));
```

其中第三种用法的删除器是空类，`unique_ptr`不额外占用空间(函数指针需要8字节)，空类没有成员变量是可以默认构造的，当我们只传指针，不传删除器时，`unique_ptr`会默认构造一个`FreeBufferDeleter`作为删除器，空类构造是没有任何开销的。

再看第一种，我们用`decltype(deleter)`推导出lambda的闭包类型，不用手写类型，而第二种写法是由于C++20给lambda加了一条默认构造函数的规则：

> **一个无捕获 lambda 的闭包类型，只有在它出现在"未求值操作数（unevaluated operand）"中时，才具有默认构造函数。**

标准里的"未求值操作数"包括：

- `decltype(...)` 的参数
- `sizeof(...)` 的参数
- `typeid(...)` 的参数
- `noexcept(...)` 的参数

写法2中的lambda直接写在`decltype`中触发了这个规则，所以编译器给这个闭包类型生成默认构造函数，所以无需显式的传删除器。而写法1中，lambda已经在`decltype`外构造了一个对象deleter，此时`decltype`的作用只是类型查询，所以闭包类型没有默认构造函数，所以我们需要显式的传`deleter`。

## 一些常用接口

`unique_ptr`提供了几个手动管理所有权的方法：

`get()`返回内部裸指针但不转移所有权:

```c++
void print_widget(const widget* W);

auto p = std::make_unique<Widget>(42);
print_widget(p.get()); //传给只读函数，p仍然拥有对象
```

`release()`放弃所有权并返回裸指针：

```c++
auto p = std::make_unique<Widget>(42);
Widget* raw = p.release();  // p 变为 nullptr，raw 指向对象
// ... 使用 raw ...
delete raw;  // 你必须手动释放
```

`reset()`替换当前管理的对象，如果不传参，就释放当前对象并置空：

```c++
auto p = std::make_unique<Widget>(1);
p.reset(new Widget(2));  // 释放 Widget(1)，接管 Widget(2)
p.reset();               // 释放 Widget(2)，p 变为 nullptr
```

