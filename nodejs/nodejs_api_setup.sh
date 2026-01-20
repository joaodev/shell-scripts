#!/usr/bin/env bash

################################################################################
# NodeJS API Setup Script
# Description: Creates a Node.js API project with confirmations and logging
# Author: João Augusto Bonfante
# GitHub: https://github.com/joaodev
# Date: January 2026
################################################################################

set -euo pipefail
IFS=$'\n\t'

# Defaults
NODE_SETUP_SCRIPT_URL="https://deb.nodesource.com/setup_18.x"
NODE_VERSION="18"
LOCAL_INSTALL=false
PROJECT_NAME=""
PROJECT_PATH="."
LOG_FILE="$HOME/.nodejs_api_setup.log"
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
  -v, --node-version VER    Node.js version to install when using local mode (default: $NODE_VERSION)
  -L, --local               Install Node locally (no sudo) using nvm
  -l, --logfile FILE        Log file (default: $LOG_FILE)
  -y, --yes                 Accept all confirmations automatically
  -h, --help                Show this help message
EOF
} 

log "=== NodeJS API Setup Script ==="

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

# Node.js
if command_exists node; then
  log "Node.js already installed: $(node -v)"
else
  if [ "$LOCAL_INSTALL" = true ]; then
    if ! confirm "Node.js is not installed. Install Node.js locally (no sudo) via nvm (version: $NODE_VERSION)?"; then
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
      # If nvm exists, try to source it (it may be available as function)
      export NVM_DIR="$HOME/.nvm"
      if [ -s "$NVM_DIR/nvm.sh" ]; then . "$NVM_DIR/nvm.sh"; fi
    fi

    # Install requested Node version
    if command -v nvm >/dev/null 2>&1; then
      nvm install "$NODE_VERSION"
      nvm alias default "$NODE_VERSION" || true
      log "Node installed locally: $(node -v)"
      log "If needed, restart your shell or run: source \"$NVM_DIR/nvm.sh\""
    else
      log "Error: nvm not available after installation attempt"
      exit 1
    fi
  else
    if ! confirm "Node.js is not installed. Install Node.js system-wide (requires sudo)?"; then
      log "Node.js installation cancelled by user"
      exit 1
    fi
    log "Installing Node.js via apt..."
    curl -fsSL "$NODE_SETUP_SCRIPT_URL" | sudo -E bash -
    sudo apt-get install -y nodejs
    log "Node.js installed: $(node -v)"
  fi
fi

# npm
if ! command_exists npm; then
  log "npm not found. Aborting"
  exit 1
else
  log "npm: $(npm -v)"
fi

# Project name
if [ -z "$PROJECT_NAME" ]; then
  if [ "$AUTO_YES" = true ]; then
    log "Error: project name missing and auto-yes enabled. Specify -n/--name."; exit 1
  fi
  read -r -p "Enter project name: " PROJECT_NAME
fi

PROJECT_PATH_FULL="$PROJECT_PATH/$PROJECT_NAME"
log "Creating project: $PROJECT_NAME at $PROJECT_PATH_FULL"
if ! confirm "Create project '$PROJECT_NAME' in '$PROJECT_PATH_FULL'?"; then
  log "Operation cancelled by user"
  exit 0
fi

mkdir -p "$PROJECT_PATH_FULL"
cd "$PROJECT_PATH_FULL"

log "Initializing npm project"
npm init -y

log "Installing essential dependencies: express, dotenv, cors"
npm install express dotenv cors
log "Installing dev-dependencies: nodemon"
npm install --save-dev nodemon

log "Creating directory structure"
mkdir -p src routes controllers models middleware config
touch src/index.js routes/.gitkeep controllers/.gitkeep models/.gitkeep

log "Creating .env"
cat > .env << 'EOF'
PORT=3000
NODE_ENV=development
EOF

log "Creating .gitignore"
cat > .gitignore << 'EOF'
node_modules/
.env
.DS_Store
*.log
dist/
EOF

log "Creating main app file"
cat > src/index.js << 'EOF'
require('dotenv').config();
const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.get('/api/health', (req, res) => {
  res.json({ status: 'Server is running' });
});

app.listen(PORT, () => {
  console.log(`✅ Server running on http://localhost:${PORT}`);
});
EOF

# Update package.json scripts
npm set-script start "node src/index.js"
npm set-script dev "nodemon src/index.js"

log "✅ Project setup complete!"
log "📋 Next steps:"
log "  1. cd $PROJECT_PATH_FULL"
log "  2. npm run dev    # (development with auto-reload)"
log "  3. npm start      # (production)"