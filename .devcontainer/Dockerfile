# Multi-stage build for better caching and smaller final image
FROM debian:12-slim as base

# Environment variables - set once for entire build
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC \
    NONINTERACTIVE=1 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

# Install system packages and setup locale in one layer
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
      lsb-release && \
    locale-gen en_US.UTF-8 && \
    # Install Docker CLI
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y --no-install-recommends docker-ce-cli docker-buildx-plugin docker-compose-plugin && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create vscode user and setup sudoers
RUN groupadd --gid 1000 vscode && \
    useradd --uid 1000 --gid 1000 -m vscode -s /bin/zsh && \
    groupadd docker && \
    usermod -aG docker vscode && \
    echo "vscode ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vscode && \
    chmod 0440 /etc/sudoers.d/vscode && \
    chsh -s "$(which zsh)" vscode

# Switch to vscode user for remaining installations
USER vscode
WORKDIR /home/vscode

# Install Homebrew in a separate layer for better caching
RUN NONINTERACTIVE=1 bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && \
    brew update --quiet

# Install development tools in parallel where possible
RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && \
    curl -fsSL https://mise.run | sh && \
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes

# Install Oh My Zsh and plugins in optimized layers
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Clone Oh My Zsh plugins efficiently
RUN git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    git clone --depth=1 https://github.com/zsh-users/zsh-completions ~/.oh-my-zsh/custom/plugins/zsh-completions

# Configure vim in separate layer
RUN git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime && \
    sh ~/.vim_runtime/install_awesome_vimrc.sh

# Configure shell environment in final layer
RUN sed -i 's/plugins=(git)/plugins=(git direnv zsh-autosuggestions zsh-syntax-highlighting zsh-completions)/g' ~/.zshrc && \
    { \
      echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'; \
      echo 'eval "$(~/.local/bin/mise activate zsh)"'; \
      echo 'eval "$(starship init zsh)"'; \
      echo 'eval "$(direnv hook zsh)"'; \
    } >> ~/.zshrc

# Setup direnv configuration
RUN mkdir -p ~/.config/direnv/lib ~/.config/direnv && \
    echo 'use mise' > ~/.envrc && \
    ~/.local/bin/mise direnv activate > ~/.config/direnv/lib/use_mise.sh && \
    echo 'use mise' >> ~/.config/direnv/direnvrc && \
    direnv allow ~/.envrc

# Set shell for subsequent commands
SHELL ["/bin/zsh", "-l", "-c"]

# Create setup script for workspace initialization
RUN echo '#!/bin/zsh' > /home/vscode/setup-workspace && \
    echo 'echo "� Initializing development workspace..."' >> /home/vscode/setup-workspace && \
    echo 'source ~/.zshrc' >> /home/vscode/setup-workspace && \
    echo 'if [ -f .envrc ]; then direnv allow .; fi' >> /home/vscode/setup-workspace && \
    echo 'echo "✅ Workspace ready!"' >> /home/vscode/setup-workspace && \
    chmod +x /home/vscode/setup-workspace && \
    sudo ln -s /home/vscode/setup-workspace /usr/local/bin/setup-workspace

# Final health check (minimal)
RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && \
    ~/.local/bin/mise --version > /dev/null && \
    starship --version > /dev/null && \
    direnv --version > /dev/null && \
    echo "✅ All tools installed successfully"
