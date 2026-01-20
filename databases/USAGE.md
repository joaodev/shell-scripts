# Usage — Database Setup Scripts 💡

Each script accepts `-l/--logfile` to set the log file path and `-y/--yes` to accept prompts automatically.

## MongoDB

Usage:

```bash
sudo ./mongodb_setup.sh -l ~/.mongodb_setup.log          # interactive by default
sudo ./mongodb_setup.sh --yes                             # run non-interactively (accept defaults)
```

Notes:
- This script must be run as root. It adds an apt repository and installs packages and service files.
- When running interactively it will ask before updating, adding the repository, and installing.

## MySQL

Usage:

```bash
./mysql_setup.sh -l ~/.mysql_setup.log                    # interactive: you will confirm install and DB creation
DB_ROOT_PASSWORD=securepassword DB_NAME=app_db ./mysql_setup.sh -y -l /tmp/mysql.log
```

Environment variables:
- `DB_ROOT_PASSWORD`, `DB_NAME`, `DB_USER`, `DB_USER_PASSWORD`, `DB_HOST` — used if set before running the script.

## PostgreSQL

Usage:

```bash
./postgresql_setup.sh -l ~/.postgresql_setup.log          # interactive mode
./postgresql_setup.sh -y                                 # use defaults with no prompts
```

When running interactively the script will prompt for database user, password and database name. With `-y`, the script uses sensible defaults.

---

If you want examples for using these scripts in CI (GitHub Actions) or to include a link or maintainer contact in the README, tell me what to add and I'll update them. ✨
