# Common Linux Commands

## Files

List files:

```bash
ls -la
```

Find files:

```bash
find . -name "*.log"
```

Search text:

```bash
grep -R "error" /var/log
```

Show disk usage:

```bash
df -h
du -sh /path/to/folder
```

## Processes

Show processes:

```bash
ps aux
```

Monitor system usage:

```bash
top
```

Kill a process:

```bash
kill PID
```

## Network

Show IP addresses:

```bash
ip addr
```

Show routes:

```bash
ip route
```

Show listening ports:

```bash
ss -tulpen
```

Test connectivity:

```bash
ping example.com
```

## Services

Check service status:

```bash
systemctl status service-name
```

Start a service:

```bash
sudo systemctl start service-name
```

Enable a service at boot:

```bash
sudo systemctl enable service-name
```

Read logs:

```bash
journalctl -u service-name
```

