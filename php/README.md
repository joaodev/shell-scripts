# PHP Scripts 🐘

This folder contains scripts to install PHP and scaffold popular PHP frameworks:

- `php_setup.sh` — Install PHP, common extensions, and Composer (with optional PHP version suffix).
- `laravel_setup.sh` — Create a Laravel project, configure environment, generate key, set permissions and optionally run migrations.
- `codeigniter_setup.sh` — Scaffold a CodeIgniter 4 project, set permissions and configure `.env`.
- `zend_setup.sh` — Create a Zend skeleton application and prepare runtime directories and permissions.

All scripts now include:
- Interactive confirmations and `-y/--yes` non-interactive mode
- Timestamped logs (default files under `~/.local/state/shell-scripts/`), many scripts accept `-l/--logfile` to override
- `--dry-run` support where applicable

If you'd like I can add Dockerfile templates, environment-specific scaffolding (DB, Redis) or CI examples for these frameworks — tell me which and I will add them.
