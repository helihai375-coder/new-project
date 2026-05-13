# Linux 系统代码仓库

这个目录用于保存 Linux 系统管理脚本、命令笔记和可复用配置模板。

## 目录结构

- `scripts/` - 日常 Linux 管理 Bash 脚本。
- `notes/` - 命令笔记、排障步骤和参考资料。
- `configs/` - 可复用的 Linux 配置模板。
- `systemd/` - systemd 服务和定时器模板。
- `security/` - 基础加固和防火墙示例。

## 使用方法

让脚本变成可执行文件：

```bash
chmod +x scripts/script-name.sh
```

运行脚本：

```bash
./scripts/script-name.sh
```

复制 systemd 服务模板：

```bash
sudo cp systemd/example-app.service /etc/systemd/system/example-app.service
sudo systemctl daemon-reload
sudo systemctl enable --now example-app
```

## 安全建议

- 运行脚本前先阅读内容。
- 优先在虚拟机中测试。
- 只有确实需要时才使用 `sudo`。
- 不要把密码、密钥、令牌等敏感信息放进仓库。
