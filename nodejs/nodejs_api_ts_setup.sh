#!/usr/bin/env bash

#########################################################################################
# NodeJS TypeScript API Setup Script
# Description: Creates a Node.js TypeScript API project with confirmations and logging
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
LOG_FILE="$HOME/.nodejs_api_ts_setup.log"
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

log "=== Node.js TypeScript API Setup ==="

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

# Check Node.js and optionally install
if command_exists node; then
  log "Node.js already installed: $(node -v)"
else
  if [ "$LOCAL_INSTALL" = true ]; then
    if ! confirm "Node.js is not installed. Install Node.js locally (no sudo) via nvm (version: $NODE_VERSION)?"; then
      log "Local Node installation cancelled by user"
      exit 1
    fi
    log "Installing nvm (if necessary) and Node $NODE_VERSION locally..."
    if [ -z "$(command -v nvm 2>/dev/null)" ]; then
      curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
      export NVM_DIR="$HOME/.nvm"
      if [ -s "$NVM_DIR/nvm.sh" ]; then . "$NVM_DIR/nvm.sh"; fi
    else
      export NVM_DIR="$HOME/.nvm"
      if [ -s "$NVM_DIR/nvm.sh" ]; then . "$NVM_DIR/nvm.sh"; fi
    fi
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

# Project name
if [ -z "$PROJECT_NAME" ]; then
  if [ "$AUTO_YES" = true ]; then
    log "Error: project name missing and auto-yes enabled. Specify -n/--name."; exit 1
  fi
  read -r -p "Enter project name (default: my-nodejs-api): " PROJECT_NAME
  PROJECT_NAME=${PROJECT_NAME:-my-nodejs-api}
fi

PROJECT_PATH_FULL="$PROJECT_PATH/$PROJECT_NAME"
if ! confirm "Create project '$PROJECT_NAME' in '$PROJECT_PATH_FULL'?"; then
  log "Operation cancelled by user"
  exit 0
fi

# Create project directory
mkdir -p "$PROJECT_PATH_FULL"
cd "$PROJECT_PATH_FULL"

log "Creating project: $PROJECT_NAME at $PROJECT_PATH"
if ! confirm "Create project '$PROJECT_NAME' in '$PROJECT_PATH'?"; then
  log "Operation cancelled by user"
  exit 0
fi

# Initialize npm project
log "Inicializando npm project"
npm init -y

# Install dependencies
log "Installing dependencies: express, dotenv, cors"
npm install express dotenv cors
log "Installing dev-dependencies: typescript, @types/node, @types/express, ts-node, nodemon"
npm install -D typescript @types/node @types/express ts-node nodemon

# Initialize TypeScript
log "Configurando TypeScript (tsconfig.json)"
npx tsc --init

# Create project structure
log "Creating src directory"
mkdir -p src

# Create tsconfig.json
cat > tsconfig.json << 'EOF'
{
    "compilerOptions": {
        "target": "ES2020",
        "module": "commonjs",
        "lib": ["ES2020"],
        "outDir": "./dist",
        "rootDir": "./src",
        "strict": true,
        "esModuleInterop": true,
        "skipLibCheck": true,
        "forceConsistentCasingInFileNames": true,
        "resolveJsonModule": true,
        "moduleResolution": "node"
    },
    "include": ["src/**/*"],
    "exclude": ["node_modules"]
}
EOF

# Create .env file
log "Creating .env"
cat > .env << 'EOF'
PORT=3000
NODE_ENV=development
EOF

# Create main server file
log "Creating src/server.ts"
cat > src/server.ts << 'EOF'
import express, { Request, Response } from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.get('/api/health', (req: Request, res: Response) => {
    res.json({ status: 'ok', message: 'Server is running' });
});

app.listen(PORT, () => {
    console.log(`✅ Server running on http://localhost:${PORT}`);
});
EOF

# Update package.json scripts
log "Updating scripts in package.json"
npm pkg set scripts.dev="ts-node src/server.ts"
npm pkg set scripts.build="tsc"
npm pkg set scripts.start="node dist/server.js"

log "✅ Setup complete!"
log "📝 Next steps:"
log "   cd $PROJECT_PATH/$PROJECT_NAME"
log "   npm run dev"
