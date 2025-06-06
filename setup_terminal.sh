#!/bin/bash

# ╭─────────────────────────────────────────────────────────────────────────────╮
# │          Ubuntu Terminal Setup Script - Memory Optimized Version              │
# │                   Solves memory issues on small droplets                      │
# ╰─────────────────────────────────────────────────────────────────────────────╯

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}╭─────────────────────────────────────────────────────────────────────────────╮${NC}"
echo -e "${BLUE}│          Ubuntu Terminal Setup Script - Memory Optimized                      │${NC}"
echo -e "${BLUE}╰─────────────────────────────────────────────────────────────────────────────╯${NC}"
echo

# Check available memory
AVAILABLE_MEM=$(free -m | awk 'NR==2{printf "%d", $7}')
echo -e "${BLUE}Available memory: ${AVAILABLE_MEM}MB${NC}"

if [ "$AVAILABLE_MEM" -lt 1000 ]; then
    echo -e "${YELLOW}Low memory detected. Enabling memory optimization...${NC}"
    MEMORY_OPTIMIZED=true
else
    MEMORY_OPTIMIZED=false
fi

# Check if running on Ubuntu
if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
  echo -e "${RED}This script is designed for Ubuntu. Detected OS: $(lsb_release -d 2>/dev/null || echo 'Unknown')${NC}"
  echo -e "${YELLOW}Continuing anyway, but some packages may not be available...${NC}"
fi

# Create swap if memory is low and no swap exists
if [ "$MEMORY_OPTIMIZED" = true ] && [ $(swapon --show | wc -l) -eq 0 ]; then
    echo -e "${YELLOW}Creating 2GB swap file for compilation...${NC}"
    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo -e "${GREEN}✓ Swap file created and activated${NC}"
fi

# Update package lists
echo -e "${BLUE}Updating package lists...${NC}"
sudo apt update

# Install essential packages first
echo -e "${BLUE}Installing essential packages...${NC}"
sudo apt install -y curl wget gpg lsb-release software-properties-common apt-transport-https ca-certificates gnupg

# Install Oh My Zsh if not already installed
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  # Install zsh first if not installed
  if ! command -v zsh &>/dev/null; then
    echo -e "${YELLOW}Installing zsh...${NC}"
    sudo apt install -y zsh
  fi
  
  echo -e "${YELLOW}Installing Oh My Zsh...${NC}"
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  
  # Set zsh as default shell
  echo -e "${YELLOW}Setting zsh as default shell...${NC}"
  sudo chsh -s $(which zsh) $(whoami)
else
  echo -e "${GREEN}✓ Oh My Zsh is already installed${NC}"
fi

# Add repositories for modern tools
echo -e "${BLUE}Adding repositories for modern CLI tools...${NC}"

# Add Git PPA for latest git
sudo add-apt-repository -y ppa:git-core/ppa

# Add Neovim PPA
sudo add-apt-repository -y ppa:neovim-ppa/unstable

# Update after adding repositories
sudo apt update

# Install tools available through apt
echo -e "${BLUE}Installing tools from apt repositories...${NC}"

apt_tools=(
  "git"          # Version control
  "neovim"       # Better vim
  "tmux"         # Terminal multiplexer
  "htop"         # Process viewer
  "tree"         # Directory tree
  "jq"           # JSON processor
  "curl"         # HTTP client
  "wget"         # File downloader
  "unzip"        # Archive extraction
  "zip"          # Archive creation
  "build-essential" # Compilation tools
  "python3-pip"  # Python package manager
  "nodejs"       # Node.js runtime
  "npm"          # Node package manager
  "ncdu"         # NCurses disk usage
  "neofetch"     # System info
  "net-tools"    # Network tools
  "fontconfig"   # Font configuration
  # "exa"          # Modern ls (replaced by eza) - disabled due to cargo conflicts
)

for tool in "${apt_tools[@]}"; do
  if dpkg -l | grep -q "^ii.*$tool "; then
    echo -e "${GREEN}✓ $tool is already installed${NC}"
  else
    echo -e "${YELLOW}Installing $tool...${NC}"
    sudo apt install -y "$tool"
  fi
done

# Install Rust with limited parallelism for low memory systems
if ! command -v cargo &>/dev/null; then
  echo -e "${YELLOW}Installing Rust...${NC}"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
  
  # Configure cargo for low memory systems
  if [ "$MEMORY_OPTIMIZED" = true ]; then
    mkdir -p ~/.cargo
    cat > ~/.cargo/config.toml << EOF
[build]
jobs = 1

[profile.release]
codegen-units = 1
EOF
    echo -e "${YELLOW}Configured cargo for low memory compilation${NC}"
  fi
else
  echo -e "${GREEN}✓ Rust is already installed${NC}"
fi

# Ensure cargo is in PATH
export PATH="$HOME/.cargo/bin:$PATH"

# Install modern CLI tools with memory optimization
echo -e "${BLUE}Installing modern CLI tools...${NC}"

# Function to install cargo package with memory optimization
install_cargo_tool() {
  local tool_name="$1"
  local package_name="${2:-$1}"
  
  if command -v "$tool_name" &>/dev/null; then
    echo -e "${GREEN}✓ $tool_name is already installed${NC}"
  else
    echo -e "${YELLOW}Installing $tool_name via cargo...${NC}"
    if [ "$MEMORY_OPTIMIZED" = true ]; then
      # Use single thread compilation
      CARGO_BUILD_JOBS=1 cargo install "$package_name"
    else
      cargo install "$package_name"
    fi
  fi
}

# Function to install pre-built binaries instead of compiling
install_prebuilt_binary() {
  local tool_name="$1"
  local download_url="$2"
  local binary_name="${3:-$1}"
  local install_dir="$HOME/.local/bin"
  
  mkdir -p "$install_dir"
  
  if command -v "$tool_name" &>/dev/null; then
    echo -e "${GREEN}✓ $tool_name is already installed${NC}"
    return
  fi
  
  echo -e "${YELLOW}Installing $tool_name from pre-built binary...${NC}"
  
  local temp_dir=$(mktemp -d)
  cd "$temp_dir"
  
  if [[ "$download_url" == *.tar.gz ]]; then
    wget -q "$download_url" -O archive.tar.gz
    tar -xzf archive.tar.gz
  elif [[ "$download_url" == *.zip ]]; then
    wget -q "$download_url" -O archive.zip
    unzip -q archive.zip
  else
    wget -q "$download_url" -O "$binary_name"
    chmod +x "$binary_name"
    cp "$binary_name" "$install_dir/"
    cd - > /dev/null
    rm -rf "$temp_dir"
    return
  fi
  
  # Find and install binary
  find . -name "$binary_name" -type f -executable | head -1 | xargs -I {} cp {} "$install_dir/"
  chmod +x "$install_dir/$binary_name"
  
  cd - > /dev/null
  rm -rf "$temp_dir"
}

# Install tools based on memory availability
if [ "$MEMORY_OPTIMIZED" = true ]; then
  echo -e "${YELLOW}Using pre-built binaries due to memory constraints...${NC}"
  
  # Install bat from deb package
  if ! command -v bat &>/dev/null; then
    echo -e "${YELLOW}Installing bat from deb package...${NC}"
    wget -q https://github.com/sharkdp/bat/releases/download/v0.24.0/bat_0.24.0_amd64.deb
    sudo dpkg -i bat_0.24.0_amd64.deb
    rm bat_0.24.0_amd64.deb
  fi
  
  # Install fd from deb package
  if ! command -v fd &>/dev/null; then
    echo -e "${YELLOW}Installing fd from deb package...${NC}"
    wget -q https://github.com/sharkdp/fd/releases/download/v8.7.0/fd_8.7.0_amd64.deb
    sudo dpkg -i fd_8.7.0_amd64.deb
    rm fd_8.7.0_amd64.deb
  fi
  
  # Install ripgrep from deb package
  if ! command -v rg &>/dev/null; then
    echo -e "${YELLOW}Installing ripgrep from deb package...${NC}"
    wget -q https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep_13.0.0_amd64.deb
    sudo dpkg -i ripgrep_13.0.0_amd64.deb
    rm ripgrep_13.0.0_amd64.deb
  fi
  
  # Install other tools as pre-built binaries
  install_prebuilt_binary "fzf" "https://github.com/junegunn/fzf/releases/latest/download/fzf-linux_amd64.tar.gz"
  install_prebuilt_binary "delta" "https://github.com/dandavison/delta/releases/latest/download/delta-0.16.5-x86_64-unknown-linux-gnu.tar.gz" "delta"
  install_prebuilt_binary "lazygit" "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_0.40.2_Linux_x86_64.tar.gz"
  install_prebuilt_binary "duf" "https://github.com/muesli/duf/releases/latest/download/duf_0.8.1_linux_x86_64.tar.gz"
  
  # Install only essential cargo tools with single-threaded compilation
  install_cargo_tool "zoxide"
  # install_cargo_tool "dust"  # Disabled due to cargo conflicts
  
else
  echo -e "${YELLOW}Installing via cargo (sufficient memory available)...${NC}"
  
  # Install tools via Cargo (original approach)
  install_cargo_tool "bat"
  install_cargo_tool "fd" "fd-find"
  install_cargo_tool "rg" "ripgrep"
  install_cargo_tool "zoxide"
  # install_cargo_tool "dust"  # Disabled due to cargo conflicts
  install_cargo_tool "procs"
  install_cargo_tool "sd"
fi

# Install GitHub CLI (available via apt)
if ! command -v gh &>/dev/null; then
  echo -e "${YELLOW}Installing GitHub CLI...${NC}"
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt update
  sudo apt install -y gh
else
  echo -e "${GREEN}✓ GitHub CLI is already installed${NC}"
fi

# Install Python tools via pipx (Ubuntu/Debian PEP 668 compatibility)
echo -e "${BLUE}Installing Python tools...${NC}"

# Install pipx first if not available
if ! command -v pipx &>/dev/null; then
  echo -e "${YELLOW}Installing pipx...${NC}"
  sudo apt update && sudo apt install -y pipx
  # Ensure pipx PATH is available
  pipx ensurepath
else
  echo -e "${GREEN}✓ pipx is already installed${NC}"
fi

# Install httpie via pipx
if ! command -v http &>/dev/null; then
  echo -e "${YELLOW}Installing HTTPie via pipx...${NC}"
  pipx install httpie
else
  echo -e "${GREEN}✓ HTTPie is already installed${NC}"
fi

# Install tldr via pipx
if ! command -v tldr &>/dev/null; then
  echo -e "${YELLOW}Installing tldr via pipx...${NC}"
  pipx install tldr
else
  echo -e "${GREEN}✓ tldr is already installed${NC}"
fi

# Install yq (single binary)
if ! command -v yq &>/dev/null; then
  echo -e "${YELLOW}Installing yq...${NC}"
  sudo wget -q https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
  sudo chmod +x /usr/local/bin/yq
else
  echo -e "${GREEN}✓ yq is already installed${NC}"
fi

# Install starship prompt (single binary)
if ! command -v starship &>/dev/null; then
  echo -e "${YELLOW}Installing Starship prompt...${NC}"
  curl -sS https://starship.rs/install.sh | sh -s -- -y
else
  echo -e "${GREEN}✓ Starship is already installed${NC}"
fi

# Install minimal Nerd Fonts (only JetBrains Mono to save space)
echo -e "${BLUE}Installing JetBrains Mono Nerd Font...${NC}"

fonts_dir="$HOME/.local/share/fonts"
mkdir -p "$fonts_dir"

if ls "$fonts_dir"/*"JetBrainsMono"* >/dev/null 2>&1; then
  echo -e "${GREEN}✓ JetBrains Mono is already installed${NC}"
else
  echo -e "${YELLOW}Installing JetBrains Mono Nerd Font...${NC}"
  temp_dir=$(mktemp -d)
  wget -q "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip" -O "$temp_dir/JetBrainsMono.zip"
  unzip -q "$temp_dir/JetBrainsMono.zip" -d "$temp_dir/JetBrainsMono/" 2>/dev/null || true
  find "$temp_dir/JetBrainsMono/" -name "*.ttf" -o -name "*.otf" | while read -r font; do
    cp "$font" "$fonts_dir/"
  done
  rm -rf "$temp_dir"
  fc-cache -fv >/dev/null 2>&1
  echo -e "${GREEN}✓ JetBrains Mono installed${NC}"
fi

# Install essential Zsh plugins
echo -e "${BLUE}Installing essential Zsh plugins...${NC}"

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Only install essential plugins to save space
plugins=(
  "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions"
  "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting"
  "zsh-completions:https://github.com/zsh-users/zsh-completions"
  "fast-syntax-highlighting:https://github.com/zdharma-continuum/fast-syntax-highlighting"
)

for plugin_info in "${plugins[@]}"; do
  plugin_name="${plugin_info%%:*}"
  plugin_url="${plugin_info#*:}"
  
  if [[ ! -d "$ZSH_CUSTOM/plugins/$plugin_name" ]]; then
    echo -e "${YELLOW}Installing $plugin_name...${NC}"
    git clone "$plugin_url" "$ZSH_CUSTOM/plugins/$plugin_name"
  else
    echo -e "${GREEN}✓ $plugin_name is already installed${NC}"
  fi
done

# Install Powerlevel10k theme
if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
  echo -e "${YELLOW}Installing Powerlevel10k theme...${NC}"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
else
  echo -e "${GREEN}✓ Powerlevel10k is already installed${NC}"
fi

# Create config directories
echo -e "${BLUE}Creating configuration directories...${NC}"
mkdir -p ~/.config
mkdir -p ~/.local/bin

# Add ~/.local/bin to PATH if not already there
if ! grep -q "$HOME/.local/bin" ~/.profile 2>/dev/null; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.profile
fi

# Add cargo bin to PATH if not already there
if ! grep -q "$HOME/.cargo/bin" ~/.profile 2>/dev/null; then
  echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.profile
fi

# Cleanup swap file if we created it and user doesn't want to keep it
if [ "$MEMORY_OPTIMIZED" = true ] && [ -f /swapfile ]; then
  echo -e "${YELLOW}Swap file was created for compilation. Keep it? [y/N]: ${NC}"
  read -r keep_swap
  if [[ ! "$keep_swap" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Removing temporary swap file...${NC}"
    sudo swapoff /swapfile
    sudo rm /swapfile
    echo -e "${GREEN}✓ Temporary swap file removed${NC}"
  else
    echo -e "${GREEN}✓ Swap file kept for future use${NC}"
    # Add to fstab for persistence
    if ! grep -q "/swapfile" /etc/fstab; then
      echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab
    fi
  fi
fi

# Source the new PATH additions
source ~/.profile 2>/dev/null || true

echo
echo -e "${GREEN}╭─────────────────────────────────────────────────────────────────────────────╮${NC}"
echo -e "${GREEN}│                    Memory-Optimized Setup Complete! 🎉                        │${NC}"
echo -e "${GREEN}╰─────────────────────────────────────────────────────────────────────────────╯${NC}"
echo
echo -e "${BLUE}What was optimized:${NC}"
echo -e "• Used pre-built binaries instead of compiling when memory < 1GB"
echo -e "• Created temporary swap file for compilation if needed"
echo -e "• Limited cargo to single-threaded compilation"
echo -e "• Installed minimal font set (JetBrains Mono only)"
echo -e "• Installed essential zsh plugins only"
echo
echo -e "${BLUE}Next steps:${NC}"
echo -e "1. Logout and login again to apply shell changes"
echo -e "2. Create your .zshrc configuration"
echo -e "3. For SSH terminals, ensure your client uses JetBrains Mono Nerd Font"
echo
echo -e "${GREEN}Memory-optimized Ubuntu terminal setup complete! 🚀${NC}"