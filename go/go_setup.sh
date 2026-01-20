#!/usr/bin/env bash

################################################################################
# Go Setup Script
# Description: Installs and configures Go programming environment
# Author: João Augusto Bonfante
# GitHub: https://github.com/joaodev
# Date: January 2026
################################################################################

set -euo pipefail
IFS=$'\n\t'

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Defaults
GO_VERSION="1.21.0"
PROJECT_NAME=""
PROJECT_PATH_DEFAULT="$HOME/go/src"
PROJECT_PATH=""
LOG_FILE="$HOME/.go_setup.log"
AUTO_YES=false
# New options
MODULE_PATH=""
MODULE_TEMPLATE=""
NO_INSTALL=false

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

# Validate a module path (simple checks)
# - No spaces
# - Contains at least one '/'
# - Domain before first slash contains a dot (e.g., github.com)
# - Allowed characters: letters, numbers, dot, underscore, hyphen and slash
validate_module() {
  local m="$1"
  # No spaces
  if [[ "$m" =~ [[:space:]] ]]; then return 1; fi
  # Must contain at least one '/'
  if [[ "$m" != */* ]]; then return 1; fi
  # Domain part must contain a dot
  local domain="${m%%/*}"
  if [[ "$domain" != *.* ]]; then return 1; fi
  # Allowed pattern
  if [[ ! "$m" =~ ^[A-Za-z0-9._-]+(/[A-Za-z0-9._-]+)+$ ]]; then return 1; fi
  return 0
} 

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -n, --name NAME       Project name (if omitted you will be prompted)
  -p, --path PATH       Parent directory for the project (default: $PROJECT_PATH_DEFAULT)
  -v, --version VER     Go version to install (default: $GO_VERSION)
  -l, --logfile FILE    Log file (default: $LOG_FILE)
  -m, --module MODULE   Custom Go module path (e.g. example.com/org/repo)
  -t, --module-template TEMPLATE  Module template with placeholders `<org>` and/or `<project>` (e.g. github.com/<org>/<project>)
  --no-install          Skip installing Go and only initialize the project
  -y, --yes             Accept all confirmations automatically
  -h, --help            Show this help message

Example: $(basename "$0") -n my-app -p ~/dev -m example.com/myorg/myapp
EOF
} 

log "=== Go Setup Script ==="

# Parse args
while [ "$#" -gt 0 ]; do
  case "$1" in
    -n|--name) PROJECT_NAME="$2"; shift 2 ;;
    -p|--path) PROJECT_PATH="$2"; shift 2 ;;
    -v|--version) GO_VERSION="$2"; shift 2 ;;
    -l|--logfile) LOG_FILE="$2"; shift 2 ;;
    -m|--module) MODULE_PATH="$2"; shift 2 ;;
    --no-install) NO_INSTALL=true; shift ;;
done

: "${PROJECT_PATH:=$PROJECT_PATH_DEFAULT}"


# Check if Go is installed
if command_exists go; then
  log "Go already installed: $(go version)"
else
  if [ "$NO_INSTALL" = true ]; then
    log "Skipping Go installation because --no-install was provided"
  else
    # If interactive and module/skip choices not provided via flags, ask the user
    if [ "$AUTO_YES" = false ]; then
      # Allow user to choose skipping install, providing a custom module, or using a template
      if [ -z "$MODULE_PATH" ] && [ -z "$MODULE_TEMPLATE" ]; then
        if confirm "Do you want to skip installing Go and only initialize the project?"; then
          NO_INSTALL=true
          log "User chose to skip Go installation"
        fi
      fi

      if [ -z "$MODULE_PATH" ] && [ -n "$MODULE_TEMPLATE" ]; then
        # If template provided via flag, prompt for placeholders interactively
        log "Module template provided: $MODULE_TEMPLATE"
        local tmp="$MODULE_TEMPLATE"
        if [[ "$tmp" == *"<org>"* ]]; then
          read -r -p "Enter org (to replace <org>) [$(whoami)]: " TEMPLATE_ORG
          TEMPLATE_ORG=${TEMPLATE_ORG:-$(whoami)}
          tmp=${tmp//"<org>"/$TEMPLATE_ORG}
        fi
        if [[ "$tmp" == *"<project>"* ]]; then
          tmp=${tmp//"<project>"/$PROJECT_NAME}
        fi
        MODULE_PATH="$tmp"
        log "Constructed module path from template: $MODULE_PATH"
      fi

      if [ -z "$MODULE_PATH" ] && [ "$NO_INSTALL" = false ]; then
        if confirm "Do you want to provide a custom module path (e.g. example.com/org/repo)?"; then
          # Prompt until a valid module path is provided or user cancels
          attempt=0
          while [ $attempt -lt 3 ]; do
            read -r -p "Enter module path: " MODULE_PATH
            if validate_module "$MODULE_PATH"; then
              log "User provided custom module path: $MODULE_PATH"
              break
            else
              echo "Invalid module path. Expected format: domain.tld/org/repo (no spaces)."
              attempt=$((attempt+1))
            fi
          done
          if [ -z "$MODULE_PATH" ] || ! validate_module "$MODULE_PATH"; then
            log "Failed to obtain a valid module path after multiple attempts"
            MODULE_PATH=""
          fi
        fi
      fi
    fi

    # If MODULE_TEMPLATE was provided non-interactively and MODULE_PATH still empty, try to fill it
    if [ -n "$MODULE_TEMPLATE" ] && [ -z "$MODULE_PATH" ]; then
      tmp="$MODULE_TEMPLATE"
      if [[ "$tmp" == *"<org>"* ]]; then
        # default org to username in non-interactive mode
        tmp=${tmp//"<org>"/$(whoami)}
      fi
      tmp=${tmp//"<project>"/$PROJECT_NAME}
      MODULE_PATH="$tmp"
      log "Auto-constructed module path from template: $MODULE_PATH"
    fi

    # Validate module path if set
    if [ -n "$MODULE_PATH" ]; then
      if ! validate_module "$MODULE_PATH"; then
        if [ "$AUTO_YES" = true ]; then
          echo "ERROR: Provided module path '$MODULE_PATH' appears invalid. Exiting."
          exit 1
        else
          echo "ERROR: Provided module path '$MODULE_PATH' appears invalid. Please re-run with a valid module or use --module-template."
          exit 1
        fi
      fi
    fi

    if [ "$NO_INSTALL" = true ]; then
      log "Skipping Go installation as chosen"
    else
      if ! confirm "Go is not installed. Install Go $GO_VERSION now (may require sudo)?"; then
        log "Go installation cancelled by user"
      else
        log "Installing Go $GO_VERSION..."
        tmpdir=$(mktemp -d)
        trap 'rm -rf "$tmpdir"' RETURN
        cd "$tmpdir"
        curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o go.tar.gz
        if [ $? -ne 0 ]; then
          log "Failed to download Go. Aborting."
          exit 1
        fi
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf go.tar.gz
        if ! command_exists go; then
          log "Installation completed, but 'go' is not in PATH. Please verify your PATH."
        else
          log "Go installed successfully: $(go version)"
        fi
        if ! grep -q '/usr/local/go/bin' ~/.bashrc 2>/dev/null; then
          echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
          log "Added /usr/local/go/bin to ~/.bashrc"
        fi
      fi
    fi
  fi
fi

# Create project
if [ -z "$PROJECT_NAME" ]; then
  if [ "$AUTO_YES" = true ]; then
    log "Error: project name missing and auto-yes enabled. Specify -n/--name."; exit 1
  fi
  echo -e "${YELLOW}Creating new Go project${NC}"
  read -r -p "Enter project name: " PROJECT_NAME
fi

PROJECT_PATH_FULL="$PROJECT_PATH/$PROJECT_NAME"
log "Project: $PROJECT_NAME -> $PROJECT_PATH_FULL"
if ! confirm "Create project '$PROJECT_NAME' in '$PROJECT_PATH_FULL'?"; then
  log "Operation cancelled by user"
  exit 0
fi

# Create project
log "Creating directory $PROJECT_PATH_FULL..."
mkdir -p "$PROJECT_PATH_FULL"
cd "$PROJECT_PATH_FULL"

# Initialize Go module
if [ -z "$MODULE_PATH" ]; then
  MODULE_PATH="github.com/$(whoami)/$PROJECT_NAME"
fi
log "Initializing module: $MODULE_PATH"
if ! go mod init "$MODULE_PATH" 2>/dev/null; then
  log "go mod init failed or module already exists — continuing..."
fi

# Create main.go
cat > main.go <<'EOF'
package main

import "fmt"

func main() {
    fmt.Println("Hello, Go!")
}
EOF

log "Project created at $PROJECT_PATH_FULL"
log "To test: cd $PROJECT_PATH_FULL && go run main.go"
