# React & JavaScript Framework Scripts 🚀

This folder contains scripts to scaffold popular JS/TS projects:

- `nestjs_setup.sh` — Scaffold a NestJS project (includes optional dependency installation and example `.env`).
- `nextjs_setup.sh` — Scaffold a Next.js (App Router) project with TypeScript, Tailwind, ESLint, and initial dev tooling.
- `react_setup.sh` — Scaffold a Create React App project and install common dependencies/devtools.

Common features across scripts:

- CLI flags: `-n/--name` to set the project name, `-p/--path` to set parent path, `-l/--logfile` to override default log path, `-y/--yes` for non-interactive mode, `-V/--verbose` for extra console output, and `--dry-run` to preview changes.
- Templates: `--template` can be used with `nextjs_setup.sh` and `react_setup.sh` to apply starters like `tailwind`, `redux` or `tailwind-redux` (installs packages and creates minimal example files).
- Timestamped logs written to `~/.local/state/shell-scripts/<script>.log` by default.
- `confirm()` helper to require user approval for potentially destructive actions (overwrites); `-y` skips confirmations.
- Safe defaults and basic validation (e.g., checks for Node.js / `nest` CLI when required).

If you'd like, I can add CI examples (GitHub Actions) that run lint/tests and verify project scaffolding, or add templates for Docker/DevContainers.
