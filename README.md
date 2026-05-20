# Domain Intel Collector

一个本地运行的授权信息收集面板，用来整理域名、IP、端口和网站基础信息。

## 功能

- DNS 记录：A、AAAA、CNAME、MX、NS、TXT
- 网站响应：HTTP/HTTPS 状态码与常见响应头
- TLS 证书：主体、签发者、有效期、备用名称
- 端口检查：默认检查少量常见端口，也可输入最多 12 个自定义端口

## 使用

```bash
npm start
```

打开 `http://localhost:3000`，输入已授权测试的域名或 URL。

## 学习资料

- [DVWA 学习笔记目录](docs/dvwa/README.md)
- [Kali 信息收集脚本代码整理](docs/kali-info-collection-scripts.md)
- [Kali Recon 脚本目录](tools/kali-recon/README.md)

## 注意

这个工具用于合法授权范围内的资产梳理。端口检查默认设置了数量和超时限制，不适合大规模扫描。

学习笔记内容仅适用于本地 DVWA、靶场或明确授权环境。不要对未授权网站进行扫描、测试、爆破或漏洞利用。
