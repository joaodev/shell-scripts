#!/usr/bin/env bash

################################################################################
# Kubernetes Setup Script
# Description: Installs and configures a Kubernetes cluster using kubeadm
# Author: João Augusto Bonfante
# GitHub: https://github.com/joaodev
# Date: January 2026
################################################################################
set -euo pipefail
IFS=$'\n\t'

# Defaults
LOG_FILE="$HOME/.kubernetes_setup.log"
AUTO_YES=false
NO_INIT=false
POD_CIDR="10.244.0.0/16"

# Helpers
timestamp() { date '+%Y-%m-%d %H:%M:%S'; }
log() { printf '%s %s\n' "$(timestamp)" "$*" | tee -a "$LOG_FILE"; }
confirm() { if [ "$AUTO_YES" = true ]; then log "Auto-approve enabled — skipping confirmation: $1"; return 0; fi; local resp; read -r -p "$1 [y/N]: " resp; case "$resp" in [yY]|[yY][eE][sS]) return 0 ;; *) return 1 ;; esac }

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  --no-init            Do not run 'kubeadm init' (useful for joining nodes)
  --pod-cidr CIDR      Pod network CIDR to use during init (default: $POD_CIDR)
  -l, --logfile FILE   Log file (default: $LOG_FILE)
  -y, --yes            Accept confirmations automatically
  -h, --help           Show this help message
EOF
}

# Parse args
while [ "$#" -gt 0 ]; do
  case "$1" in
    --no-init) NO_INIT=true; shift ;;
    --pod-cidr) POD_CIDR="$2"; shift 2 ;;
    -l|--logfile) LOG_FILE="$2"; shift 2 ;;
    -y|--yes) AUTO_YES=true; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) echo "Unknown option: $1"; usage; exit 1 ;;
    *) break ;;
  esac
done

log "Starting Kubernetes setup..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    log "ERROR: This script must be run as root"
    echo "This script must be run as root"
    exit 1
fi

# Update system packages
if confirm "Update system packages and upgrade?"; then
    log "Updating system packages"
    apt-get update
    apt-get upgrade -y
else
    log "Skipped system update"
fi

# Install Docker
if confirm "Install Docker (docker.io)?"; then
    log "Installing Docker"
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker
    if [ -n "${SUDO_USER:-}" ]; then
      usermod -aG docker "$SUDO_USER"
    fi
else
    log "Skipped Docker installation"
fi

# Install kubeadm, kubelet, and kubectl
if confirm "Install Kubernetes components (kubeadm, kubelet, kubectl)?"; then
    log "Installing Kubernetes components"
    apt-get install -y apt-transport-https curl
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list

    apt-get update
    apt-get install -y kubelet kubeadm kubectl
    apt-mark hold kubelet kubeadm kubectl
else
    log "Skipped Kubernetes components installation"
fi

# Disable swap
if confirm "Disable swap now?"; then
    log "Disabling swap"
    swapoff -a
    sed -i '/ swap / s/^/#/' /etc/fstab
else
    log "Left swap enabled"
fi

# Initialize Kubernetes cluster
if [ "$NO_INIT" = false ]; then
    if confirm "Run 'kubeadm init' to initialize a cluster (pod CIDR: $POD_CIDR)?"; then
        log "Initializing Kubernetes cluster"
        kubeadm init --pod-network-cidr="$POD_CIDR"

        # Setup kubectl for current user
        if [ -n "${SUDO_USER:-}" ]; then
          mkdir -p /home/$SUDO_USER/.kube
          cp -i /etc/kubernetes/admin.conf /home/$SUDO_USER/.kube/config
          chown $(id -u $SUDO_USER):$(id -g $SUDO_USER) /home/$SUDO_USER/.kube/config
        fi

        # Install CNI plugin (Flannel)
        log "Installing Flannel networking"
        kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

        # Untaint master node to allow pod scheduling
        log "Untainting master node"
        kubectl taint nodes --all node-role.kubernetes.io/master- || true
    else
        log "Skipped cluster initialization"
    fi
else
    log "Cluster initialization skipped by option --no-init"
fi

log "Kubernetes setup completed"
log "Run 'kubectl get nodes' to verify the setup"