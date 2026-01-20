# Shell Scripts — Development Environment & Project Scaffolding ✅

## Overview
This repository collects small, focused shell scripts to help bootstrap, install and configure development environments and project scaffolding for multiple languages and services.

## What this repository provides
Each script is located under a category folder and is intended to be run independently. All scripts include a standardized header with **author**, **GitHub**, and **date** metadata.

### Java
- `java/gradle_setup.sh` — Installs and configures Gradle for Java development
- `java/maven_setup.sh` — Installs and configures Apache Maven
- `java/setup_java_jdks.sh` — Installs and configures OpenJDKs (17, 21, 25)
- `java/springboot_setup.sh` — Scaffolds a Spring Boot project
- `java/quarkus_setup.sh` — Scaffolds a Quarkus project
- `java/kubernetes_setup.sh` — Installs/configures Kubernetes (kubeadm)

### Node.js / Frontend
- `nodejs/nodejs_setup.sh` — System-wide Node.js installation
- `nodejs/nodejs_nvm_setup.sh` — Install NVM and Node versions
- `nodejs/nodejs_api_setup.sh` — Create a Node.js API project
- `nodejs/nodejs_api_ts_setup.sh` — Create a Node.js TypeScript API project
- `react/react_setup.sh` — Scaffolds a React project
- `react/nextjs_setup.sh` — Scaffolds a Next.js project
- `react/nestjs_setup.sh` — Scaffolds a NestJS project
- `angular/angular_setup.sh` — Scaffolds an Angular project
- `vue/vue_setup.sh` — Scaffolds a Vue.js project

### Python
- `python/python_setup.sh` — Installs Python 3 and common tools
- `python/django_setup.sh` — Scaffolds a Django project
- `python/fastapi_setup.sh` — Scaffolds a FastAPI project

### PHP
- `php/php_setup.sh` — Installs PHP and common extensions
- `php/laravel_setup.sh` — Scaffolds a Laravel project
- `php/codeigniter_setup.sh` — Scaffolds a CodeIgniter project
- `php/zend_setup.sh` — Scaffolds a Zend project

### Databases
- `databases/mysql_setup.sh` — Install/configure MySQL
- `databases/postgresql_setup.sh` — Install/configure PostgreSQL
- `databases/mongodb_setup.sh` — Install/configure MongoDB

### Containers & Infra
- `docker/docker_setup.sh` — Installs Docker
- `docker/docker_cleanup.sh` — Cleans up Docker resources
- `nginx/nginx_setup.sh` — Installs/configures Nginx
- `apache2/apache2_setup.sh` — Installs/configures Apache2

### Other languages & tools
- `go/go_setup.sh` — Installs/configures Go environment
- `dotnet/dotnet_setup.sh` — Installs/configures .NET SDK

### Utilities
- `environment/setup-dev-environment.sh` — Full development environment setup
- `utils/setup_ubuntu_utils.sh` — Ubuntu utilities setup
- `shell_menu.sh` — Interactive menu (entry point to run scripts)

## Usage
- Make a script executable: `chmod +x path/to/script.sh`
- Run a script: `./path/to/script.sh -h` to see options
- Most scripts support `-y` or `--yes` to run non-interactively

### Shell Menu (interactive)
- Entry point: `./shell_menu.sh` (make it executable: `chmod +x shell_menu.sh`).
- Purpose: an interactive, user-friendly launcher to discover and execute the setup scripts in this repository. Browse by category (directory), search by name, inspect a script's help, and run it with or without elevated privileges.
- Script actions available after selection:
  - **Show help** (`-h`) — view the script help text
  - **Run** — run the script and provide extra args if needed
  - **Run with `-y`** — run non-interactively where supported
  - **Run with `sudo`** — run the script under sudo (you will be prompted for extra args)

Quick usage
1. Make executable: `chmod +x shell_menu.sh`
2. Start: `./shell_menu.sh`
3. Follow the prompts to choose a category, script, and action.

Short ASCII demo (example session)

```bash
$ ./shell_menu.sh

========================================
Shell Scripts Menu
========================================
Repository: /home/joao/Documentos/shell-scripts
1) Choose category & script
2) Search script by name
3) Exit
Select an option [1-3]: 1

========================================
Categories
========================================
1) All scripts
2) nodejs
3) react
4) java
Select a category (or 0 to Exit): 2

========================================
Scripts in nodejs
========================================
1) ./nodejs/nodejs_setup.sh
2) ./nodejs/nodejs_nvm_setup.sh
3) ./nodejs/nodejs_api_setup.sh
Select a script (or 0 to go back): 1

========================================
Script: ./nodejs/nodejs_setup.sh
========================================
1) Show help (-h)
2) Run
3) Run with -y (non-interactive)
4) Run with sudo
5) Back
Choose an action [1-5]: 3

---- Running: bash ./nodejs/nodejs_setup.sh -y ----
... (script output) ...
---- Script finished with exit code: 0 ----
```

Tips
- Use option **2) Search script by name** to quickly find scripts by keyword.
- The menu will offer to make non-executable scripts executable before running them.
- If you want a non-interactive launcher feature (run a single script by CLI), I can add `--run` mode to the menu script.

## Notes
- I standardized the header block in all `.sh` files to include **Author: João Augusto Bonfante**, **GitHub: `https://github.com/joaodev`**, and **Date: January 2026**. Title and description lines are customized per script.

## Contributing
Contributions are welcome. Open issues or create PRs with small, focused changes.

## Author
João Augusto Bonfante — https://github.com/joaodev

## License
No license file is included in the repository. Add a LICENSE if you want to apply a specific license.

