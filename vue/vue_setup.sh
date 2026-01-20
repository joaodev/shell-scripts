#!/usr/bin/env bash

##########################################################################################
# Vue.js Setup Script
# Description: Sets up Vue.js system with optional templates, confirmations, and logging
# Author: João Augusto Bonfante
# GitHub: https://github.com/joaodev
# Date: January 2026
##########################################################################################

set -euo pipefail
IFS=$'\n\t'

# Defaults
NODE_SETUP_SCRIPT_URL="https://deb.nodesource.com/setup_18.x"
NODE_VERSION="18"
LOCAL_INSTALL=false
PROJECT_NAME=""
PROJECT_PATH="."
LOG_FILE="${HOME}/.local/state/shell-scripts/vue_setup.log"
AUTO_YES=false
VERBOSE=false
TEMPLATE=""

timestamp() { date -u '+%Y-%m-%dT%H:%M:%SZ'; }
log() { mkdir -p "$(dirname "$LOG_FILE")"; printf '%s %s\n' "$(timestamp)" "$*" | tee -a "$LOG_FILE"; }
log_debug() { if [ "${VERBOSE:-false}" = true ]; then mkdir -p "$(dirname "$LOG_FILE")"; printf '%s [DEBUG] %s\n' "$(timestamp)" "$*" | tee -a "$LOG_FILE"; fi }
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

# Helper: create a backup of a file if it doesn't already exist
backup_file() {
  local f="$1"
  if [ -f "$f" ] && [ ! -f "${f}.bak" ]; then
    cp "$f" "${f}.bak" && log "Backup created: ${f}.bak"
  fi
}

# Helper: find the project's main file (js or ts)
find_main_file() {
  if [ -f "src/main.js" ]; then echo "src/main.js"
  elif [ -f "src/main.ts" ]; then echo "src/main.ts"
  elif [ -f "main.js" ]; then echo "main.js"
  elif [ -f "main.ts" ]; then echo "main.ts"
  else echo ""; fi
}

# Insert an import line if it's not already present
insert_import() {
  local file="$1" import_line="$2"
  if grep -qF "$import_line" "$file" 2>/dev/null; then
    log_debug "Import already present: $import_line"
    return 0
  fi
  local last_import_line
  last_import_line=$(grep -nE '^import ' "$file" | tail -n1 | cut -d: -f1 || true)
  if [ -n "$last_import_line" ]; then
    sed -i "${last_import_line}a ${import_line}" "$file"
  else
    sed -i "1i ${import_line}" "$file"
  fi
  log "Added import to $file: $import_line"
}

# Insert an app.use(...) line if 'const app = createApp' exists
insert_app_use() {
  local file="$1" use_line="$2"
  if grep -qF "$use_line" "$file" 2>/dev/null; then
    log_debug "app.use already present: $use_line"
    return 0
  fi
  local app_line_num
  app_line_num=$(grep -nE 'const[[:space:]]+app[[:space:]]*=.*createApp' "$file" | head -n1 | cut -d: -f1 || true)
  if [ -n "$app_line_num" ]; then
    sed -i "${app_line_num}a ${use_line}" "$file"
    log "Inserted ${use_line} after app creation in $file"
  else
    log "No 'const app = createApp' found in $file; skipping automatic app.use injection (please add manually)"
  fi
}

# Wire Pinia into the project's main file (idempotent)
wire_pinia() {
  local main_file
  main_file=$(find_main_file)
  if [ -z "$main_file" ]; then
    log "No main file found; cannot auto-wire Pinia"
    return 0
  fi
  backup_file "$main_file"
  insert_import "$main_file" "import { createPinia } from 'pinia'"
  insert_app_use "$main_file" "app.use(createPinia())"
  log "Pinia wiring applied to $main_file"
}

# Wire Vuex into the project's main file (idempotent)
wire_vuex() {
  local main_file
  main_file=$(find_main_file)
  if [ -z "$main_file" ]; then
    log "No main file found; cannot auto-wire Vuex"
    return 0
  fi
  backup_file "$main_file"
  insert_import "$main_file" "import store from './store'"
  insert_app_use "$main_file" "app.use(store)"
  log "Vuex wiring applied to $main_file"
}

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -n, --name NAME           Project name (will prompt if omitted)
  -p, --path PATH           Directory to create the project in (default: .)
  -v, --node-version VER    Node.js version to install when using local install (default: $NODE_VERSION)
  -L, --local               Install Node locally (no sudo) using nvm
  -l, --logfile FILE        Log file (default: $LOG_FILE)
  -V, --verbose             Show debug/verbose output on stdout
  -t, --template NAME       Starter template to apply (tailwind|pinia|vuex)
  -y, --yes                 Assume yes for all prompts (non-interactive)
  -h, --help                Show this help
EOF
}  

log "=== Vue.js Setup Script ==="

# Parse args
while [ "$#" -gt 0 ]; do
  case "$1" in
    -n|--name) PROJECT_NAME="$2"; shift 2 ;;
    -p|--path) PROJECT_PATH="$2"; shift 2 ;;
    -v|--node-version) NODE_VERSION="$2"; shift 2 ;;
    -L|--local) LOCAL_INSTALL=true; shift ;;
    -l|--logfile) LOG_FILE="$2"; shift 2 ;;
    -V|--verbose) VERBOSE=true; shift ;;
    -t|--template) TEMPLATE="$2"; shift 2 ;;
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
      export NVM_DIR="$HOME/.nvm"
      if [ -s "$NVM_DIR/nvm.sh" ]; then . "$NVM_DIR/nvm.sh"; fi
    fi

    if command -v nvm >/dev/null 2>&1; then
      nvm install "$NODE_VERSION"
      nvm alias default "$NODE_VERSION" || true
      log "Node installed locally: $(node -v)"
      log "If necessary, restart your shell or run: source \"$NVM_DIR/nvm.sh\""
    else
      log "Error: nvm not available after attempted installation"
      exit 1
    fi
  else
    if ! confirm "Node.js is not installed. Install Node.js and npm system-wide? (requires sudo)"; then
      log "System Node.js installation cancelled by user"
      exit 1
    fi
    log "Installing Node.js..."
    curl -fsSL "$NODE_SETUP_SCRIPT_URL" | sudo -E bash -
    sudo apt-get install -y nodejs
    log "Node.js installed: $(node -v)"
  fi
fi

log "npm: $(npm -v)"



# Project name selection
if [ -z "$PROJECT_NAME" ]; then
  echo -e "Creating a new Vue project"
  read -r -p "Enter project name (default: vue-app): " PROJECT_NAME
  PROJECT_NAME=${PROJECT_NAME:-vue-app}
fi

PROJECT_PATH_FULL="$PROJECT_PATH/$PROJECT_NAME"
log "Creating Vue project: $PROJECT_NAME at $PROJECT_PATH_FULL"
if ! confirm "Create project '$PROJECT_NAME' at '$PROJECT_PATH_FULL'?"; then
  log "Operation cancelled by user"
  exit 0
fi

mkdir -p "$PROJECT_PATH"
pushd "$PROJECT_PATH" >/dev/null
log "Scaffolding Vue project using the official create script"
log_debug "Executing: npm create vue@latest '$PROJECT_NAME' -- --typescript false --jsx false --router true --pinia true --vitest false --playwright false --eslint false"
npm create vue@latest "$PROJECT_NAME" -- --typescript false --jsx false --router true --pinia true --vitest false --playwright false --eslint false
cd "$PROJECT_NAME"
log "Installing dependencies"
npm install

# Apply optional starter templates
if [ -n "$TEMPLATE" ]; then
  log "Applying template: $TEMPLATE"
  case "$TEMPLATE" in
    tailwind)
      log "Installing Tailwind CSS packages..."
      log_debug "npm install -D tailwindcss postcss autoprefixer"
      npm install -D tailwindcss postcss autoprefixer
      log_debug "npx tailwindcss init -p"
      npx tailwindcss init -p
      # Create a basic Tailwind CSS file if none exists
      if [ -f "src/assets/styles.css" ]; then TARGET="src/assets/styles.css"; elif [ -f "src/styles.css" ]; then TARGET="src/styles.css"; else TARGET="src/index.css"; fi
      if [ ! -f "$TARGET" ]; then
        cat > "$TARGET" <<'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF
        log "Created $TARGET with Tailwind directives"
      else
        log "Tailwind target $TARGET already exists; leaving it untouched"
      fi
      # Ensure import in main file
      if [ -f "src/main.js" ]; then MAINFILE="src/main.js"; elif [ -f "src/main.ts" ]; then MAINFILE="src/main.ts"; else MAINFILE=""; fi
      if [ -n "$MAINFILE" ] && ! grep -q "tailwind" "$MAINFILE"; then
        echo "\n// Tailwind import added by script\nimport './${TARGET#src/}'" >> "$MAINFILE"
        log "Imported $TARGET in $MAINFILE"
      fi
      ;;
    pinia)
      log "Installing Pinia..."
      log_debug "npm install pinia"
      npm install pinia
      if [ ! -d "src/stores" ]; then mkdir -p src/stores; fi
      if [ ! -f "src/stores/index.js" ]; then
        cat > src/stores/index.js <<'EOF'
import { defineStore } from 'pinia'

export const useExampleStore = defineStore('example', {
  state: () => ({ count: 0 }),
  actions: { increment() { this.count += 1 } }
})
EOF
        log "Created example Pinia store at src/stores/index.js"
      else
        log "Pinia store already exists at src/stores/index.js; leaving it untouched"
      fi
      # Attempt automatic wiring into main file (idempotent)
      MAIN_FILE=$(find_main_file)
      if [ -n "$MAIN_FILE" ]; then
        if [ "$AUTO_YES" = true ] || confirm "Attempt to automatically wire Pinia into $MAIN_FILE? A backup will be created."; then
          wire_pinia
        else
          if [ -f "src/main.js" ] && ! grep -q "createPinia" src/main.js; then
            printf "\n// Pinia setup (added by script)\nimport { createPinia } from 'pinia'\n// In your app initialization call: app.use(createPinia())\n" >> src/main.js
            log "Added Pinia import/comment to src/main.js; please add app.use(createPinia()) in your app init if not present"
          fi
        fi
      else
        log "No main file found; skipped auto-wiring for Pinia. You can add Pinia manually by importing createPinia and calling app.use(createPinia())."
      fi
      ;;
    vuex)
      log "Installing Vuex (v4)..."
      log_debug "npm install vuex@4"
      npm install vuex@4
      if [ ! -d "src/store" ]; then mkdir -p src/store; fi
      if [ ! -f "src/store/index.js" ]; then
        cat > src/store/index.js <<'EOF'
import { createStore } from 'vuex'

export default createStore({
  state: { count: 0 },
  mutations: { increment(state) { state.count += 1 } },
  actions: {},
  modules: {}
})
EOF
        log "Created example Vuex store at src/store/index.js"
      else
        log "Vuex store already exists at src/store/index.js; leaving it untouched"
      fi
      # Attempt automatic wiring into main file (idempotent)
      MAIN_FILE=$(find_main_file)
      if [ -n "$MAIN_FILE" ]; then
        if [ "$AUTO_YES" = true ] || confirm "Attempt to automatically wire Vuex into $MAIN_FILE? A backup will be created."; then
          wire_vuex
        else
          if [ -f "src/main.js" ] && ! grep -q "createStore" src/main.js; then
            printf "\n// Vuex setup (added by script)\n// Import the store and use it in your app: import store from './store' and app.use(store)\n" >> src/main.js
            log "Added Vuex usage comment to src/main.js"
          fi
        fi
      else
        log "No main file found; skipped auto-wiring for Vuex. You can add Vuex manually by importing the store and calling app.use(store)."
      fi
      ;;
    *)
      log "Unknown template: $TEMPLATE"
      ;;
  esac
fi

popd >/dev/null

log "=== Vue setup complete ==="
log "To start: cd $PROJECT_PATH_FULL && npm run dev"