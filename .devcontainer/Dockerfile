# Use a specific Debian version for reproducibility
FROM mcr.microsoft.com/devcontainers/base:debian

# Set shell with pipefail option for safer RUN commands
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Environment variables for a non-interactive build
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    LANGUAGE=en_US:en

# Install system dependencies, Docker CLI, and clean up in a single layer
# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      # Core utilities
      wget git vim build-essential ca-certificates curl sudo zsh locales direnv procps file apt-transport-https gnupg lsb-release \
      # Python build dependencies
      libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev && \
    # Configure locales
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=en_US.UTF-8 && \
    # Install Docker CLI
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y --no-install-recommends docker-ce-cli docker-buildx-plugin docker-compose-plugin && \
    # Clean up
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set proper locale environment for remaining build stages
ENV LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

# Create vscode user, add to docker group, and setup sudoers
RUN groupadd --gid 1000 vscode || true && \
    useradd --uid 1000 --gid 1000 -m vscode -s /bin/zsh || true && \
    groupadd -f docker && \
    usermod -aG docker vscode && \
    echo "vscode ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vscode && \
    chmod 0440 /etc/sudoers.d/vscode && \
    chsh -s "$(which zsh)" vscode

# Switch to vscode user for user-specific installations
USER vscode
WORKDIR /home/vscode

# Set zsh as the default shell for subsequent commands
SHELL ["/bin/zsh", "-o", "pipefail", "-c"]

# Install Homebrew in its own layer for better caching
# hadolint ignore=SC1071
RUN NONINTERACTIVE=1 bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && \
    brew update --quiet && \
    brew install gcc update --quiet

# Install dev tools, Oh My Zsh, plugins, and vimrc in a single layer to reduce image size
# hadolint ignore=SC1071
RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && \
    # Install mise and starship
    curl -fsSL https://mise.run | sh && \
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes && \
    # Install Oh My Zsh
    if [ ! -d "/home/vscode/.oh-my-zsh" ]; then \
      zsh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; \
    fi && \
    # Clone Oh My Zsh plugins
    ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom} && \
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions && \
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting && \
    git clone --depth=1 https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM}/plugins/zsh-completions && \
    # Configure vim
    git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime && \
    zsh ~/.vim_runtime/install_awesome_vimrc.sh

# Configure shell environment and direnv in the final user layer
# hadolint ignore=SC1071
RUN sed -i 's/plugins=(git)/plugins=(git direnv zsh-autosuggestions zsh-syntax-highlighting zsh-completions)/g' ~/.zshrc && \
    { \
      echo ''; \
      echo '# Load Homebrew environment'; \
      echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'; \
      echo ''; \
      echo '# Initialize mise'; \
      echo 'eval "$(~/.local/bin/mise activate zsh)"'; \
      echo ''; \
      echo '# Initialize starship'; \
      echo 'eval "$(starship init zsh)"'; \
      echo ''; \
      echo '# Initialize direnv'; \
      echo 'eval "$(direnv hook zsh)"'; \
    } >> ~/.zshrc && \
    # Setup direnv configuration for global mise integration
    mkdir -p ~/.config/direnv && \
    echo 'eval "$(~/.local/bin/mise hook direnv)"' > ~/.config/direnv/direnvrc

# Switch back to root to create setup script
USER root
# hadolint ignore=SC1071
RUN echo '#!/bin/zsh' > /usr/local/bin/setup-workspace && \
    echo 'echo "🚀 Initializing development workspace..."' >> /usr/local/bin/setup-workspace && \
    echo 'source ~/.zshrc' >> /usr/local/bin/setup-workspace && \
    echo 'mise install' >> /usr/local/bin/setup-workspace && \
    echo 'echo "✅ Workspace ready!"' >> /usr/local/bin/setup-workspace && \
    chmod +x /usr/local/bin/setup-workspace && \
    chown vscode:vscode /usr/local/bin/setup-workspace

# Switch back to vscode user
USER vscode
WORKDIR /home/vscode
SHELL ["/bin/zsh", "-l", "-c"]

# Final health check to ensure tools are installed and on the PATH
# hadolint ignore=SC1071
RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && \
    mise --version > /dev/null && \
    starship --version > /dev/null && \
    direnv --version > /dev/null && \
    brew --version > /dev/null && \
    echo "✅ All tools installed and configured successfully"
