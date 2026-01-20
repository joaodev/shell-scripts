#!/usr/bin/env bash

################################################################################
# Gradle Installation and Configuration Script
# Description: Installs and configures Gradle for Java development
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
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Defaults
GRADLE_VERSION="8.5"
GRADLE_HOME="${GRADLE_HOME:-$HOME/.gradle/gradle-${GRADLE_VERSION}}"
GRADLE_USER_HOME="${GRADLE_USER_HOME:-$HOME/.gradle}"
LOG_FILE="$HOME/.gradle_setup.log"
AUTO_YES=false
TEST_PROJECT_NAME="gradle-test"
TEST_PROJECT_PARENT="/tmp"

# Helpers
timestamp() { date '+%Y-%m-%d %H:%M:%S'; }
log() { printf '%s %s\n' "$(timestamp)" "$*" | tee -a "$LOG_FILE"; }
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

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
    log "$1"
}

print_success() { echo -e "${GREEN}✓ $1${NC}"; log "$1"; }
print_error() { echo -e "${RED}✗ $1${NC}"; log "$1"; }
print_info() { echo -e "${YELLOW}ℹ $1${NC}"; log "$1"; }

################################################################################
# Usage and argument parsing
################################################################################

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -v, --version VER     Gradle version (default: $GRADLE_VERSION)
  -n, --name NAME       Test project name (default: $TEST_PROJECT_NAME)
  -p, --path PATH       Parent directory for test project (default: $TEST_PROJECT_PARENT)
  -l, --logfile FILE    Log file (default: $LOG_FILE)
  -y, --yes             Accept confirmations automatically
  -h, --help            Show this help message
EOF
}

# Parse args
while [ "$#" -gt 0 ]; do
  case "$1" in
    -v|--version) GRADLE_VERSION="$2"; shift 2 ;;
    -n|--name) TEST_PROJECT_NAME="$2"; shift 2 ;;
    -p|--path) TEST_PROJECT_PARENT="$2"; shift 2 ;;
    -l|--logfile) LOG_FILE="$2"; shift 2 ;;
    -y|--yes) AUTO_YES=true; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) echo "Unknown option: $1"; usage; exit 1 ;;
    *) break ;;
  esac
done

# Propagate GRADLE_HOME from version change
GRADLE_HOME="${GRADLE_HOME:-$HOME/.gradle/gradle-${GRADLE_VERSION}}"


print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

check_command() {
    if command -v "$1" &> /dev/null; then
        print_success "$1 found"
        return 0
    else
        print_error "$1 not found"
        return 1
    fi
}

################################################################################
# Prerequisites
################################################################################

print_header "Verifying prerequisites"

# Check if we are on a Linux/macOS system
if [[ ! "$OSTYPE" =~ ^(linux|darwin) ]]; then
    print_error "This script is designed for Linux/macOS"
    exit 1
fi

# Check if Java is installed
if ! command -v java &> /dev/null; then
    print_error "Java JDK not found. Please install a JDK first."
    exit 1
else
    JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    print_success "Java version: $JAVA_VERSION"
fi

# Check for curl or wget
if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
    print_error "curl or wget not found"
    exit 1
fi

# Check if unzip is available
if ! command -v unzip >/dev/null 2>&1; then
    if confirm "unzip is not installed. Install it now?"; then
        print_info "Installing unzip"
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y unzip
        elif command -v yum &> /dev/null; then
            sudo yum install -y unzip
        elif command -v brew &> /dev/null; then
            brew install unzip
        fi
    else
        print_error "unzip is required for Gradle installation. Exiting."
        exit 1
    fi
fi

################################################################################
# Download and install Gradle
################################################################################

print_header "Installing Gradle v${GRADLE_VERSION}"

GRADLE_DOWNLOAD_URL="https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"
GRADLE_TEMP_DIR="/tmp/gradle-install-$$"

mkdir -p "$GRADLE_TEMP_DIR"

if confirm "Download and install Gradle ${GRADLE_VERSION}?"; then
  print_info "Downloading Gradle ${GRADLE_VERSION}..."
  if command -v curl &> /dev/null; then
      curl -L -o "${GRADLE_TEMP_DIR}/gradle-${GRADLE_VERSION}-bin.zip" "$GRADLE_DOWNLOAD_URL"
  else
      wget -O "${GRADLE_TEMP_DIR}/gradle-${GRADLE_VERSION}-bin.zip" "$GRADLE_DOWNLOAD_URL"
  fi

  print_success "Download completed"

  # Create installation directory
  mkdir -p "$(dirname "$GRADLE_HOME")"

  print_info "Extracting files to $GRADLE_HOME..."
  unzip -q "${GRADLE_TEMP_DIR}/gradle-${GRADLE_VERSION}-bin.zip" -d "$(dirname "$GRADLE_HOME")"

  # If extraction created a gradle-version directory, rename if necessary
  if [ -d "$(dirname "$GRADLE_HOME")/gradle-${GRADLE_VERSION}" ]; then
      if [ "$GRADLE_HOME" != "$(dirname "$GRADLE_HOME")/gradle-${GRADLE_VERSION}" ]; then
          mv "$(dirname "$GRADLE_HOME")/gradle-${GRADLE_VERSION}" "$GRADLE_HOME"
      fi
  fi

  print_success "Gradle installed to $GRADLE_HOME"

  # Clean temporary files
  rm -rf "$GRADLE_TEMP_DIR"
else
  print_info "Skipped Gradle installation"
fi
################################################################################
# Configure environment variables
################################################################################

print_header "Configuring Environment Variables"

# Detect shell
SHELL_NAME=$(basename "$SHELL")
if [[ "$SHELL_NAME" == "zsh" ]]; then
    PROFILE_FILE="$HOME/.zshrc"
elif [[ "$SHELL_NAME" == "bash" ]]; then
    PROFILE_FILE="$HOME/.bashrc"
else
    PROFILE_FILE="$HOME/.profile"
fi

print_info "Using profile file: $PROFILE_FILE"

# Add GRADLE_HOME if not present
if ! grep -q "export GRADLE_HOME" "$PROFILE_FILE"; then
    if confirm "Add GRADLE_HOME and PATH exports to $PROFILE_FILE?"; then
      cat >> "$PROFILE_FILE" << EOF

# Gradle Configuration
export GRADLE_HOME=$GRADLE_HOME
export PATH=\$GRADLE_HOME/bin:\$PATH
EOF
      print_success "Environment variables added to $PROFILE_FILE"
    else
      print_info "Skipped adding environment variables to $PROFILE_FILE"
    fi
else
    print_info "Environment variables already configured"
fi

# Load the new variables into the current shell
export GRADLE_HOME="$GRADLE_HOME"
export PATH="$GRADLE_HOME/bin:$PATH"

################################################################################
# Configure Gradle User Home
################################################################################

print_header "Configuring Gradle User Home"

mkdir -p "$GRADLE_USER_HOME"

# Create default gradle.properties file
GRADLE_PROPERTIES="$GRADLE_USER_HOME/gradle.properties"
if [ ! -f "$GRADLE_PROPERTIES" ]; then
    cat > "$GRADLE_PROPERTIES" << 'EOF'
# Gradle Properties Configuration

# JVM Arguments
org.gradle.jvmargs=-Xmx2048m -XX:MaxMetaspaceSize=512m

# Performance
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.workers.max=8

# Build Features
org.gradle.warning.mode=fail

# Daemon Settings
org.gradle.daemon=true
org.gradle.daemon.idletimeout=60000

# Native Build Tools
org.gradle.native.dir=${GRADLE_USER_HOME}/native

# Repository Credentials (optional - uncomment as needed)
# systemProp.https.proxyHost=proxy.example.com
# systemProp.https.proxyPort=8080
EOF
    print_success "gradle.properties file created"
else
    print_info "gradle.properties already exists"
fi

################################################################################
# Verificação da Instalação
################################################################################

print_header "Verifying installation"

# Wait a moment to ensure PATH was updated
sleep 1

if command -v gradle &> /dev/null; then
    GRADLE_INSTALLED_VERSION=$(gradle --version 2>&1 | head -1)
    print_success "Gradle installed successfully!"
    echo -e "${GREEN}$GRADLE_INSTALLED_VERSION${NC}"
else
    print_error "Gradle not found in PATH"
    print_info "Run 'source $PROFILE_FILE' or restart your terminal"
    exit 1
fi

################################################################################
# Testes de Validação
################################################################################

print_header "Running validation tests"

# Test 1: Check Gradle version
print_info "Test 1: Gradle version"
gradle --version

# Test 2: Check GRADLE_HOME
print_info "Test 2: GRADLE_HOME configured"
echo "GRADLE_HOME: $GRADLE_HOME"

# Test 3: Create a test project (optional)
TEST_PROJECT_DIR="/tmp/gradle-test-$$"
print_info "Test 3: Creating test Gradle project at $TEST_PROJECT_DIR"

mkdir -p "$TEST_PROJECT_DIR"
cd "$TEST_PROJECT_DIR"

# Create basic project structure
mkdir -p src/main/java src/test/java

# Create build.gradle
cat > build.gradle << 'EOF'
plugins {
    id 'java'
    id 'application'
}

group = 'com.example'
version = '1.0-SNAPSHOT'

repositories {
    mavenCentral()
}

dependencies {
    testImplementation 'junit:junit:4.13.2'
}

application {
    mainClass = 'Main'
}

java {
    sourceCompatibility = '11'
    targetCompatibility = '11'
}

tasks.withType(JavaCompile) {
    options.encoding = 'UTF-8'
}
EOF

# Create Main.java
cat > src/main/java/Main.java << 'EOF'
public class Main {
    public static void main(String[] args) {
        System.out.println("Gradle is working correctly!");
    }
}
EOF

# Run gradle build
print_info "Building test project..."
gradle build --quiet 2>/dev/null && print_success "Test project build completed successfully" || print_error "Failed to build test project"

# Clean test project
cd - > /dev/null
rm -rf "$TEST_PROJECT_DIR"

################################################################################
# Installation Summary
################################################################################

print_header "Installation Summary"

echo -e "${GREEN}✓ Gradle ${GRADLE_VERSION} installed successfully!${NC}\n"

echo -e "Installation details:"
echo -e "  Installation directory: ${BLUE}$GRADLE_HOME${NC}"
echo -e "  Gradle User Home: ${BLUE}$GRADLE_USER_HOME${NC}"
echo -e "  Profile file: ${BLUE}$PROFILE_FILE${NC}"
echo -e "  Properties: ${BLUE}$GRADLE_PROPERTIES${NC}\n"

echo -e "Available commands:"
echo -e "  ${YELLOW}gradle --version${NC}          - Show Gradle version"
echo -e "  ${YELLOW}gradle build${NC}              - Build project"
echo -e "  ${YELLOW}gradle run${NC}                - Run application"
echo -e "  ${YELLOW}gradle test${NC}               - Run tests"
echo -e "  ${YELLOW}gradle clean${NC}              - Clean build"
echo -e "  ${YELLOW}gradle properties${NC}         - List properties\n"

echo -e "Next steps:"
echo -e "  1. Reload your shell: ${YELLOW}source $PROFILE_FILE${NC}"
echo -e "  2. Create a new project: ${YELLOW}gradle init${NC}"
echo -e "  3. Go to the project and run: ${YELLOW}gradle build${NC}\n"

print_success "Installation complete!"
