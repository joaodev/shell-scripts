#!/usr/bin/env bash

################################################################################
# PHP Setup Script
# Description: Sets up PHP with common extensions and Composer
# Author: João Augusto Bonfante
# GitHub: https://github.com/joaodev
# Date: January 2026
################################################################################

set -euo pipefail
IFS=$'\n\t'

# Defaults
PHP_PACKAGES=(php php-cli php-fpm php-mysql php-pgsql php-sqlite3 php-curl php-gd php-json php-mbstring php-xml php-zip php-bcmath php-opcache php-redis php-memcached php-imagick php-intl php-soap php-ldap)
LOG_FILE="$HOME/.php_setup.log"
AUTO_YES=false
PHP_VERSION="" # e.g. 8.2 to install php8.2 packages

# Helpers
timestamp() { date '+%Y-%m-%d %H:%M:%S'; }
log() { printf '%s %s\n' "$(timestamp)" "$*" | tee -a "$LOG_FILE"; }
confirm() { if [ "$AUTO_YES" = true ]; then log "Auto-approve — $1"; return 0; fi; local resp; read -r -p "$1 [y/N]: " resp; case "$resp" in [yY]|[yY][eE][sS]) return 0 ;; *) return 1 ;; esac }
usage() { cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -v, --php-version VER  PHP version suffix (e.g. 8.2 to install php8.2 packages)
  -l, --logfile FILE     Log file (default: $LOG_FILE)
  -y, --yes              Run non-interactively (accept confirmations)
  -h, --help             Show this help message
EOF
}

# Parse args
while [ "$#" -gt 0 ]; do
  case "$1" in
    -v|--php-version) PHP_VERSION="$2"; shift 2 ;;
    -l|--logfile) LOG_FILE="$2"; shift 2 ;;
    -y|--yes) AUTO_YES=true; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) echo "Unknown option: $1"; usage; exit 1 ;;
    *) break ;;
  esac
done

log "=== PHP Setup ==="
log "Logfile: $LOG_FILE"

if confirm "Update package lists and upgrade packages? (requires sudo)"; then
  log "Updating package lists"
  sudo apt-get update
  sudo apt-get upgrade -y
else
  log "Skipped apt update/upgrade"
fi

# Optionally adjust package names if PHP_VERSION specified
if [ -n "$PHP_VERSION" ]; then
  PACKAGES=()
  for p in "${PHP_PACKAGES[@]}"; do
    # replace 'php' with 'php$PHP_VERSION' only for base package names
    if [[ "$p" == "php" ]]; then
      PACKAGES+=("php$PHP_VERSION")
    else
      PACKAGES+=("${p/\bphp/\php$PHP_VERSION}")
    fi
  done
else
  PACKAGES=("${PHP_PACKAGES[@]}")
fi

if confirm "Install PHP packages: ${PACKAGES[*]}? (requires sudo)"; then
  log "Installing PHP packages"
  sudo apt-get install -y "${PACKAGES[@]}"
else
  log "Skipped PHP package installation"
fi

# Install Composer
if command -v composer >/dev/null 2>&1; then
  log "Composer is already installed: $(composer --version)"
else
  if confirm "Install Composer (PHP dependency manager)?"; then
    log "Installing Composer"
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
    sudo chmod +x /usr/local/bin/composer
  else
    log "Skipped Composer installation"
  fi
fi

# Verify installations
log "PHP Version:"
php -v || log "php not found"
log "Composer Version:"
composer --version || log "composer not found"

# Start PHP-FPM service
if confirm "Start and enable PHP-FPM service? (requires sudo)"; then
  log "Starting/enabling php-fpm"
  sudo systemctl start php-fpm || true
  sudo systemctl enable php-fpm || true
else
  log "Skipped starting php-fpm"
fi

log "PHP setup completed"