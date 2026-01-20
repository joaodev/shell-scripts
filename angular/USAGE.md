# Usage — Angular Setup Script 💡

## Synopsis

```bash
./angular_setup.sh [options]
```

## Options

- `-n, --name NAME`           Project name (if omitted you will be prompted)
- `-p, --path PATH`           Directory to create the project in (default: `.`)
- `-v, --node-version VER`    Node.js version to install when using local install (default: `18`)
- `-L, --local`               Install Node.js locally (no `sudo`) using `nvm`
- `-l, --logfile FILE`        Log file (default: `~/.angular_setup.log`)
- `-y, --yes`                 Accept all confirmations automatically
- `-h, --help`                Show this help message

## Examples

Create a project interactively (prompted for any missing values):

```bash
./angular_setup.sh -n my-awesome-app -p ~/projects
```

Install Node locally with `nvm` and create a project:

```bash
./angular_setup.sh -n my-app -L -v 18
```

Run fully non-interactively (CI-friendly):

```bash
./angular_setup.sh -n ci-app -p /opt/projects -y
```

## Logging

All operations are appended to the default log file `~/.angular_setup.log`. Use this file to review what the script did or to troubleshoot failures.

## Troubleshooting

- If `nvm` installation fails, open a new shell or `source ~/.nvm/nvm.sh` after the script finishes and try `nvm install <version>` manually.
- If `ng` is not recognized after global install, check `npm` global install path and that your shell has the correct PATH.
- For system installs, ensure you have `sudo` privileges and internet access.

---

If you'd like the README and USAGE to include your email or a repository link, tell me what to add and I will update them. ✨
