#!/usr/bin/env bash

################################################################################
# MySQL Setup Script
# Description: Installs and configures MySQL database server
# Author: João Augusto Bonfante
# GitHub: https://github.com/joaodev
# Date: January 2026
################################################################################

set -euo pipefail
IFS=$'\n\t'

# Defaults
LOG_FILE="$HOME/.mysql_setup.log"
AUTO_YES=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DB_ROOT_PASSWORD="${DB_ROOT_PASSWORD:-root_password}"
DB_NAME="${DB_NAME:-myapp_db}"
DB_USER="${DB_USER:-myapp_user}"
DB_USER_PASSWORD="${DB_USER_PASSWORD:-user_password}"
DB_HOST="${DB_HOST:-localhost}"

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

log "Starting MySQL Setup"

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

# Check if MySQL is installed
if ! command -v mysql &> /dev/null; then
    if confirm "MySQL is not installed. Install it now?"; then
      log "Installing MySQL"
      echo -e "${YELLOW}Installing MySQL...${NC}"
      sudo apt-get update
      sudo apt-get install -y mysql-server
    else
      log "MySQL installation skipped by user"
    fi
else
    log "MySQL is already installed"
    echo -e "${GREEN}MySQL is already installed${NC}"
fi

# Start MySQL service
echo -e "${YELLOW}Starting MySQL service...${NC}"
sudo systemctl start mysql
sudo systemctl enable mysql

# Wait for MySQL to be ready
sleep 2

# Set root password (if needed)
if confirm "Configure root password for MySQL now?"; then
  log "Configuring root user"
  echo -e "${YELLOW}Configuring root user...${NC}"
  mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PASSWORD';" 2>/dev/null || true
else
  log "Skipped root password configuration"
fi

# Create database
if confirm "Create database '$DB_NAME'?"; then
  log "Creating database: $DB_NAME"
  echo -e "${YELLOW}Creating database: $DB_NAME${NC}"
  mysql -u root -p"$DB_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;"
else
  log "Skipped creating database '$DB_NAME'"
fi

# Create user
if confirm "Create database user '$DB_USER'@'$DB_HOST'?"; then
  log "Creating database user: $DB_USER"
  echo -e "${YELLOW}Creating database user: $DB_USER${NC}"
  mysql -u root -p"$DB_ROOT_PASSWORD" -e "CREATE USER IF NOT EXISTS '$DB_USER'@'$DB_HOST' IDENTIFIED BY '$DB_USER_PASSWORD';"

  # Grant privileges
  log "Granting privileges"
  echo -e "${YELLOW}Granting privileges...${NC}"
  mysql -u root -p"$DB_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'$DB_HOST'; FLUSH PRIVILEGES;"
else
  log "Skipped creating user '$DB_USER'"
fi

log "MySQL setup completed successfully"



echo -e "${GREEN}MySQL setup completed successfully!${NC}"
echo -e "${GREEN}Database: $DB_NAME${NC}"
echo -e "${GREEN}User: $DB_USER${NC}"