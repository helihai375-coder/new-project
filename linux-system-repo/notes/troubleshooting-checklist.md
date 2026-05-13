# Linux 排障清单

## 1. 确认问题现象

- 最近是否改动过系统、配置或代码？
- 问题是否可以重复出现？
- 只影响一个用户，还是影响所有用户？

## 2. 检查系统状态

```bash
uptime
free -h
df -h
top
```

## 3. 检查日志

```bash
journalctl -xe
journalctl -f
dmesg
```

## 4. 检查网络

```bash
ip addr
ip route
ping 8.8.8.8
ping example.com
ss -tulpen
```

## 5. 检查服务

```bash
systemctl status service-name
journalctl -u service-name
```

## 6. 记录修复过程

记录以下内容：

- 根本原因。
- 使用过的命令。
- 修改过的文件。
- 如何验证问题已经修复。
