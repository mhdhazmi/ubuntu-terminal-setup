# Ubuntu Terminal Setup - Memory Optimized

This repository contains all the necessary files to set up a modern, feature-rich terminal environment on Ubuntu (tested on Ubuntu 22.04 LTS and newer).

## Memory Optimization for Small Droplets

The setup script now includes **automatic memory optimization** specifically designed for small Digital Ocean droplets and low-memory Ubuntu systems. The script automatically detects available memory and optimizes installation accordingly.

### Memory Optimization Features

When memory is detected to be less than 1GB, the script automatically:

- **Creates temporary swap file** (2GB) for compilation if no swap exists
- **Uses pre-built binaries** instead of compiling from source for major tools (bat, fd, ripgrep, etc.)
- **Limits cargo compilation** to single-threaded for memory-constrained systems
- **Installs minimal font set** (JetBrains Mono only) instead of multiple fonts
- **Installs essential plugins only** to reduce overhead
- **Provides interactive swap cleanup** after installation

## What's Included

- `setup_terminal.sh` - Memory-optimized installation script that adapts to system resources
- `zshrc` - Zsh configuration with plugins and aliases optimized for Ubuntu
- `tmux.conf` - Tmux configuration
- `p10k.zsh` - Powerlevel10k theme configuration
- `gitconfig` - Git configuration
- `configs/` - Directory containing application-specific configs:
  - `alacritty/` - Alacritty terminal emulator config
  - `nvim/` - Neovim editor configuration (LazyVim)

## Quick Start

### For Digital Ocean Droplet or Fresh Ubuntu Installation (Automatic Memory Detection)

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd ubuntu-terminal-setup
   ```

2. Make the setup script executable and run it:
   ```bash
   chmod +x setup_terminal.sh
   ./setup_terminal.sh
   ```
   
   The script will automatically detect your system's available memory and apply optimizations for low-memory systems (< 1GB available RAM).

3. Copy configuration files to their proper locations:
   ```bash
   cp zshrc ~/.zshrc
   cp tmux.conf ~/.tmux.conf
   cp p10k.zsh ~/.p10k.zsh
   cp gitconfig ~/.gitconfig
   cp -r configs/* ~/.config/
   ```

4. Log out and log back in (or reboot) to ensure all changes take effect.

5. Configure Powerlevel10k theme:
   ```bash
   p10k configure
   ```

6. Install tmux plugins (inside tmux):
   ```bash
   tmux
   # Press Ctrl-a + I to install plugins
   ```

## Memory Optimization in Action

### Low Memory Systems (< 1GB available)
When the script detects low memory, you'll see:
- Memory detection: `Available memory: XXXMb`
- `Low memory detected. Enabling memory optimization...`
- `Creating 2GB swap file for compilation...` (if no swap exists)
- `Using pre-built binaries due to memory constraints...`
- Tools installed from .deb packages instead of cargo compilation
- Interactive prompt at end: `Swap file was created for compilation. Keep it? [y/N]:`

### Normal Memory Systems (≥ 1GB available)
The script runs with full feature installation:
- All modern CLI tools compiled from source via cargo
- Multiple Nerd Fonts installed
- All zsh plugins installed
- No temporary swap file needed

## What Gets Installed

The setup script installs a comprehensive set of modern CLI tools:

### Core Tools
- **Zsh** with Oh My Zsh framework
- **Neovim** (latest version)
- **Tmux** with TPM (Tmux Plugin Manager)
- **Git** (latest version)

### Modern CLI Replacements
- **eza** - Modern replacement for `ls` with icons
- **bat** - Better `cat` with syntax highlighting
- **fd** - Better `find`
- **ripgrep** - Better `grep`
- **zoxide** - Smarter `cd`
- **fzf** - Fuzzy finder
- **btop** - Better `top`/`htop`
- **dust** - Better `du`
- **procs** - Better `ps`
- **duf** - Better `df`

### Development Tools
- **Rust** toolchain (for building modern CLI tools)
- **Go** programming language
- **Node.js** and npm
- **Python3** and pip
- **Docker** (if not already installed)
- **GitHub CLI** (`gh`)
- **GitLab CLI** (`glab`)
- **lazygit** - Terminal UI for git
- **gitui** - Another terminal UI for git
- **delta** - Better git diff

### Utilities
- **httpie** - Better `curl`
- **tldr** - Simplified man pages
- **jq** - JSON processor
- **yq** - YAML processor
- **direnv** - Directory-specific environment variables
- **thefuck** - Correct previous commands
- **starship** - Cross-shell prompt (alternative to Powerlevel10k)
- **fastfetch** - System information tool
- **uv** - Fast Python package installer and resolver

### Fonts
- **JetBrainsMono Nerd Font** (always installed)
- **FiraCode Nerd Font** (high memory systems only)
- **Hack Nerd Font** (high memory systems only)
- **Meslo Nerd Font** (high memory systems only)

## Installation Methods by Memory Availability

### Low Memory Mode (< 1GB available)
- **Pre-built .deb packages**: bat, fd, ripgrep
- **Direct binary downloads**: fzf, delta, lazygit, duf
- **Single-threaded cargo**: zoxide, dust (essential tools only)
- **Minimal installation**: JetBrains Mono font only, essential plugins only

### Normal Memory Mode (≥ 1GB available)
- **Cargo compilation**: All modern CLI tools built from source
- **Full font suite**: All Nerd Fonts installed
- **Complete plugin set**: All zsh plugins and themes

## SSH Terminal Setup

If you're connecting via SSH, you'll need to configure your local terminal to use a Nerd Font:

### For Windows (Windows Terminal)
1. Download a Nerd Font from the setup (e.g., JetBrainsMono Nerd Font)
2. Install it on your Windows system
3. In Windows Terminal settings, set the font to "JetBrainsMono Nerd Font"

### For macOS (iTerm2/Terminal)
1. The fonts are installed in `~/.local/share/fonts` on the server
2. You need to install the same font on your local macOS
3. Set your terminal font to the Nerd Font

### For Linux Desktop
1. Copy fonts from the server: `scp -r user@server:~/.local/share/fonts/* ~/.local/share/fonts/`
2. Run `fc-cache -fv`
3. Set your terminal font to a Nerd Font

## Customization

### Zsh Configuration
The `zshrc` file includes:
- Optimized plugins for Ubuntu environment
- Aliases for modern CLI tools
- Ubuntu-specific aliases (apt, systemctl, etc.)
- Git, Docker, and Kubernetes shortcuts
- Useful functions for daily tasks

### Tmux Configuration
- Prefix key set to `Ctrl-a`
- Mouse support enabled
- Tokyo Night theme
- Vim-like navigation

### Neovim
Uses LazyVim configuration for a modern IDE-like experience.

## Differences from macOS Version

This Ubuntu version has been adapted with:
- **Memory optimization for small droplets** - automatic detection and optimization
- **Multiple installation strategies** - pre-built binaries vs compilation based on available memory
- **Temporary swap file management** - creates and optionally removes swap during installation
- Ubuntu-specific package management (apt instead of brew)
- Systemd service management aliases  
- Different font installation paths
- Ubuntu/Debian-specific tool installation methods
- Removed macOS-specific plugins and configurations

## Troubleshooting

### Memory and Performance Issues

#### Out of memory during installation
```bash
# Check available memory
free -h

# Create swap file manually if script fails
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

#### Cargo compilation fails with memory errors
```bash
# Configure cargo for low memory
mkdir -p ~/.cargo
cat > ~/.cargo/config.toml << EOF
[build]
jobs = 1

[profile.release]
codegen-units = 1
EOF
```

#### Installation taking too long on small droplets
The memory-optimized version typically completes in 10-15 minutes on a 1GB droplet compared to potentially hours or failures with the original script.

### Zsh not set as default shell
```bash
chsh -s $(which zsh)
```

### Fonts not showing correctly
- Ensure your SSH client terminal is using a Nerd Font
- For web-based terminals, font support may be limited

### Permission issues
```bash
# Fix permissions for local binaries
chmod -R 755 ~/.local/bin

# Fix font permissions
chmod -R 644 ~/.local/share/fonts/*
```

### Tool not found after installation
```bash
# Reload PATH
source ~/.profile
source ~/.zshrc

# Check if tool is in ~/.local/bin or ~/.cargo/bin
ls ~/.local/bin/
ls ~/.cargo/bin/
```

## Updating

To update installed tools:
```bash
# System packages
sudo apt update && sudo apt upgrade

# Rust tools
cargo install-update -a

# Python tools
pip install --upgrade httpie tldr thefuck

# Oh My Zsh
omz update
```

## License

This configuration is provided as-is for personal use.