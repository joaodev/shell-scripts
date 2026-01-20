#!/bin/bash

################################################################################
# Ubuntu Setup Script
# Description: Sets up a fresh Ubuntu installation with essential tools and configurations
# Author: João Augusto Bonfante
# GitHub: https://github.com/joaodev
# Date: January 2026
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ============================================================================
# SECTION 1: Initial System Update
# ============================================================================
log_info "Starting initial system update..."

sudo apt update && sudo apt upgrade -y
sudo apt dist-upgrade -y
sudo apt autoremove -y
sudo apt autoclean

log_info "System update completed."

# ============================================================================
# SECTION 2: Hardware Drivers & Firmware
# ============================================================================
log_info "Installing additional drivers..."

sudo ubuntu-drivers autoinstall

log_info "Setting up firmware updates..."

sudo apt install fwupd -y
sudo fwupdmgr refresh
sudo fwupdmgr update

log_info "Driver and firmware installation completed."

# ============================================================================
# SECTION 3: Essential Utilities & Tools
# ============================================================================
log_info "Installing essential utilities and development tools..."

sudo apt install -y \
  ubuntu-restricted-extras \
  gnome-tweaks \
  git curl wget \
  build-essential \
  software-properties-common \
  apt-transport-https \
  ca-certificates \
  gnupg \
  lsb-release \
  net-tools \
  htop \
  neofetch \
  unzip \
  p7zip-full \
  vim \
  terminator

log_info "Essential utilities installed successfully."

# ============================================================================
# SECTION 4: Zsh & Oh My Zsh Configuration
# ============================================================================
log_info "Installing Zsh shell..."

sudo apt install zsh -y

log_info "Installing Oh My Zsh framework..."
log_warn "You may be prompted to change your default shell. Accept if desired."

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

log_info "Installing Zsh plugins..."

# Install useful plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

log_info "Zsh plugins installed."
log_warn "MANUAL STEP REQUIRED: Edit ~/.zshrc and add the following plugins:"
log_warn "plugins=(git docker docker-compose node npm zsh-autosuggestions zsh-syntax-highlighting)"

# ============================================================================
# SECTION 5: System Performance Optimization
# ============================================================================
log_info "Optimizing system performance..."

# Increase inotify watches (important for IDEs and file watchers)
log_info "Increasing inotify watches limit for development tools..."
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Adjust swappiness for better performance
log_info "Adjusting swappiness for improved performance..."
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

log_info "System optimization completed."

# ============================================================================
# SECTION 6: Basic Firewall Configuration
# ============================================================================
log_info "Configuring basic firewall (UFW)..."

sudo apt install ufw -y
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw --force enable

log_info "Firewall configured and enabled."

# ============================================================================
# SECTION 7: Final Cleanup
# ============================================================================
log_info "Performing final system cleanup..."

sudo apt autoremove -y
sudo apt autoclean
sudo snap refresh

# ============================================================================
# COMPLETION
# ============================================================================
log_info "============================================================"
log_info "Setup completed successfully!"
log_info "============================================================"
log_warn "REMINDER: Don't forget to configure your ~/.zshrc plugins!"
log_info "You may need to restart your terminal or run: source ~/.zshrc"
log_info "To change your default shell to Zsh, run: chsh -s \$(which zsh)"
log_info "============================================================"

neofetch