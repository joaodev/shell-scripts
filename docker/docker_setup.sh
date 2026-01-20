#!/usr/bin/env bash

################################################################################
# Docker Setup Script
# Description: Installs and configures Docker on Debian/Ubuntu systems
# Author: João Augusto Bonfante
# GitHub: https://github.com/joaodev
# Date: January 2026
################################################################################

set -euo pipefail
IFS=$'\n\t'

# Defaults
LOG_FILE="$HOME/.docker_setup.log"
AUTO_YES=false
VERBOSE=false

# Helpers
timestamp() { date '+%Y-%m-%d %H:%M:%S'; }
log() {
  # Append to logfile and optionally print to stdout when verbose
  if [ "$VERBOSE" = true ]; then
    printf '%s %s\n' "$(timestamp)" "$*" | tee -a "$LOG_FILE"
  else
    printf '%s %s\n' "$(timestamp)" "$*" >> "$LOG_FILE"
  fi
}
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
  -y, --yes           Run non-interactively (assume yes)
  -v, --verbose       Enable verbose output
  -l, --logfile FILE  Log file (default: $LOG_FILE)
  -h, --help          Show this help message
EOF
}


while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes) AUTO_YES=true; shift ;;
    -v|--verbose) VERBOSE=true; shift ;;
    -l|--logfile) LOG_FILE="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) echo "Unknown option: $1"; usage; exit 1 ;;
    *) break ;;
  esac
done

# Print summary and confirm unless --yes is provided
echo "Docker installation script will make changes to your system."
log "Non-interactive: $AUTO_YES; verbose: $VERBOSE; logfile: $LOG_FILE"
if [ "$AUTO_YES" = true ]; then
  export DEBIAN_FRONTEND=noninteractive
else
  if ! confirm "Continue with Docker installation and system changes?"; then
    log "User aborted before starting installation"
    echo "Aborted."
    exit 1
  fi
fi

# Enable shell command tracing if verbose
if [ "$VERBOSE" = true ]; then
  set -o xtrace
fi

log "Starting: update system packages"
if confirm "Run apt-get update now?"; then
  echo "Updating system packages..."
  sudo apt-get update
else
  log "Skipped apt-get update"
fi

log "About to install Docker dependencies"
if confirm "Install prerequisites (ca-certificates, curl, gnupg, lsb-release)?"; then
  log "Installing dependencies: ca-certificates curl gnupg lsb-release"
  echo "Installing Docker dependencies..."
  sudo apt-get install -y \
      ca-certificates \
      curl \
      gnupg \
      lsb-release
else
  log "Skipped installing prerequisites"
fi

if confirm "Import Docker GPG key and add Docker apt repository?"; then
  log "Adding Docker GPG key (downloading and creating keyring)"
  echo "Adding Docker GPG key..."
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

  log "Configuring Docker apt repository"
  echo "Setting up Docker repository..."
  echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
else
  log "Skipped adding Docker GPG key/repository"
fi

if confirm "Install Docker packages now (docker-ce, docker-ce-cli, containerd.io, docker-compose-plugin)?"; then
  log "Installing Docker packages"
  echo "Installing Docker..."
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
else
  log "Skipped Docker package installation"
fi

if confirm "Add current user '$USER' to docker group? (requires sudo)"; then
  log "Adding current user to docker group: $USER"
  echo "Adding current user to docker group..."
  sudo usermod -aG docker "$USER"
else
  log "Skipped adding user to docker group"
fi

if confirm "Start and enable Docker service?"; then
  log "Starting and enabling docker service"
  echo "Starting Docker service..."
  sudo systemctl start docker
  sudo systemctl enable docker
else
  log "Skipped starting/enabling Docker service"
fi

echo "Docker installation completed!"
log "Installed Docker version: $(docker --version 2>/dev/null || echo 'unknown')"
if command -v docker >/dev/null 2>&1; then
  docker --version || true
else
  echo "docker executable not found in PATH"
fi