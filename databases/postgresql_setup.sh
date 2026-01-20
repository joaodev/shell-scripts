#!/usr/bin/env bash

################################################################################
# PostgreSQL Setup Script
# Description: Installs and configures PostgreSQL database server
# Author: João Augusto Bonfante
# GitHub: https://github.com/joaodev
# Date: January 2026
################################################################################

set -euo pipefail
IFS=$'\n\t'

# Defaults
LOG_FILE="$HOME/.postgresql_setup.log"
AUTO_YES=false

# Helpers
timestamp() { date '+%Y-%m-%d %H:%M:%S'; }
log() { printf '%s %s\n' "$(timestamp)" "$*" | tee -a "$LOG_FILE"; }
command_exists() { command -v "$1" >/dev/null 2>&1; }
confirm() {
  if [ "$AUTO_YES" = true ]; then
    log "Auto-approve enabled — skipping confirmation: $1"
    return 0
  fi
  local resp
  read -r -p "$1 [y/N]: " resp
  case "$resp" in
    [yY]|[yY][eE][sS]) return 0 ;;
    *) return 1 ;;
  esac
}

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -l, --logfile FILE    Log file (default: $LOG_FILE)
  -y, --yes             Accept all confirmations automatically
  -h, --help            Show this help message
EOF
}

log "=== PostgreSQL Setup ==="

# Parse args
while [ "$#" -gt 0 ]; do
  case "$1" in
    -l|--logfile) LOG_FILE="$2"; shift 2 ;;
    -y|--yes) AUTO_YES=true; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) log "Unknown option: $1"; usage; exit 1 ;;
    *) break ;;
  esac
done

# Update system packages and install PostgreSQL
if confirm "Update system packages and install PostgreSQL (requires sudo)?"; then
  log "Updating system packages"
  echo "Updating system packages..."
  sudo apt-get update
  sudo apt-get upgrade -y

  log "Installing PostgreSQL"
  echo "Installing PostgreSQL..."
  sudo apt-get install -y postgresql postgresql-contrib

  log "Starting and enabling PostgreSQL service"
  echo "Starting PostgreSQL service..."
  sudo systemctl start postgresql
  sudo systemctl enable postgresql
else
  log "Skipped PostgreSQL installation"
fi

# Create a new database user (optional)
if [ "$AUTO_YES" = true ]; then
  DB_USER="${DB_USER:-postgres}"
  DB_PASSWORD="${DB_PASSWORD:-changeme}"
  log "AUTO_YES enabled — using default DB user and password"
else
  read -r -p "Enter database username (default: postgres): " DB_USER
  DB_USER=${DB_USER:-postgres}
  read -r -s -p "Enter database password: " DB_PASSWORD
  echo
fi

if confirm "Create database user '$DB_USER'?"; then
  log "Creating database user $DB_USER"
  echo "Creating database user..."
  sudo -u postgres psql <<EOF
CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';
ALTER ROLE $DB_USER CREATEDB;
EOF
else
  log "Skipped creating database user"
fi

# Create a sample database
if [ "$AUTO_YES" = true ]; then
  DB_NAME="${DB_NAME:-myapp_db}"
else
  read -r -p "Enter database name (default: myapp_db): " DB_NAME
  DB_NAME=${DB_NAME:-myapp_db}
fi

if confirm "Create database '$DB_NAME' owned by '$DB_USER'?"; then
  log "Creating database $DB_NAME"
  echo "Creating database '$DB_NAME'..."
  sudo -u postgres createdb -O "$DB_USER" "$DB_NAME"
else
  log "Skipped creating database $DB_NAME"
fi

# Display PostgreSQL status


# Display PostgreSQL status
echo ""
echo "=== PostgreSQL Status ==="
sudo systemctl status postgresql --no-pager

echo ""
echo "✓ PostgreSQL setup complete!"
echo "Database: $DB_NAME"
echo "User: $DB_USER"