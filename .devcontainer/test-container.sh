#!/bin/bash

# Test script for dev container functionality
# This script can be run inside the container to verify everything works

set -e

echo "🧪 Testing Dev Container Functionality"
echo "======================================"

# Test 1: Basic tools
echo "📦 Testing basic tools..."
echo "  ✓ Checking zsh: $(zsh --version)"
echo "  ✓ Checking git: $(git --version)"
echo "  ✓ Checking curl: $(curl --version | head -1)"
echo "  ✓ Checking vim: $(vim --version | head -1)"

# Test 2: Development tools
echo ""
echo "🛠️  Testing development tools..."
echo "  ✓ Checking mise: $(mise --version)"
echo "  ✓ Checking starship: $(starship --version)"
echo "  ✓ Checking direnv: $(direnv --version)"

# Test 3: Homebrew
echo ""
echo "🍺 Testing Homebrew..."
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
echo "  ✓ Checking brew: $(brew --version | head -1)"

# Test 4: Oh My Zsh
echo ""
echo "🐚 Testing Oh My Zsh..."
if [ -d ~/.oh-my-zsh ]; then
	echo "  ✓ Oh My Zsh installed"
	if [ -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
		echo "  ✓ zsh-autosuggestions plugin installed"
	fi
	if [ -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
		echo "  ✓ zsh-syntax-highlighting plugin installed"
	fi
	if [ -d ~/.oh-my-zsh/custom/plugins/zsh-completions ]; then
		echo "  ✓ zsh-completions plugin installed"
	fi
else
	echo "  ❌ Oh My Zsh not found"
	exit 1
fi

# Test 5: Vim configuration
echo ""
echo "📝 Testing Vim configuration..."
if [ -d ~/.vim_runtime ]; then
	echo "  ✓ Awesome Vim configuration installed"
else
	echo "  ❌ Vim configuration not found"
	exit 1
fi

# Test 6: Environment setup
echo ""
echo "🌍 Testing environment setup..."
echo "  ✓ USER: $USER"
echo "  ✓ HOME: $HOME"
echo "  ✓ SHELL: $SHELL"
echo "  ✓ PWD: $PWD"
if [ -n "$WORKSPACE" ]; then
	echo "  ✓ WORKSPACE: $WORKSPACE"
else
	echo "  ⚠️  WORKSPACE not set"
fi

# Test 7: Setup script
echo ""
echo "⚙️  Testing setup script..."
if command -v setup-workspace >/dev/null 2>&1; then
	echo "  ✓ setup-workspace command available"
else
	echo "  ❌ setup-workspace command not found"
	exit 1
fi

# Test 8: Direnv functionality
echo ""
echo "📁 Testing direnv functionality..."
if [ -f ~/.envrc ]; then
	echo "  ✓ Default .envrc exists"
else
	echo "  ⚠️  Default .envrc not found"
fi

# Test 9: Mise functionality
echo ""
echo "🔧 Testing mise functionality..."
if ~/.local/bin/mise ls >/dev/null 2>&1; then
	echo "  ✓ Mise is functional"
	echo "  📋 Available tools: $(~/.local/bin/mise ls-remote | head -5 | tr '\n' ' ')"
else
	echo "  ❌ Mise not working properly"
	exit 1
fi

echo ""
echo "✅ All tests passed! Dev container is ready for use."
echo ""
echo "🚀 Quick start commands:"
echo "  mise install node@20     # Install Node.js"
echo "  mise install python@3.11 # Install Python"
echo "  mise install go@1.21     # Install Go"
echo "  setup-workspace          # Initialize workspace"
echo ""
echo "📚 For more information, see DEVCONTAINER-USAGE.md"
