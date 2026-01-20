# Vue Scripts 🖖

This folder contains a small helper to install Node and scaffold a Vue project:

- `vue_setup.sh` — Installs Node (system-wide or locally via `nvm`) and scaffolds a Vue project using `npm create vue@latest`.

Features:
- Interactive confirmations with `-y/--yes` to enable non-interactive runs.
- Timestamped logs (default at `~/.local/state/shell-scripts/vue_setup.log`) and `-l/--logfile` to override.
- `-V/--verbose` to show debug traces and command previews.
- `-L/--local` to install Node locally with `nvm` (no sudo).
- `-t/--template` to apply starter wiring for `tailwind`, `pinia` or `vuex` (installs packages and adds minimal example files/comments).

When `--template pinia` or `--template vuex` is used the script can attempt to automatically wire the store into your `src/main.js` or `src/main.ts` by adding the necessary import and `app.use(...)` call. The script will prompt before editing and creates a `.bak` backup of the original file; use `-y` to skip the prompt and accept automatic wiring.

If you'd like, I can expand templates to wire components/store usage more deeply, add CI examples, or provide a Docker devcontainer template — tell me which feature to add next.