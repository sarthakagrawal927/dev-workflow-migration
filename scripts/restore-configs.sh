#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
FORCE=0
BACKUP=1
SELECTIONS=()

usage() {
  cat <<'USAGE'
Usage: bash ./scripts/restore-configs.sh [options] [item...]

Restore reviewed config files from this repo into the current user's home directory.

Items:
  shell      Restore shell startup files
  git        Restore Git config files
  all        Restore shell and git

Options:
  --dry-run   Print actions without writing files
  --force     Overwrite existing files without skipping
  --no-backup Do not create .bak timestamped backups
  -h, --help  Show this help
USAGE
}

log() {
  printf '==> %s\n' "$*"
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

repo_root() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  cd "$script_dir/.." && pwd
}

backup_path() {
  printf '%s.bak.%s' "$1" "$(date +%Y%m%d%H%M%S)"
}

copy_file() {
  local src="$1"
  local dest="$2"
  if [[ ! -f "$src" ]]; then
    return
  fi

  run mkdir -p "$(dirname "$dest")"

  if [[ -e "$dest" && "$FORCE" != "1" ]]; then
    printf 'skip existing: %s\n' "$dest"
    return
  fi

  if [[ -e "$dest" && "$BACKUP" == "1" ]]; then
    run cp "$dest" "$(backup_path "$dest")"
  fi

  run cp "$src" "$dest"
}

copy_dir() {
  local src="$1"
  local dest="$2"
  if [[ ! -d "$src" ]]; then
    return
  fi

  run mkdir -p "$(dirname "$dest")"

  if [[ -e "$dest" && "$FORCE" != "1" ]]; then
    printf 'skip existing: %s\n' "$dest"
    return
  fi

  if [[ -e "$dest" && "$BACKUP" == "1" ]]; then
    run cp -R "$dest" "$(backup_path "$dest")"
  fi

  run rm -rf "$dest"
  run cp -R "$src" "$dest"
}

restore_shell() {
  local root="$1"
  log "Restoring shell config"
  copy_file "$root/shell/.bash_profile" "$HOME/.bash_profile"
  copy_file "$root/shell/.bashrc" "$HOME/.bashrc"
  copy_file "$root/shell/.zprofile" "$HOME/.zprofile"
  copy_file "$root/shell/.zshrc" "$HOME/.zshrc"
}

restore_git() {
  local root="$1"
  log "Restoring git config"
  copy_file "$root/git/gitconfig" "$HOME/.gitconfig"
  copy_file "$root/git/gitignore_global" "$HOME/.gitignore_global"
}

run_selection() {
  local root="$1"
  local item="$2"
  case "$item" in
    shell) restore_shell "$root" ;;
    git) restore_git "$root" ;;
    all)
      restore_shell "$root"
      restore_git "$root"
      ;;
    *)
      printf 'Unknown item: %s\n' "$item" >&2
      exit 2
      ;;
  esac
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run) DRY_RUN=1 ;;
      --force) FORCE=1 ;;
      --no-backup) BACKUP=0 ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        SELECTIONS+=("$1")
        ;;
    esac
    shift
  done

  if [[ "${#SELECTIONS[@]}" -eq 0 ]]; then
    SELECTIONS=(shell git)
  fi

  local root
  root="$(repo_root)"

  for item in "${SELECTIONS[@]}"; do
    run_selection "$root" "$item"
  done

  cat <<'NEXT'
Next:
  1. Open a new shell after restoring shell config.
  2. Re-auth tools you install separately as needed.
NEXT
}

main "$@"
