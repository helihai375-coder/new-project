# UFW Basic Firewall

Install UFW:

```bash
sudo apt install ufw
```

Allow SSH before enabling the firewall:

```bash
sudo ufw allow OpenSSH
```

Allow HTTP and HTTPS:

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

Enable UFW:

```bash
sudo ufw enable
```

Check status:

```bash
sudo ufw status verbose
```

Disable UFW:

```bash
sudo ufw disable
```

