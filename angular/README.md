# Angular Setup Script ⚙️

A small, opinionated Bash script to install Node.js/npm (system-wide or via `nvm`), install the Angular CLI, and create a new Angular project with interactive confirmations and logging.

---

## Features ✅

- Interactive prompts with an option for non-interactive mode (`-y`).
- Install Node.js locally via `nvm` (no `sudo`) or system-wide via `apt`.
- Installs Angular CLI globally (if requested).
- Logs all actions to `~/.angular_setup.log` for auditing and troubleshooting.

---

## Requirements 🔧

- Debian/Ubuntu-based system (uses `apt` for system installs).
- `curl` available for installer downloads.
- `sudo` access if performing system-wide installs.
- Internet access to download Node.js and packages.

---

## Quick Start 🚀

Clone or navigate to this folder and run the script directly:

```bash
./angular_setup.sh -n my-app -p ~/projects
```

To run non-interactively (useful for automation):

```bash
./angular_setup.sh -n my-app -p ~/projects -y
```

To install Node.js locally via `nvm` and create a project:

```bash
./angular_setup.sh -n my-app -L -v 18
```

---

## Where to look for help ❓

See `USAGE.md` for detailed examples, flags and troubleshooting tips.

---

**Maintainer:** João

If you want changes to the default options or additional features, open an issue or edit the script directly. ✨
