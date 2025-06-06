# ╭─────────────────────────────────────────────────────────────────────────────╮
# │                                 ZSH Configuration                               │
# ╰─────────────────────────────────────────────────────────────────────────────╯

# ─── Oh My Zsh Installation Check ───────────────────────────────────────────────
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "Oh My Zsh not found. Install it with:"
    echo 'sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
fi

# ─── Instant Prompt for Powerlevel10k ───────────────────────────────────────────
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ─── Oh My Zsh Configuration ────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins (removed macOS-specific plugins)
plugins=(
    git
    docker
    docker-compose
    kubectl
    terraform
    aws
    python
    pip
    npm
    node
    ubuntu
    systemd
    z
    fzf
    history
    command-not-found
    colored-man-pages
    extract
    sudo
    web-search
    jsontools
    encode64
    urltools
    copypath
    copybuffer
    dirhistory
    history-substring-search
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    fast-syntax-highlighting
)

# Oh My Zsh settings
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
HIST_STAMPS="yyyy-mm-dd"

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# ─── Environment Variables ──────────────────────────────────────────────────────
# PATH additions
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="/usr/local/go/bin:$PATH"
export PATH="$HOME/.poetry/bin:$PATH"

# Editor
export EDITOR='nvim'
export VISUAL='nvim'

# Language settings
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Man pages with colors
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

# FZF settings
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS="
--height 40%
--layout=reverse
--border
--preview 'bat --style=numbers --color=always --line-range :500 {}'
--preview-window=right:50%:wrap
--bind='ctrl-/:toggle-preview'
--bind='ctrl-u:preview-page-up'
--bind='ctrl-d:preview-page-down'
"

# ─── History Configuration ──────────────────────────────────────────────────────
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY

# ─── Zsh Options ────────────────────────────────────────────────────────────────
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_MINUS
setopt CDABLE_VARS
setopt EXTENDED_GLOB
setopt INTERACTIVE_COMMENTS
setopt PROMPT_SUBST

# ─── Completion System ──────────────────────────────────────────────────────────
autoload -Uz compinit && compinit
autoload -Uz bashcompinit && bashcompinit

# Completion options
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*' rehash true
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Better completion formatting
zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:corrections' format '%F{yellow}-- %d (errors: %e) --%f'
zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'

# ─── Key Bindings ───────────────────────────────────────────────────────────────
bindkey -e  # Emacs key bindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[3~' delete-char
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# ─── Modern CLI Tool Aliases ────────────────────────────────────────────────────
# Better ls with eza
if command -v eza &> /dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -l --icons --git --group-directories-first'
    alias la='eza -la --icons --git --group-directories-first'
    alias lt='eza -T --icons --git-ignore --level=2'
    alias tree='eza -T --icons --git-ignore'
else
    alias ls='ls --color=auto'
    alias ll='ls -alF'
    alias la='ls -A'
fi

# Better cat with bat
if command -v bat &> /dev/null; then
    alias cat='bat --style=plain'
    alias catn='bat --style=numbers'
fi

# Better find with fd
if command -v fd &> /dev/null; then
    alias find='fd'
fi

# Better grep with ripgrep
if command -v rg &> /dev/null; then
    alias grep='rg'
fi

# Better cd with zoxide
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
    alias cd='z'
fi

# Better top with btop
if command -v btop &> /dev/null; then
    alias top='btop'
    alias htop='btop'
fi

# Better du with dust
if command -v dust &> /dev/null; then
    alias du='dust'
fi

# Better ps with procs
if command -v procs &> /dev/null; then
    alias ps='procs'
fi

# Better df with duf
if command -v duf &> /dev/null; then
    alias df='duf'
fi

# ─── Git Aliases ────────────────────────────────────────────────────────────────
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add -p'
alias gc='git commit -v'
alias gc!='git commit -v --amend'
alias gcm='git commit -m'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch -v'
alias gba='git branch -a -v'
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gbl='git blame -b -w'
alias gbs='git bisect'
alias gbss='git bisect start'
alias gbsb='git bisect bad'
alias gbsg='git bisect good'
alias gbsr='git bisect reset'
alias gd='git diff'
alias gds='git diff --staged'
alias gdt='git diff-tree --no-commit-id --name-only -r'
alias gf='git fetch'
alias gfo='git fetch origin'
alias gl='git pull'
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
alias glogp='git log --stat -p'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpo='git push origin'
alias gpom='git push origin main'
alias gr='git remote -v'
alias gra='git remote add'
alias grb='git rebase'
alias grbi='git rebase -i'
alias grbc='git rebase --continue'
alias grba='git rebase --abort'
alias grbs='git rebase --skip'
alias grhh='git reset --hard HEAD'
alias grs='git restore'
alias grss='git restore --staged'
alias gsh='git show'
alias gss='git stash save'
alias gsp='git stash pop'
alias gsl='git stash list'
alias gsa='git stash apply'
alias gsd='git stash drop'
alias gsc='git stash clear'
alias gwch='git whatchanged -p --abbrev-commit --pretty=medium'
alias lg='lazygit'

# ─── Docker Aliases ─────────────────────────────────────────────────────────────
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dl='docker logs'
alias dlf='docker logs -f'
alias drm='docker rm'
alias drmi='docker rmi'
alias drmf='docker rm -f'
alias dstop='docker stop $(docker ps -q)'
alias drma='docker rm $(docker ps -aq)'
alias drmia='docker rmi $(docker images -q)'
alias dprune='docker system prune -a'
alias dvol='docker volume ls'
alias dnet='docker network ls'

# ─── Kubernetes Aliases ─────────────────────────────────────────────────────────
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kaf='kubectl apply -f'
alias kdel='kubectl delete'
alias klog='kubectl logs'
alias kex='kubectl exec -it'
alias kctx='kubectl config get-contexts'
alias kuse='kubectl config use-context'
alias kns='kubectl config set-context --current --namespace'

# ─── Python/AI/ML Aliases ───────────────────────────────────────────────────────
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv'
alias activate='source venv/bin/activate'
alias jlab='jupyter lab'
alias jnb='jupyter notebook'
alias conda-activate='conda activate'
alias conda-deactivate='conda deactivate'
alias conda-list='conda env list'

# ─── Node/NPM Aliases ───────────────────────────────────────────────────────────
alias ni='npm install'
alias nis='npm install --save'
alias nid='npm install --save-dev'
alias nig='npm install -g'
alias nr='npm run'
alias nrs='npm run start'
alias nrd='npm run dev'
alias nrt='npm run test'
alias nrb='npm run build'
alias nrw='npm run watch'

# ─── Ubuntu/System Aliases ──────────────────────────────────────────────────────
alias c='clear'
alias h='history'
alias reload='source ~/.zshrc && echo "✅ Zsh configuration reloaded!"'
alias zshconfig='${EDITOR:-nvim} ~/.zshrc'
alias ohmyzsh='${EDITOR:-nvim} ~/.oh-my-zsh'
alias update='sudo apt update && sudo apt upgrade'
alias install='sudo apt install'
alias search='apt search'
alias services='systemctl list-units --type=service'
alias service-status='systemctl status'
alias service-start='sudo systemctl start'
alias service-stop='sudo systemctl stop'
alias service-restart='sudo systemctl restart'
alias service-enable='sudo systemctl enable'
alias service-disable='sudo systemctl disable'

# ─── Navigation Aliases ─────────────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'
alias home='cd ~'
alias docs='cd ~/Documents'
alias proj='cd ~/Projects'
alias down='cd ~/Downloads'
alias desk='cd ~/Desktop'
alias code='cd ~/code'

# ─── Network Utilities ──────────────────────────────────────────────────────────
alias myip='curl -s ifconfig.me'
alias localip='hostname -I | awk "{print \$1}"'
alias ports='sudo lsof -i -P -n | grep LISTEN'
alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -'

# ─── File Operations ────────────────────────────────────────────────────────────
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias mkdir='mkdir -pv'
alias rmdir='rmdir -v'
alias ln='ln -v'
alias chmod='chmod -v'
alias chown='chown -v'

# ─── Useful Functions ───────────────────────────────────────────────────────────
# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract archives
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar e "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# ─── IDE-like Features ──────────────────────────────────────────────────────────
# Quick project navigation
alias pj='cd ~/projects'
alias dot='cd ~/.config'

# File exploration
alias lf='lf'
alias br='broot'
alias exp='eza -T --icons --git-ignore --level=3'

# Code search and navigation
alias rgi='rg -i'  # Case insensitive ripgrep
alias rgf='rg --files | rg'  # Search filenames
alias ast='ast-grep'

# Git UI tools
alias tig='tig'
alias gitu='gitui'
alias glog='glow'

# Development workflow
alias dev='tmux new-session -s dev || tmux attach -t dev'
alias ide='nvim'
alias watch='watchexec'
alias bench='hyperfine'
alias lines='tokei'

# Quick file preview
alias preview='bat --style=numbers --color=always'
alias mdview='glow'

# Session management
alias tn='tmux new-session -s'
alias ta='tmux attach -t'
alias tl='tmux list-sessions'
alias tk='tmux kill-session -t'
alias mux='tmuxinator'

# LSP and formatting
alias fmt='prettier --write'
alias fmtall='prettier --write "**/*.{js,jsx,ts,tsx,json,css,scss,md}"'

# Project templates
alias new='cookiecutter'

# Quick edit configs
alias ezsh='nvim ~/.zshrc'
alias envim='nvim ~/.config/nvim/init.lua'
alias etmux='nvim ~/.tmux.conf'

# Functions for IDE-like experience
# Create and enter directory
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Quick project setup
project() {
    mkcd "$1"
    git init
    echo "# $1" > README.md
    echo "node_modules/" > .gitignore
    nvim README.md
}

# Live grep with preview
rgp() {
    rg --color=always --line-number --no-heading "$@" |
      fzf --ansi \
          --color "hl:-1:underline,hl+:-1:underline:reverse" \
          --delimiter : \
          --preview 'bat --color=always {1} --highlight-line {2}' \
          --preview-window 'up,60%,border-bottom,+{2}+3/3,~3'
}

# Interactive file search with preview
fzfp() {
    fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'
}

# Quick server for current directory
serve() {
    python3 -m http.server ${1:-8000}
}

# Search for text in files
search() {
    if command -v rg &> /dev/null; then
        rg --hidden --follow --smart-case "$@"
    else
        grep -r "$@" .
    fi
}

# Quick backup
backup() {
    cp -r "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
}

# Weather
weather() {
    curl -s "wttr.in/${1:-}"
}

# Generate .gitignore
gitignore() {
    curl -sL "https://www.toptal.com/developers/gitignore/api/$@"
}

# Quick HTTP server
serve() {
    local port="${1:-8000}"
    python3 -m http.server "$port"
}

# Show path in readable format
path() {
    echo -e "${PATH//:/\\n}"
}

# Calculator
calc() {
    echo "scale=2; $*" | bc -l
}

# Create QR code
qr() {
    if command -v qrencode &> /dev/null; then
        qrencode -t ansiutf8 "$1"
    else
        echo "qrencode not installed. Install with: sudo apt install qrencode"
    fi
}

# Kill process by port
killport() {
    sudo kill -9 $(sudo lsof -t -i:"$1")
}

# Show directory size
dirsize() {
    du -sh "${1:-.}" 2>/dev/null | cut -f1
}

# Show top 10 largest files/directories
top10() {
    du -a "${1:-.}" 2>/dev/null | sort -n -r | head -n 10
}

# Git commit browser
fshow() {
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
        --bind "ctrl-m:execute:
            (grep -o '[a-f0-9]\{7\}' | head -1 |
            xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
            {}
    FZF-EOF"
}

# ─── Load Additional Tools ──────────────────────────────────────────────────────
# FZF
if [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
    source /usr/share/doc/fzf/examples/key-bindings.zsh
fi
if [ -f /usr/share/doc/fzf/examples/completion.zsh ]; then
    source /usr/share/doc/fzf/examples/completion.zsh
fi

# Zoxide
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# thefuck
if command -v thefuck &> /dev/null; then
    eval "$(thefuck --alias)"
fi

# direnv
if command -v direnv &> /dev/null; then
    eval "$(direnv hook zsh)"
fi

# ─── Local Configuration ────────────────────────────────────────────────────────
# Source local configuration if it exists
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# ─── Final Setup ────────────────────────────────────────────────────────────────
# Set terminal title
precmd() {
    echo -ne "\033]0;${PWD##*/}\007"
}

# Welcome message
if command -v fastfetch &> /dev/null; then
    fastfetch
elif command -v neofetch &> /dev/null; then
    neofetch
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh