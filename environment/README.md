# Development Environment Setup Script 🔧

**File:** `setup-dev-environment.sh`

## Description ✅
This repository contains an interactive Bash script to install and configure a development environment on Debian/Ubuntu systems. The script optionally installs and configures common services and tools such as Apache, MySQL, PostgreSQL, PHP, Node.js, Docker, Python, Git, and SSH key generation.

## Key features ✨
- Updates system repositories and packages
- Installs and configures:
  - Apache Web Server
  - MySQL Server
  - PostgreSQL
  - PHP (multiple versions via PPA)
  - Node.js (multiple versions via NodeSource)
  - Docker (official packages)
  - Python 3 (pip, venv)
  - Git (with user configuration)
- Generates SSH keys (RSA 4096 or ED25519)
- Displays a final summary showing service status

## Requirements 🔍
- Operating system: Debian / Ubuntu (or apt-compatible derivatives)
- Root / sudo access (the script checks for root and exits if not run as root)
- Internet connection to download packages and repositories
- Recommended: a terminal with color support

## Usage 🚀
1. Make the script executable (optional):

   ```bash
   chmod +x environment/setup-dev-environment.sh
   ```

2. Run the script as root (recommended using sudo):

   ```bash
   sudo bash environment/setup-dev-environment.sh
   ```

3. The script is interactive: answer `y`/`n` (or `s`/`n` in Portuguese prompts) to select which steps to run.

## Important notes ⚠️
> - The script asks for confirmation before each installation/action — read prompts carefully and confirm where appropriate.
> - To use Docker without `sudo`, choose to add your user to the `docker` group when prompted, then log out and log back in to apply the change.
> - After installing MySQL, run `sudo mysql_secure_installation` manually to set the root password and harden the installation.
> - If generating SSH keys for another user, the script attempts to use `su - <user>` to run `ssh-keygen` in that user's context.

## Customization 💡
- PHP and Node.js versions are selectable via the interactive menu (PHP: 8.1/8.2/8.3 — Node: 22.x/24.x/25.x).
- The script installs common PHP extensions if you confirm.
- You can adapt the script to add/remove packages or automate additional configuration steps.

## Repository layout 📁
- `environment/setup-dev-environment.sh` — main script (see usage above)
- `.README` — optional hidden README (the primary README is `README.md`)

## Author & date ✍️
- Author: João Augusto Bonfante
- Date: the script header contains a dynamically generated date

## License 📜
Feel free to use and adapt this script for your environment. Add an explicit license if you plan to share it publicly.

---

If you want, I can also:
- Update the hidden `.README` with the same content;
- Create an additional `USAGE.md` with examples and post-install tips;
- Generate a version in Portuguese (if needed).

🔧 Would you like me to update the `.README` file as well? (reply yes/no)