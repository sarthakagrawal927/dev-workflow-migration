# Dev Workflow Migration

Sanitized development workflow bundle for setting up a new laptop deliberately.

## Included

- `shell/`: shell startup files from this machine.
- `git/`: global Git configuration and global ignore rules.
- `codex/skills/`: local Codex skills.
- `codex/prompts/`: local Codex role prompts.
- `codex/agents/`: local Codex agent definitions.
- `codex/rules/`: local Codex rules.
- `codex/AGENTS.md` and `codex/hooks.json`: portable Codex guidance and hook configuration.
- `cloud/aws/config`: AWS profile metadata only.
- `cloud/gcloud/`: gcloud named configurations and active config only.
- `cloud/azure/`: Azure CLI non-token configuration files only.

## Intentionally Excluded

- SSH private keys, public keys, known hosts, and SSH config.
- GitHub CLI `hosts.yml` and auth state.
- AWS credentials, SSO cache, and CLI cache.
- gcloud credential databases, access tokens, ADC files, legacy credentials, logs, and virtualenv.
- Azure MSAL token cache, session files, logs, telemetry, and profile/session state.
- Codex auth, sessions, logs, browser sessions, caches, temporary files, SQLite state, worktrees, history, and internal storage.
- Token-shaped examples in copied Codex reference files were redacted so the bundle passes `gitleaks`.

## New Machine Notes

Run the one-shot setup script to install the selected tooling and place reviewed config under `$HOME`:

```sh
bash ./scripts/setup-dev-machine.sh --dry-run
bash ./scripts/setup-dev-machine.sh
```

Default behavior:

- Installs the small default tool set: Homebrew, Git, GitHub CLI, `gitleaks`, `ripgrep`, Node, Codex CLI, AWS CLI, gcloud, and Azure CLI.
- Restores `shell`, `git`, `codex`, and `cloud` config into the right places under `$HOME`.

Re-auth manually:

```sh
gh auth login
aws sso login --profile <profile>
gcloud auth login
az login
```

Optional installs are explicit and documented in `INSTALL-MANIFEST.md`:

```sh
bash ./scripts/setup-dev-machine.sh --with-shell
bash ./scripts/setup-dev-machine.sh --with-js
bash ./scripts/setup-dev-machine.sh --with-k8s
bash ./scripts/setup-dev-machine.sh --with-db
bash ./scripts/setup-dev-machine.sh --with-mobile
bash ./scripts/setup-dev-machine.sh --with-ai
bash ./scripts/setup-dev-machine.sh --with-deploy
bash ./scripts/setup-dev-machine.sh --with-most
bash ./scripts/setup-dev-machine.sh --with-gui
bash ./scripts/setup-dev-machine.sh --with-infra
```

Restore-only and install-only modes:

```sh
bash ./scripts/setup-dev-machine.sh --only-install --with-most
bash ./scripts/setup-dev-machine.sh --only-restore --restore shell --restore git
```

For a new MacBook, this should work as long as network access is available and Xcode Command Line Tools can be installed when prompted.
