#!/usr/bin/env bash

################################################################################
# NodeJS Setup Script
# Description: Sets up Node.js system-wide installation
# Author: João Augusto Bonfante
# GitHub: https://github.com/joaodev
# Date: January 2026
################################################################################

set -euo pipefail
IFS=$'\n\t'

# Defaults
NODE_VERSION="20.10.0"
LOG_FILE="$HOME/.nodejs_setup.log"
AUTO_YES=false
VERBOSE=false

timestamp() { date '+%Y-%m-%d %H:%M:%S'; }
log() { if [ "$VERBOSE" = true ]; then printf '%s %s\n' "$(timestamp)" "$*" | tee -a "$LOG_FILE"; else printf '%s %s\n' "$(timestamp)" "$*" >> "$LOG_FILE"; fi }
confirm() { if [ "$AUTO_YES" = true ]; then log "Auto-approve enabled — skipping confirmation: $1"; return 0; fi; local resp; read -r -p "$1 [y/N]: " resp; case "$resp" in [yY]|[yY][eE][sS]) return 0 ;; *) return 1 ;; esac }

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -v, --version VER    Node.js version (default: $NODE_VERSION)
  -l, --logfile FILE   Log file (default: $LOG_FILE)
  -y, --yes            Run non-interactively (assume yes)
  -V, --verbose        Enable verbose logging
  -h, --help           Show help

Example: sudo ./$(basename "$0") -v 20.10.0
EOF
}

log "Starting Node.js installation..."
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

# Update system packages if user confirms
if confirm "Update system packages and upgrade? (requires sudo)"; then
  log "Updating system packages"
  sudo apt-get update
  sudo apt-get upgrade -y
else
  log "Skipped system update"
fi

# Install dependencies
if confirm "Install build dependencies (curl, wget, git, build-essential, python3)? (requires sudo)"; then
  log "Installing dependencies"
  sudo apt-get install -y \
      curl \
      wget \
      git \
      build-essential \
      python3
else
  log "Skipped installing dependencies"
fi

# Determine architecture
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    NODE_ARCH="x64"
elif [ "$ARCH" = "aarch64" ]; then
    NODE_ARCH="arm64"
else
    NODE_ARCH="$ARCH"
fi

NODEJS_URL="https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz"

if confirm "Download and install Node.js v${NODE_VERSION} to /usr/local (requires sudo)?"; then
  log "Downloading Node.js v${NODE_VERSION} from $NODEJS_URL"
  cd /tmp
  wget -q "$NODEJS_URL"

  log "Extracting Node.js"
  tar -xf "node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz"

  log "Installing Node.js to /usr/local"
  sudo cp -r "node-v${NODE_VERSION}-linux-${NODE_ARCH}"/* /usr/local/

  # Cleanup
  rm -rf "node-v${NODE_VERSION}-linux-${NODE_ARCH}"*

  log "Verifying installation"
  node --version || log "node not found"
  npm --version || log "npm not found"

  log "Node.js installation complete!"
else
  log "Node.js installation skipped"
fi