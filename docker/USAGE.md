# Usage & Safety — Docker scripts 🐳

This quick guide contains usage notes and safety tips for the scripts in the `docker/` folder.

---

## 1) Docker Setup — `docker_setup.sh` ✅

Purpose: install and configure Docker Engine on Debian/Ubuntu systems.

### Quickstart 🚀
1. (Opcional) tornar o script executável:

```bash
chmod +x docker/docker_setup.sh
```

2. Run with administrative privileges:

```bash
sudo ./docker/docker_setup.sh
```

### What the script does
- Adds the official Docker GPG key and apt repository
- Installs `docker-ce`, `docker-ce-cli`, `containerd.io`, and `docker-compose-plugin`
- Optionally adds the current user to the `docker` group
- Starts and enables the `docker` service

### Post-install checks 🔎
- Apply the new group with `newgrp docker` or log out/in.
- Check version and status:

```bash
docker --version
sudo systemctl status docker
```

- Test with a simple container:

```bash
docker run --rm hello-world
```

### Notes & troubleshooting 🛠️
- The script targets Debian/Ubuntu (it uses `lsb_release -cs`). For other distros, review and adapt.
- If the daemon doesn't start: `sudo journalctl -u docker --no-pager` and `sudo systemctl restart docker`.
- If repository/GPG steps fail, check `/usr/share/keyrings/docker-archive-keyring.gpg` and `/etc/apt/sources.list.d/docker.list`.

---

## 2) Docker Cleanup — `docker_cleanup.sh` 🧹

**Warning:** This script is destructive. Use only when you are sure about what you want to remove.

### Quickstart 🚀

```bash
chmod +x docker/docker_cleanup.sh
./docker/docker_cleanup.sh           # interactive
./docker/docker_cleanup.sh -y        # non-interactive
```

### Pre-run checks ⚠️
- List containers: `docker ps -a`
- List images: `docker images -a`
- List volumes: `docker volume ls`
- Check disk usage: `docker system df`

### Recovery & tips
- If you remove something by mistake, re-pull images from a registry with `docker pull`.
- Export important volume data before deleting volumes.

---

If you'd like, I can add a `--dry-run` mode to `docker_cleanup.sh` or other improvements to `docker_setup.sh` (for example, a non-interactive `--yes` option). Tell me which you prefer.
