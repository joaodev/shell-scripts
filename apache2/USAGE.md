# Usage — Apache2 Setup Script 💡

Usage:

```bash
sudo ./apache2_setup.sh [options]
```

Options:
- `-n, --name NAME`       Create a virtual host for this site (e.g. example.com)
- `-p, --path PATH`       Parent path for site root (default: /var/www)
- `-l, --logfile FILE`    Log file (default: `~/.apache2_setup.log`)
- `-y, --yes`             Non-interactive (accept confirmations)
- `-h, --help`            Show help

Example:

```bash
sudo ./apache2_setup.sh -n example.com -p /var/www -y
```

The script will install Apache2 and recommended modules, enable essential mods, and can create a simple virtual host with default logs in `/var/log/apache2/`.
