#!/usr/bin/env bash

###################################################################################
# Django Setup Script
# Description: Sets up a Django project with virtualenv, app creation, and logging
# Author: João Augusto Bonfante
# GitHub: https://github.com/joaodev
# Date: January 2026
###################################################################################

set -euo pipefail
IFS=$'\n\t'

# Defaults
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PROJECT_NAME=""
APP_NAME=""
PROJECT_PATH="."
LOG_FILE="${HOME}/.local/state/shell-scripts/django_setup.log"
AUTO_YES=false

timestamp() { date '+%Y-%m-%d %H:%M:%S'; }
log() { mkdir -p "$(dirname "$LOG_FILE")"; printf '%s %s\n' "$(timestamp)" "$*" | tee -a "$LOG_FILE"; }
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
  -n, --name NAME      Project name (will prompt if omitted)
  -a, --app NAME       Django app name (will prompt if omitted)
  -p, --path PATH      Directory to create the project in (default: .)
  -l, --logfile FILE   Log file (default: $LOG_FILE)
  -y, --yes            Assume yes for all prompts (non-interactive)
  -h, --help           Show this help
EOF
}

log "=== Django Setup Script ==="

# Parse args
while [ "$#" -gt 0 ]; do
  case "$1" in
    -n|--name) PROJECT_NAME="$2"; shift 2 ;;
    -a|--app) APP_NAME="$2"; shift 2 ;;
    -p|--path) PROJECT_PATH="$2"; shift 2 ;;
    -l|--logfile) LOG_FILE="$2"; shift 2 ;;
    -y|--yes) AUTO_YES=true; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) log "Opção desconhecida: $1"; usage; exit 1 ;;
    *) break ;;
  esac
done

: "${PROJECT_PATH:=$PROJECT_PATH}"

# Check if Python is installed
if ! command_exists python3; then
  log "Python3 is required but not installed."
  exit 1
fi

log "Python3 found: $(python3 --version)"

# Project and app names
if [ -z "$PROJECT_NAME" ]; then
  if [ "$AUTO_YES" = true ]; then
    log "Error: project name missing and auto-yes enabled. Specify -n/--name."; exit 1
  fi
  read -r -p "Enter project name: " PROJECT_NAME
fi

if [ -z "$APP_NAME" ]; then
  if [ "$AUTO_YES" = true ]; then
    log "Error: app name missing and auto-yes enabled. Specify -a/--app."; exit 1
  fi
  read -r -p "Enter app name: " APP_NAME
fi

PROJECT_DIR="$PROJECT_PATH/$PROJECT_NAME"

log "Parameters: project='$PROJECT_NAME' app='$APP_NAME' path='$PROJECT_PATH' logfile='$LOG_FILE' auto-yes='$AUTO_YES'"
if ! confirm "Create project '$PROJECT_NAME' (app: $APP_NAME) in '$PROJECT_DIR'?"; then
  log "Operation cancelled by user"
  exit 0
fi

# Create virtual environment
log "Creating directory $PROJECT_DIR and virtualenv..."
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"
python3 -m venv venv
# shellcheck disable=SC1091
source venv/bin/activate
log "Virtual environment created and activated"

# Upgrade pip
log "Updating pip..."
pip install --upgrade pip

# Install Django and common packages
log "Installing Django and dependencies..."
pip install django djangorestframework python-decouple psycopg2-binary
log "Dependencies installed"

# Create Django project
log "Creating Django project: $PROJECT_NAME"
django-admin startproject "$PROJECT_NAME" .
log "Django project created"

# Create Django app
log "Creating Django app: $APP_NAME"
python manage.py startapp "$APP_NAME"
log "Django app created"

# Database migrations
log "Running migrations..."
python manage.py migrate
log "Database migrations completed"

log "=== Setup complete! To start: cd $PROJECT_DIR && source venv/bin/activate && python manage.py runserver ===" 
