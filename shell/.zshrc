# Enable Powerlevel10k instant prompt only for interactive TTY shells.
if [[ -o interactive ]] && [[ -t 1 ]] && [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # p10k handles the prompt
DISABLE_COMPFIX=true
DISABLE_UPDATE_PROMPT=true
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

export PATH="$HOME/.local/bin:$PATH"

# Powerlevel10k
if [[ -o interactive ]] && [[ -t 1 ]]; then
  source ~/powerlevel10k/powerlevel10k.zsh-theme
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
fi

# PATH
export PATH=/opt/homebrew/opt/ruby/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:$HOME/bin:$PATH

# Go
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# Android
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools

# Java
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-17.0.2.jdk/Contents/Home

# mise (manages runtime toolchains)
eval "$(mise activate zsh)"

# pnpm
export PNPM_HOME="/Users/sarthakagrawal/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# Bun
export BUN_INSTALL="/Users/sarthakagrawal/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "/Users/sarthakagrawal/.bun/_bun" ] && source "/Users/sarthakagrawal/.bun/_bun"

# Google Cloud SDK (via Homebrew)
export PATH=$PATH:/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin/

# Locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Modern tool aliases
alias ls="eza --icons --group-directories-first"
alias ll="eza -la --icons --group-directories-first --git"
alias lt="eza --tree --level=2 --icons"
alias cat="bat --paging=never"
alias find="fd"
alias du="dust"
alias lg="lazygit"

# Git
alias ga="git add ."
alias gc="git commit -m"
alias gs="git status"
alias gp="git push"
alias gch="git checkout"
alias gpl="git pull"
alias grebase="git stash && git rebase && git stash pop"
alias gcl="git clone"

# Project
alias p="pnpm"
alias ku="kubectl"
alias nrd="npm run dev"
alias pubsub="gcloud beta emulators pubsub start --project=spidrservices"
alias proddb="cd ~/Desktop/frontpage && ./cloud-sql-proxy spidrservices:asia-south1:cwdb-1-replica-1 -p 3312 --gcloud-auth"
alias pro="sh ~/Desktop/productivity/submodule/run.sh"

# NanoClaw (Andy)
alias andy-start="launchctl load ~/Library/LaunchAgents/com.nanoclaw.plist"
alias andy-stop="launchctl unload ~/Library/LaunchAgents/com.nanoclaw.plist"
alias andy-restart="launchctl kickstart -k gui/\$(id -u)/com.nanoclaw"
alias andy-logs="tail -f ~/Desktop/experiment/nanoclaw/logs/nanoclaw.log"
alias andy-status="launchctl list | grep nanoclaw"
alias andy-config="cd ~/Desktop/experiment/nanoclaw && claude"

# Claude Code profiles
claude-work() {
  CLAUDE_CONFIG_DIR="$HOME/.claude-work" command claude "$@"
}


# Functions
migrate_prisma() {
  parallel ::: 'kubectl exec -t deployment/ibkr-connector-deployment -- sh -c "cd .. && npx prisma migrate deploy"' 'kubectl exec -t deployment/user-backend-deployment -- sh -c "cd .. && npx prisma migrate deploy"'
}

# Automations
source ~/.zsh/automations.sh

# Modern CLI Tools
if [[ -o interactive ]] && [[ -t 1 ]]; then
  eval "$(fzf --zsh)"
fi
eval "$(zoxide init zsh)"
if [[ -o interactive ]] && [[ -t 1 ]]; then
  eval "$(atuin init zsh)"
fi
export PATH="$PATH:/Users/sarthakagrawal/.lmstudio/bin"
export PATH="/Users/sarthakagrawal/.antigravity/antigravity/bin:$PATH"
export PATH="$PATH:/Users/sarthakagrawal/.turso"
export PATH="/Users/sarthakagrawal/.codeium/windsurf/bin:$PATH"
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"
. "$HOME/.local/bin/env"
if [[ -o interactive ]] && [[ -t 1 ]] && (( ${+functions[p10k]} )); then
  p10k finalize
fi
# Credential exports omitted from migration bundle. Re-auth GitHub and Cloudflare on the new machine.
