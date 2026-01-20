# JDK Installer — JDK 17, 21 and 25 ⚙️

**File:** `setup_java_jdks.sh`

## Description ✅
This script installs OpenJDK 17 and 21, and attempts to install OpenJDK 25 if available in the distribution repositories. It is intended for Debian/Ubuntu-based distributions (Zorin OS tested) and uses apt and `update-alternatives` to manage Java versions.

## Features ✨
- Installs OpenJDK 17 and 21 automatically
- Attempts to install OpenJDK 25 if present in the repositories
- Lists installed JDKs and allows you to select the active one using `update-alternatives`
- Prints useful commands to manage and verify Java installations

## Requirements 🔍
- Debian/Ubuntu-based system (Zorin OS)
- Root or sudo privileges (the script checks and exits if not run as root)
- Internet connection to download packages

## Usage 🚀
1. Make the script executable (optional):

```bash
chmod +x java/setup_java_jdks.sh
```

2. Run the script as root (recommended using sudo):

```bash
sudo bash java/setup_java_jdks.sh
```

3. The script is interactive and will prompt you to select which installed JDK to set as default.

## Notes & Troubleshooting ⚠️
- If JDK 25 is not available, the script will warn and continue (you can add a PPA or install manually).
- After changing the default JDK, use `java -version` and `javac -version` to verify the active version.

## Other scripts in this folder

- `gradle_setup.sh` — Install and configure Gradle. Adds environment variables and can optionally create a temporary test project to validate the installation. Supports `-v/--version`, `-n/--name` (test project name), `-p/--path`, `-l/--logfile`, and `-y/--yes`.

- `maven_setup.sh` — Download and install Apache Maven; optionally create a sample Maven project with `-c/--create` and set artifactId with `-n/--name`.

- `quarkus_setup.sh` — Create a Quarkus project via the Quarkus Maven plugin. Use `-n/--name`, `-p/--path`, `-l/--logfile`, `-y/--yes`.

- `springboot_setup.sh` — Create a Spring Boot project (Maven or Gradle). Supports `-n/--name`, `-t/--tool`, `-p/--path`, `-l/--logfile`, `-y/--yes`.

- `kubernetes_setup.sh` — Bootstrap a single-node Kubernetes cluster with kubeadm (Ubuntu). Supports `--no-init` to skip cluster initialization and `--pod-cidr` to customize the pod network CIDR; includes confirmations and logging.

- `setup_java_jdks.sh` — Install JDK 17, 21 and optionally 25 (if available) with interactive selection afterwards. Supports `-l/--logfile` and `-y/--yes` for non-interactive mode.

---

## Author & License ✍️
- Author: João Augusto Bonfante
- Feel free to use and adapt this script. Add an explicit license if you plan to publish it.
