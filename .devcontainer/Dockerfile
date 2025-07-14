FROM mcr.microsoft.com/devcontainers/base:debian

# Set shell with pipefail option for safer RUN commands - start with bash
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Environment variables - set once for entire build
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC \
    NONINTERACTIVE=1 \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    LANGUAGE=en_US:en

# Install system packages and setup locale in one layer
# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      wget \
      git \
      vim \
      build-essential \
      ca-certificates \
      curl \
      sudo \
      zsh \
      locales \
      direnv \
      procps \
      file \
      apt-transport-https \
      gnupg \
      lsb-release \
      # Python build dependencies
      libssl-dev \
      zlib1g-dev \
      libbz2-dev \
      libreadline-dev \
      libsqlite3-dev \
      libncursesw5-dev \
      xz-utils \
      tk-dev \
      libxml2-dev \
      libxmlsec1-dev \
      libffi-dev \
      liblzma-dev && \
    # Configure locales properly
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8 && \
    # Install Docker CLI
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y --no-install-recommends docker-ce-cli docker-buildx-plugin docker-compose-plugin && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set proper locale environment for remaining build stages
ENV LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

# Create vscode user and setup sudoers if they don't exist
RUN if ! getent group vscode > /dev/null; then groupadd --gid 1000 vscode; fi && \
    if ! id -u vscode > /dev/null 2>&1; then useradd --uid 1000 --gid 1000 -m vscode -s /bin/zsh; fi && \
    groupadd -f docker && \
    usermod -aG docker vscode && \
    echo "vscode ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vscode && \
    chmod 0440 /etc/sudoers.d/vscode && \
    chsh -s "$(which zsh)" vscode

# Now switch to zsh for remaining operations since it's installed
SHELL ["/bin/zsh", "-o", "pipefail", "-c"]

# Switch to vscode user for remaining installations
USER vscode
WORKDIR /home/vscode

# Install Homebrew in a separate layer for better caching
# hadolint ignore=SC1071
RUN NONINTERACTIVE=1 bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && \
    brew update --quiet && \
    # Install gcc as recommended by Homebrew
    brew install gcc


# Install development tools in parallel where possible
# hadolint ignore=SC1071
RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && \
    curl -fsSL https://mise.run | sh && \
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes && 
# Install Oh My Zsh and plugins in optimized layers
# hadolint ignore=SC1071
RUN if [ ! -d "/home/vscode/.oh-my-zsh" ]; then \
      zsh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; \
    fi

# Clone Oh My Zsh plugins efficiently
# hadolint ignore=SC1071
RUN git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    git clone --depth=1 https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions

# Configure vim in separate layer
# hadolint ignore=SC1071
RUN git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime && \
    zsh ~/.vim_runtime/install_awesome_vimrc.sh

# Configure shell environment in final layer
# hadolint ignore=SC1071
RUN sed -i 's/plugins=(git)/plugins=(git direnv zsh-autosuggestions zsh-syntax-highlighting zsh-completions)/g' ~/.zshrc && \
    { \
      echo "eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\""; \
      echo "eval \"\$(~/.local/bin/mise activate zsh)\""; \
      echo "eval \"\$(starship init zsh)\""; \
      echo "eval \"\$(direnv hook zsh)\""; \
    } >> ~/.zshrc

# Setup direnv configuration for global mise integration
# hadolint ignore=SC1071
RUN mkdir -p ~/.config/direnv && \
    echo 'eval "$(~/.local/bin/mise hook direnv)"' > ~/.config/direnv/direnvrc

# Set shell for subsequent commands
SHELL ["/bin/zsh", "-l", "-c"]

# Create setup script for workspace initialization (run as root to avoid sudo)
USER root
# hadolint ignore=SC1071
RUN echo '#!/bin/zsh' > /usr/local/bin/setup-workspace && \
    echo 'echo "🚀 Initializing development workspace..."' >> /usr/local/bin/setup-workspace && \
    echo 'source ~/.zshrc' >> /usr/local/bin/setup-workspace && \
    echo 'echo "✅ Workspace ready!"' >> /usr/local/bin/setup-workspace && \
    chmod +x /usr/local/bin/setup-workspace && \
    chown vscode:vscode /usr/local/bin/setup-workspace

# Switch back to vscode user
USER vscode

# Final health check (minimal) - using zsh consistently
# hadolint ignore=SC1071
RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && \
    ~/.local/bin/mise --version > /dev/null && \
    starship --version > /dev/null && \
    direnv --version > /dev/null && \
    echo "✅ All tools installed successfully"
