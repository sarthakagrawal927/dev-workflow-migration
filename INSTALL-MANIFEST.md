# Install Manifest

Use this as the decision record for what the bootstrap script installs.

## Default

Required for this repo to be useful on a fresh machine:

- `git`: clone and work with repos.
- `gh`: GitHub auth and repo access.
- `gitleaks`: verify this migration repo stays credential-clean.
- `ripgrep`: fast search used by Codex workflows.
- `node`: runtime for Codex CLI.
- `@openai/codex`: Codex CLI.
- `awscli`, `google-cloud-sdk`, `azure-cli`: keep the common cloud CLIs available without bundling provider config.

## User-Owned Homebrew Additions

Put any extra Homebrew packages you specifically want into `brew/Brewfile`.

- Keep the script defaults surgical.
- Use the Brewfile for your own must-have formulas, casks, and taps.
- The bootstrap script applies that file automatically with `brew bundle`.

## Optional Profiles

- `--with-shell`: shell quality-of-life tools already referenced by shell config.
- `--with-js`: JavaScript tools with usage evidence: `bun`, `pnpm`, `yarn`, `nodemon`, `tsx`.
- `--with-k8s`: Kubernetes tools with usage evidence: `kubectl`, `helm`, `k9s`, `kind`, `minikube`, `skaffold`, `argocd`.
- `--with-db`: database tools with usage evidence: Postgres, Redis, MySQL client, MongoDB tools.
- `--with-mobile`: mobile tools with usage evidence: Android command line tools, CocoaPods.
- `--with-ai`: AI/dev CLIs present on this machine: Claude Code, Gemini, opencode.
- `--with-deploy`: deploy/service CLIs present on this machine: Wrangler, Stripe, Render, Temporal, hcloud, ngrok.
- `--with-infra`: Docker only.
- `--with-gui`: selected UI tools: Ghostty, iTerm2, Rectangle.
- `--with-most`: all named profiles except GUI.

## Deliberately Not Installed

These exist on the old machine but are not surgical defaults:

- Media/image tools: `ffmpeg`, `graphicsmagick`, `vips`, `tesseract`.
- Benchmark/load tools: `hyperfine`, `k6`, `hurl`.
- Language stacks without clear week-one need: Java, Go, Rust/Zig, Ruby gems, Python scientific packages.
- One-off or niche CLIs: `stockfish`, `sniffnet`, `smartmontools`, `topgrade`, `witr`, `croc`, `dust`, `jj`, `nushell`.
- GUI apps unrelated to dev bootstrap: Discord, Spotify, IINA, Stats, Sloth, TrackWeight.

Add any of these only when current work needs them.
