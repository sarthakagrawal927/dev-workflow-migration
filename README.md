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

Install tools deliberately, then copy back only the files you actually need. Re-auth with each provider instead of migrating auth state:

```sh
gh auth login
aws sso login --profile <profile>
gcloud auth login
az login
```

Before reusing anything, review the files in this repo and delete configs for workflows you no longer want.
