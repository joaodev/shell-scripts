# Go Setup Script 🐹

A small Bash utility that installs Go (user-local / system depending on privileges), initializes a new project module, and creates a minimal `main.go` with a "Hello, Go!" example.

---

## Features ✅

- Installs a specific Go version (default: 1.21.0) by downloading the official tarball (unless `--no-install` is used).
- Creates a new project directory and initializes a Go module (default `github.com/<user>/<project>`). Use `-m/--module` to provide a custom module path or `-t/--module-template` to supply a template with `<org>` and `<project>` placeholders.
- The script validates module paths to ensure they look like `domain.tld/org/repo` (no spaces). Interactive prompts help you fill template placeholders; in non-interactive mode defaults are used or the script exits on invalid input.
- Interactive confirmations with a non-interactive `-y/--yes` mode for automation.
- Timestamped logging to `~/.go_setup.log` by default and a `-l/--logfile` option to override.

---

## Requirements 🔧

- Linux system with `curl` available.
- `sudo` privileges to install Go under `/usr/local` if desired.

---

## Quick Start 🚀

Interactive usage (recommended):

```bash
./go_setup.sh -n myapp -p ~/dev
```

Non-interactive (CI-friendly):

```bash
./go_setup.sh -n ci-app -p /opt/projects -y
```

You can also set a custom Go version:

```bash
./go_setup.sh -v 1.22.0 -n myapp
```

---

If you'd like, I can add more features (select Go install destination, support macOS, or add testing scaffolding). Reply to tell me which you'd like.
