# Python 第一阶段学习笔记：基础语法 + 成绩统计器

日期：2026-05-20
阶段：第一阶段 Python 入门基础
环境：VS Code / Python
练习项目：命令行成绩统计器
学习方式：边写代码、边报错、边修改、边总结
学习范围：基础语法、函数、返回值、字典、异常处理、输入校验

说明：本笔记用于记录 Python 入门第一天的学习过程，内容仅用于个人学习和复习。

---

## 一、今日学习日志

### 1. 今日目标

- 通过一个成绩统计器小任务测试 Python 基础水平。
- 学会接收用户输入。
- 学会处理字符串和列表。
- 学会把字符串数字转换成整数。
- 学会用循环和判断完成统计逻辑。
- 学会用函数封装代码。
- 学会用 return 返回结果。
- 学会用字典保存多个统计结果。
- 学会处理用户错误输入。
- 学会让程序在输入错误时继续要求用户重新输入。


### 2. 今日完成内容

今天完成了一个命令行成绩统计器，功能包括：

- 输入一组成绩。
- 用英文逗号分隔多个成绩。
- 统计总人数。
- 统计最高分。
- 统计最低分。
- 计算平均分。
- 统计及格人数。
- 统计不及格人数。
- 统计优秀人数。
- 判断输入是否为数字。
- 判断成绩是否在 0 到 100 分之间。
- 输入错误时继续要求用户重新输入。


### 3. 今日学习评价

今天的学习效果很好，已经从单纯写代码进入到理解代码结构的阶段。

今天最明显的进步：

- 能根据报错定位问题。
- 知道 input() 得到的是字符串。
- 知道计算前需要把字符串转成 int。
- 知道 print 和 return 的区别。
- 知道函数可以封装一段逻辑。
- 知道字典可以保存多个结果。
- 知道 success/message 可以表示程序处理状态。
- 知道 while True 可以让程序反复执行。
- 知道 try...except 可以避免程序因为错误输入而崩溃。

当前水平判断：

Python 入门基础已经完成第一轮实践，正在进入“函数封装 + 程序结构设计”的阶段。


---

## 二、今日程序最终效果

**用户输入：**

```text
85,90,72,60,45,100,88
```

**程序输出：**

```text
总人数：7
最高分：100
最低分：45
平均分：77.14
及格人数：6
不及格人数：1
优秀人数：3
```


如果用户输入：

```text
85,abc,90
```

**程序提示：**

```text
输入错误：请只输入数字，并用英文逗号分隔
请重新输入。
```


如果用户输入：

```text
85,120,90
```

**程序提示：**

```text
输入错误：成绩必须在 0 到 100 之间
请重新输入。
```


---

## 三、基础代码分类整理

### 1. 数据类型类

#### 1.1 字符串 str

字符串就是文字内容，需要用引号包起来。

**示例：**

```python
chenji = "85,90,72,60,45,100,88"
```

**今天的用法：**

```python
user_input = input("请输入成绩，用英文逗号分隔：")
```

注意：

input() 得到的一定是字符串。

比如用户输入：

85,90,72

程序拿到的是：

"85,90,72"


#### 1.2 整数 int

整数就是没有小数点的数字。

**示例：**

```python
score = 85
```

**今天的用法：**

```python
int("85")
```

作用：

把字符串 "85" 转成整数 85。


#### 1.3 列表 list

列表用来保存多个数据。

**示例：**

```python
scores = [85, 90, 72, 60]
```

**今天的用法：**

```python
s = [85, 90, 72, 60, 45, 100, 88]
```

取列表里的数据：

```python
print(s[0])
```

输出：

```text
85
```

注意：

列表下标从 0 开始。


#### 1.4 字典 dict

字典用来保存“名字对应值”的数据。

**示例：**

```python
data = {
    "平均分": 77.14,
    "最高分": 100
}
```

取字典里的数据：

```python
print(data["平均分"])
```

输出：

```text
77.14
```

**今天的用法：**

```python
result = {
    "success": True,
    "总人数": len(s),
    "最高分": max(s),
    "最低分": min(s),
    "平均分": round(sum(s) / len(s), 2)
}
```


#### 1.5 布尔值 bool

布尔值只有两个：

True
False

**今天的用法：**

```python
"success": True
```

表示处理成功。

"success": False

表示处理失败。

判断时可以这样写：

```python
if data["success"]:
    print("成功")
else:
    print("失败")
```


---

### 2. 输入输出类

#### 2.1 输入 input()

格式：

```python
变量 = input("提示文字：")
```

**今天的用法：**

```python
user_input = input("请输入成绩，用英文逗号分隔：")
```

作用：

让用户输入成绩。


#### 2.2 输出 print()

格式：

```python
print("你好")
```

**今天的用法：**

```python
print("请重新输入。")
```

输出变量：

print(data)


#### 2.3 拼接输出

如果文字和数字一起输出，需要把数字转成字符串。

**示例：**

```python
print("及格人数：" + str(jige))
```

如果不加 str()，可能会报错。


#### 2.4 f-string 输出

格式：

```python
print(f"结果是：{变量}")
```

**示例：**

```python
name = "小明"
age = 18
```

print(f"姓名：{name}，年龄：{age}")

**今天的用法：**

```python
print(f"""
总人数：{data["总人数"]}
最高分：{data["最高分"]}
最低分：{data["最低分"]}
平均分：{data["平均分"]}
""")
```

作用：

一次性输出多行内容，并且可以直接在大括号里放变量或字典取值。


---

### 3. 类型转换类

#### 3.1 转整数 int()

**示例：**

```python
num = int("85")
```

**今天的用法：**

```python
s.append(int(i))
```

或者：

s = [int(i) for i in chenji.split(',')]

作用：

把字符串成绩转成整数成绩。


#### 3.2 转字符串 str()

**示例：**

```python
text = str(85)
```

**今天的用法：**

```python
print("最高分为：" + str(max(s)))
```

作用：

把数字转成字符串，方便和文字拼接。


---

### 4. 字符串操作类

#### 4.1 字符串切割 split()

格式：

```python
字符串.split("分隔符")
```

**今天的用法：**

```python
chenji.split(',')
```

**示例：**

```python
"85,90,72".split(',')
```

结果：

["85", "90", "72"]

作用：

把一整串成绩拆成多个成绩。


---

### 5. 列表操作类

#### 5.1 创建空列表

s = []

作用：

先准备一个空列表。


#### 5.2 添加数据 append()

**示例：**

```python
s.append(85)
```

今天的基础写法：

s = []

for i in lchenji:
    s.append(int(i))

意思是：

把每个成绩转成整数后，放进列表 s。


#### 5.3 列表推导式

基础格式：

[处理结果 for 变量 in 列表]

**今天的用法：**

```python
s = [int(i) for i in chenji.split(',')]
```

等价于：

s = []

for i in chenji.split(','):
    s.append(int(i))


#### 5.4 带条件的列表推导式

格式：

```python
[变量 for 变量 in 列表 if 条件]
```

**今天的用法：**

```python
[i for i in s if i >= 60]
```

意思是：

从 s 里面筛选出所有大于等于 60 的成绩。

统计及格人数：

jige = len([i for i in s if i >= 60])

统计不及格人数：

bujige = len([i for i in s if i < 60])

统计优秀人数：

youxie = len([i for i in s if i >= 85])


---

### 6. 统计函数类

#### 6.1 数量 len()

len(s)

作用：

统计列表里有多少个数据。

**今天的用法：**

```python
"总人数": len(s)
```


#### 6.2 最大值 max()

max(s)

**今天的用法：**

```python
"最高分": max(s)
```


#### 6.3 最小值 min()

min(s)

**今天的用法：**

```python
"最低分": min(s)
```


#### 6.4 求和 sum()

sum(s)

**今天的用法：**

```python
sum(s) / len(s)
```

作用：

计算平均分。


#### 6.5 保留小数 round()

格式：

```python
round(数字, 小数位数)
```

**今天的用法：**

```python
round(sum(s) / len(s), 2)
```

作用：

平均分保留 2 位小数。


#### 6.6 判断是否存在 any()

格式：

```python
any(条件 for 变量 in 列表)
```

**今天的用法：**

```python
any(i < 0 or i > 100 for i in s)
```

意思是：

只要有一个成绩小于 0 或大于 100，就返回 True。


---

### 7. 判断语句类

#### 7.1 if 判断

格式：

```python
if 条件:
    条件成立时执行
```

**今天的用法：**

```python
if i >= 60:
    jige = jige + 1
```


#### 7.2 if...else 判断

格式：

```python
if 条件:
    条件成立时执行
else:
    条件不成立时执行
```

**今天的用法：**

```python
if data["success"]:
    return data
else:
    print(data["message"])
```


#### 7.3 多个 if 判断

今天一开始的写法：

if i >= 60:
    jige = jige + 1

if i >= 85:
    youxie = youxie + 1

if i < 60:
    bujige = bujige + 1

意思是分别判断：

- 是否及格
- 是否优秀
- 是否不及格


#### 7.4 范围判断

**示例：**

```python
if i < 0 or i > 100:
    print("成绩不合法")
```

今天升级后的写法：

if any(i < 0 or i > 100 for i in s):
    return {
        "success": False,
        "message": "输入错误：成绩必须在 0 到 100 之间"
    }


---

### 8. 循环类

#### 8.1 for 循环

格式：

```python
for 变量 in 列表:
    执行代码
```

**今天的用法：**

```python
for i in s:
    if i >= 60:
        jige += 1
```

意思是：

一个一个检查成绩。


#### 8.2 while 循环

格式：

```python
while 条件:
    循环执行的代码
```

**今天的用法：**

```python
while True:
    user_input = input("请输入成绩，用英文逗号分隔：")
```

意思是：

一直让用户输入。


#### 8.3 break 跳出循环

break

**示例：**

```python
while True:
    text = input("请输入：")
    if text == "q":
        break
```

注意：

今天后面更多用的是 return，因为写在函数里时，return 可以直接结束函数。


---

### 9. 函数类

#### 9.1 定义函数

格式：

```python
def 函数名(参数):
    函数内容
```

**今天的用法：**

```python
def scores(chenji):
    ...
```

意思是：

定义一个叫 scores 的函数，它接收一个参数 chenji。


#### 9.2 调用函数

格式：

```python
函数名(传入的数据)
```

**今天的用法：**

```python
scores("85,90,72")
```


#### 9.3 接收函数返回值

格式：

```python
变量 = 函数名(参数)
```

**今天的用法：**

```python
data = scores("85,90,72")
```

意思是：

scores 函数执行完后，把 return 的结果交给 data。


#### 9.4 return 返回结果

格式：

```python
return 结果
```

**今天的用法：**

```python
return result
```

或者：

return {
    "success": True,
    "平均分": 77.14
}

作用：

把函数内部的结果交给函数外面。


#### 9.5 函数里调用另一个函数

**今天的用法：**

```python
def input_scores():
    while True:
        user_input = input("请输入成绩，用英文逗号分隔：")
        data = scores(user_input)
```

        if data["success"]:
            return data
        else:
            print(data["message"])

这里 input_scores() 里面调用了 scores()。

这就是：

- 一个函数负责输入
- 另一个函数负责计算


---

### 10. 字典调用类

#### 10.1 创建字典

data = {
    "success": True,
    "平均分": 77.14
}


#### 10.2 通过 key 取值

data["平均分"]

**今天的用法：**

```python
print(data["平均分"])
```


#### 10.3 用字典控制程序流程

if data["success"]:
    print("成功")
else:
    print(data["message"])

这就是今天用 success 和 message 的地方。


---

### 11. 异常处理类

#### 11.1 try...except

格式：

```python
try:
    可能出错的代码
except 错误类型:
    出错后执行的代码
```

**今天的用法：**

```python
try:
    s = [int(i) for i in chenji.split(',')]
except ValueError:
    return {
        "success": False,
        "message": "输入错误：请只输入数字，并用英文逗号分隔"
    }
```

意思是：

如果 int(i) 转换失败，就返回错误信息。

比如输入：

85,abc,90

就会进入 except ValueError。


---

### 12. 比较和逻辑运算类

#### 12.1 大于等于

i >= 60

判断是否及格。


#### 12.2 小于

i < 60

判断是否不及格。


#### 12.3 大于

i > 100

判断是否超过 100。


#### 12.4 或者 or

i < 0 or i > 100

意思是：

小于 0 或者大于 100，只要满足一个，就不合法。


---

## 四、今日完整代码

```python
def scores(chenji):
    try:
        s = [int(i) for i in chenji.split(',')]
    except ValueError:
        return {
            "success": False,
            "message": "输入错误：请只输入数字，并用英文逗号分隔"
        }

    if any(i < 0 or i > 100 for i in s):
        return {
            "success": False,
            "message": "输入错误：成绩必须在 0 到 100 之间"
        }

    return {
        "success": True,
        "总人数": len(s),
        "最高分": max(s),
        "最低分": min(s),
        "平均分": round(sum(s) / len(s), 2),
        "及格人数": len([i for i in s if i >= 60]),
        "不及格人数": len([i for i in s if i < 60]),
        "优秀人数": len([i for i in s if i >= 85])
    }


def input_scores():
    while True:
        user_input = input("请输入成绩，用英文逗号分隔：")
        data = scores(user_input)

        if data["success"]:
            return data
        else:
            print(data["message"])
            print("请重新输入。")


data = input_scores()

print(f"""
总人数：{data["总人数"]}
最高分：{data["最高分"]}
最低分：{data["最低分"]}
平均分：{data["平均分"]}
及格人数：{data["及格人数"]}
不及格人数：{data["不及格人数"]}
优秀人数：{data["优秀人数"]}
""")
```


---

## 五、今日程序算法思路

### 1. 接收输入

用户输入一串成绩，例如：

```text
85,90,72,60,45,100,88
```

此时它是字符串。


### 2. 切割字符串

使用 split(',') 把字符串拆成列表：

```python
["85", "90", "72", "60", "45", "100", "88"]
```


### 3. 类型转换

使用 int(i) 把每个字符串成绩转成整数：

```python
[85, 90, 72, 60, 45, 100, 88]
```


### 4. 检查输入是否合法

第一层检查：

如果输入中包含 abc 这种非数字内容，就进入 except ValueError。

第二层检查：

如果成绩小于 0 或大于 100，就返回错误信息。


### 5. 统计成绩

总人数：

```python
len(s)
```

最高分：

```python
max(s)
```

最低分：

```python
min(s)
```

平均分：

```python
round(sum(s) / len(s), 2)
```

及格人数：

```python
len([i for i in s if i >= 60])
```

不及格人数：

```python
len([i for i in s if i < 60])
```

优秀人数：

```python
len([i for i in s if i >= 85])
```


### 6. 返回结果

**如果成功，返回：**

```python
{
    "success": True,
    "总人数": ...,
    "最高分": ...,
    "平均分": ...
}
```

**如果失败，返回：**

```python
{
    "success": False,
    "message": "错误提示"
}
```


### 7. 重新输入机制

input_scores() 使用 while True 反复输入。

如果 data["success"] 是 True：

```python
return data
```

如果 data["success"] 是 False：

输出错误信息，并继续下一轮输入。


---

## 六、今日重要报错整理

### 1. TypeError: unsupported operand type(s) for +: 'int' and 'str'

**原因：**

字符串没有转成整数，就直接拿去计算了。

**解决：**

使用 int(i) 转换。


### 2. 'set' object is not subscriptable

**原因：**

把字典写成了集合。

**错误写法：**

```python
result = {"平均分", 77.14}
```

**正确写法：**

```python
result = {"平均分": 77.14}
```


### 3. TypeError: string indices must be integers, not 'str'

**原因：**

函数返回的是字符串，但外面用字典方式取值。

**错误场景：**

```python
data = "输入错误"
print(data["平均分"])
```

**解决：**

统一返回字典，并使用 success 判断。


---

## 七、今日最重要的总结

### 1. input() 得到的是字符串，不是数字。
### 2. 需要计算时，要先用 int() 转换。
### 3. print 是给人看的，return 是给程序用的。
### 4. 字典使用 key: value。
### 5. 列表适合保存多个数据。
### 6. 函数可以把一段逻辑封装起来。
### 7. return 可以把函数结果交给外面。
### 8. try...except 可以防止错误输入导致程序崩溃。
### 9. while True 可以让程序持续运行。
### 10. 一个函数最好只负责一类事情。


---

## 八、下次学习建议

下次可以继续做一个命令行 Todo List 待办事项管理器。

建议练习内容：

### 1. 添加任务。
### 2. 查看任务。
### 3. 删除任务。
### 4. 输入 q 退出程序。
### 5. 使用列表保存任务。
### 6. 使用函数拆分功能。
### 7. 使用 while 循环做菜单系统。

这个项目可以继续巩固今天学到的函数、列表、循环、判断和输入输出。
