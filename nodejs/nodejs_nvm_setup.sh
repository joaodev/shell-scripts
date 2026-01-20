#!/usr/bin/env bash

################################################################################
# NodeJS NVM Setup Script
# Description: Sets up NVM (Node Version Manager) and installs Node.js
# Author: João Augusto Bonfante
# GitHub: https://github.com/joaodev
# Date: January 2026
################################################################################

set -euo pipefail
IFS=$'\n\t'

# Defaults
NODE_VERSION="lts/*"
LOG_FILE="$HOME/.nvm_setup.log"
AUTO_YES=false
VERBOSE=false

timestamp() { date '+%Y-%m-%d %H:%M:%S'; }
log() { if [ "$VERBOSE" = true ]; then printf '%s %s\n' "$(timestamp)" "$*" | tee -a "$LOG_FILE"; else printf '%s %s\n' "$(timestamp)" "$*" >> "$LOG_FILE"; fi }
confirm() { if [ "$AUTO_YES" = true ]; then log "Auto-approve enabled — skipping confirmation: $1"; return 0; fi; local resp; read -r -p "$1 [y/N]: " resp; case "$resp" in [yY]|[yY][eE][sS]) return 0 ;; *) return 1 ;; esac }

usage() { cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -v, --version VER    Node version to install (default: LTS)
  -l, --logfile FILE   Log file (default: $LOG_FILE)
  -y, --yes            Run non-interactively (assume yes)
  -V, --verbose        Enable verbose logging
  -h, --help           Show help
EOF
}

# Parse args
while [ "$#" -gt 0 ]; do
  case "$1" in
    -v|--version) NODE_VERSION="$2"; shift 2 ;;
    -l|--logfile) LOG_FILE="$2"; shift 2 ;;
    -y|--yes) AUTO_YES=true; shift ;;
    -V|--verbose) VERBOSE=true; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) echo "Unknown option: $1"; usage; exit 1 ;;
    *) break ;;
  esac
done

log "=== NodeJS NVM Setup ==="

if ! confirm "Install nvm and Node.js ($NODE_VERSION) for the current user?"; then
  log "User cancelled nvm installation"
  exit 1
fi

log "Installing NVM"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash

# Load NVM
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  # shellcheck disable=SC1090
  . "$NVM_DIR/nvm.sh"
else
  log "Error: nvm install script did not leave nvm available in $NVM_DIR"
  exit 1
fi

log "Installing Node.js $NODE_VERSION"
nvm install "$NODE_VERSION"

log "Setting default Node version"
nvm alias default "$NODE_VERSION" || true

log "=== Installation Complete ==="
node --version || true
npm --version || true
nvm --version || true