# Linux System Repository

This repository folder stores Linux system administration scripts, notes, and reusable configuration templates.

## Directory Structure

- `scripts/` - Bash scripts for daily Linux administration.
- `notes/` - command notes, troubleshooting steps, and references.
- `configs/` - reusable Linux configuration templates.
- `systemd/` - systemd service and timer templates.
- `security/` - basic hardening and firewall examples.

## How To Use

Make a script executable:

```bash
chmod +x scripts/script-name.sh
```

Run a script:

```bash
./scripts/script-name.sh
```

Copy a systemd service template:

```bash
sudo cp systemd/example-app.service /etc/systemd/system/example-app.service
sudo systemctl daemon-reload
sudo systemctl enable --now example-app
```

## Safety

- Read every script before running it.
- Test on a virtual machine first.
- Use `sudo` only when required.
- Keep secrets out of this repository.

