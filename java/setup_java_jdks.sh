#!/usr/bin/env bash

################################################################################
# JDK 17, 21 and 25 Setup Script
# Description: Installs and configures OpenJDK 17, 21 and 25
# Author: João Augusto Bonfante
# GitHub: https://github.com/joaodev
# Date: January 2026
################################################################################

set -euo pipefail
IFS=$'\n\t'

# Defaults
LOG_FILE="$HOME/.java_jdks_setup.log"
AUTO_YES=false

timestamp() { date '+%Y-%m-%d %H:%M:%S'; }
log() { printf '%s %s\n' "$(timestamp)" "$*" | tee -a "$LOG_FILE"; }
confirm() { if [ "$AUTO_YES" = true ]; then log "Auto-approve enabled — skipping confirmation: $1"; return 0; fi; local resp; read -r -p "$1 [y/N]: " resp; case "$resp" in [yY]|[yY][eE][sS]) return 0 ;; *) return 1 ;; esac }

usage() { cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -l, --logfile FILE    Log file (default: $LOG_FILE)
  -y, --yes             Accept confirmations automatically
  -h, --help            Show this help message
EOF
}

# Parse args
while [ "$#" -gt 0 ]; do
  case "$1" in
    -l|--logfile) LOG_FILE="$2"; shift 2 ;;
    -y|--yes) AUTO_YES=true; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) echo "Unknown option: $1"; usage; exit 1 ;;
    *) break ;;
  esac
done

log "============================================"
log "  JDK 17, 21 and 25 Installer"
log "============================================"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    log "Please run as root (sudo ./script.sh)"
    echo "Please run as root (sudo ./script.sh)"
    exit 1
fi

# Update repositories
if confirm "[1/4] Update package repositories now?"; then
  log "Updating repositories"
  apt update
else
  log "Skipped repository update"
fi

# Install JDK 17
if confirm "[2/4] Install OpenJDK 17 now?"; then
  log "Installing JDK 17"
  apt install -y openjdk-17-jdk
else
  log "Skipped JDK 17 installation"
fi

# Install JDK 21
if confirm "[3/4] Install OpenJDK 21 now?"; then
  log "Installing JDK 21"
  apt install -y openjdk-21-jdk
else
  log "Skipped JDK 21 installation"
fi

# Install JDK 25 (if available in repositories)
log "[4/4] Attempting to install JDK 25 if available"
if apt-cache show openjdk-25-jdk &> /dev/null; then
    if confirm "Install OpenJDK 25 now?"; then
        apt install -y openjdk-25-jdk
        JDK25_INSTALLED=true
        log "JDK 25 installed"
    else
        JDK25_INSTALLED=false
        log "Skipped JDK 25 installation"
    fi
else
    echo "WARNING: JDK 25 is not available in the standard repositories."
    echo "You may need to add a PPA or download it manually."
    JDK25_INSTALLED=false
    log "JDK 25 not available in repositories"
fi

log "Installation complete"

# List all installed Java versions
log "Installed Java versions:"
update-java-alternatives --list || true

# Select which JDK to activate
log "Prompting to select active JDK"

if [ "$AUTO_YES" = true ]; then
  echo "Non-interactive mode: not changing default JDK"
else
  echo "1) JDK 17"
  echo "2) JDK 21"
  if [ "$JDK25_INSTALLED" = true ]; then
      echo "3) JDK 25"
  fi
  echo "0) Do not change (keep current)"
  echo ""
  read -r -p "Enter your choice (0-3): " choice

  case $choice in
      1)
          log "Setting JDK 17 as default"
          update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java
          update-alternatives --set javac /usr/lib/jvm/java-17-openjdk-amd64/bin/javac
          ;;
      2)
          log "Setting JDK 21 as default"
          update-alternatives --set java /usr/lib/jvm/java-21-openjdk-amd64/bin/java
          update-alternatives --set javac /usr/lib/jvm/java-21-openjdk-amd64/bin/javac
          ;; 
      3)
          if [ "$JDK25_INSTALLED" = true ]; then
              log "Setting JDK 25 as default"
              update-alternatives --set java /usr/lib/jvm/java-25-openjdk-amd64/bin/java
              update-alternatives --set javac /usr/lib/jvm/java-25-openjdk-amd64/bin/javac
          else
              echo "JDK 25 was not installed."
          fi
          ;;
      0)
          log "Keeping current configuration"
          ;;
      *)
          echo "Invalid option. Keeping current configuration."
          ;;
  esac
fi

log "Active Java version:"
java -version || true

log "Helpful commands:"
log "  sudo update-alternatives --config java"
log "  sudo update-alternatives --config javac"
log "  java -version"
log "  javac -version"
log "  update-java-alternatives --list"