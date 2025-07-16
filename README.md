[![CI](https://github.com/smerlos/dev-container/actions/workflows/ci.yml/badge.svg)](https://github.com/smerlos/dev-container/actions/workflows/ci.yml)
[![CodeQL](https://github.com/smerlos/dev-container/actions/workflows/codeql-analysis.yml/badge.svg)](https://github.com/smerlos/dev-container/actions/workflows/codeql-analysis.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/smerlos/dev-container)](https://hub.docker.com/r/smerlos/dev-container)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

# Modern Development Container

A production-ready development container with Docker-in-Docker support, modern tooling, and zero-configuration setup.

## 🚀 Quick Start

Get started in seconds with a single command:

```bash
curl -fsSL https://raw.githubusercontent.com/smerlos/dev-container/main/install.sh | bash
```

This will:

- ✅ Check prerequisites (Docker)
- ✅ Download dev container configuration
- ✅ Pull the container image
- ✅ Create example configuration files
- ✅ Set up your development environment

## 🎯 What's Included

### Core Tools

- **Docker-in-Docker**: Run containers from within the dev container
- **mise**: Modern runtime version manager (replaces nvm, rbenv, pyenv, etc.)
- **direnv**: Automatic environment variable loading
- **Starship**: Beautiful, fast shell prompt
- **Oh My Zsh**: Enhanced shell with useful plugins

### Development Essentials

- **Git**: Version control with enhanced configuration
- **Vim**: Configured with awesome-vimrc
- **Build tools**: gcc, make, and essential development packages
- **Homebrew**: Package manager for additional tools

### Visual Studio Code Integration

- **Essential extensions**: mise, direnv, Docker, and editor config sharing
- **Optimized settings**: Performance and usability improvements
- **Seamless experience**: Full Visual Studio Code functionality in containers

## 🛠️ Usage

### 1. Install and Setup

```bash
# In your project directory
curl -fsSL https://raw.githubusercontent.com/smerlos/dev-container/main/install.sh | bash
```

### 2. Open in Visual Studio Code

1. Install the "Dev Containers" extension
2. Open your project in Visual Studio Code
3. Press `Ctrl+Shift+P` → "Dev Containers: Reopen in Container"
4. Wait for the container to start

### 3. Start Developing

The container includes everything you need:

```bash
# Tool version management
mise install node@20
mise use python@3.11

# Environment variables
echo 'export API_KEY="your-key"' >> .envrc
direnv allow

# Docker usage
docker run hello-world
docker compose up -d
```

## 📁 Project Structure

After installation, your project will have:

```text
your-project/
├── .devcontainer/
│   └── devcontainer.json    # Visual Studio Code dev container config
├── .envrc                   # Environment variables (direnv)
├── .mise.toml              # Tool versions (mise)
└── README.md               # Usage instructions
```

## 🔧 Configuration

### Tool Versions (.mise.toml)

```toml
[tools]
node = "20"
python = "3.11"
go = "1.21"
terraform = "1.6"

[env]
PROJECT_NAME = "my-awesome-project"
```

### Environment Variables (.envrc)

```bash
# Load mise configuration
use mise

# Project-specific variables
export DATABASE_URL="postgresql://localhost/myapp"
export API_KEY="your-api-key"
export NODE_ENV="development"
```

### Visual Studio Code Extensions (.devcontainer/devcontainer.json)

```json
{
  "customizations": {
    "vscode": {
      "extensions": [
        "jdinhlife.gruvbox",
        "ms-vscode.vscode-direnv",
        "ms-azuretools.vscode-docker"
      ]
    }
  }
}
```

## 🐳 Docker-in-Docker

The container supports running Docker commands and containers:

```bash
# Build images
docker build -t my-app .

# Run containers
docker run -p 3000:3000 my-app

# Use docker-compose
docker compose up -d

# Manage volumes and networks
docker volume create my-data
docker network create my-network
```

## 🎨 Customization

### Add More Tools

```bash
# Inside the container
mise install ruby@3.2
mise install terraform@1.6
brew install jq
```

### Modify Visual Studio Code Settings

Edit `.devcontainer/devcontainer.json` to:

- Add extensions
- Change container settings
- Mount additional volumes
- Set environment variables

### Shell Configuration

The container uses Zsh with Oh My Zsh and includes:

- Auto-suggestions
- Syntax highlighting
- Git integration
- Starship prompt

## 🔍 Troubleshooting

### Container Won't Start

```bash
# Check Docker is running
docker info

# Check Visual Studio Code Dev Containers extension is installed
code --list-extensions | grep ms-vscode-remote.remote-containers
```

### Missing Tools

```bash
# Inside the container, run the setup script
setup-workspace

# Or manually install tools
mise install node@latest
brew install your-tool
```

### Permission Issues

The container runs as user `vscode` with sudo access:

```bash
# If you need root access
sudo apt update
sudo apt install package-name
```

## 🚀 Advanced Usage

### Custom Dockerfile

If you need additional customization, you can extend the base image:

```dockerfile
FROM ghcr.io/smerlos/dev-container:latest

# Install additional packages
USER root
RUN apt-get update && apt-get install -y your-package

# Switch back to vscode user
USER vscode

# Install additional tools
RUN mise install your-tool@version
```

### CI/CD Integration

Use the same container in your CI/CD pipelines:

```yaml
# GitHub Actions example
jobs:
  test:
    runs-on: ubuntu-latest
    container: ghcr.io/smerlos/dev-container:latest
    steps:
      - uses: actions/checkout@v4
      - run: mise install
      - run: npm test
```

## 📝 Requirements

- **Docker**: Version 20.10 or later
- **Visual Studio Code**: With Dev Containers extension
- **Operating System**: Linux, macOS, or Windows with WSL2

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [mise](https://mise.jdx.dev/) - Modern runtime manager
- [direnv](https://direnv.net/) - Environment variable manager
- [Starship](https://starship.rs/) - Cross-shell prompt
- [Oh My Zsh](https://ohmyz.sh/) - Zsh framework
- [Visual Studio Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers) - Container development
