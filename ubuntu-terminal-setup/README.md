# Ubuntu Terminal Setup

This repository contains all the necessary files to set up a modern, feature-rich terminal environment on Ubuntu (tested on Ubuntu 22.04 LTS and newer).

## What's Included

- `setup_terminal.sh` - Main installation script that installs all tools and dependencies
- `zshrc` - Zsh configuration with plugins and aliases optimized for Ubuntu
- `tmux.conf` - Tmux configuration
- `p10k.zsh` - Powerlevel10k theme configuration
- `gitconfig` - Git configuration
- `configs/` - Directory containing application-specific configs:
  - `alacritty/` - Alacritty terminal emulator config
  - `nvim/` - Neovim editor configuration (LazyVim)

## Quick Start

### For Digital Ocean Droplet or Fresh Ubuntu Installation

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
- JetBrainsMono Nerd Font
- FiraCode Nerd Font
- Hack Nerd Font
- Meslo Nerd Font

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
- Ubuntu-specific package management (apt instead of brew)
- Systemd service management aliases
- Different font installation paths
- Ubuntu/Debian-specific tool installation methods
- Removed macOS-specific plugins and configurations

## Troubleshooting

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