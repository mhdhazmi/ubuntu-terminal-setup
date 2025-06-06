#!/bin/bash

# ╭─────────────────────────────────────────────────────────────────────────────╮
# │                     Ubuntu Terminal Setup Script                               │
# │                   Install tools for an awesome terminal                        │
# ╰─────────────────────────────────────────────────────────────────────────────╯

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}╭─────────────────────────────────────────────────────────────────────────────╮${NC}"
echo -e "${BLUE}│                     Ubuntu Terminal Setup Script                               │${NC}"
echo -e "${BLUE}╰─────────────────────────────────────────────────────────────────────────────╯${NC}"
echo

# Check if running on Ubuntu
if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
  echo -e "${RED}This script is designed for Ubuntu. Detected OS: $(lsb_release -d 2>/dev/null || echo 'Unknown')${NC}"
  echo -e "${YELLOW}Continuing anyway, but some packages may not be available...${NC}"
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
  "ffmpeg"       # Video/audio processing
  "imagemagick"  # Image manipulation
  "qrencode"     # Generate QR codes
  "net-tools"    # Network tools
  "fontconfig"   # Font configuration
)

for tool in "${apt_tools[@]}"; do
  if dpkg -l | grep -q "^ii.*$tool "; then
    echo -e "${GREEN}✓ $tool is already installed${NC}"
  else
    echo -e "${YELLOW}Installing $tool...${NC}"
    sudo apt install -y "$tool"
  fi
done

# Install Rust (needed for many modern CLI tools)
if ! command -v cargo &>/dev/null; then
  echo -e "${YELLOW}Installing Rust...${NC}"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
else
  echo -e "${GREEN}✓ Rust is already installed${NC}"
fi

# Install Go (needed for some tools)
if ! command -v go &>/dev/null; then
  echo -e "${YELLOW}Installing Go...${NC}"
  GO_VERSION="1.21.5"
  wget -q "https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
  rm "go${GO_VERSION}.linux-amd64.tar.gz"
  
  # Add Go to PATH if not already there
  if ! grep -q "/usr/local/go/bin" ~/.profile; then
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
  fi
  export PATH=$PATH:/usr/local/go/bin
else
  echo -e "${GREEN}✓ Go is already installed${NC}"
fi

# Ensure cargo is in PATH
export PATH="$HOME/.cargo/bin:$PATH"

# Install modern CLI tools via various methods
echo -e "${BLUE}Installing modern CLI tools...${NC}"

# Function to install cargo package
install_cargo_tool() {
  local tool_name="$1"
  local package_name="${2:-$1}"
  
  if command -v "$tool_name" &>/dev/null; then
    echo -e "${GREEN}✓ $tool_name is already installed${NC}"
  else
    echo -e "${YELLOW}Installing $tool_name via cargo...${NC}"
    cargo install "$package_name"
  fi
}

# Function to install from GitHub releases
install_github_release() {
  local tool_name="$1"
  local repo="$2"
  local binary_name="${3:-$1}"
  local install_dir="$HOME/.local/bin"
  
  mkdir -p "$install_dir"
  
  if command -v "$tool_name" &>/dev/null; then
    echo -e "${GREEN}✓ $tool_name is already installed${NC}"
    return
  fi
  
  echo -e "${YELLOW}Installing $tool_name from GitHub...${NC}"
  
  # Get latest release URL with more flexible patterns
  local latest_url=""
  
  # Try different naming patterns based on the tool
  case "$tool_name" in
    "fzf")
      latest_url=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | jq -r '.assets[] | select(.name | test("linux_amd64\\.tar\\.gz$|linux_amd64\\.tgz$")) | .browser_download_url' | head -1)
      ;;
    "lazygit")
      latest_url=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | jq -r '.assets[] | select(.name | test("Linux_x86_64\\.tar\\.gz$")) | .browser_download_url' | head -1)
      ;;
    "delta")
      latest_url=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | jq -r '.assets[] | select(.name | test("x86_64-unknown-linux-gnu\\.tar\\.gz$")) | .browser_download_url' | head -1)
      ;;
    "gitui")
      latest_url=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | jq -r '.assets[] | select(.name | test("linux-musl\\.tar\\.gz$")) | .browser_download_url' | head -1)
      ;;
    "btop")
      latest_url=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | jq -r '.assets[] | select(.name | test("x86_64-linux-musl\\.tbz$")) | .browser_download_url' | head -1)
      ;;
    "duf")
      latest_url=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | jq -r '.assets[] | select(.name | test("linux_x86_64\\.tar\\.gz$")) | .browser_download_url' | head -1)
      ;;
    "gping")
      latest_url=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | jq -r '.assets[] | select(.name | test("x86_64-unknown-linux-musl\\.tar\\.gz$")) | .browser_download_url' | head -1)
      ;;
    "bandwhich")
      latest_url=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | jq -r '.assets[] | select(.name | test("x86_64-unknown-linux-musl\\.tar\\.gz$")) | .browser_download_url' | head -1)
      ;;
    *)
      # Generic fallback pattern
      latest_url=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | jq -r '.assets[] | select(.name | test("linux.*x86_64|x86_64.*linux"; "i") and (.name | test("\\.tar\\.gz$|\\.tgz$|\\.zip$"))) | .browser_download_url' | head -1)
      ;;
  esac
  
  if [[ -z "$latest_url" ]]; then
    echo -e "${RED}Could not find suitable release for $tool_name${NC}"
    return
  fi
  
  # Download and extract
  local temp_dir=$(mktemp -d)
  cd "$temp_dir"
  wget -q "$latest_url" -O archive
  
  if [[ "$latest_url" == *.tar.gz ]] || [[ "$latest_url" == *.tgz ]]; then
    tar -xzf archive
  elif [[ "$latest_url" == *.tbz ]]; then
    tar -xjf archive
  else
    unzip -q archive
  fi
  
  # Find and install binary
  find . -name "$binary_name" -type f -executable | head -1 | xargs -I {} cp {} "$install_dir/"
  chmod +x "$install_dir/$binary_name"
  
  cd - > /dev/null
  rm -rf "$temp_dir"
}

# Install tools via Cargo
install_cargo_tool "eza"
install_cargo_tool "bat"
install_cargo_tool "fd" "fd-find"
install_cargo_tool "rg" "ripgrep"
install_cargo_tool "zoxide"
# install_cargo_tool "dust"  # Disabled due to cargo conflicts
install_cargo_tool "procs"
install_cargo_tool "sd"
install_cargo_tool "choose"
install_cargo_tool "grex"

# Install tools from GitHub releases
install_github_release "fzf" "junegunn/fzf"
install_github_release "delta" "dandavison/delta" "delta"
install_github_release "gitui" "extrawurst/gitui"
install_github_release "lazygit" "jesseduffield/lazygit"
install_github_release "btop" "aristocratos/btop" "btop"
install_github_release "duf" "muesli/duf"
install_github_release "gping" "orf/gping"
install_github_release "bandwhich" "imsnif/bandwhich"

# Install GitHub CLI
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

# Install GitLab CLI
if ! command -v glab &>/dev/null; then
  echo -e "${YELLOW}Installing GitLab CLI...${NC}"
  glab_url=$(curl -s https://api.github.com/repos/gitlab-org/cli/releases/latest | jq -r '.assets[] | select(.name | test("linux_amd64\\.tar\\.gz$")) | .browser_download_url' | head -1)
  if [[ -n "$glab_url" ]]; then
    wget -q "$glab_url" -O - | tar -xz -C /tmp
    sudo mv /tmp/bin/glab /usr/local/bin/ 2>/dev/null || sudo mv /tmp/glab /usr/local/bin/
  else
    echo -e "${RED}Could not find GitLab CLI release${NC}"
  fi
else
  echo -e "${GREEN}✓ GitLab CLI is already installed${NC}"
fi

# Install httpie
if ! command -v http &>/dev/null; then
  echo -e "${YELLOW}Installing HTTPie...${NC}"
  python3 -m pip install --user httpie
else
  echo -e "${GREEN}✓ HTTPie is already installed${NC}"
fi

# Install tldr
if ! command -v tldr &>/dev/null; then
  echo -e "${YELLOW}Installing tldr...${NC}"
  python3 -m pip install --user tldr
else
  echo -e "${GREEN}✓ tldr is already installed${NC}"
fi

# Install yq
if ! command -v yq &>/dev/null; then
  echo -e "${YELLOW}Installing yq...${NC}"
  sudo wget -q https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
  sudo chmod +x /usr/local/bin/yq
else
  echo -e "${GREEN}✓ yq is already installed${NC}"
fi

# Install fastfetch (modern neofetch alternative)
if ! command -v fastfetch &>/dev/null; then
  echo -e "${YELLOW}Installing fastfetch...${NC}"
  # Add fastfetch PPA
  sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
  sudo apt update
  sudo apt install -y fastfetch
else
  echo -e "${GREEN}✓ fastfetch is already installed${NC}"
fi

# Install thefuck
if ! command -v fuck &>/dev/null; then
  echo -e "${YELLOW}Installing thefuck...${NC}"
  python3 -m pip install --user thefuck
else
  echo -e "${GREEN}✓ thefuck is already installed${NC}"
fi

# Install uv (Fast Python package installer)
if ! command -v uv &>/dev/null; then
  echo -e "${YELLOW}Installing uv (Fast Python package installer)...${NC}"
  curl -LsSf https://astral.sh/uv/install.sh | sh
else
  echo -e "${GREEN}✓ uv is already installed${NC}"
fi

# Install direnv
if ! command -v direnv &>/dev/null; then
  echo -e "${YELLOW}Installing direnv...${NC}"
  curl -sfL https://direnv.net/install.sh | bash
else
  echo -e "${GREEN}✓ direnv is already installed${NC}"
fi

# Install starship prompt
if ! command -v starship &>/dev/null; then
  echo -e "${YELLOW}Installing Starship prompt...${NC}"
  curl -sS https://starship.rs/install.sh | sh -s -- -y
else
  echo -e "${GREEN}✓ Starship is already installed${NC}"
fi

# Install Nerd Fonts
echo -e "${BLUE}Installing Nerd Fonts...${NC}"

# Create fonts directory
fonts_dir="$HOME/.local/share/fonts"
mkdir -p "$fonts_dir"

# Function to install a Nerd Font
install_nerd_font() {
  local font_name="$1"
  local font_url="$2"
  
  if ls "$fonts_dir"/*"$font_name"* >/dev/null 2>&1; then
    echo -e "${GREEN}✓ $font_name is already installed${NC}"
  else
    echo -e "${YELLOW}Installing $font_name...${NC}"
    # Download and extract font
    local temp_dir=$(mktemp -d)
    wget -q "$font_url" -O "$temp_dir/${font_name}.zip"
    unzip -q "$temp_dir/${font_name}.zip" -d "$temp_dir/${font_name}/" 2>/dev/null || true
    # Copy font files to fonts directory
    find "$temp_dir/${font_name}/" -name "*.ttf" -o -name "*.otf" | while read -r font; do
      cp "$font" "$fonts_dir/"
    done
    rm -rf "$temp_dir"
    echo -e "${GREEN}✓ $font_name installed${NC}"
  fi
}

# Install popular Nerd Fonts
echo -e "${BLUE}Downloading and installing Nerd Fonts...${NC}"

# JetBrains Mono
install_nerd_font "JetBrainsMono" \
  "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip"

# Fira Code
install_nerd_font "FiraCode" \
  "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip"

# Hack
install_nerd_font "Hack" \
  "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Hack.zip"

# Meslo
install_nerd_font "Meslo" \
  "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Meslo.zip"

# Refresh font cache
fc-cache -fv >/dev/null 2>&1

echo -e "${GREEN}✓ Nerd Fonts installation complete${NC}"

# Install Zsh plugins
echo -e "${BLUE}Installing Zsh plugins...${NC}"

# Clone plugins if not already present
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# zsh-autosuggestions
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  echo -e "${YELLOW}Installing zsh-autosuggestions...${NC}"
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
  echo -e "${GREEN}✓ zsh-autosuggestions is already installed${NC}"
fi

# zsh-syntax-highlighting
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
  echo -e "${YELLOW}Installing zsh-syntax-highlighting...${NC}"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
  echo -e "${GREEN}✓ zsh-syntax-highlighting is already installed${NC}"
fi

# zsh-completions
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]]; then
  echo -e "${YELLOW}Installing zsh-completions...${NC}"
  git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
else
  echo -e "${GREEN}✓ zsh-completions is already installed${NC}"
fi

# fast-syntax-highlighting
if [[ ! -d "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" ]]; then
  echo -e "${YELLOW}Installing fast-syntax-highlighting...${NC}"
  git clone https://github.com/zdharma-continuum/fast-syntax-highlighting "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"
else
  echo -e "${GREEN}✓ fast-syntax-highlighting is already installed${NC}"
fi

# zsh-history-substring-search
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-history-substring-search" ]]; then
  echo -e "${YELLOW}Installing zsh-history-substring-search...${NC}"
  git clone https://github.com/zsh-users/zsh-history-substring-search "$ZSH_CUSTOM/plugins/zsh-history-substring-search"
else
  echo -e "${GREEN}✓ zsh-history-substring-search is already installed${NC}"
fi

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

# Install vim-plug for Neovim
if [[ ! -f "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim" ]]; then
  echo -e "${YELLOW}Installing vim-plug for Neovim...${NC}"
  sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
           https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
fi

# Install TPM (Tmux Plugin Manager)
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  echo -e "${YELLOW}Installing TPM (Tmux Plugin Manager)...${NC}"
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
  echo -e "${GREEN}✓ TPM is already installed${NC}"
fi

# Backup existing .zshrc if it exists
if [[ -f ~/.zshrc && ! -f ~/.zshrc.backup ]]; then
  echo -e "${YELLOW}Backing up existing .zshrc...${NC}"
  cp ~/.zshrc ~/.zshrc.backup
fi

# Source the new PATH additions
source ~/.profile 2>/dev/null || true

echo
echo -e "${GREEN}╭─────────────────────────────────────────────────────────────────────────────╮${NC}"
echo -e "${GREEN}│                          Setup Complete! 🎉                                   │${NC}"
echo -e "${GREEN}╰─────────────────────────────────────────────────────────────────────────────╯${NC}"
echo
echo -e "${BLUE}Next steps:${NC}"
echo -e "1. Logout and login again (or reboot) to apply shell changes"
echo -e "2. Copy configuration files: ${YELLOW}cp zshrc ~/.zshrc && cp tmux.conf ~/.tmux.conf && cp p10k.zsh ~/.p10k.zsh && cp gitconfig ~/.gitconfig${NC}"
echo -e "3. Copy application configs: ${YELLOW}cp -r configs/* ~/.config/${NC}"
echo -e "4. If using SSH, set your terminal font to a Nerd Font (JetBrainsMono Nerd Font recommended)"
echo -e "5. For tmux: ${YELLOW}tmux source ~/.tmux.conf${NC} then press prefix + I to install plugins"
echo -e "6. For Powerlevel10k configuration: ${YELLOW}p10k configure${NC}"
echo
echo -e "${GREEN}Enjoy your awesome Ubuntu terminal! 🚀${NC}"