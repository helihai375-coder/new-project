# 常用 Linux 命令

## 文件

列出文件：

```bash
ls -la
```

查找文件：

```bash
find . -name "*.log"
```

搜索文本：

```bash
grep -R "error" /var/log
```

查看磁盘占用：

```bash
df -h
du -sh /path/to/folder
```

## 进程

查看进程：

```bash
ps aux
```

实时监控系统使用情况：

```bash
top
```

结束一个进程：

```bash
kill PID
```

## 网络

查看 IP 地址：

```bash
ip addr
```

查看路由：

```bash
ip route
```

查看正在监听的端口：

```bash
ss -tulpen
```

测试网络连通性：

```bash
ping example.com
```

## 服务

查看服务状态：

```bash
systemctl status service-name
```

启动服务：

```bash
sudo systemctl start service-name
```

设置服务开机自启：

```bash
sudo systemctl enable service-name
```

读取服务日志：

```bash
journalctl -u service-name
```
