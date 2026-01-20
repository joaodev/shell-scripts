# Ubuntu Development Utilities — setup_ubuntu_utils.sh 🔧

**File:** `setup_ubuntu_utils.sh`

## Description ✅
A comprehensive script to prepare an Ubuntu (or Ubuntu-based) system for development. The script performs system updates, installs drivers and firmware, adds essential utilities and development tools, configures Zsh and Oh My Zsh, adjusts system performance settings, sets a basic UFW firewall, and runs final cleanup tasks.

## Key features ✨
- System update and cleanup (apt update/upgrade, dist-upgrade, autoremove, autoclean)
- Automatic driver installation (`ubuntu-drivers autoinstall`) and firmware updates (`fwupd`)
- Installs essential development utilities and packages (git, build-essential, curl, vim, etc.)
- Installs Zsh and Oh My Zsh with useful plugins
- Adjusts system tuning parameters (inotify watches, swappiness)
- Configures basic firewall rules with UFW
- Final cleanup and useful reminders (neofetch output)

## Requirements 🔍
- Ubuntu or Ubuntu-based distribution (tested on Zorin/Ubuntu derivatives)
- Root or sudo privileges
- Internet connection to download packages and drivers

## Usage 🚀
1. Make the script executable (optional):

```bash
chmod +x utils/setup_ubuntu_utils.sh
```

2. Run the script as root (recommended with sudo):

```bash
sudo bash utils/setup_ubuntu_utils.sh
```

3. Follow any manual instructions printed by the script (for example editing `~/.zshrc` to add plugins).

## Notes & Safety ⚠️
- The script performs system-level changes; review it before running if you manage a critical system.
- The script appends `sysctl.conf` settings (inotify and swappiness). If you prefer to manage those centrally, review and adjust after running.
- The Oh My Zsh installer runs in unattended mode; you may still have manual steps to customize `~/.zshrc` as prompted.

## Verification & Troubleshooting 🔎
- Check that updates applied: `sudo apt update && sudo apt upgrade -y`
- Verify drivers: `ubuntu-drivers list` and `sudo ubuntu-drivers autoinstall` logs
- Check firmware: `sudo fwupdmgr get-devices`
- UFW status: `sudo ufw status`
- Zsh availability: `which zsh` and `zsh --version`

## Author & License ✍️
- Author: João Augusto Bonfante
- Use and adapt freely. Add an explicit license if you plan to share publicly.

---

If you'd like, I can:
- Add a `--non-interactive` flag to install a pre-selected set of packages;
- Add a safe `--dry-run` mode that lists actions without applying them;
- Convert this into an idempotent Ansible playbook for repeatable provisioning.

Reply **non-interactive**, **dry-run**, **ansible**, or **no** to request one of these enhancements.
