#!/bin/bash
set -e

# -----------------------------------------------------------
# Docker Installation Script for (Azure/EC2)
# -----------------------------------------------------------

log_info() {
  echo "[INFO] $1"
}

log_warn() {
  echo "[WARN] $1"
}

update_system() {
  log_info "Updating system packages..."
  apt-get update -y
  log_info "System update completed"
}

install_docker() {
  log_info "Installing Docker via get.docker.com..."

  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh

  log_info "Docker installation completed"
}

configure_docker_user() {
  log_info "Configuring Docker user permissions..."

  # Prefer an explicit override if you ever want to set it via env
  if [ -n "$DOCKER_USER" ]; then
    USER_NAME="$DOCKER_USER"
    log_info "Using DOCKER_USER override: $USER_NAME"
  else
    # Fallback to first non-root user (uid 1000)
    USER_NAME=$(getent passwd 1000 | cut -d: -f1 || true)
    if [ -z "$USER_NAME" ]; then
      USER_NAME="azureuser"  # good default for Azure Ubuntu images
      log_info "Could not detect UID 1000 user, defaulting to: $USER_NAME"
    else
      log_info "Detected user with UID 1000: $USER_NAME"
    fi
  fi

  if id "$USER_NAME" &>/dev/null; then
    # docker group normally created by get.docker.com, but be defensive
    groupadd -f docker
    usermod -aG docker "$USER_NAME"
    log_info "User $USER_NAME added to docker group"
  else
    log_warn "User $USER_NAME not found, skipping group addition"
  fi
}

start_docker_service() {
  log_info "Enabling and starting Docker service..."

  systemctl enable docker
  systemctl start docker

  log_info "Docker service enabled and started"
}

cleanup() {
  log_info "Cleaning up installation files..."
  rm -f get-docker.sh || true
  log_info "Cleanup completed"
}

create_completion_marker() {
  local USER_NAME

  if [ -n "$DOCKER_USER" ]; then
    USER_NAME="$DOCKER_USER"
  else
    USER_NAME=$(getent passwd 1000 | cut -d: -f1 || true)
    [ -z "$USER_NAME" ] && USER_NAME="azureuser"
  fi

  local MARKER_FILE="/home/$USER_NAME/.docker-setup-complete"

  log_info "Creating completion marker at: $MARKER_FILE"
  echo "Docker setup completed at $(date)" > "$MARKER_FILE"
  chown "$USER_NAME:$USER_NAME" "$MARKER_FILE" 2>/dev/null || true
}

verify_installation() {
  log_info "Verifying Docker installation..."

  if command -v docker &>/dev/null; then
    docker --version || true
    docker compose version 2>/dev/null || log_warn "Docker Compose plugin not available"
    log_info "Docker verification completed"
  else
    log_warn "Docker binary not found on PATH"
    exit 1
  fi
}

main() {
  log_info "Starting Docker setup..."

  update_system
  install_docker
  configure_docker_user
  start_docker_service
  verify_installation
  cleanup
  create_completion_marker

  log_info "Docker setup completed successfully!"
  log_info "Note: user must log out/in for group changes to take effect"
}

main
