# Vue Scripts Usage 🖖

Quick usage and examples for `vue_setup.sh`.

Flags:

- `-n, --name <name>` — Project name (will prompt if omitted)
- `-p, --path <path>` — Parent directory to create the project in (default: current directory)
- `-v, --node-version <ver>` — Node.js version to install when using `-L/--local` (default: 18)
- `-L, --local` — Install Node locally using `nvm` (no sudo)
- `-l, --logfile <file>` — Override default log file
- `-V, --verbose` — Increase console output (show debug traces)
- `-t, --template <name>` — Apply a starter template (supported: `tailwind`, `pinia`, `vuex`)
- `-y, --yes` — Assume yes for interactive confirmations (also accepts automatic wiring prompts)
- `-h, --help` — Show help

Examples:

- Scaffold a Vue project interactively:

    ./vue_setup.sh

- Scaffold a project with Tailwind wiring:

    ./vue_setup.sh -n frontend -t tailwind

- Scaffold a project with Pinia store example (auto-creates `src/stores/index.js` and prompts to auto-wire Pinia into `src/main.js`):

    ./vue_setup.sh -n frontend -t pinia

- Scaffold a project with Vuex example store (auto-creates `src/store/index.js` and prompts to auto-wire Vuex into `src/main.js`):

    ./vue_setup.sh -n frontend -t vuex

- Run non-interactively and accept automatic wiring with `-y`:

    ./vue_setup.sh -n frontend -t pinia -y

- Scaffold a project named `frontend` in `~/projects` non-interactively:

    ./vue_setup.sh -n frontend -p ~/projects -y

- Install Node locally via `nvm` (version 18) and scaffold:

    ./vue_setup.sh -L -v 18 -n myapp

Notes: The script will install Node with `nvm` if `-L` is used, or system-wide via the NodeSource setup script otherwise. Use `-V/--verbose` to see debug-level command traces.