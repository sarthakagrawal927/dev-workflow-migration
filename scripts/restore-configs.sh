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
  codex      Restore Codex prompts/skills/agents/rules/hooks
  aws        Restore AWS config only
  gcloud     Restore gcloud named configs only
  azure      Restore Azure CLI config only
  cloud      Restore aws, gcloud, and azure together
  all        Restore shell, git, codex, and cloud

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

restore_codex() {
  local root="$1"
  log "Restoring Codex config"
  run mkdir -p "$HOME/.codex"
  copy_file "$root/codex/AGENTS.md" "$HOME/.codex/AGENTS.md"
  copy_file "$root/codex/hooks.json" "$HOME/.codex/hooks.json"
  copy_dir "$root/codex/agents" "$HOME/.codex/agents"
  copy_dir "$root/codex/prompts" "$HOME/.codex/prompts"
  copy_dir "$root/codex/rules" "$HOME/.codex/rules"
  copy_dir "$root/codex/skills" "$HOME/.codex/skills"
}

restore_aws() {
  local root="$1"
  log "Restoring AWS config"
  copy_file "$root/cloud/aws/config" "$HOME/.aws/config"
}

restore_gcloud() {
  local root="$1"
  log "Restoring gcloud config"
  copy_file "$root/cloud/gcloud/active_config" "$HOME/.config/gcloud/active_config"
  copy_dir "$root/cloud/gcloud/configurations" "$HOME/.config/gcloud/configurations"
  copy_dir "$root/cloud/gcloud/emulators" "$HOME/.config/gcloud/emulators"
}

restore_azure() {
  local root="$1"
  log "Restoring Azure config"
  copy_file "$root/cloud/azure/config" "$HOME/.azure/config"
  copy_file "$root/cloud/azure/clouds.config" "$HOME/.azure/clouds.config"
  copy_file "$root/cloud/azure/az.json" "$HOME/.azure/az.json"
}

run_selection() {
  local root="$1"
  local item="$2"
  case "$item" in
    shell) restore_shell "$root" ;;
    git) restore_git "$root" ;;
    codex) restore_codex "$root" ;;
    aws) restore_aws "$root" ;;
    gcloud) restore_gcloud "$root" ;;
    azure) restore_azure "$root" ;;
    cloud)
      restore_aws "$root"
      restore_gcloud "$root"
      restore_azure "$root"
      ;;
    all)
      restore_shell "$root"
      restore_git "$root"
      restore_codex "$root"
      restore_aws "$root"
      restore_gcloud "$root"
      restore_azure "$root"
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
    SELECTIONS=(shell git codex cloud)
  fi

  local root
  root="$(repo_root)"

  for item in "${SELECTIONS[@]}"; do
    run_selection "$root" "$item"
  done

  cat <<'NEXT'
Next:
  1. Open a new shell after restoring shell config.
  2. Re-auth providers manually:
     gh auth login
     aws sso login --profile <profile>
     gcloud auth login
     az login
NEXT
}

main "$@"
