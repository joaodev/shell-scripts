# React Scripts Usage ⚛️

Quick usage and examples for scaffolding React-based projects.

Common flags (supported by all scripts):

- `-n, --name <name>` — Project name
- `-p, --path <path>` — Parent directory to create the project in (default: current directory)
- `-l, --logfile <file>` — Override default log file (default: `~/.local/state/shell-scripts/<script>.log`)
- `-V, --verbose` — Increase console output (show debug/command traces)
- `-y, --yes` — Assume yes for interactive confirmations (non-interactive mode)
- `--dry-run` — Show the commands that would be executed without performing them
- `--template <name>` — Apply a starter template (supports `tailwind`, `redux`, `tailwind-redux`)
- `-h, --help` — Show help

---

## nestjs_setup.sh

Usage:

    ./nestjs_setup.sh [options]

Examples:

- Scaffold a NestJS project named `backend` in the current directory (interactive):

    ./nestjs_setup.sh -n backend

- Dry-run to preview actions and install `@nestjs/cli` if missing:

    ./nestjs_setup.sh -n backend --dry-run

Notes: The script checks for `nest` and will install the Nest CLI globally if required. Use `-y` to skip confirmations.

---

## nextjs_setup.sh

Usage:

    ./nextjs_setup.sh [options]

Examples:

- Create a typed Next.js app in `./web` interactively:

    ./nextjs_setup.sh -n web

- Create non-interactively and specify a parent path:

    ./nextjs_setup.sh -n web -p ~/projects -y

Notes: Requires Node.js >= 18. Use `--dry-run` to see the commands without executing them.

---

## react_setup.sh

Usage:

    ./react_setup.sh [options]

Examples:

- Create a React app named `frontend` interactively:

    ./react_setup.sh -n frontend

- Create non-interactively and use a custom log file:

    ./react_setup.sh -n frontend -p ~/projects -y -l ~/.local/state/shell-scripts/react_setup.log

Notes: The script uses `create-react-app` and installs common dev tools (`eslint`, `prettier`, `husky`, `lint-staged`). If a target directory exists, you will be asked to confirm overwrite unless `-y` is used.

---

For more detailed info and troubleshooting, see `README.md`. If you'd like CI workflows or Docker templates added, tell me which framework to start with and I will add examples.
