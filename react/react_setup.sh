#!/usr/bin/env bash

################################################################################
# React Setup Script
# Description: Sets up a React project with optional templates, confirmations, and logging
# Author: João Augusto Bonfante
# GitHub: https://github.com/joaodev
# Date: January 2026
################################################################################

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

DRY_RUN=false
AUTO_YES=false
VERBOSE=false
TEMPLATE=""
PROJECT_ARG=""
PROJECT_PATH_BASE="$PWD"

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
  -n, --name NAME       Project name (default: my-react-app)
  -p, --path PATH       Parent directory where project will be created (default: current directory)
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
    -p|--path) PROJECT_PATH_BASE="$2"; shift 2 ;;
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

PROJECT_NAME="${PROJECT_ARG:-my-react-app}"
PROJECT_PATH="$PROJECT_PATH_BASE/$PROJECT_NAME"

run_cmd() { if [ "$DRY_RUN" = true ]; then echo "[DRY-RUN] $*"; else log_debug "Executing: $*"; "$@"; fi }

log_info "Creating React project: $PROJECT_NAME"

if [ -d "$PROJECT_PATH" ] && [ "$(ls -A "$PROJECT_PATH")" ]; then
  if ! confirm "Directory $PROJECT_PATH exists and is not empty. Overwrite?"; then
    log_error "Operation cancelled"; exit 1
  fi
  log_warn "Overwriting existing directory $PROJECT_PATH"
  rm -rf "$PROJECT_PATH"/*
fi

# Create React app using Create React App
run_cmd npx create-react-app "$PROJECT_NAME"

cd "$PROJECT_PATH" || exit 1

log_info "Installing additional dependencies..."
run_cmd npm install axios react-router-dom

log_info "Installing dev dependencies..."
run_cmd npm install --save-dev eslint prettier husky lint-staged

log_info "Setting up Prettier..."
run_cmd bash -c "cat > .prettierrc << 'EOF'
{
    \"semi\": true,
    \"singleQuote\": true,
    \"tabWidth\": 2,
    \"trailingComma\": \"es5\"
}
EOF"

log_info "React project setup complete!"
log_info "Project location: $PROJECT_PATH"

echo "\nNext steps:"
echo "  cd $PROJECT_NAME"
echo "  npm start"

if [ -d "$PROJECT_PATH" ] && [ "$(ls -A "$PROJECT_PATH")" ]; then
  if ! confirm "Directory $PROJECT_PATH exists and is not empty. Overwrite?"; then
    log_error "Operation cancelled"; exit 1
  fi
  log_warn "Overwriting existing directory $PROJECT_PATH"
  rm -rf "$PROJECT_PATH"/*
fi

# Create React app using Create React App
run_cmd npx create-react-app "$PROJECT_NAME"

cd "$PROJECT_PATH" || exit 1

log_info "Installing additional dependencies..."
run_cmd npm install axios react-router-dom

log_info "Installing dev dependencies..."
run_cmd npm install --save-dev eslint prettier husky lint-staged

log_info "Setting up Prettier..."
run_cmd bash -c "cat > .prettierrc << 'EOF'
{
    \"semi\": true,
    \"singleQuote\": true,
    \"tabWidth\": 2,
    \"trailingComma\": \"es5\"
}
EOF"

# Template handling (tailwind, redux, tailwind-redux)
if [ -n "$TEMPLATE" ]; then
  log_info "Applying template: $TEMPLATE"
  case "$TEMPLATE" in
    tailwind)
      log_info "Installing Tailwind CSS packages..."
      run_cmd npm install -D tailwindcss postcss autoprefixer
      run_cmd npx tailwindcss init -p
      # Add directives to src/index.css if it exists
      if [ -f "src/index.css" ]; then
        if ! grep -q "@tailwind base;" src/index.css; then
          cat > src/index.css <<'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF
          log_info "Updated src/index.css with Tailwind directives"
        fi
      else
        cat > src/index.css <<'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF
        log_info "Created src/index.css with Tailwind directives"
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

log_info "React project setup complete!"
log_info "Project location: $PROJECT_PATH"

echo "\nNext steps:"
echo "  cd $PROJECT_NAME"
echo "  npm start"