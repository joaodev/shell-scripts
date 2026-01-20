# Usage — Nginx Setup Script 💡

Usage:

```bash
sudo ./nginx_setup.sh [options]
```

Options:
- `-n, --name NAME`       Create a server block for this site (e.g. example.com)
- `-p, --path PATH`       Parent path for site root (default: /var/www)
- `-l, --logfile FILE`    Log file (default: `~/.nginx_setup.log`)
- `-y, --yes`             Non-interactive (accept confirmations)
- `-V, --verbose`         Verbose mode (prints log to stdout)
- `-h, --help`            Show help

Example:

```bash
sudo ./nginx_setup.sh -n example.com -p /var/www -V
```

The script will install Nginx, create a default web root if requested, and create/enable a server block when `-n` is provided.
