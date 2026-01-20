# Python Scripts Usage 🐍

Quick examples and flags for the scripts in this folder.

Common flags:
- `-l, --logfile <file>` — Override the default logfile
- `-y, --yes` — Assume yes for all confirmation prompts (non-interactive)
- `-h, --help` — Show help for each script

---

## python_setup.sh

Usage:

    ./python_setup.sh [options]

Examples:

- Install system Python and create a user venv (interactive):

    ./python_setup.sh

- Run non-interactively and set a custom log file:

    ./python_setup.sh -y -l ~/.local/state/shell-scripts/python_setup.log

---

## django_setup.sh

Usage:

    ./django_setup.sh [options]

Examples:

- Create a Django project `myproj` with an app `web` interactively:

    ./django_setup.sh -n myproj -a web -p ~/projects

- Create non-interactively and log to a specific file:

    ./django_setup.sh -n myproj -a web -p ~/projects -y -l ~/.local/state/shell-scripts/django_setup.log

---

## fastapi_setup.sh

Usage:

    ./fastapi_setup.sh [options]

Examples:

- Scaffold the default `fastapi_project` in the default parent path:

    ./fastapi_setup.sh

- Scaffold a project named `api` in `~/projects` non-interactively:

    ./fastapi_setup.sh -n api -p ~/projects -y

---

For detailed options and behavior, see `README.md`. If you want CI examples or Docker templates, tell me which one to add next.