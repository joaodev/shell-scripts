# .NET Setup Script ⚙️

A concise Bash script to install the .NET SDK (system-wide or into the user directory), create a new console project, restore dependencies and build it — all with interactive confirmations and logging.

---

## Features ✅

- Interactive prompts with an option for non-interactive mode (`-y`).
- Installs the .NET SDK into the user's directory (no `sudo` required) or uses an existing installation.
- Creates a new console application and runs `dotnet restore` and `dotnet build` automatically.
- Logs all actions to `~/.dotnet_setup.log` for auditing and troubleshooting.

---

## Requirements 🔧

- Linux with `curl` installed.
- Internet access to download the .NET installer.
- `sudo` is not required for the default install path (the script installs to `~/.dotnet`).

---

## Quick Start 🚀

Run the script and provide a project name:

```bash
./dotnet_setup.sh -n MyApp -p ~/Projects
```

To run non-interactively (useful for automation or CI):

```bash
./dotnet_setup.sh -n ci-app -p /opt/projects -y
```

---

## Where to find more info ❓

See `USAGE.md` for detailed options, examples and troubleshooting tips.

---

**Maintainer:** João — let me know if you want to include an email/project link here.
