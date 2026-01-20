#!/usr/bin/env bash

################################################################################
# Nginx Setup Script
# Description: Sets up Nginx with a basic configuration
# Author: João Augusto Bonfante
# GitHub: https://github.com/joaodev
# Date: January 2026
################################################################################

set -euo pipefail
IFS=$'\n\t'

# Defaults
SITE_NAME=""
SITE_ROOT="/var/www"
LOG_FILE="$HOME/.nginx_setup.log"
AUTO_YES=false
VERBOSE=false

timestamp() { date '+%Y-%m-%d %H:%M:%S'; }
log() { if [ "$VERBOSE" = true ]; then printf '%s %s\n' "$(timestamp)" "$*" | tee -a "$LOG_FILE"; else printf '%s %s\n' "$(timestamp)" "$*" >> "$LOG_FILE"; fi }
confirm() { if [ "$AUTO_YES" = true ]; then log "Auto-approve — $1"; return 0; fi; local resp; read -r -p "$1 [y/N]: " resp; case "$resp" in [yY]|[yY][eE][sS]) return 0 ;; *) return 1 ;; esac }

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -n, --name NAME       Create a server block for this site (e.g. example.com)
  -p, --path PATH       Parent path for site root (default: /var/www)
  -l, --logfile FILE    Log file (default: $LOG_FILE)
  -y, --yes             Accept confirmations automatically
  -V, --verbose         Enable verbose logging
  -h, --help            Show this help message

Examples:
  sudo $(basename "$0") -n example.com -p /var/www
  sudo $(basename "$0") -y
EOF
}

log "=== Nginx Setup ==="

# Parse args
while [ "$#" -gt 0 ]; do
  case "$1" in
    -n|--name) SITE_NAME="$2"; shift 2 ;;
    -p|--path) SITE_ROOT="$2"; shift 2 ;;
    -l|--logfile) LOG_FILE="$2"; shift 2 ;;
    -y|--yes) AUTO_YES=true; shift ;;
    -V|--verbose) VERBOSE=true; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) echo "Unknown option: $1"; usage; exit 1 ;;
    *) break ;;
  esac
done

# Update and upgrade
if confirm "Update and upgrade system packages? (requires sudo)"; then
  log "Updating packages"
  sudo apt-get update
  sudo apt-get upgrade -y
else
  log "Skipped update/upgrade"
fi

# Install nginx
if confirm "Install Nginx and recommended libraries? (requires sudo)"; then
  log "Installing Nginx and libraries"
  sudo apt-get install -y nginx
  sudo apt-get install -y \
    curl wget git build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev libgeoip-dev

  log "Enabling and starting nginx"
  sudo systemctl enable nginx
  sudo systemctl start nginx
else
  log "Skipped nginx installation"
fi

# Verify installation
log "Verifying Nginx installation"
nginx -v || log "nginx not found"

# Create default site dir and permissions
DEFAULT_DIR="$SITE_ROOT/html/default"
if confirm "Create default web root at $DEFAULT_DIR and set permissions?"; then
  sudo mkdir -p "$DEFAULT_DIR"
  sudo chown -R "$SUDO_USER":"$SUDO_USER" "$SITE_ROOT" 2>/dev/null || true
  log "Created $DEFAULT_DIR and adjusted permissions"
fi

# Create server block if site name provided
if [ -n "$SITE_NAME" ]; then
  SERVER_BLOCK="/etc/nginx/sites-available/$SITE_NAME"
  SITE_DIR="$SITE_ROOT/$SITE_NAME/html"
  if confirm "Create server block for $SITE_NAME and enable it?"; then
    log "Creating site directory $SITE_DIR"
    sudo mkdir -p "$SITE_DIR"
    sudo chown -R "$SUDO_USER":"$SUDO_USER" "$SITE_ROOT" 2>/dev/null || true

    echo "<html><head><title>$SITE_NAME</title></head><body><h1>Welcome to $SITE_NAME</h1></body></html>" | sudo tee "$SITE_DIR/index.html" >/dev/null

    log "Creating server block $SERVER_BLOCK"
    sudo tee "$SERVER_BLOCK" > /dev/null <<EOF
server {
    listen 80;
    server_name $SITE_NAME;

    root $SITE_DIR;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

    sudo ln -sf "$SERVER_BLOCK" "/etc/nginx/sites-enabled/$SITE_NAME"
    sudo nginx -t && sudo systemctl reload nginx
    log "Server block $SITE_NAME created and enabled"
  else
    log "Skipped creating server block for $SITE_NAME"
  fi
fi

log "Nginx setup completed"