# Node.js Scripts 🟢

This folder contains small utility scripts to install Node.js and scaffold simple API projects (JavaScript and TypeScript). All scripts include confirmations and optional non-interactive mode where applicable.

Scripts:
- `nodejs_setup.sh` — System-wide Node.js installation (installs to /usr/local). Use `sudo`.
- `nodejs_nvm_setup.sh` — Install `nvm` and Node.js (recommended for per-user installs).
- `nodejs_api_setup.sh` — Scaffold a minimal JavaScript (Express) API project with common structure and scripts.
- `nodejs_api_ts_setup.sh` — Scaffold a minimal TypeScript (Express + ts-node) API project with TypeScript configuration.

Logging and safety
- Most scripts write a timestamped log to `~/.<script>_setup.log` by default. Use `-l/--logfile` (where implemented) to change the log file.
- Confirmations are shown for major actions; use `-y/--yes` to run non-interactively and accept the defaults.

If you'd like, I can add a `--template` option for the scaffolding scripts to select between multiple starters (e.g., with JWT auth, database, or simple health endpoint). Reply with which templates you want and I can implement them.
