#!/usr/bin/env bash

################################################################################
# .NET Setup Script
# Description: Installs and configures .NET SDK and Runtime
# Author: João Augusto Bonfante
# GitHub: https://github.com/joaodev
# Date: January 2026
################################################################################

set -euo pipefail
IFS=$'\n\t'

# Defaults
DOTNET_VERSION="8.0"
PROJECT_NAME="MyApp"
PROJECT_PATH_DEFAULT="$HOME/Projects"
PROJECT_PATH=""
LOG_FILE="$HOME/.dotnet_setup.log"
AUTO_YES=false

# Helpers
timestamp() { date '+%Y-%m-%d %H:%M:%S'; }
log() {
  printf '%s %s\n' "$(timestamp)" "$*" | tee -a "$LOG_FILE"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

confirm() {
  # Usage: confirm "Mensagem"
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
  -n, --name NAME       Project name (default: $PROJECT_NAME)
  -p, --path PATH       Parent directory for the project (default: $PROJECT_PATH_DEFAULT)
  -v, --version VER     .NET version to install/use (default: $DOTNET_VERSION)
  -l, --logfile FILE    Log file (default: $LOG_FILE)
  -y, --yes             Accept all confirmations automatically
  -h, --help            Show this help message

Example: $(basename "$0") -n MyApp -p ~/Projects -v 8.0
EOF
} 


install_dotnet() {
  if command_exists dotnet; then
    log ".NET SDK already installed: $(dotnet --version)"
    return 0
  fi

  if ! confirm "Do you want to install the .NET SDK (version $DOTNET_VERSION)?"; then
    log ".NET SDK installation cancelled by user"
    return 1
  fi

  log "Installing .NET SDK version $DOTNET_VERSION..."
  tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' RETURN
  curl -fsSL https://dot.net/v1/dotnet-install.sh -o "$tmpdir/dotnet-install.sh"
  chmod +x "$tmpdir/dotnet-install.sh"

  # Install to the user's directory to avoid requiring sudo
  INSTALL_DIR="$HOME/.dotnet"
  "$tmpdir/dotnet-install.sh" --version "$DOTNET_VERSION" --install-dir "$INSTALL_DIR"

  # Update PATH if necessary
  if ! grep -q 'export DOTNET_ROOT' ~/.bashrc 2>/dev/null; then
    echo "export DOTNET_ROOT=\"$INSTALL_DIR\"" >> ~/.bashrc
    echo 'export PATH="$DOTNET_ROOT:$PATH"' >> ~/.bashrc
  fi
  export DOTNET_ROOT="$INSTALL_DIR"
  export PATH="$DOTNET_ROOT:$PATH"

  if command_exists dotnet; then
    log ".NET SDK installed successfully: $(dotnet --version)"
    return 0
  else
    log "Error: could not verify the .NET SDK installation"
    return 1
  fi
} 

create_project() {
  PROJECT_PATH_FULL="$PROJECT_PATH/$PROJECT_NAME"
  log "Creating project '$PROJECT_NAME' in '$PROJECT_PATH_FULL'..."

  if [ -d "$PROJECT_PATH_FULL" ] && [ "$(ls -A "$PROJECT_PATH_FULL")" ]; then
    if ! confirm "The directory '$PROJECT_PATH_FULL' already exists and is not empty. Do you want to overwrite/continue?"; then
      log "Project creation cancelled by user"
      return 1
    fi
  fi

  mkdir -p "$PROJECT_PATH_FULL"
  pushd "$PROJECT_PATH_FULL" >/dev/null

  # Use --output . to ensure the project is created in the current directory
  dotnet new console --output . --name "$PROJECT_NAME"

  popd >/dev/null
  log "Project created successfully"
} 

restore_dependencies() {
  log "Restoring dependencies in '$PROJECT_PATH/$PROJECT_NAME'..."
  pushd "$PROJECT_PATH/$PROJECT_NAME" >/dev/null
  dotnet restore
  popd >/dev/null
  log "Dependencies restored"
}

build_project() {
  log "Building project in '$PROJECT_PATH/$PROJECT_NAME'..."
  pushd "$PROJECT_PATH/$PROJECT_NAME" >/dev/null
  dotnet build
  popd >/dev/null
  log "Build completed"
} 

# main "$@"

# Trap for errors
trap 'log "Unexpected error. See $LOG_FILE"; exit 1' ERR

# Parse args
while [ "$#" -gt 0 ]; do
  case "$1" in
    -n|--name) PROJECT_NAME="$2"; shift 2 ;;
    -p|--path) PROJECT_PATH="$2"; shift 2 ;;
    -v|--version) DOTNET_VERSION="$2"; shift 2 ;;
    -l|--logfile) LOG_FILE="$2"; shift 2 ;;
    -y|--yes) AUTO_YES=true; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) log "Unknown option: $1"; usage; exit 1 ;; 
    *) break ;;
  esac
done

# If path was not provided, use the default
: "${PROJECT_PATH:=$PROJECT_PATH_DEFAULT}"

# Final confirmation of parameters
log "Parameters: project='$PROJECT_NAME' path='$PROJECT_PATH' version='$DOTNET_VERSION' logfile='$LOG_FILE' auto-yes='$AUTO_YES'"
if ! confirm "Proceed with these parameters?"; then
  log "Operation cancelled by user"
  exit 0
fi

# Execução
install_dotnet
create_project
restore_dependencies
build_project

log "=== Setup Complete ==="
