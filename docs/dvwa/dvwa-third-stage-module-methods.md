# DVWA 第三阶段学习笔记：模块作用位置、简介与测试方法

> 日期：2026-05-17  
> 环境：Kali Linux / Docker / DVWA / Burp Suite  
> 目标地址：`http://127.0.0.1:8080` 或 `http://localhost:8080`  
> 范围：本地 DVWA 靶场，仅用于授权学习和安全测试。

## 说明

本笔记整理 DVWA 第三阶段学习到的模块，统一使用以下字段记录：

- 作用位置
- 简介
- 关键参数
- 测试方法
- 成功判断
- 典型现象

## 模块速查表

| 模块 | 作用位置 | 简介 | 关键参数 | 测试方法 | 成功判断 | 典型现象 |
| --- | --- | --- | --- | --- | --- | --- |
| Brute Force | 登录框 / 账号密码验证接口 | 测试登录接口是否缺少失败次数限制、验证码、锁定或响应保护 | `username`, `password`, `Login` | 固定用户名，替换密码，对比成功和失败响应 | 正确密码返回欢迎内容，响应长度明显不同 | `Welcome to the password protected area admin` 或 `incorrect` |
| SQL Injection (Blind) | 数据库查询参数 | 不直接回显数据库内容，通过真假响应推断信息 | `id` | 输入真条件和假条件，再逐步猜长度与字符 | 真条件返回 exists，假条件返回 MISSING | `length(database())=4` 返回 exists，拼出 `dvwa` |
| Weak Session IDs | Cookie / Session ID | 检查会话 ID 是否简单、递增或可预测 | `dvwaSession` | 多次点击 Generate，并查看页面和 `Set-Cookie` | Session ID 呈递增或固定规律 | `dvwaSession=1`, `2`, `3` |
| JavaScript | 前端校验逻辑 / token 生成逻辑 | 理解前端校验不能替代服务端安全校验 | `phrase`, `token`, `send` | 阅读前端 JS，计算正确 token 后提交 | phrase 和 token 同时正确时通过 | `token = md5(rot13(phrase))` |
| CSP Bypass | 浏览器脚本加载策略 / CSP 响应头 | 检查 CSP 白名单是否允许加载指定来源脚本 | `include`, `Content-Security-Policy` | 测试非白名单脚本和白名单脚本加载结果 | 非白名单被拦截，白名单加载成功 | Console 出现 CSP violation，Network 中白名单脚本 200 |
| Insecure CAPTCHA | 验证码流程 / 修改密码功能 | 验证码是否真正被服务端校验，流程是否可绕过 | `password_new`, `password_conf`, `g-recaptcha-response`, `Change` | 对比验证码为空和通过时的请求差异 | 后端接受验证码后才允许修改密码 | `g-recaptcha-response=` 为空时报错，非空时进入后续验证 |

## Brute Force 暴力破解

模块位置：

```text
DVWA -> Brute Force
```

作用位置：登录框 / 账号密码验证接口。

简介：Brute Force 用来测试登录功能是否容易被不断尝试密码。它关注的不是密码本身，而是登录接口有没有限制失败次数、验证码、账号锁定或响应差异。

关键参数：

```text
username
password
Login
```

测试方法：

1. 输入错误密码，例如 `admin / 123456`，观察失败提示。
2. 输入正确密码，例如 `admin / password`，观察成功提示。
3. 在 Burp `HTTP history` 中找到登录请求。
4. 发送到 Repeater，手动替换 `password` 参数。
5. 使用 Intruder 做少量密码枚举演示，只选中 `password` 的值作为 payload 位置。
6. 对比 `Response` 内容、`Content-Length`、`Welcome` 和 `incorrect`。

典型请求：

```http
GET /vulnerabilities/brute/?username=admin&password=123456&Login=Login
```

成功判断：

```text
成功密码 -> Welcome to the password protected area admin
失败密码 -> Username and/or password incorrect.
```

典型现象：成功和失败响应内容不同，`Content-Length` 也可能明显不同。

一句话总结：固定用户名，不断替换密码，并通过响应差异判断哪个密码正确。

## SQL Injection (Blind) SQL 盲注

模块位置：

```text
DVWA -> SQL Injection (Blind)
```

作用位置：数据库查询参数。

简介：SQL 盲注不会直接显示数据库结果，而是通过页面真假反应判断数据库里的信息。

关键参数：

```text
id
```

测试方法：

1. 输入 `1`，确认存在用户。
2. 输入 `999`，确认不存在用户。
3. 输入真条件 `1' and '1'='1`。
4. 输入假条件 `1' and '1'='2`。
5. 根据真假响应判断盲注是否成立。
6. 使用 `length(database())` 判断数据库名长度。
7. 使用 `substr(database(),位置,1)` 逐字符猜数据库名。

测试 Payload：

```text
1' and '1'='1
1' and '1'='2
1' and length(database())=4#
1' and substr(database(),1,1)='d'#
1' and substr(database(),2,1)='v'#
1' and substr(database(),3,1)='w'#
1' and substr(database(),4,1)='a'#
```

成功判断：

```text
真条件 -> User ID exists in the database.
假条件 -> User ID is MISSING from the database.
```

典型现象：能够通过真假响应推断数据库名长度和字符，最终拼出 `dvwa`。

一句话总结：不断提出“是或不是”的问题，通过页面真假响应一点点猜出数据库信息。

## Weak Session IDs 弱会话 ID

模块位置：

```text
DVWA -> Weak Session IDs
```

作用位置：登录状态 / Cookie / Session ID。

简介：Session ID 是网站发给用户的“登录通行证编号”。如果 Session ID 太简单、递增或有规律，就可能被预测。

关键观察位置：

```text
页面生成的 Session ID
Response Header 中的 Set-Cookie
```

测试方法：

1. 进入模块后点击 `Generate`。
2. 记录生成的 Session ID。
3. 多次点击，观察是否递增。
4. 在 Burp Response Header 中查看 `Set-Cookie`。
5. 判断页面显示和 Cookie 是否都存在规律。

成功判断：

```text
dvwaSession=1
dvwaSession=2
dvwaSession=3
```

典型现象：Session ID 递增、固定格式或可预测。

一句话总结：多次生成 Session ID，观察它是否递增、有规律、容易预测。

## JavaScript 前端校验模块

模块位置：

```text
DVWA -> JavaScript
```

作用位置：前端页面逻辑 / 浏览器中的 JavaScript / token 生成逻辑。

简介：JavaScript 模块用于理解前端校验不能当成真正的安全防护。页面会根据 `phrase` 生成 `token`，如果 token 不对，页面会返回 `Invalid token`。

关键参数：

```text
phrase
token
send
```

测试方法：

1. 正常提交一次，观察 Burp 中的 POST 请求。
2. 在 Repeater 中把 `phrase=ChangeMe` 改成 `phrase=success`，保持原 token 不变。
3. 观察是否返回 `Invalid token`。
4. 查看 Response 中的 JavaScript，搜索 `token`、`phrase`、`md5`、`rot13`。
5. 找到 token 生成逻辑并计算正确值。
6. 同时提交正确 `phrase` 和 `token`。

关键逻辑：

```text
token = md5(rot13(phrase))
success -> rot13 -> fhpprff -> md5 -> 38581812b435834ebf84ebcc2c6424d6
```

成功判断：

```text
只改 phrase -> Invalid token.
phrase 和 token 都正确 -> 不再出现 Invalid token，并显示成功结果
```

典型现象：只改业务参数失败，同时改 token 后通过。

一句话总结：查看前端 JS 代码，找出 token 生成逻辑，然后自己生成正确 token 提交。

## CSP Bypass 内容安全策略绕过

模块位置：

```text
DVWA -> CSP Bypass
```

作用位置：浏览器脚本加载策略 / Response Header / 外部脚本来源。

简介：CSP 全称是 `Content-Security-Policy`，用于限制页面可以加载和执行哪些脚本。

关键参数和响应头：

```text
include
Content-Security-Policy
```

测试方法：

1. 在 Burp 中查看该页面 Response Header。
2. 找到 `Content-Security-Policy`。
3. 记录 `script-src` 白名单。
4. 在 `include` 中输入非白名单脚本地址。
5. 打开浏览器 Console 观察 CSP 报错。
6. 在 `include` 中输入白名单脚本地址。
7. 打开 Network 观察脚本是否 200 加载。

示例 CSP：

```text
Content-Security-Policy: script-src 'self' https://pastebin.com example.com code.jquery.com https://ssl.google-analytics.com ;
```

测试输入：

```text
https://evil.com/test.js
https://code.jquery.com/jquery-3.7.1.min.js
```

成功判断：

```text
非白名单地址 -> Console 出现 CSP violation，脚本被拦截
白名单地址 -> Network 中脚本状态码 200，脚本被允许加载
```

典型现象：加载 jQuery 不一定弹窗，因为它只是库，不会自动 `alert`。

一句话总结：先看 CSP 白名单，再分别测试非白名单和白名单脚本是否被拦截或加载。

## Insecure CAPTCHA 不安全验证码

模块位置：

```text
DVWA -> Insecure CAPTCHA
```

作用位置：验证码验证流程 / 修改密码功能 / 请求参数 `g-recaptcha-response`。

简介：验证码不是“页面上看起来有”就安全，关键是服务端有没有真正校验验证码结果，流程有没有被绕过。

关键参数：

```text
password_new
password_conf
g-recaptcha-response
Change
```

配置观察：

```text
如果页面提示 reCAPTCHA API key missing，说明 DVWA 没有配置 reCAPTCHA key。
配置测试 key 后，页面看到 “I'm not a robot” 表示前端验证码加载成功。
```

测试方法：

1. 不勾选验证码，直接提交修改密码请求。
2. 在 Burp 中查看 `g-recaptcha-response` 是否为空。
3. 观察页面是否提示 `The CAPTCHA was incorrect.`。
4. 勾选验证码，等绿色对勾出现后再次提交。
5. 在 Burp 中找 DVWA 的 POST 请求，不要看 Google 的 `/recaptcha/api2` 请求。
6. 查看请求底部参数，确认 `g-recaptcha-response` 是否出现一大长串值。
7. 观察 Response 中是否有 `step`、`passed_captcha`、`Password Changed`、`incorrect`。

成功判断：

```text
验证码未通过 -> g-recaptcha-response=，页面提示 The CAPTCHA was incorrect.
验证码前端通过 -> g-recaptcha-response=一大长串内容
后端也通过 -> 密码会被修改，可能出现密码修改成功提示
后端失败 -> 仍然显示 CAPTCHA incorrect
```

典型现象：前端验证码通过不等于服务端一定通过，需要看 DVWA 后端响应。

一句话总结：对比验证码为空和验证码通过时的请求差异，重点观察 `g-recaptcha-response` 是否出现，以及服务端是否真正接受它。

## 通用测试逻辑

每个模块都可以按这条流程学习：

1. 先看正常功能：这个页面本来是做什么的？
2. 找用户可控参数：例如 `username`、`password`、`id`、`phrase`、`token`、`include`、`g-recaptcha-response`。
3. 构造测试输入：改密码、改 token、改 password、改 id、改 include、改验证码参数。
4. 对比响应：页面提示、`Content-Length`、Cookie、Console 报错、Network 状态是否变化。
5. 形成证据链：不是只看一次结果，而是用多次对比证明问题。

## 安全边界

这些内容只适用于：

- 本地 DVWA 靶场
- 自己的实验环境
- 明确授权的安全测试环境

不要用于：

- 未授权网站
- 公网目标
- 真实业务系统
- 真实账号
- 真实用户数据

不要做：

- 爆破真实账号
- 窃取真实 Cookie
- 上传恶意脚本到真实系统
- 读取真实服务器敏感文件
- 破坏数据
- 绕过真实系统安全机制
