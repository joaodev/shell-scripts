#!/usr/bin/env bash

##################################################################################################
# Next.js Setup Script
# Description: Sets up a Next.js project with optional templates, confirmations, and logging
# Author: João Augusto Bonfante
# GitHub: https://github.com/joaodev
# Date: January 2026
##################################################################################################

set -euo pipefail
IFS=$'\n\t'

# Defaults
LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/shell-scripts"
mkdir -p "$LOG_DIR"
SCRIPT_NAME="$(basename "$0")"
LOG_FILE="$LOG_DIR/${SCRIPT_NAME%.sh}.log"

timestamp() { date -u '+%Y-%m-%dT%H:%M:%SZ'; }
log_info() { mkdir -p "$(dirname "$LOG_FILE")"; echo -e "[INFO] $1"; echo "$(timestamp) [INFO] $1" >> "$LOG_FILE"; }
log_warn() { mkdir -p "$(dirname "$LOG_FILE")"; echo -e "[WARN] $1"; echo "$(timestamp) [WARN] $1" >> "$LOG_FILE"; }
log_error() { mkdir -p "$(dirname "$LOG_FILE")"; echo -e "[ERROR] $1"; echo "$(timestamp) [ERROR] $1" >> "$LOG_FILE"; }
log_debug() { if [ "${VERBOSE:-false}" = true ]; then mkdir -p "$(dirname "$LOG_FILE")"; echo -e "[DEBUG] $1"; echo "$(timestamp) [DEBUG] $1" >> "$LOG_FILE"; fi }

DRY_RUN=false
AUTO_YES=false
VERBOSE=false
TEMPLATE=""
PROJECT_ARG=""
PROJECT_PATH="$PWD"

confirm() {
  if [ "$AUTO_YES" = true ]; then
    log_info "Auto-approve enabled — skipping confirmation: $1"
    return 0
  fi
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
  -n, --name NAME       Project name (defaults to '.' - current directory)
  -p, --path PATH       Parent directory to create the project in (default: current directory)
  -l, --logfile FILE    Log file (default: $LOG_FILE)
  --template NAME       Starter template to apply (tailwind|redux|tailwind-redux)
  --dry-run             Show actions without executing
  -V, --verbose         Show debug/verbose output on stdout
  -y, --yes             Assume yes for all prompts
  -h, --help            Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--name) PROJECT_ARG="$2"; shift 2 ;;
    -p|--path) PROJECT_PATH="$2"; shift 2 ;;
    -l|--logfile) LOG_FILE="$2"; shift 2 ;;
    --template) TEMPLATE="$2"; shift 2 ;;
    -V|--verbose) VERBOSE=true; shift ;;
    -y|--yes) AUTO_YES=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) log_error "Unknown option: $1"; usage; exit 1 ;;
    *) if [[ -z "$PROJECT_ARG" ]]; then PROJECT_ARG="$1"; else log_error "Unexpected argument: $1"; usage; exit 1; fi; shift ;;
  esac
done

PROJECT_NAME="${PROJECT_ARG:-.}"
NODE_VERSION="18"

run_cmd() { if [ "$DRY_RUN" = true ]; then echo "[DRY-RUN] $*"; else log_debug "Executing: $*"; "$@"; fi }

log_info "Starting Next.js project setup: $PROJECT_NAME"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    log_error "Node.js is not installed. Please install Node.js ${NODE_VERSION}+"
    exit 1
fi


log_info "Node.js version: $(node --version)"
log_info "npm version: $(npm --version)"

# If PROJECT_NAME is not '.', create folder and check
if [ "$PROJECT_NAME" != "." ]; then
  if [ -d "$PROJECT_NAME" ] && [ "$(ls -A "$PROJECT_NAME")" ]; then
    if [ "$AUTO_YES" = false ]; then
      read -r -p "Directory $PROJECT_NAME exists and is not empty. Overwrite? (y/N): " resp
      if [[ ! "$resp" =~ ^[Yy]$ ]]; then log_error "Operation cancelled"; exit 1; fi
    else
      log_warn "Overwriting existing directory $PROJECT_NAME (auto-confirmed)"
      rm -rf "$PROJECT_NAME"/*
    fi
  fi
fi

log_info "Creating Next.js project..."
run_cmd npx create-next-app@latest "$PROJECT_NAME" --typescript --tailwind --eslint --app --no-git --import-alias '@/*'

cd "$PROJECT_NAME" || exit 1

log_info "Installing additional dependencies..."
run_cmd npm install -D @testing-library/react @testing-library/jest-dom jest jest-environment-jsdom

log_info "Creating directory structure..."
run_cmd mkdir -p src/components src/utils src/hooks src/types public/images

# Template handling (tailwind, redux, tailwind-redux)
if [ -n "$TEMPLATE" ]; then
  log_info "Applying template: $TEMPLATE"
  case "$TEMPLATE" in
    tailwind)
      log_info "Installing Tailwind CSS packages..."
      run_cmd npm install -D tailwindcss postcss autoprefixer
      run_cmd npx tailwindcss init -p
      # Create a basic globals.css if not present
      if [ ! -f "styles/globals.css" ] && [ ! -f "src/styles/globals.css" ]; then
        log_info "Creating basic Tailwind globals file at styles/globals.css"
        cat > styles/globals.css <<'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF
        log_info "Please ensure you import styles/globals.css in your app layout or _app.js/_app.tsx"
      fi
      ;;
    redux)
      log_info "Installing Redux Toolkit and React-Redux..."
      run_cmd npm install @reduxjs/toolkit react-redux
      if [ ! -d "src/store" ]; then
        run_cmd mkdir -p src/store
        cat > src/store/index.js <<'EOF'
import { configureStore } from '@reduxjs/toolkit'
// Example store - add your reducers here
export default configureStore({ reducer: {} })
EOF
        log_info "Created example store at src/store/index.js"
      fi
      ;;
    tailwind-redux|redux-tailwind|tailwind+redux)
      log_info "Applying combined Tailwind + Redux template..."
      "$0" --template tailwind
      "$0" --template redux
      ;;
    *) log_warn "Unknown template: $TEMPLATE" ;;
  esac
fi

log_info "Initializing git repository..."
run_cmd git init
run_cmd git add .
run_cmd git commit -m "Initial commit: Next.js project setup"

log_info "Setup complete!"
log_info "Project directory: $(pwd)"

echo "\nNext steps:"
echo "  cd $PROJECT_NAME"
echo "  npm run dev"
echo ""