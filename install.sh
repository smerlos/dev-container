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

# Create example files
create_examples() {
    log_info "Creating example configuration files..."
    
    # Create .envrc example if it doesn't exist
    if [[ ! -f .envrc ]]; then
        cat > .envrc << 'EOF'
# Example .envrc file
# This file is automatically loaded by direnv when you enter the directory

# Use mise for tool version management
use mise

# Example environment variables
# export DATABASE_URL="postgresql://localhost/myapp"
# export API_KEY="your-api-key-here"
# export NODE_ENV="development"

# Example: Install and use specific tool versions
# mise use node@20
# mise use python@3.11
# mise use go@1.21
EOF
        log_success "Created example .envrc file"
    fi
    
    # Create .mise.toml example if it doesn't exist
    if [[ ! -f .mise.toml ]]; then
        cat > .mise.toml << 'EOF'
# Example .mise.toml file
# This file defines tool versions for your project

[tools]
# node = "20"
# python = "3.11"
# go = "1.21"
# terraform = "1.6"

[env]
# PROJECT_NAME = "my-awesome-project"
# LOG_LEVEL = "debug"
EOF
        log_success "Created example .mise.toml file"
    fi
}

# Create README with instructions
create_readme() {
    if [[ ! -f README.md ]]; then
        cat > README.md << 'EOF'
# Development Environment

This project is configured to use a modern development container with Docker-in-Docker support.

## Quick Start

1. **Open in VS Code**: Install the "Dev Containers" extension
2. **Reopen in Container**: Press `Ctrl+Shift+P` → "Dev Containers: Reopen in Container"
3. **Wait for setup**: The container will be created and configured automatically

## What's Included

- **Docker-in-Docker**: Run containers from within the dev container
- **mise**: Modern tool version management
- **direnv**: Automatic environment loading
- **Starship**: Beautiful shell prompt
- **Oh My Zsh**: Enhanced shell with plugins
- **Essential tools**: git, vim, curl, build tools

## Using the Environment

### Tool Management with mise
```bash
# Install and use Node.js
mise install node@20
mise use node@20

# Install and use Python
mise install python@3.11
mise use python@3.11

# See available tools
mise ls-remote node
```

### Environment Variables with direnv
Edit `.envrc` to set project-specific environment variables:
```bash
# .envrc
use mise
export DATABASE_URL="postgresql://localhost/myapp"
export API_KEY="your-api-key"
```

Then allow the file:
```bash
direnv allow
```

### Docker Usage
```bash
# Run containers
docker run hello-world

# Use docker-compose
docker compose up -d

# Build images
docker build -t my-app .
```

## Customization

- **Add VS Code extensions**: Edit `.devcontainer/devcontainer.json`
- **Install additional tools**: Use `mise install <tool>`
- **Configure environment**: Edit `.envrc` and `.mise.toml`

## Troubleshooting

- **Container won't start**: Check Docker is running
- **Missing tools**: Run `setup-workspace` inside the container
- **Permission issues**: The container runs as user `vscode` with sudo access
EOF
        log_success "Created README.md with instructions"
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
    create_examples
    create_readme
    
    echo
    log_success "🎉 Setup complete!"
    echo
    log_info "Next steps:"
    echo "  1. Open this directory in VS Code"
    echo "  2. Install the 'Dev Containers' extension if you haven't already"
    echo "  3. Press Ctrl+Shift+P and select 'Dev Containers: Reopen in Container'"
    echo "  4. Wait for the container to start and enjoy your development environment!"
    echo
    log_info "For more information, check the README.md file"
    echo
}

# Run main function
main "$@"
