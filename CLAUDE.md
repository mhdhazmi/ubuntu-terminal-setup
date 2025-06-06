# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Ubuntu terminal setup project that automates the installation and configuration of a modern terminal environment on Ubuntu systems (particularly optimized for Digital Ocean droplets and Ubuntu Server installations). It's adapted from a macOS terminal setup to work seamlessly on Ubuntu/Debian-based systems.

## Architecture

The project follows the same structure as the macOS version but with Ubuntu-specific adaptations:

- **Main installer**: `setup_terminal.sh` - orchestrates tool installation using apt, cargo, pip, and direct downloads
- **Config files**: Root-level dotfiles ready for copying to home directory
- **Application configs**: `configs/` directory with structured configurations

### Key Differences from macOS Version

1. **Package Management**: Uses apt, cargo, pip, and direct GitHub releases instead of Homebrew
2. **System Tools**: Includes systemd aliases and Ubuntu-specific utilities
3. **Font Paths**: Installs to `~/.local/share/fonts` instead of `~/Library/Fonts`
4. **Tool Installation**: Many tools require building from source via Rust/Cargo
5. **Path Management**: Uses `~/.profile` for PATH additions

## Commands

### Installation and Setup
```bash
# Full installation
chmod +x setup_terminal.sh
./setup_terminal.sh

# Copy configurations
cp zshrc ~/.zshrc
cp tmux.conf ~/.tmux.conf
cp p10k.zsh ~/.p10k.zsh
cp gitconfig ~/.gitconfig
cp -r configs/* ~/.config/

# Apply changes
source ~/.profile
source ~/.zshrc
```

### Testing Installation
```bash
# Verify tool installations
command -v eza && eza --version
command -v bat && bat --version
command -v fd && fd --version
command -v rg && rg --version

# Check Rust/Cargo tools
ls ~/.cargo/bin/

# Check local binaries
ls ~/.local/bin/

# Verify fonts
fc-list | grep -i nerd
```

### System Management (Ubuntu-specific)
```bash
# Service management
systemctl status <service>
sudo systemctl restart <service>

# Package management
sudo apt update && sudo apt upgrade
apt search <package>
apt show <package>
```

## Installation Architecture

### Tool Installation Methods

1. **APT Packages**: Core system tools and dependencies
   ```bash
   apt_tools=(git neovim tmux htop tree jq ...)
   ```

2. **Cargo/Rust Tools**: Modern CLI replacements
   ```bash
   install_cargo_tool "eza"
   install_cargo_tool "bat"
   install_cargo_tool "fd" "fd-find"
   ```

3. **GitHub Releases**: Pre-built binaries
   ```bash
   install_github_release "fzf" "junegunn/fzf"
   install_github_release "lazygit" "jesseduffield/lazygit"
   ```

4. **Python Tools**: Via pip
   ```bash
   python3 -m pip install --user httpie tldr thefuck
   ```

### Helper Functions

The script includes two key installation functions:

- `install_cargo_tool()`: Installs Rust-based tools via cargo
- `install_github_release()`: Downloads and installs pre-built binaries from GitHub

Both functions check for existing installations to make the script idempotent.

## Configuration Details

### Zsh Configuration Changes
- Removed macOS-specific plugins (brew, macos)
- Added Ubuntu-specific plugins (ubuntu, systemd)
- Updated PATH for Linux standards
- Modified aliases for apt instead of brew
- Changed network utility commands for Linux

### Font Management
- Fonts installed to `~/.local/share/fonts`
- Uses `fc-cache -fv` to refresh font cache
- Downloads same Nerd Font versions as macOS setup

### Service Integration
- Includes systemctl aliases for service management
- Supports both system and user services
- Integration with direnv for environment management

## Development Workflow

### Adding New Tools

1. **For APT packages**: Add to `apt_tools` array
2. **For Cargo tools**: Use `install_cargo_tool` function
3. **For GitHub releases**: Use `install_github_release` function
4. **For Python tools**: Add pip install command

### Updating Configurations

When modifying for Ubuntu:
- Test on fresh Ubuntu installation
- Ensure compatibility with Ubuntu 20.04 LTS and newer
- Consider headless server environments (no GUI)
- Account for SSH-only access scenarios

## Common Operations

### Troubleshooting Installation

```bash
# Check if running on Ubuntu
lsb_release -a

# Verify package installations
dpkg -l | grep <package>

# Check cargo installations
cargo install --list

# Verify PATH
echo $PATH | tr ':' '\n'

# Check for missing dependencies
sudo apt install -f
```

### Manual Tool Installation

If automatic installation fails:

```bash
# Cargo tools
cargo install <tool-name>

# From GitHub releases
wget <release-url>
tar -xzf <archive>
sudo mv <binary> /usr/local/bin/

# Python tools
python3 -m pip install --user <tool>
```

### SSH-Specific Considerations

For Digital Ocean droplets:
- Fonts only display correctly if SSH client uses Nerd Fonts
- Some features (like icons) require terminal emulator support
- Consider using tmux for persistent sessions

## Maintenance

### Regular Updates
```bash
# System updates
sudo apt update && sudo apt upgrade

# Rust toolchain
rustup update

# Cargo tools
cargo install-update -a  # requires cargo-update

# Oh My Zsh
omz update
```

### Backup Configurations
```bash
# Before modifications
cp ~/.zshrc ~/.zshrc.backup
cp ~/.tmux.conf ~/.tmux.conf.backup
```

This Ubuntu adaptation maintains the same user experience as the macOS version while properly handling Linux-specific requirements and package management systems.