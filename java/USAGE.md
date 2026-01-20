# Usage & Verification — JDK Installer 🛠️

**File:** `setup_java_jdks.sh`

## Quickstart 🚀
1. Optional: make the script executable:

```bash
chmod +x java/setup_java_jdks.sh
```

2. Run the script as root (recommended using sudo):

```bash
sudo bash java/setup_java_jdks.sh
```

3. Follow prompts to select the default JDK after installation.

---

## Verify installed JDKs 🔎
- List all installed JDK alternatives:

```bash
update-java-alternatives --list
```

- Check active Java and Javac versions:

```bash
java -version
javac -version
```

---

## Manually switch JDKs 🔧
- Use the interactive alternatives tool to choose a different installed JDK:

```bash
sudo update-alternatives --config java
sudo update-alternatives --config javac
```

---

## If JDK 25 is not available 📌
- You may need to add a third-party repository or download the vendor-provided package manually.
- Example: add an appropriate PPA (only if trusted) or download a binary distribution from an official source.

---

## Other scripts & quick usage

- Gradle setup:

```bash
./java/gradle_setup.sh -v 8.5 -n my-test -p /tmp -l ~/.gradle_setup.log
```

- Maven setup (install and create sample project):

```bash
./java/maven_setup.sh -v 3.9.6 -c -n my-app -p ~/projects
```

- Create a Quarkus project:

```bash
./java/quarkus_setup.sh -n my-quarkus-app -p ~/projects
```

- Create a Spring Boot project:

```bash
./java/springboot_setup.sh -n my-app -t gradle -p ~/projects
```

- Kubernetes (Ubuntu) bootstrap (interactive):

```bash
sudo ./java/kubernetes_setup.sh
# or non-interactive
sudo ./java/kubernetes_setup.sh --no-init -y
```

- JDK installer (non-interactive):

```bash
sudo ./java/setup_java_jdks.sh -y
```

---

If you want me to add more examples, CI snippets, or a `--dry-run` mode for destructive operations, tell me which and I will add it.
