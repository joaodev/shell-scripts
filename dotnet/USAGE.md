# Usage — .NET Setup Script 💡

## Synopsis

```bash
./dotnet_setup.sh [options]
```

## Options

- `-n, --name NAME`       Project name (default: `MyApp`)
- `-p, --path PATH`       Parent directory for the project (default: `~/Projects`)
- `-v, --version VER`     .NET version to install/use (default: `8.0`)
- `-l, --logfile FILE`    Log file (default: `~/.dotnet_setup.log`)
- `-y, --yes`             Accept all confirmations automatically
- `-h, --help`            Show this help message

## Examples

Create a new console project interactively:

```bash
./dotnet_setup.sh -n MyApp -p ~/Projects
```

Install a specific .NET version into the user directory and create a project:

```bash
./dotnet_setup.sh -n MyApp -p ~/Projects -v 8.0
```

Run fully non-interactively (CI-friendly):

```bash
./dotnet_setup.sh -n ci-app -p /opt/ci-projects -y
```

## Logging

All actions are appended to `~/.dotnet_setup.log`. Use that file to inspect what the script did or to diagnose failures.

## Troubleshooting

- If the installer fails, retry manually:

```bash
curl -fsSL https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh && bash dotnet-install.sh --version 8.0 --install-dir ~/.dotnet
```

- If `dotnet` is not available after installation, ensure `~/.dotnet` is added to your PATH or `source ~/.bashrc`.
- For permission errors when writing to the chosen `-p` path, run the script in a directory you control or adjust permissions.

---

If you'd like me to add a link to a repository, a maintainer email, or CI examples (GitHub Actions), tell me and I will update the docs. ✨
