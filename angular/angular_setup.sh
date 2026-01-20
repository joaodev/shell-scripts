#!/usr/bin/env bash

#########################################################################################
# Angular Setup Script
# Description: Installs Node.js/npm, Angular CLI and creates an Angular project
# Author: João Augusto Bonfante
# GitHub: https://github.com/joaodev
# Date: January 2026
#########################################################################################

set -euo pipefail
IFS=$'\n\t'

# Defaults
NODE_SETUP_SCRIPT_URL="https://deb.nodesource.com/setup_18.x"
NODE_VERSION="18"
LOCAL_INSTALL=false
PROJECT_NAME=""
PROJECT_PATH="."
LOG_FILE="$HOME/.angular_setup.log"
AUTO_YES=false

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
  -n, --name NAME           Project name (if omitted you will be prompted)
  -p, --path PATH           Directory to create the project in (default: .)
  -v, --node-version VER    Node.js version to install when using local install (default: $NODE_VERSION)
  -L, --local               Install Node.js locally (no sudo) using nvm
  -l, --logfile FILE        Log file (default: $LOG_FILE)
  -y, --yes                 Accept all confirmations automatically
  -h, --help                Show this help message
EOF
} 

log "=== Angular Setup Script ==="

# Parse args
while [ "$#" -gt 0 ]; do
  case "$1" in
    -n|--name) PROJECT_NAME="$2"; shift 2 ;;
    -p|--path) PROJECT_PATH="$2"; shift 2 ;;
    -v|--node-version) NODE_VERSION="$2"; shift 2 ;;
    -L|--local) LOCAL_INSTALL=true; shift ;;
    -l|--logfile) LOG_FILE="$2"; shift 2 ;;
    -y|--yes) AUTO_YES=true; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) log "Unknown option: $1"; usage; exit 1 ;;
    *) break ;;
  esac
done

: "${PROJECT_PATH:=$PROJECT_PATH}"

# Check if Node.js is installed
if command_exists node; then
  log "Node.js already installed: $(node --version)"
else
  if [ "$LOCAL_INSTALL" = true ]; then
    if ! confirm "Node.js is not installed. Do you want to install Node.js locally (no sudo) via nvm (version: $NODE_VERSION)?"; then
      log "Local Node installation cancelled by user"
      exit 1
    fi
    log "Installing nvm (if necessary) and Node $NODE_VERSION locally..."
    # Install nvm if missing
    if [ -z "$(command -v nvm 2>/dev/null)" ]; then
      curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
      export NVM_DIR="$HOME/.nvm"
      # shellcheck disable=SC1090
      if [ -s "$NVM_DIR/nvm.sh" ]; then . "$NVM_DIR/nvm.sh"; fi
    else
      export NVM_DIR="$HOME/.nvm"
      if [ -s "$NVM_DIR/nvm.sh" ]; then . "$NVM_DIR/nvm.sh"; fi
    fi

    if command -v nvm >/dev/null 2>&1; then
      nvm install "$NODE_VERSION"
      nvm alias default "$NODE_VERSION" || true
      log "Node installed locally: $(node -v)"
      log "If necessary, restart your shell or run: source \"$NVM_DIR/nvm.sh\""
    else
      log "Error: nvm not available after installation attempt"
      exit 1
    fi
  else
    if ! confirm "Node.js is not installed. Do you want to install Node.js and npm?"; then
      log "Node.js installation cancelled by user"
      exit 1
    fi
    log "Installing Node.js..."
    curl -fsSL "$NODE_SETUP_SCRIPT_URL" | sudo -E bash -
    sudo apt-get install -y nodejs
    log "Node.js installed: $(node --version)"
  fi
fi

# npm check
if command_exists npm; then
  log "npm available: $(npm --version)"
else
  log "npm not found after Node.js installation — trying to install npm via apt"
  sudo apt-get install -y npm
  log "npm installed: $(npm --version)"
fi

# Angular CLI
if command_exists ng; then
  log "Angular CLI already installed: $(ng version --minimal)"
else
  if ! confirm "Do you want to install Angular CLI globally (requires sudo)?"; then
    log "Angular CLI installation cancelled"
  else
    log "Installing Angular CLI..."
    sudo npm install -g @angular/cli
    log "Angular CLI installed: $(ng version --minimal)"
  fi
fi

# Project name
if [ -z "$PROJECT_NAME" ]; then
  if [ "$AUTO_YES" = true ]; then
    log "Error: project name missing and auto-yes enabled. Specify -n/--name."; exit 1
  fi
  read -r -p "Enter project name: " PROJECT_NAME
fi

echo ""
PROJECT_PATH_FULL="$PROJECT_PATH/$PROJECT_NAME"
log "Creating Angular project '$PROJECT_NAME' in '$PROJECT_PATH_FULL'"
if ! confirm "Create project '$PROJECT_NAME' in '$PROJECT_PATH_FULL'?"; then
  log "Operation cancelled by user"
  exit 0
fi

mkdir -p "$PROJECT_PATH"
pushd "$PROJECT_PATH" >/dev/null
log "Running: ng new '$PROJECT_NAME' --skip-git --package-manager=npm"
ng new "$PROJECT_NAME" --skip-git --package-manager=npm
popd >/dev/null

log "=== Angular setup complete ==="
log "To get started: cd $PROJECT_PATH_FULL && ng serve"

echo ""
echo "================================"
echo "Setup Complete!"
echo "================================"
echo ""
# (instructions shown in logs)


echo ""