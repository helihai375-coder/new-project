# Linux Troubleshooting Checklist

## 1. Confirm The Symptom

- What changed recently?
- Is the issue repeatable?
- Does it affect one user or all users?

## 2. Check System Health

```bash
uptime
free -h
df -h
top
```

## 3. Check Logs

```bash
journalctl -xe
journalctl -f
dmesg
```

## 4. Check Network

```bash
ip addr
ip route
ping 8.8.8.8
ping example.com
ss -tulpen
```

## 5. Check Services

```bash
systemctl status service-name
journalctl -u service-name
```

## 6. Record The Fix

Write down:

- Root cause.
- Commands used.
- Files changed.
- How to verify the fix.

