# Database Setup Scripts 🗄️

This folder contains small, focused Bash scripts to install and configure popular databases on Debian/Ubuntu-based systems:

- `mongodb_setup.sh` — Install and configure MongoDB (requires root)
- `mysql_setup.sh` — Install and create a database and user for MySQL
- `postgresql_setup.sh` — Install PostgreSQL, create a user and a sample database

All scripts now include:

- Interactive confirmations with an automatic non-interactive mode (`-y` / `--yes`).
- Basic logging to a per-script log file (default: `~/.<script>_setup.log`), configurable with `-l/--logfile`.
- Clear messages and simple defaults to help automation and manual runs.

---

Notes & recommendations:

- `mongodb_setup.sh` must be run as `root` (it modifies apt sources and installs a system service).
- `mysql_setup.sh` and `postgresql_setup.sh` use `sudo` when necessary — run them from a user with sudo rights.
- For CI or automated runs, prefer non-interactive mode: `-y` will accept confirmations and use sensible defaults.

If you'd like, I can add examples for GitHub Actions or systemd units that use these scripts.
