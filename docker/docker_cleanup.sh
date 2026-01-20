#!/usr/bin/env bash

################################################################################
# Docker Cleanup Script
# Description: Performs a full cleanup of Docker resources
# Author: João Augusto Bonfante
# GitHub: https://github.com/joaodev
# Date: January 2026
################################################################################

set -euo pipefail
IFS=$'\n\t'

# Defaults
LOG_FILE="$HOME/.docker_cleanup.log"
AUTO_YES=false
VERBOSE=false

# Helpers
timestamp() { date '+%Y-%m-%d %H:%M:%S'; }
log() { if [ "$VERBOSE" = true ]; then printf '%s %s\n' "$(timestamp)" "$*" | tee -a "$LOG_FILE"; else printf '%s %s\n' "$(timestamp)" "$*" >> "$LOG_FILE"; fi }
confirm() { if [ "$AUTO_YES" = true ]; then log "Auto-approve enabled — skipping confirmation: $1"; return 0; fi; local resp; read -r -p "$1 [y/N]: " resp; case "$resp" in [yY]|[yY][eE][sS]) return 0 ;; *) return 1 ;; esac }
usage() { cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -y, --yes           Run non-interactively (accept confirmations)
  -v, --verbose       Show verbose output
  -l, --logfile FILE  Log file (default: $LOG_FILE)
  -h, --help          Show this help message
EOF
}

log "Docker Full Cleanup"

echo "=================================="
echo "Docker Full Cleanup"
echo "=================================="
echo ""

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes) AUTO_YES=true; shift ;;
    -v|--verbose) VERBOSE=true; shift ;;
    -l|--logfile) LOG_FILE="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) echo "Unknown option: $1"; usage; exit 1 ;;
    *) break ;;
  esac
done

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    log "ERROR: Docker is not running or you don't have permission to access it"
    echo "❌ Error: Docker is not running or you don't have permission to access it"
    exit 1
fi

# Function to show disk usage
show_disk_usage() {
    echo "📊 Docker disk usage:"
    docker system df
    echo ""
}

# Show current usage
echo "Before cleanup:"
show_disk_usage

# Ask for confirmation
if ! confirm "⚠️  Proceed with cleanup? This will remove stopped containers, unused images, volumes and networks."; then
    log "Cleanup cancelled by user"
    echo "❌ Operation cancelled"
    exit 0
fi

echo ""

echo ""
echo "🧹 Starting cleanup..."
echo ""

# Stop all running containers
log "Stopping all running containers"
echo "🛑 Stopping all running containers..."
if [ "$(docker ps -q)" ]; then
    docker stop $(docker ps -q)
    log "Containers stopped"
    echo "✅ Containers stopped"
else
    log "No running containers to stop"
    echo "ℹ️  No running containers"
fi

echo ""

# Remove all containers
log "Removing all containers"
echo "🗑️  Removing all containers..."
if [ "$(docker ps -aq)" ]; then
    docker rm $(docker ps -aq)
    log "Containers removed"
    echo "✅ Containers removed"
else
    log "No containers to remove"
    echo "ℹ️  No containers to remove"
fi

echo ""

# Remove all images
log "Removing all images"
echo "🗑️  Removing all images..."
if [ "$(docker images -q)" ]; then
    docker rmi -f $(docker images -q)
    log "Images removed"
    echo "✅ Images removed"
else
    log "No images to remove"
    echo "ℹ️  No images to remove"
fi

echo ""

# Remove all volumes
log "Removing all volumes"
echo "🗑️  Removing all volumes..."
if [ "$(docker volume ls -q)" ]; then
    docker volume rm $(docker volume ls -q)
    log "Volumes removed"
    echo "✅ Volumes removed"
else
    log "No volumes to remove"
    echo "ℹ️  No volumes to remove"
fi

echo ""

# Remove unused networks
log "Removing unused networks"
echo "🗑️  Removing unused networks..."
docker network prune -f
log "Networks pruned"
echo "✅ Networks removed"
echo ""

# System cleanup (build cache, etc)
log "Running docker system prune"
echo "🗑️  Removing build cache and unused data..."
docker system prune -a -f --volumes
log "docker system prune completed"
echo "✅ System cleaned"
echo ""

# Show final usage
log "Showing disk usage after cleanup"
echo "After cleanup:"
show_disk_usage

echo "=================================="
echo "✅ Cleanup completed successfully!"
echo "=================================="