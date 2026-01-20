#!/usr/bin/env bash

################################################################################
# NestJS Setup Script
# Description: Sets up a NestJS project with common dependencies and structure
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
log_debug() { if [ "${VERBOSE:-false}" = true ]; then mkdir -p "$(dirname "$LOG_FILE")"; echo -e "[DEBUG] $1"; echo "$(timestamp) [DEBUG] $1" >> "$LOG_FILE"; fi }

DRY_RUN=false
AUTO_YES=false
VERBOSE=false
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
  -n, --name NAME       Project name (default: my-nestjs-app)
  -p, --path PATH       Directory to create the project in (default: current directory)
  -l, --logfile FILE    Log file (default: $LOG_FILE)
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
    -V|--verbose) VERBOSE=true; shift ;;
    -y|--yes) AUTO_YES=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) log_error "Unknown option: $1"; usage; exit 1 ;;
    *) if [[ -z "$PROJECT_ARG" ]]; then PROJECT_ARG="$1"; else log_error "Unexpected argument: $1"; usage; exit 1; fi; shift ;;
  esac
done

# Wrap commands to include debug output when verbose


PROJECT_NAME="${PROJECT_ARG:-my-nestjs-app}"
PROJECT_PATH="$PWD/$PROJECT_NAME"

run_cmd() { if [ "$DRY_RUN" = true ]; then echo "[DRY-RUN] $*"; else log_debug "Executing: $*"; "$@"; fi }

log_info "Creating NestJS project: $PROJECT_NAME"

# Install NestJS CLI globally if not present
if ! command -v nest &> /dev/null; then
    log_info "Installing NestJS CLI..."
    run_cmd npm install -g @nestjs/cli
fi

# Create new NestJS project
log_info "Scaffolding NestJS project..."
run_cmd nest new "$PROJECT_NAME" --package-manager npm

cd "$PROJECT_PATH" || exit 1

# Install additional common packages
log_info "Installing additional dependencies..."
run_cmd npm install @nestjs/config @nestjs/typeorm typeorm mysql2 class-validator class-transformer
run_cmd npm install -D @types/node @nestjs/testing jest ts-jest

# Create basic directory structure
log_info "Creating project structure..."
run_cmd mkdir -p src/{modules,common/{decorators,filters,guards,interceptors}}

# Generate initial resources
log_info "Generating initial modules..."
run_cmd nest generate module modules/users
run_cmd nest generate controller modules/users
run_cmd nest generate service modules/users

# Create environment file
log_info "Creating environment configuration..."
cat > .env.example << 'EOF'
NODE_ENV=development
PORT=3000
DATABASE_HOST=localhost
DATABASE_PORT=3306
DATABASE_USER=root
DATABASE_PASSWORD=password
DATABASE_NAME=nestjs_db
EOF

run_cmd cp .env.example .env

log_info "Setup complete!"
log_info "Next steps:"
log_info "  cd $PROJECT_NAME"
log_info "  npm run start:dev"