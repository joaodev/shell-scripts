#!/usr/bin/env bash

################################################################################
# MongoDB Setup Script
# Description: Installs and configures MongoDB database server
# Author: João Augusto Bonfante
# GitHub: https://github.com/joaodev
# Date: January 2026
################################################################################

set -euo pipefail
IFS=$'\n\t'

# Defaults
LOG_FILE="$HOME/.mongodb_setup.log"
AUTO_YES=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

log "MongoDB Setup Script"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    log "ERROR: This script must be run as root"
    echo -e "${RED}This script must be run as root${NC}"
    exit 1
fi

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


# Update system packages
if confirm "Update system packages and run upgrade?"; then
  log "Updating system packages"
  echo -e "${YELLOW}Updating system packages...${NC}"
  apt-get update
  apt-get upgrade -y
else
  log "Skipped system update"
fi

# Import MongoDB GPG key and add repository
if confirm "Add MongoDB repository and import GPG key?"; then
  log "Importing MongoDB GPG key"
  echo -e "${YELLOW}Importing MongoDB GPG key...${NC}"
  curl -fsSL https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add -

  log "Adding MongoDB repository"
  echo -e "${YELLOW}Adding MongoDB repository...${NC}"
  echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list

  # Update apt cache
  apt-get update
else
  log "Skipped adding MongoDB repository"
fi

# Install MongoDB
if confirm "Install MongoDB package?"; then
  log "Installing MongoDB"
  echo -e "${YELLOW}Installing MongoDB...${NC}"
  apt-get install -y mongodb-org

  # Enable and start MongoDB
  log "Enabling and starting MongoDB service"
  echo -e "${YELLOW}Enabling MongoDB service...${NC}"
  systemctl enable mongod
  systemctl start mongod
else
  log "Skipped MongoDB installation"
fi

# Verify installation
log "Verifying MongoDB installation"
echo -e "${YELLOW}Verifying MongoDB installation...${NC}"
if command -v mongosh >/dev/null 2>&1; then
  mongosh --version || log "mongosh returned an error"
else
  log "mongosh not available"
fi

# Check service status
if systemctl is-active --quiet mongod; then
     echo -e "${GREEN}MongoDB is running successfully${NC}"
else
     echo -e "${RED}MongoDB failed to start${NC}"
     exit 1
fi

echo -e "${GREEN}MongoDB setup completed!${NC}"