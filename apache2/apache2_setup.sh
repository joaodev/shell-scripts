#!/usr/bin/env bash

################################################################################
# Apache2 Setup Script
# Description: Installs and configures Apache2 web server
# Author: João Augusto Bonfante
# GitHub: https://github.com/joaodev
# Date: January 2026
################################################################################

set -euo pipefail
IFS=$'\n\t'

# Defaults
APACHE_VERSION=""
SITE_NAME=""
SITE_ROOT="/var/www"
LOG_FILE="$HOME/.apache2_setup.log"
AUTO_YES=false

timestamp() { date '+%Y-%m-%d %H:%M:%S'; }
log() { printf '%s %s\n' "$(timestamp)" "$*" | tee -a "$LOG_FILE"; }
confirm() { if [ "$AUTO_YES" = true ]; then log "Auto-approve — $1"; return 0; fi; local resp; read -r -p "$1 [y/N]: " resp; case "$resp" in [yY]|[yY][eE][sS]) return 0 ;; *) return 1 ;; esac }

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -n, --name NAME       Create a virtual host with this site name (e.g. example.com)
  -p, --path PATH       Parent path for site root (default: /var/www)
  -l, --logfile FILE    Log file (default: $LOG_FILE)
  -y, --yes             Accept confirmations automatically
  -h, --help            Show this help message

Examples:
  sudo $(basename "$0") -n example.com -p /var/www
  sudo $(basename "$0") -y
EOF
}

log "=== Apache2 Setup ==="

# Parse args
while [ "$#" -gt 0 ]; do
  case "$1" in
    -n|--name) SITE_NAME="$2"; shift 2 ;;
    -p|--path) SITE_ROOT="$2"; shift 2 ;;
    -l|--logfile) LOG_FILE="$2"; shift 2 ;;
    -y|--yes) AUTO_YES=true; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) log "Unknown option: $1"; usage; exit 1 ;;
    *) break ;;
  esac
done

log "Logfile: $LOG_FILE"

# Update package manager
if confirm "Update package lists and upgrade packages? (requires sudo)"; then
  log "Updating package lists"
  sudo apt-get update
  sudo apt-get upgrade -y
else
  log "Skipped apt update/upgrade"
fi

# Install Apache
if confirm "Install Apache2 and recommended modules? (requires sudo)"; then
  log "Installing Apache2"
  sudo apt-get install -y apache2 apache2-utils apache2-dev

  log "Installing recommended modules"
  sudo apt-get install -y \
    libapache2-mod-php \
    libapache2-mod-ssl \
    libapache2-mod-security2 \
    libapache2-mod-proxy-html \
    libapache2-mod-rewrite

  log "Enabling essential modules"
  sudo a2enmod rewrite ssl proxy proxy_http headers
  # mod-security package is usually libapache2-mod-security2; enable if present
  if dpkg -l | grep -q libapache2-mod-security2; then
    sudo a2enmod security2 || true
  fi

  log "Starting and enabling Apache2"
  sudo systemctl start apache2
  sudo systemctl enable apache2
else
  log "Skipped Apache installation"
fi

log "Checking Apache2 status"
sudo systemctl status apache2 --no-pager || true

# Create virtual host if requested
if [ -n "$SITE_NAME" ]; then
  SITE_DIR="$SITE_ROOT/$SITE_NAME/public_html"
  if confirm "Create virtual host for '$SITE_NAME' at '$SITE_DIR'?"; then
    log "Creating site directory $SITE_DIR"
    sudo mkdir -p "$SITE_DIR"
    sudo chown -R "$SUDO_USER":"$SUDO_USER" "$(dirname "$SITE_DIR")" 2>/dev/null || true

    # Create a simple index.html
    echo "<html><head><title>$SITE_NAME</title></head><body><h1>Welcome to $SITE_NAME</h1></body></html>" | sudo tee "$SITE_DIR/index.html" >/dev/null

    # Create Apache vhost configuration
    VHOST_CONF="/etc/apache2/sites-available/$SITE_NAME.conf"
    log "Creating vhost configuration $VHOST_CONF"
    sudo tee "$VHOST_CONF" > /dev/null <<EOF
<VirtualHost *:80>
    ServerName $SITE_NAME
    ServerAdmin webmaster@$SITE_NAME
    DocumentRoot $SITE_DIR

    <Directory $SITE_DIR>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog "/var/log/apache2/$SITE_NAME-error.log"
    CustomLog "/var/log/apache2/$SITE_NAME-access.log" combined
</VirtualHost>
EOF

    sudo a2ensite "$SITE_NAME.conf"
    sudo systemctl reload apache2
    log "Virtual host $SITE_NAME created and enabled"
  else
    log "Skipped virtual host creation"
  fi
fi

log "Apache2 setup completed"