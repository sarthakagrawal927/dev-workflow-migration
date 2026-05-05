#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
WITH_GUI=0
WITH_INFRA=0
WITH_SHELL_EXTRAS=0

CORE_BREW_PACKAGES=(
  git
  gh
  gitleaks
  ripgrep
  node
  awscli
  azure-cli
)

SHELL_EXTRA_BREW_PACKAGES=(
  bat
  eza
  fd
  fzf
  jq
  tmux
  zoxide
)

INFRA_BREW_PACKAGES=(
  kubectl
  kubectx
  helm
  k9s
  kind
  redis
  postgresql@17
)

INFRA_BREW_CASKS=(
  docker
)

CORE_BREW_CASKS=(
  google-cloud-sdk
)

GUI_BREW_CASKS=(
  ghostty
  iterm2
  rectangle
)

GLOBAL_NPM_PACKAGES=(
  @openai/codex
)

usage() {
  cat <<'USAGE'
Usage: scripts/bootstrap-dev-machine.sh [options]

Installs the minimal dev tools this migration bundle expects on a new Mac.
It does not copy credentials or authenticate cloud providers.

Options:
  --dry-run          Print commands without running them
  --with-shell       Also install shell comfort tools: bat, eza, fd, fzf, jq, tmux, zoxide
  --with-gui         Also install selected GUI apps: Ghostty, iTerm2, Rectangle
  --with-infra       Also install heavier local infra tools: Docker, kubectl, Redis, Postgres
  --no-codex         Skip global Codex CLI installation
  -h, --help         Show this help
USAGE
}

log() {
  printf '\n==> %s\n' "$*"
}

run() {
  if [[ "$DRY_RUN" == "1" ]]; then
    printf '+'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

have() {
  command -v "$1" >/dev/null 2>&1
}

ensure_macos() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    printf 'This bootstrap script is intended for macOS.\n' >&2
    exit 1
  fi
}

ensure_xcode_tools() {
  if xcode-select -p >/dev/null 2>&1; then
    return
  fi

  log "Installing Xcode Command Line Tools"
  run xcode-select --install
  printf 'Re-run this script after Xcode Command Line Tools finish installing.\n' >&2
  exit 1
}

ensure_homebrew() {
  if have brew; then
    return
  fi

  log "Installing Homebrew"
  run /bin/bash -c '$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)'
}

brew_shellenv() {
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

brew_install_packages() {
  local package
  for package in "$@"; do
    if brew list --formula "$package" >/dev/null 2>&1; then
      printf 'already installed: %s\n' "$package"
    else
      run brew install "$package"
    fi
  done
}

brew_install_casks() {
  local cask
  for cask in "$@"; do
    if brew list --cask "$cask" >/dev/null 2>&1; then
      printf 'already installed: %s\n' "$cask"
    else
      run brew install --cask "$cask"
    fi
  done
}

install_codex_cli() {
  if [[ "${WITH_CODEX:-1}" != "1" ]]; then
    return
  fi

  if ! have npm && [[ "$DRY_RUN" != "1" ]]; then
    printf 'npm is unavailable; skipping global npm packages.\n' >&2
    return
  fi

  log "Installing Codex CLI"
  local package
  for package in "${GLOBAL_NPM_PACKAGES[@]}"; do
    if npm list -g --depth=0 "$package" >/dev/null 2>&1; then
      printf 'already installed: %s\n' "$package"
    else
      run npm install -g "$package"
    fi
  done
}

print_next_steps() {
  cat <<'NEXT'

Next steps:
  1. Re-auth providers:
       gh auth login
       aws sso login --profile <profile>
       gcloud auth login
       az login
  2. Copy only reviewed files from shell/, git/, codex/, and cloud/.
NEXT
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run) DRY_RUN=1 ;;
      --with-shell) WITH_SHELL_EXTRAS=1 ;;
      --with-gui) WITH_GUI=1 ;;
      --with-infra) WITH_INFRA=1 ;;
      --no-codex) WITH_CODEX=0 ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        printf 'Unknown option: %s\n\n' "$1" >&2
        usage >&2
        exit 2
        ;;
    esac
    shift
  done

  ensure_macos
  ensure_xcode_tools
  ensure_homebrew
  brew_shellenv

  log "Updating Homebrew"
  run brew update

  log "Installing core CLI tools"
  brew_install_packages "${CORE_BREW_PACKAGES[@]}"

  log "Installing core casks"
  brew_install_casks "${CORE_BREW_CASKS[@]}"

  if [[ "$WITH_SHELL_EXTRAS" == "1" ]]; then
    log "Installing optional shell tools"
    brew_install_packages "${SHELL_EXTRA_BREW_PACKAGES[@]}"
  fi

  if [[ "$WITH_INFRA" == "1" ]]; then
    log "Installing optional infra tools"
    brew_install_packages "${INFRA_BREW_PACKAGES[@]}"
    brew_install_casks "${INFRA_BREW_CASKS[@]}"
  fi

  if [[ "$WITH_GUI" == "1" ]]; then
    log "Installing optional GUI apps"
    brew_install_casks "${GUI_BREW_CASKS[@]}"
  fi

  install_codex_cli
  print_next_steps
}

main "$@"
