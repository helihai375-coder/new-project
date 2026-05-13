# UFW 基础防火墙

安装 UFW：

```bash
sudo apt install ufw
```

启用防火墙前先允许 SSH：

```bash
sudo ufw allow OpenSSH
```

允许 HTTP 和 HTTPS：

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

启用 UFW：

```bash
sudo ufw enable
```

查看状态：

```bash
sudo ufw status verbose
```

关闭 UFW：

```bash
sudo ufw disable
```
