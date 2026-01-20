#!/bin/bash

################################################################################
# Zend Framework Setup Script
# Description: Sets up a Zend Framework project with confirmations and logging
# Author: João Augusto Bonfante
# GitHub: https://github.com/joaodev
# Date: January 2026
################################################################################

set -e

# Logging and options
LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/shell-scripts"
mkdir -p "$LOG_DIR"
SCRIPT_NAME="$(basename "$0")"
LOG_FILE="$LOG_DIR/${SCRIPT_NAME%.sh}.log"

log_info() { echo -e "[INFO] $1"; echo "$(date -Iseconds) [INFO] $1" >> "$LOG_FILE"; }
log_warn() { echo -e "[WARN] $1"; echo "$(date -Iseconds) [WARN] $1" >> "$LOG_FILE"; }
log_error() { echo -e "[ERROR] $1"; echo "$(date -Iseconds) [ERROR] $1" >> "$LOG_FILE"; }

DRY_RUN=false
AUTO_YES=false
PROJECT_NAME_ARG=""
PROJECT_PATH_ARG=""

usage() { echo "Usage: $0 [project-name] [project-path] [--dry-run] [-y|--yes] [-l|--logfile FILE]"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes) AUTO_YES=true; shift;;
    --dry-run) DRY_RUN=true; shift;;
    -l|--logfile) LOG_FILE="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    *) if [[ -z "$PROJECT_NAME_ARG" ]]; then PROJECT_NAME_ARG="$1"; elif [[ -z "$PROJECT_PATH_ARG" ]]; then PROJECT_PATH_ARG="$1"; fi; shift;;
  esac
done

PROJECT_NAME="${PROJECT_NAME_ARG:-zend-project}"
PROJECT_PATH="${PROJECT_PATH_ARG:-./$PROJECT_NAME}"

run_cmd() { if [ "$DRY_RUN" = true ]; then echo "[DRY-RUN] $*"; else "$@"; fi }

log_info "Creating Zend Framework project: $PROJECT_NAME -> $PROJECT_PATH"

# Create project directory
if [ -d "$PROJECT_PATH" ] && [ "$(ls -A "$PROJECT_PATH")" ]; then
    if [ "$AUTO_YES" = false ]; then
        read -r -p "Directory $PROJECT_PATH exists and is not empty. Overwrite? (y/N): " resp
        if [[ ! "$resp" =~ ^[Yy]$ ]]; then log_error "Operation cancelled"; exit 1; fi
    else
        log_warn "Overwriting existing directory $PROJECT_PATH (auto-confirmed)"
        rm -rf "$PROJECT_PATH"/*
    fi
fi

run_cmd mkdir -p "$PROJECT_PATH"
run_cmd cd "$PROJECT_PATH"

# Initialize composer project
if confirm "Create Zend skeleton project at $PROJECT_PATH (this will run composer create-project)?"; then
    log_info "Initializing Composer project..."
    run_cmd composer create-project zendframework/skeleton-application . --no-interaction
else
    log_info "Skipped creating Zend project"
fi

# Create necessary directories
if confirm "Create runtime directories (data/cache, data/logs, public/uploads)?"; then
    run_cmd mkdir -p data/cache
    run_cmd mkdir -p data/logs
    run_cmd mkdir -p public/uploads
else
    log_info "Skipped creating runtime directories"
fi

# Set proper permissions
if confirm "Set recommended permissions for data/ and public/?"; then
    run_cmd chmod -R 775 data/
    run_cmd chmod -R 755 public/
else
    log_info "Skipped setting permissions"
fi

# Install dependencies
if confirm "Run 'composer install' now?"; then
    run_cmd composer install
else
    log_info "Skipped composer install"
fi

# Generate database tables (if needed)
if [ -f "data/db.sql" ]; then
    log_info "Database schema found"
fi

log_info "Zend project setup complete!"
log_info "Project location: $PROJECT_PATH"
log_info "Next steps:"
log_info "  cd $PROJECT_PATH"
log_info "  php -S localhost:8080 -t public/"