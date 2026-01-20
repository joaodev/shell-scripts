# Apache2 Setup Script ☕️

This script installs Apache2, recommended modules, and can optionally create and enable a virtual host (site).

Features:
- Installs Apache2 and common modules
- Adds confirmations for actions and a `-y/--yes` non-interactive mode
- Timestamped log file (default: `~/.apache2_setup.log`), configurable with `-l/--logfile`
- Optional virtual host creation (`-n/--name`) with a simple index page and automatic enabling

Examples:

Install Apache interactively:

```bash
sudo ./apache2_setup.sh
```

Install and create a vhost for `example.com`:

```bash
sudo ./apache2_setup.sh -n example.com -p /var/www
```

Notes:
- Run with `sudo` to allow package installation and enabling services.
- After creating a vhost you can visit http://example.com (point DNS/hosts accordingly).
