# Usage & Verification — Ubuntu Utilities 🛠️

**File:** `setup_ubuntu_utils.sh`

## Quickstart 🚀
1. Optional: make the script executable:

```bash
chmod +x utils/setup_ubuntu_utils.sh
```

2. Run the script as root (recommended using sudo):

```bash
sudo bash utils/setup_ubuntu_utils.sh
```

3. Review printed warnings and manual steps (e.g., add recommended plugins to `~/.zshrc`).

---

## Common checks after running 🔎
- Confirm packages installed:

```bash
apt list --installed | grep -E "git|zsh|vim|curl|build-essential"
```

- Verify drivers/firmware:

```bash
ubuntu-drivers list
sudo fwupdmgr get-devices
```

- Confirm `sysctl` values are applied:

```bash
sysctl fs.inotify.max_user_watches
sysctl vm.swappiness
```

- Check UFW is enabled and allows SSH:

```bash
sudo ufw status verbose
```

- Confirm Zsh and Oh My Zsh:

```bash
which zsh
ls -la ~/.oh-my-zsh
```

---

## Revert / Undo tips 🛠️
- To revert `sysctl` changes, edit `/etc/sysctl.conf` and remove the appended lines, then run `sudo sysctl -p`.
- To remove Oh My Zsh, run `~/.oh-my-zsh/tools/uninstall.sh` or follow the official uninstall instructions.
- To remove packages installed by the script, list them (`apt list --installed`) and remove selectively: `sudo apt remove --purge <package>`.

---

## Troubleshooting ⚠️
- Permission issues: re-run the script with `sudo`.
- Driver / firmware issues: check `sudo journalctl -u fwupd` and `dmesg` for errors.
- If you need the script to skip certain sections, I can add command-line flags (`--no-zsh`, `--no-fwupd`, etc.).

---

If you want, I can add command-line flags to the script for selective execution or a dry-run mode. Reply **yes** to have me add that (or specify which flags you prefer).
