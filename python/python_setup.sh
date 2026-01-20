#!/usr/bin/env bash

################################################################################
# Python Setup Script
# Description: Sets up Python 3 with common packages and a user virtualenv
# Author: João Augusto Bonfante
# GitHub: https://github.com/joaodev
# Date: January 2026
################################################################################

set -euo pipefail
IFS=$'\n\t'

# Defaults
LOG_FILE="${HOME}/.local/state/shell-scripts/python_setup.log"
AUTO_YES=false

timestamp() { date '+%Y-%m-%d %H:%M:%S'; }
log() { mkdir -p "$(dirname "$LOG_FILE")"; printf '%s %s\n' "$(timestamp)" "$*" | tee -a "$LOG_FILE"; }
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
  -l, --logfile FILE   Log file (default: $LOG_FILE)
  -y, --yes            Assume yes for all prompts (non-interactive)
  -h, --help           Show this help
EOF
}

# Parse args
while [ "$#" -gt 0 ]; do
  case "$1" in
    -l|--logfile) LOG_FILE="$2"; shift 2 ;;
    -y|--yes) AUTO_YES=true; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) log "Unknown option: $1"; usage; exit 1 ;;
    *) break ;;
  esac
done

log "=== Python system setup ==="

if ! command -v python3 >/dev/null 2>&1; then
  log "Running apt-get update and install Python 3"
  if ! confirm "Install Python 3 and development packages?"; then
    log "Operation cancelled by user"
    exit 0
  fi
  sudo apt-get update
  sudo apt-get upgrade -y
  sudo apt-get install -y python3 python3-pip python3-venv build-essential libssl-dev libffi-dev python3-dev
else
  log "Python3 already present: $(python3 --version)"
fi

log "Upgrading pip (user)..."
python3 -m pip install --user --upgrade pip

VENV_DIR="$HOME/venv"
if [ ! -d "$VENV_DIR" ]; then
  log "Creating user virtualenv at $VENV_DIR"
  python3 -m venv "$VENV_DIR"
fi

log "Activating virtualenv and installing common Python packages"
# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"
python3 -m pip install --upgrade pip setuptools wheel
python3 -m pip install requests flask django numpy pandas

log "=== Python setup completed. To activate: source $VENV_DIR/bin/activate ===" 