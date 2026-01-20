#!/bin/bash

################################################################################
# CodeIgniter Setup Script
# Description: Sets up a CodeIgniter project with confirmations and logging
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
PROJECT_ARG=""

usage() { echo "Usage: $0 [project-path] [--dry-run] [-y|--yes] [-l|--logfile FILE]"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes) AUTO_YES=true; shift;;
    --dry-run) DRY_RUN=true; shift;;
    -l|--logfile) LOG_FILE="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    *) if [[ -z "$PROJECT_ARG" ]]; then PROJECT_ARG="$1"; fi; shift;;
  esac
done

PROJECT_NAME="${PROJECT_ARG:-.}"

run_cmd() { if [ "$DRY_RUN" = true ]; then echo "[DRY-RUN] $*"; else "$@"; fi }

log_info "Setting up CodeIgniter project: $PROJECT_NAME"

# Check if Composer is installed
if ! command -v composer &> /dev/null; then
    log_error "Composer is not installed"
    exit 1
fi

# Create project directory
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
    run_cmd mkdir -p "$PROJECT_NAME"
    cd "$PROJECT_NAME" || exit 1
fi

# Create CodeIgniter project via Composer
log_info "Creating CodeIgniter 4 project..."
run_cmd composer create-project codeigniter4/appstarter . --no-interaction

# Set permissions
if confirm "Set permissions (writable/public) now?"; then
    log_info "Setting permissions..."
    run_cmd chmod -R 755 writable/
    run_cmd chmod -R 755 public/
else
    log_info "Skipped setting permissions"
fi

# Create .env file
if confirm "Create and update .env file?"; then
    log_info "Creating .env file..."
    run_cmd cp env .env
    run_cmd sed -i 's/# CI_ENVIRONMENT = production/CI_ENVIRONMENT = development/' .env
    run_cmd sed -i 's/# app.baseURL = .*/app.baseURL = "http:\/\/localhost:8080\/"/' .env
else
    log_info "Skipped .env creation"
fi

# Install dependencies
if confirm "Run 'composer install' now?"; then
    log_info "Installing Composer dependencies..."
    run_cmd composer install
else
    log_info "Skipped Composer install"
fi
log_info "CodeIgniter project setup complete!"

echo "\nNext steps:"
echo "1. Configure .env file in the project root"
echo "2. Run: php spark serve"
echo "3. Visit: http://localhost:8080"