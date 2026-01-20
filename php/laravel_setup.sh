#!/bin/bash

################################################################################
# Laravel Setup Script
# Description: Sets up a Laravel project with confirmations and logging
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

PROJECT_NAME="${PROJECT_NAME_ARG:-my-laravel-app}"
PROJECT_PATH="${PROJECT_PATH_ARG:-./$PROJECT_NAME}"

run_cmd() { if [ "$DRY_RUN" = true ]; then echo "[DRY-RUN] $*"; else "$@"; fi }

log_info "Starting Laravel project setup: $PROJECT_NAME -> $PROJECT_PATH"

# Check if Composer is installed
if ! command -v composer &> /dev/null; then
    log_error "Composer is not installed. Please install Composer first."
    exit 1
fi

# Check if PHP is installed
if ! command -v php &> /dev/null; then
    log_error "PHP is not installed. Please install PHP first."
    exit 1
fi

# Check target directory
if [ -d "$PROJECT_PATH" ] && [ "$(ls -A "$PROJECT_PATH")" ]; then
    if [ "$AUTO_YES" = false ]; then
        read -r -p "Directory $PROJECT_PATH exists and is not empty. Overwrite? (y/N): " resp
        if [[ ! "$resp" =~ ^[Yy]$ ]]; then log_error "Operation cancelled"; exit 1; fi
    else
        log_warn "Overwriting existing directory $PROJECT_PATH (auto-confirmed)"
        rm -rf "$PROJECT_PATH"/*
    fi
fi

log_info "Creating new Laravel project: $PROJECT_NAME"
run_cmd composer create-project laravel/laravel "$PROJECT_PATH"

cd "$PROJECT_PATH" || exit 1

log_info "Setting up environment file..."
run_cmd cp .env.example .env

log_info "Generating application key..."
run_cmd php artisan key:generate

log_info "Setting permissions..."
run_cmd chmod -R 775 storage bootstrap/cache

if confirm "Run database migrations now?"; then
  log_info "Running migrations..."
  run_cmd php artisan migrate
else
  log_info "Skipped running migrations"
fi

log_info "Laravel project setup complete!"

echo "\nNext steps:"
echo "  cd $PROJECT_PATH"
echo "  php artisan serve"
echo "\nYour Laravel app will be available at http://localhost:8000"