# Python Scripts 🐍

This folder contains scripts to set up Python and scaffold small Python projects:

- `python_setup.sh` — Install system Python3 (with development packages), create a user virtualenv and install common packages.
- `django_setup.sh` — Create a Django project and app, create a venv, install dependencies and run migrations.
- `fastapi_setup.sh` — Scaffold a minimal FastAPI project, create a venv, and produce a simple `app/main.py` and `.env`.

All scripts include:
- Timestamped logging (default files under `~/.local/state/shell-scripts/`) — many scripts accept `-l/--logfile` to override
- Interactive confirmations with `-y/--yes` to enable non-interactive mode
- `log()` and `confirm()` helpers for consistent behavior

If you want CI examples, Docker templates, or additional framework integration (e.g., Celery, Postgres), tell me which and I'll add them.