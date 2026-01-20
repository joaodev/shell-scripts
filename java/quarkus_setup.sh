#!/usr/bin/env bash

################################################################################
# Quarkus Project Setup Script
# Description: Sets up a new Quarkus project with Maven
# Author: João Augusto Bonfante
# GitHub: https://github.com/joaodev
# Date: January 2026
################################################################################

set -euo pipefail
IFS=$'\n\t'

# Defaults
LOG_FILE="$HOME/.quarkus_setup.log"
AUTO_YES=false
PROJECT_NAME=""
PROJECT_DIR="$PWD"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helpers
timestamp() { date '+%Y-%m-%d %H:%M:%S'; }
log() { printf '%s %s\n' "$(timestamp)" "$*" | tee -a "$LOG_FILE"; }
confirm() { if [ "$AUTO_YES" = true ]; then log "Auto-approve enabled — skipping confirmation: $1"; return 0; fi; local resp; read -r -p "$1 [y/N]: " resp; case "$resp" in [yY]|[yY][eE][sS]) return 0 ;; *) return 1 ;; esac }

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -n, --name NAME       Project name (if omitted you will be prompted)
  -p, --path PATH       Directory in which to create the project (default: current directory)
  -l, --logfile FILE    Log file (default: $LOG_FILE)
  -y, --yes             Accept confirmations automatically
  -h, --help            Show this help message
EOF
}

# Parse args
while [ "$#" -gt 0 ]; do
  case "$1" in
    -n|--name) PROJECT_NAME="$2"; shift 2 ;;
    -p|--path) PROJECT_DIR="$2"; shift 2 ;;
    -l|--logfile) LOG_FILE="$2"; shift 2 ;;
    -y|--yes) AUTO_YES=true; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) echo "Unknown option: $1"; usage; exit 1 ;;
    *) break ;;
  esac
done

log "=== Quarkus Project Setup ==="

# Check Java installation
log "Checking Java installation"
if ! command -v java &> /dev/null; then
    log "ERROR: Java is not installed. Please install Java 11 or higher."
    echo -e "${RED}Java is not installed. Please install Java 11 or higher.${NC}"
    exit 1
fi
JAVA_VERSION=$(java -version 2>&1 | awk -F'"' '/version/ {print $2}')
log "Java $JAVA_VERSION found"

env | grep -i mvn >/dev/null 2>&1 || true

# Check Maven installation
log "Checking Maven installation"
if ! command -v mvn &> /dev/null; then
    log "ERROR: Maven is not installed. Please install Maven."
    echo -e "${RED}Maven is not installed. Please install Maven.${NC}"
    exit 1
fi
log "Maven installed"

# Project name input
if [ -z "$PROJECT_NAME" ]; then
  if [ "$AUTO_YES" = true ]; then
    echo "ERROR: project name is required in non-interactive mode. Use -n/--name."; exit 1
  fi
  read -r -p "Enter project name: " PROJECT_NAME
fi

if [ -z "$PROJECT_NAME" ]; then
    log "ERROR: Project name cannot be empty"
    echo -e "${RED}Project name cannot be empty.${NC}"
    exit 1
fi

# Confirm creation
if ! confirm "Create Quarkus project '$PROJECT_NAME' in '$PROJECT_DIR'?"; then
  log "User cancelled Quarkus project creation"
  exit 0
fi

# Create Quarkus project
log "Creating Quarkus project: $PROJECT_NAME"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

mvn io.quarkus.platform:quarkus-maven-plugin:create \
    -DprojectGroupId=com.example \
    -DprojectArtifactId="$PROJECT_NAME" \
    -Dextensions="resteasy-reactive,resteasy-reactive-jackson"

cd "$PROJECT_NAME"

log "Project created successfully at $PROJECT_DIR/$PROJECT_NAME"

echo -e "${GREEN}✓ Project created successfully${NC}\n"
echo -e "${BLUE}Project structure:${NC}"
ls -la

echo -e "\n${GREEN}=== Setup Complete ===${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo "1. cd $PROJECT_NAME"
echo "2. ./mvnw quarkus:dev   (Run in dev mode)"
echo "3. ./mvnw package       (Build for production)"