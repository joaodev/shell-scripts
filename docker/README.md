# Docker scripts 🐳

Este diretório contém scripts utilitários para gerenciar o Docker no host: instalação/configuração e limpeza de recursos.

## Scripts disponíveis 🧰
- `docker_setup.sh` — instala e configura o Docker (Ubuntu/Debian).
- `docker_cleanup.sh` — limpa containers, imagens, volumes e dados não utilizados do Docker (destrutivo).

---

## docker_setup.sh — Overview ✅

**File:** `docker_setup.sh`

### Overview
A straightforward installer that adds the official Docker GPG key and repository, installs Docker Engine and related packages, and optionally adds the current user to the `docker` group.

### Key points
- Adds confirmations for repository and package changes.
- Provides `-y/--yes` (non-interactive), `-v/--verbose` and `-l/--logfile` options.
- Writes a timestamped log by default to `~/.docker_setup.log`.

### Run example 🚀

```bash
sudo ./docker/docker_setup.sh         # interactive (recommended)
sudo ./docker/docker_setup.sh -y      # non-interactive (CI/automation)
./docker/docker_setup.sh -l /tmp/dock.log -v
```

Notes:
- Run with `sudo` to allow package installation and service control.
- After adding your user to the `docker` group, run `newgrp docker` or log out/in to apply the change.

---

### Troubleshooting 🛠️
- If the service fails to start: `sudo journalctl -u docker --no-pager` and `sudo systemctl restart docker`.
- If repository or GPG steps fail, verify connectivity and the presence of `/usr/share/keyrings/docker-archive-keyring.gpg` and `/etc/apt/sources.list.d/docker.list`.


---

## docker_cleanup.sh — Overview 🧹

**File:** `docker_cleanup.sh`

**WARNING:** This script is destructive — it permanently removes containers, images and volumes. Use with caution and back up/export important data before running.

### What it does
- Shows Docker disk usage (`docker system df`)
- Stops and removes containers
- Removes images
- Removes volumes
- Prunes unused networks
- Runs `docker system prune -a -f --volumes`

### Run example

```bash
chmod +x docker/docker_cleanup.sh
./docker/docker_cleanup.sh           # interactive — inspect before confirm
./docker/docker_cleanup.sh -y        # non-interactive
```

### Recommendations
- Review what will be removed (`docker ps -a`, `docker images -a`, `docker volume ls`) before running.


---

## Author & License ✍️
- Author: João Augusto Bonfante
- Feel free to use and adapt. Consider adding an explicit license if you plan to publish this repository.

---

If you prefer, I can:
- add a `--dry-run` mode to `docker_cleanup.sh` that lists what would be removed without performing deletions;
- add additional flags (`--force`, `--selective`) for safer automated removals.

Reply **yes** if you'd like me to implement any of these improvements.
