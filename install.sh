#!/bin/bash

# Modern Development Container Setup Script
# Usage: curl -fsSL https://raw.githubusercontent.com/smerlos/dev-container/main/install.sh | bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://raw.githubusercontent.com/smerlos/dev-container/main"
IMAGE_NAME="ghcr.io/smerlos/dev-container:latest"

# Helper functions
log_info() {
	echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
	echo -e "${GREEN}✅${NC} $1"
}

log_warning() {
	echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
	echo -e "${RED}❌${NC} $1"
}

# Check if command exists
command_exists() {
	command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
	log_info "Checking prerequisites..."

	if ! command_exists docker; then
		log_error "Docker is not installed. Please install Docker first."
		log_info "Visit: https://docs.docker.com/get-docker/"
		exit 1
	fi

	if ! docker info >/dev/null 2>&1; then
		log_error "Docker daemon is not running. Please start Docker."
		exit 1
	fi

	log_success "Prerequisites check passed"
}

# Create .devcontainer directory and files
setup_devcontainer() {
	log_info "Setting up dev container configuration..."

	# Create .devcontainer directory
	mkdir -p .devcontainer

	# Download devcontainer.json
	log_info "Downloading devcontainer.json..."
	curl -fsSL "${REPO_URL}/.devcontainer/devcontainer.json" -o .devcontainer/devcontainer.json

	log_success "Dev container configuration created"
}

# Pull the container image
pull_image() {
	log_info "Pulling dev container image..."
	log_info "This may take a few minutes on first run..."

	if docker pull "${IMAGE_NAME}"; then
		log_success "Container image pulled successfully"
	else
		log_error "Failed to pull container image"
		exit 1
	fi
}

# Main installation function
main() {
	echo
	log_info "🚀 Modern Development Container Setup"
	echo

	check_prerequisites
	setup_devcontainer
	pull_image

	echo
	log_success "🎉 Setup complete!"
	echo
	log_info "Next steps:"
	echo "  1. Open this directory in VS Code."
	echo "  2. If you don't have it, install the 'Dev Containers' extension."
	echo "  3. Press Ctrl+Shift+P and select 'Dev Containers: Reopen in Container'."
	echo "  4. Enjoy your modern development environment!"
	echo
}

# Run main function
main "$@"
