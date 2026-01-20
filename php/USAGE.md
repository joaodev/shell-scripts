# PHP Scripts Usage 🐘

This file provides quick command examples and flags for the PHP scripts in this folder.

Common flags (supported by most scripts):

- `-n, --name <name>` — Project or site name
- `-p, --path <path>` — Target directory path
- `-v, --version <ver>` — PHP version (for `php_setup.sh`)
- `-l, --logfile <path>` — Override default log file
- `-y, --yes` — Assume "yes" for interactive prompts (non-interactive mode)
- `--dry-run` — Show actions without performing them (where implemented)
- `-V, --verbose` — More output (where supported)

Default log location: `~/.local/state/shell-scripts/<script_name>.log`

---

## php_setup.sh

Usage:

    ./php_setup.sh [options]

Examples:

- Install PHP 8.1 with defaults and non-interactive mode:

    ./php_setup.sh --version 8.1 -y

- Install PHP 8.0 and save logs to a custom file:

    ./php_setup.sh -v 8.0 -l ~/.local/state/shell-scripts/php_setup.log

Notes: This script installs PHP and common extensions and optionally Composer. Use `-y` to skip confirmations.

---

## laravel_setup.sh

Usage:

    ./laravel_setup.sh [options]

Examples:

- Create a Laravel project named `myapp` in `~/projects` (interactive prompts will appear):

    ./laravel_setup.sh -n myapp -p ~/projects

- Create a project non-interactively and skip migrations:

    ./laravel_setup.sh -n blog -p ~/websites/blog -y --no-migrate

Notes: The script will generate the application key and prompt to run migrations and set directory permissions unless `-y` is provided.

---

## codeigniter_setup.sh

Usage:

    ./codeigniter_setup.sh [options]

Examples:

- Scaffold a CodeIgniter 4 app named `ci4app`:

    ./codeigniter_setup.sh -n ci4app -p ~/projects/ci4app

- Scaffold non-interactively and run Composer install:

    ./codeigniter_setup.sh -n ci4app -p ~/projects/ci4app -y

Notes: The script may prompt to set writable permissions and create a `.env` file.

---

## zend_setup.sh

Usage:

    ./zend_setup.sh [options]

Examples:

- Create a Zend skeleton application named `zendapp`:

    ./zend_setup.sh -n zendapp -p ~/projects/zendapp

- Create non-interactively and allow the script to prepare runtime directories:

    ./zend_setup.sh -n zendapp -p ~/projects/zendapp -y

Notes: Composer is required; the script will ask for confirmation before running `composer create-project` unless `-y` is provided.

---

For full details and advanced options, see `README.md` in this folder. If you want additional examples (CI workflows, Docker templates, or TLS/Let's Encrypt setup), tell me which one you prefer and I'll add it. ✅
