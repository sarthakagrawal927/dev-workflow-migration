#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
ONLY_INSTALL=0
ONLY_RESTORE=0
FORCE=0
BACKUP=1
INSTALL_ARGS=()
RESTORE_ARGS=()
RESTORE_ITEMS=()

usage() {
  cat <<'USAGE'
Usage: bash ./scripts/setup-dev-machine.sh [options]

Install selected tooling and restore reviewed config into the right places under $HOME.
By default this runs both steps:
  1. bootstrap install
  2. restore shell and git config

Install options:
  --with-shell
  --with-js
  --with-k8s
  --with-db
  --with-mobile
  --with-ai
  --with-deploy
  --with-gui
  --with-infra
  --with-most
  --no-codex

Restore options:
  --restore ITEM   Restore one item; repeatable
                   Items: shell, git, all
  --force          Overwrite existing files during restore
  --no-backup      Do not create timestamped backups during restore

General options:
  --dry-run        Print actions without making changes
  --only-install   Skip config restore
  --only-restore   Skip tool installation
  -h, --help       Show this help
USAGE
}

run_step() {
  printf '\n==> %s\n' "$1"
  shift
  "$@"
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run)
        DRY_RUN=1
        INSTALL_ARGS+=("$1")
        RESTORE_ARGS+=("$1")
        ;;
      --with-shell|--with-js|--with-k8s|--with-db|--with-mobile|--with-ai|--with-deploy|--with-gui|--with-infra|--with-most|--no-codex)
        INSTALL_ARGS+=("$1")
        ;;
      --restore)
        shift
        if [[ $# -eq 0 ]]; then
          printf 'Missing value for --restore\n' >&2
          exit 2
        fi
        RESTORE_ITEMS+=("$1")
        ;;
      --force)
        FORCE=1
        RESTORE_ARGS+=("$1")
        ;;
      --no-backup)
        BACKUP=0
        RESTORE_ARGS+=("$1")
        ;;
      --only-install)
        ONLY_INSTALL=1
        ;;
      --only-restore)
        ONLY_RESTORE=1
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        printf 'Unknown option: %s\n' "$1" >&2
        exit 2
        ;;
    esac
    shift
  done

  if [[ "$ONLY_INSTALL" == "1" && "$ONLY_RESTORE" == "1" ]]; then
    printf 'Choose at most one of --only-install or --only-restore\n' >&2
    exit 2
  fi

  if [[ "${#RESTORE_ITEMS[@]}" -eq 0 ]]; then
    RESTORE_ITEMS=(shell git)
  fi

  if [[ "$ONLY_RESTORE" != "1" ]]; then
    run_step "Installing tools" bash ./scripts/bootstrap-dev-machine.sh "${INSTALL_ARGS[@]}"
  fi

  if [[ "$ONLY_INSTALL" != "1" ]]; then
    if [[ "$FORCE" == "0" && "$BACKUP" == "1" ]]; then
      :
    fi
    run_step "Restoring config" bash ./scripts/restore-configs.sh "${RESTORE_ARGS[@]}" "${RESTORE_ITEMS[@]}"
  fi
}

main "$@"
