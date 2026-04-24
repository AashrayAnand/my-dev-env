# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
 
# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# increase soft limit for open files
ulimit -n 65536


# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# ===========================================
# Git Aliases
# ===========================================
alias gits='git status'
alias gita='git add'
alias gitd='git diff'
alias commitm='git commit -m'
alias noverifycommitm='git commit --no-verify -m'
alias pull='git pull'
alias push='git push'
alias headpush='git push -u origin HEAD'
alias checkout='git checkout'
alias cpick='git cherry-pick'

# git log oneline with param for number of entries (default 5)
unalias glo 2>/dev/null
glo() {
  local n="${1:-5}"      # default to 5 if no arg given
  shift || true
  git log -n"$n" --oneline "$@"
}
# git log with param for number of entries (default 5)
unalias gl 2>/dev/null
gl() {
  local n="${1:-5}"      # default to 5 if no arg given
  shift || true
  git log -n"$n"
}

# ===========================================
# Docker Aliases
# ===========================================
alias dps="docker ps --format 'table {{.Names}} {{.Status}}     {{.Image}}'"

docker-nuke() {
  echo "🛑 Stopping all containers..."
  docker stop $(docker ps -q) 2>&1 || echo "No running containers"

  echo "🗑️  Removing all containers..."
  docker rm $(docker ps -aq) 2>&1 || echo "No containers to remove"

  echo "🖼️  Removing all images..."
  docker rmi $(docker images -q) 2>&1 || echo "No images to remove"

  echo "💾 Removing unused volumes..."
  docker volume prune -f

  echo "🌐 Removing unused networks..."
  docker network prune -f

  echo "✅ Docker cleanup complete!"
}
alias docker-clean='docker-nuke'

alias docker-ps='docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Size}}"'
alias docker-images='docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"'
alias docker-prune='docker system prune -f'
alias docker-prune-all='docker system prune -af'
alias docker-stop-all='docker stop $(docker ps -q) 2>/dev/null || echo "No running containers"'
alias docker-rm-all='docker rm $(docker ps -aq) 2>/dev/null || echo "No containers to remove"'
alias docker-rmi-dangling='docker rmi $(docker images -f "dangling=true" -q) 2>/dev/null || echo "No dangling images"'
alias docker-volumes-prune='docker volume prune -f'

# ===========================================
# Disk Usage Aliases
# ===========================================
alias du-here='du -sh * | sort -h'
alias du-top='du -h --max-depth=1 | sort -h'
alias du-big='du -h --max-depth=2 | sort -h | tail -20'
alias df-h='df -h'
alias disk='df -h | grep -E "^/dev|Filesystem"'
alias disk-usage='ncdu 2>/dev/null || du -sh * | sort -h'

# ===========================================
# Tools
# ===========================================
export PATH="$HOME/bin:$PATH"
alias gi="git-interfaces"
alias ggi="git-interfaces"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Cargo
. "$HOME/.cargo/env" 2>/dev/null
