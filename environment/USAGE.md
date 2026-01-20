# Usage and Post-Install Tips 🚀

This document provides quick examples, verification commands, and post-installation tips for the `setup-dev-environment.sh` script.

---

## Quickstart ✅
1. Make the script executable (optional):

```bash
chmod +x environment/setup-dev-environment.sh
```

2. Run the script as root (recommended with sudo):

```bash
sudo bash environment/setup-dev-environment.sh
```

3. Follow interactive prompts and answer `y`/`n` (or `s`/`n` for Portuguese prompts).

---

## Common verification commands 🔎
- Apache

```bash
sudo systemctl status apache2
curl -I http://localhost
```

- MySQL

```bash
sudo systemctl status mysql
sudo mysql_secure_installation
```

- PostgreSQL

```bash
sudo systemctl status postgresql
sudo -u postgres psql -c "SELECT version();"
```

- PHP

```bash
php -v
php -m | grep -E "mysql|pgsql|curl|xml|mbstring"
```

- Node.js & npm

```bash
node -v
npm -v
```

- Docker

```bash
sudo systemctl status docker
docker --version
sudo docker run --rm hello-world
```

- Python

```bash
python3 --version
pip3 --version
python3 -m venv .venv && source .venv/bin/activate
```

- Git

```bash
git --version
git config --global --list
```

- SSH keys

```bash
ls -la ~/.ssh
cat ~/.ssh/id_rsa.pub
```

---

## Post-install checklist ✅
- Run `sudo mysql_secure_installation` after MySQL install to secure the server.
- If you added your user to the `docker` group, log out and back in (or run `newgrp docker`) to apply the change.
- If you installed PHP and use Apache, confirm `libapache2-mod-php` is enabled and restart Apache: `sudo systemctl restart apache2`.
- Create and activate virtual environments for Python projects: `python3 -m venv env && source env/bin/activate`.

---

## Troubleshooting tips ⚠️
- Package installation failed? Check `apt` logs and run `sudo apt update && sudo apt upgrade`.
- Service won't start? Check `sudo journalctl -u <service>` and `sudo systemctl status <service>` for errors.
- Permission issues with Docker? Verify membership: `groups $USER` and re-login.

---

## Security notes 🔐
- Never share private keys (e.g., `~/.ssh/id_rsa`).
- Choose strong passwords for database users and the MySQL root account.
- Consider firewall rules (ufw) to restrict access to database services.

---

## Customization tips 🔧
- Edit `setup-dev-environment.sh` to enable/disable steps or pre-define answers for automation.
- For reproducible setups, consider converting steps into an Ansible playbook or Docker Compose stacks for services.

---

If you want, I can:
- Add step-by-step examples for a sample web app (Apache + PHP + MySQL);
- Create an automated non-interactive mode for the script;
- Provide a Portuguese translation of this `USAGE.md`.

Reply **yes** to any option you want me to add.