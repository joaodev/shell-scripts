# Usage — Go Setup Script 💡

## Synopsis

```bash
./go_setup.sh [options]
```

## Options

- `-n, --name NAME`       Project name (if omitted you'll be prompted)
- `-p, --path PATH`       Parent directory for the project (default: `~/go/src`)
- `-v, --version VER`     Go version to download/install (default: `1.21.0`)
- `-m, --module MODULE`   Custom Go module path (e.g. example.com/org/repo)
- `-t, --module-template TEMPLATE`  Module template with placeholders `<org>` and/or `<project>` (e.g. `github.com/<org>/<project>`)
- `--no-install`          Skip installing Go and only initialize the project
- `-l, --logfile FILE`    Log file (default: `~/.go_setup.log`)
- `-y, --yes`             Accept all confirmations automatically
- `-h, --help`            Show help

## Examples

Create a project interactively:

```bash
./go_setup.sh -n myapp -p ~/dev
```

Install Go (default), set up a project and run in non-interactive mode:

```bash
./go_setup.sh -n ci-app -p /opt/ci -y
```

Use a specific Go version:

```bash
./go_setup.sh -v 1.22.1 -n myapp
```

Use a module template and fill placeholders interactively:

```bash
./go_setup.sh -n myapp -t "github.com/<org>/<project>"
# will prompt for <org> (and use project name for <project>)
```

## Notes

- Module paths are validated by the script (must have the form `domain.tld/owner/repo`, no spaces). If a provided module path or template produces an invalid module path, the script will inform you and ask to fix it (in interactive mode) or exit with an error (in non-interactive mode).

- The installer attempts to add `/usr/local/go/bin` to `~/.bashrc` if needed — you may need to open a new shell or `source ~/.bashrc` for the change to take effect.
- The script initializes a module named `github.com/<user>/<project>`. If you prefer a different module path, you can edit it after creation or run `go mod edit`.

If you want I can add additional flags (e.g., `--module` to provide a custom module path, or `--no-install` to skip Go installation). Tell me what you'd prefer and I'll implement it. ✨
