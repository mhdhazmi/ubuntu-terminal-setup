# Neovim Clipboard Integration Guide for SSH

This guide explains how to set up clipboard synchronization between Neovim on your Digital Ocean droplet and your local machine.

## How It Works

1. **Basic Setup**: `set clipboard=unnamedplus` makes all yanks go to the system clipboard
2. **SSH Integration**: OSC52 escape sequences allow clipboard sync over SSH
3. **Fallback**: xclip/wl-clipboard for local terminal sessions

## Installation

The setup script automatically installs:
- `xclip` - For X11 systems
- `wl-clipboard` - For Wayland systems
- `nvim-osc52` plugin - For SSH clipboard sync

## Usage

### Default Behavior (with clipboard=unnamedplus)
- `y` - Yank to system clipboard
- `p` - Paste from system clipboard
- `dd` - Cut to system clipboard
- `x` - Delete to system clipboard

### Leader Key Mappings
- `<leader>y` - Explicitly yank to clipboard
- `<leader>p` - Explicitly paste from clipboard
- `<leader>d` - Delete without affecting clipboard

### Testing Clipboard
1. In Neovim: `<leader>cc` - Check clipboard status
2. Yank some text with `yy`
3. Try pasting in your local terminal with Cmd+V (macOS) or Ctrl+V

## Terminal Requirements

Your SSH client must support OSC52. Compatible terminals:
- **iTerm2** (macOS) - Enable in Preferences → General → Selection → "Applications in terminal may access clipboard"
- **Terminal.app** (macOS) - Works by default
- **Windows Terminal** - Works by default
- **Alacritty** - Add to config:
  ```yaml
  selection:
    save_to_clipboard: true
  ```
- **tmux** - Add to .tmux.conf:
  ```bash
  set -g set-clipboard on
  ```

## Troubleshooting

### Clipboard not working over SSH?

1. **Check terminal support**:
   ```vim
   :echo has('clipboard')
   ```

2. **Test OSC52**:
   ```vim
   :lua require('osc52').copy('test')
   ```
   Then try pasting locally

3. **Check SSH settings**:
   Some SSH configs disable clipboard. Ensure your SSH doesn't have:
   ```
   ForwardX11 no
   ```

4. **For tmux users**:
   Make sure tmux clipboard is enabled:
   ```bash
   tmux show-options -g | grep clipboard
   ```

### Alternative Solutions

If OSC52 doesn't work, you can use:

1. **SSH with X11 forwarding**:
   ```bash
   ssh -X user@droplet
   ```

2. **Manual clipboard commands**:
   ```vim
   :w !xclip -selection clipboard
   ```

3. **Use a clipboard manager**:
   Install `parcellite` or `clipman` on the server

## Best Practices

1. Use `<leader>d` when you don't want to pollute the clipboard
2. Use `"_` (black hole register) for deletions: `"_dd`
3. Use named registers for multiple clipboards: `"ayy` then `"ap`

## Configuration Location

The clipboard configuration is in:
- `/home/user/.config/nvim/lua/config/options.lua` - Main clipboard setting
- `/home/user/.config/nvim/lua/config/keymaps.lua` - Keybindings
- `/home/user/.config/nvim/lua/plugins/clipboard.lua` - OSC52 plugin config