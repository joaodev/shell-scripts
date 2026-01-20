# Usage — Node.js Scripts 💡

## nodejs_setup.sh
System-wide Node.js installer (copies Node to `/usr/local`). Use with `sudo`.

Options:
- `-v, --version VER`    Node.js version (default: 20.10.0)
- `-l, --logfile FILE`   Log file (default: `~/.nodejs_setup.log`)
- `-y, --yes`            Non-interactive, accept confirmations
- `-V, --verbose`        Show verbose output

Example:

```bash
sudo ./nodejs_setup.sh -v 20.10.0
```

Notes:
- The script will ask to update/upgrade the system and to install dependencies. It downloads the Node tarball and copies to `/usr/local/`.

---

## nodejs_nvm_setup.sh
Installs `nvm` and a Node version for the current user (no sudo required).

Options:
- `-v, --version VER`    Node version (e.g., `14`, `16`, `lts/*`) (default: `lts/*`)
- `-l, --logfile FILE`   Log file (default: `~/.nvm_setup.log`)
- `-y, --yes`            Non-interactive
- `-V, --verbose`        Verbose output

Example:

```bash
./nodejs_nvm_setup.sh -v lts/*
```

---

## nodejs_api_setup.sh (JavaScript)
Scaffold a simple Express API with `src/` and basic health endpoint.

Options:
- `-n, --name NAME`      Project name (if omitted you will be prompted)
- `-p, --path PATH`      Parent directory to create the project (default: `.`)
- `-L, --local`          Install Node locally via `nvm` if Node is missing
- `-v, --node-version`   Node version to install when using `--local` (default: 18)
- `-l, --logfile FILE`   Log file (default: `~/.nodejs_api_setup.log`)
- `-y, --yes`            Non-interactive (accept defaults)

Example:

```bash
./nodejs_api_setup.sh -n myapp -p ~/projects
```

---

## nodejs_api_ts_setup.sh (TypeScript)
Scaffold a TypeScript Express API with `tsconfig.json`, `src/server.ts`, and dev scripts.

Options are the same as the JavaScript scaffold script.

Example:

```bash
./nodejs_api_ts_setup.sh -n mytsapp -p ~/projects
```

---

If you'd like templates (auth, DB, logging) or Dockerfiles added to the scaffold, tell me which features and I'll add them.