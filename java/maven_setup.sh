#!/usr/bin/env bash

################################################################################
# Maven Setup Script
# Description: Installs and configures Apache Maven
# Author: João Augusto Bonfante
# GitHub: https://github.com/joaodev
# Date: January 2026
################################################################################

set -euo pipefail
IFS=$'\n\t'

# Defaults
MAVEN_VERSION="3.9.6"
MAVEN_HOME="${HOME}/.maven"
MAVEN_URL="https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/apache-maven-${MAVEN_VERSION}-bin.tar.gz"
LOG_FILE="$HOME/.maven_setup.log"
AUTO_YES=false
CREATE_PROJECT=false
PROJECT_NAME="maven-app"
PROJECT_PATH="$PWD"

# Helpers
timestamp() { date '+%Y-%m-%d %H:%M:%S'; }
log() { printf '%s %s\n' "$(timestamp)" "$*" | tee -a "$LOG_FILE"; }
confirm() { if [ "$AUTO_YES" = true ]; then log "Auto-approve enabled — skipping confirmation: $1"; return 0; fi; local resp; read -r -p "$1 [y/N]: " resp; case "$resp" in [yY]|[yY][eE][sS]) return 0 ;; *) return 1 ;; esac }

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -v, --version VER     Maven version (default: $MAVEN_VERSION)
  -n, --name NAME       Create a sample Maven project with this artifactId (default: $PROJECT_NAME)
  -p, --path PATH       Parent directory for created project (default: $PROJECT_PATH)
  -c, --create          Create a sample Maven project after installation
  -l, --logfile FILE    Log file (default: $LOG_FILE)
  -y, --yes             Accept confirmations automatically
  -h, --help            Show this help message
EOF
}

# Parse args
while [ "$#" -gt 0 ]; do
  case "$1" in
    -v|--version) MAVEN_VERSION="$2"; MAVEN_URL="https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/apache-maven-${MAVEN_VERSION}-bin.tar.gz"; shift 2 ;;
    -n|--name) PROJECT_NAME="$2"; shift 2 ;;
    -p|--path) PROJECT_PATH="$2"; shift 2 ;;
    -c|--create) CREATE_PROJECT=true; shift ;;
    -l|--logfile) LOG_FILE="$2"; shift 2 ;;
    -y|--yes) AUTO_YES=true; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) echo "Unknown option: $1"; usage; exit 1 ;;
    *) break ;;
  esac
done

log "🔧 Starting Maven setup..."

# Create directory
mkdir -p "${MAVEN_HOME}"

# Download Maven
if confirm "Download Maven ${MAVEN_VERSION} and install to ${MAVEN_HOME}?"; then
  log "📥 Downloading Maven ${MAVEN_VERSION}..."
  cd /tmp
  curl -fsSL "${MAVEN_URL}" -o maven.tar.gz

  # Extract
  log "📦 Extracting Maven..."
  tar -xzf maven.tar.gz -C "${MAVEN_HOME}" --strip-components=1
  rm maven.tar.gz
else
  log "Skipped Maven download and install"
fi

# Update PATH
PROFILE_FILE="${HOME}/.bashrc"
if [[ ! -f "${PROFILE_FILE}" ]]; then
    PROFILE_FILE="${HOME}/.zshrc"
fi

if ! grep -q "MAVEN_HOME" "${PROFILE_FILE}"; then
    if confirm "Add MAVEN_HOME and PATH exports to $PROFILE_FILE?"; then
      echo "" >> "${PROFILE_FILE}"
      echo "# Maven configuration" >> "${PROFILE_FILE}"
      echo "export MAVEN_HOME=${MAVEN_HOME}" >> "${PROFILE_FILE}"
      echo "export PATH=\$MAVEN_HOME/bin:\$PATH" >> "${PROFILE_FILE}"
      log "Updated $PROFILE_FILE with Maven environment variables"
    else
      log "Skipped updating $PROFILE_FILE"
    fi
fi

# Verify installation
log "Verifying Maven installation"
"${MAVEN_HOME}/bin/mvn" --version || log "mvn not found; ensure MAVEN_HOME/bin is in PATH or source ${PROFILE_FILE}"

# Create sample project if requested
if [ "$CREATE_PROJECT" = true ] || confirm "Create a sample Maven project named '$PROJECT_NAME' in '$PROJECT_PATH'?"; then
  log "Creating sample Maven project: $PROJECT_NAME"
  mkdir -p "$PROJECT_PATH"
  cd "$PROJECT_PATH"
  mvn archetype:generate -DgroupId=com.example -DartifactId="$PROJECT_NAME" -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
  log "Sample project created at $PROJECT_PATH/$PROJECT_NAME"
fi

log "✅ Maven setup completed. Run: source ${PROFILE_FILE} if needed"