# Nginx Setup Script 🌀

This script installs Nginx, optional recommended libraries, and can create a server block (site) with a default index page.

Features:
- Installs Nginx and common libraries
- Adds confirmations and `-y/--yes` non-interactive mode
- Timestamped logging (default: `~/.nginx_setup.log`), configurable with `-l/--logfile`
- Optional server block (`-n/--name`) creation and enabling in `/etc/nginx/sites-enabled`

Examples:

Install Nginx interactively:

```bash
sudo ./nginx_setup.sh
```

Install and create a site `example.com`:

```bash
sudo ./nginx_setup.sh -n example.com -p /var/www -y
```

Notes:
- Run with `sudo` for package installation and service control.
- After creating a server block, ensure DNS or `/etc/hosts` points `example.com` to your machine to test locally.
