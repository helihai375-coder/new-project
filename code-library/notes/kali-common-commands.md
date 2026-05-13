# Kali Linux Common Commands

This note is for learning, system administration, and authorized security testing only. Only run scanning or testing commands on systems you own or have explicit permission to assess.

## System Basics

Check current user:

```bash
whoami
```

Show current directory:

```bash
pwd
```

List files:

```bash
ls -la
```

Change directory:

```bash
cd /path/to/folder
```

Create a folder:

```bash
mkdir my-folder
```

Copy files:

```bash
cp source.txt destination.txt
```

Move or rename files:

```bash
mv old-name.txt new-name.txt
```

Remove a file:

```bash
rm file.txt
```

View a text file:

```bash
cat file.txt
```

Read a long file page by page:

```bash
less file.txt
```

Search text inside files:

```bash
grep -R "search text" .
```

Find files by name:

```bash
find . -name "*.txt"
```

## Package Management

Update package lists:

```bash
sudo apt update
```

Upgrade installed packages:

```bash
sudo apt upgrade
```

Install a package:

```bash
sudo apt install package-name
```

Remove a package:

```bash
sudo apt remove package-name
```

Search for a package:

```bash
apt search keyword
```

## Network Information

Show IP addresses and interfaces:

```bash
ip addr
```

Show routing table:

```bash
ip route
```

Test network connectivity:

```bash
ping example.com
```

Trace network route:

```bash
traceroute example.com
```

Show listening ports and active connections:

```bash
ss -tulpen
```

Show DNS information:

```bash
dig example.com
```

Query a domain name:

```bash
nslookup example.com
```

Download a file:

```bash
wget https://example.com/file.txt
```

Make an HTTP request:

```bash
curl -I https://example.com
```

## Processes And Services

Show running processes:

```bash
ps aux
```

Interactive process monitor:

```bash
top
```

Stop a process by PID:

```bash
kill 1234
```

Check a service:

```bash
systemctl status service-name
```

Start a service:

```bash
sudo systemctl start service-name
```

Stop a service:

```bash
sudo systemctl stop service-name
```

Enable a service at boot:

```bash
sudo systemctl enable service-name
```

## Files, Permissions, And Archives

Change file permissions:

```bash
chmod 755 script.sh
```

Change file owner:

```bash
sudo chown user:user file.txt
```

Create a tar.gz archive:

```bash
tar -czvf archive.tar.gz folder/
```

Extract a tar.gz archive:

```bash
tar -xzvf archive.tar.gz
```

Create a zip archive:

```bash
zip -r archive.zip folder/
```

Extract a zip archive:

```bash
unzip archive.zip
```

## Authorized Security Testing Basics

Identify live hosts on your own local network:

```bash
nmap -sn 192.168.1.0/24
```

Scan common ports on an authorized host:

```bash
nmap 192.168.1.10
```

Scan service versions on an authorized host:

```bash
nmap -sV 192.168.1.10
```

Run default safe scripts against an authorized host:

```bash
nmap -sC 192.168.1.10
```

Check HTTP response headers:

```bash
curl -I http://192.168.1.10
```

Inspect a web page response:

```bash
curl http://192.168.1.10
```

List directory content on a web server only when you own or administer it:

```bash
dirb http://192.168.1.10
```

Capture packets on your own interface for troubleshooting:

```bash
sudo tcpdump -i eth0
```

Open a packet capture file:

```bash
wireshark capture.pcap
```

## Wireless Diagnostics

Show wireless interfaces:

```bash
iw dev
```

Show wireless connection information:

```bash
iwconfig
```

Scan nearby Wi-Fi networks using NetworkManager:

```bash
nmcli dev wifi list
```

Restart NetworkManager:

```bash
sudo systemctl restart NetworkManager
```

## Web And Application Testing Notes

Start Burp Suite from the menu or terminal:

```bash
burpsuite
```

Start OWASP ZAP from the menu or terminal:

```bash
zaproxy
```

Run Nikto against a web server you own or are allowed to test:

```bash
nikto -h http://192.168.1.10
```

## Logs And Troubleshooting

Show system logs:

```bash
journalctl
```

Follow system logs live:

```bash
journalctl -f
```

Show recent kernel messages:

```bash
dmesg
```

Check disk usage:

```bash
df -h
```

Check folder size:

```bash
du -sh folder/
```

Check memory usage:

```bash
free -h
```

## Good Practice

- Keep Kali updated.
- Document what you test and why.
- Get written permission before scanning or testing any system.
- Prefer lab targets such as Metasploitable, DVWA, OWASP Juice Shop, or your own virtual machines.
- Do not run exploit, password attack, or intrusive commands against systems you do not own.

