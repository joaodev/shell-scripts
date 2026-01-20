#!/usr/bin/env bash

################################################################################
# SpringBoot Setup Script
# Description: Creates a basic SpringBoot project structure
# Author: João Augusto Bonfante
# GitHub: https://github.com/joaodev
# Date: January 2026
################################################################################

set -euo pipefail
IFS=$'\n\t'

# Defaults
LOG_FILE="$HOME/.springboot_setup.log"
AUTO_YES=false

# Helpers
timestamp() { date '+%Y-%m-%d %H:%M:%S'; }
log() { printf '%s %s\n' "$(timestamp)" "$*" | tee -a "$LOG_FILE"; }
confirm() { if [ "$AUTO_YES" = true ]; then log "Auto-approve enabled — skipping confirmation: $1"; return 0; fi; local resp; read -r -p "$1 [y/N]: " resp; case "$resp" in [yY]|[yY][eE][sS]) return 0 ;; *) return 1 ;; esac }

# Parse arguments (support -n and -t, -p, -l, -y)
while [ "$#" -gt 0 ]; do
  case "$1" in
    -n|--name) PROJECT_NAME="$2"; shift 2 ;;
    -t|--tool) BUILD_TOOL="$2"; shift 2 ;;
    -p|--path) PROJECT_PARENT="$2"; shift 2 ;;
    -l|--logfile) LOG_FILE="$2"; shift 2 ;;
    -y|--yes) AUTO_YES=true; shift ;;
    -h|--help) echo "Usage: $0 [-n name] [-t maven|gradle] [-p path]"; exit 0 ;;
    --) shift; break ;;
    -*) echo "Unknown option: $1"; exit 1 ;;
    *) break ;;
  esac
done

# Defaults
PROJECT_PARENT="$PWD"
BUILD_TOOL="maven"

# Prompt interactively if needed
if [ -z "${PROJECT_NAME:-}" ]; then
  if [ "$AUTO_YES" = true ]; then
    echo "Error: project name required in non-interactive mode. Use -n/--name."; exit 1
  fi
  read -r -p "Project name (default: my-springboot-app): " PROJECT_NAME
  PROJECT_NAME=${PROJECT_NAME:-my-springboot-app}
fi

if [ -z "${BUILD_TOOL:-}" ]; then
  BUILD_TOOL="maven"
fi

PROJECT_DIR="$PROJECT_PARENT/$PROJECT_NAME"

log "Creating SpringBoot project: $PROJECT_NAME (build tool: $BUILD_TOOL)"

# Confirm
if ! confirm "Create project at $PROJECT_DIR?"; then
  log "User cancelled SpringBoot project creation"
  exit 0
fi

# Create project directory
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR" || exit 1

if [[ "$BUILD_TOOL" == "maven" ]]; then
    # Initialize Maven project
    if ! command -v mvn &> /dev/null; then
        log "ERROR: Maven is not installed. Please install Maven or choose Gradle."
        echo "[ERROR] Maven is not installed. Please install Maven or choose Gradle."
        exit 1
    fi

    mvn archetype:generate \
        -DgroupId=com.example \
        -DartifactId="$PROJECT_NAME" \
        -DarchetypeArtifactId=maven-archetype-quickstart \
        -DinteractiveMode=false

    cd "$PROJECT_NAME" || exit 1

    # Update pom.xml with Spring Boot dependencies
    cat > pom.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
                 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                 xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
                 http://maven.apache.org/xsd/maven-4.0.0.xsd">
        <modelVersion>4.0.0</modelVersion>

        <groupId>com.example</groupId>
        <artifactId>$PROJECT_NAME</artifactId>
        <version>1.0.0</version>

        <parent>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-starter-parent</artifactId>
                <version>3.1.5</version>
        </parent>

        <dependencies>
                <dependency>
                        <groupId>org.springframework.boot</groupId>
                        <artifactId>spring-boot-starter-web</artifactId>
                </dependency>
                <dependency>
                        <groupId>org.springframework.boot</groupId>
                        <artifactId>spring-boot-starter-test</artifactId>
                        <scope>test</scope>
                </dependency>
        </dependencies>

        <build>
                <plugins>
                        <plugin>
                                <groupId>org.springframework.boot</groupId>
                                <artifactId>spring-boot-maven-plugin</artifactId>
                        </plugin>
                </plugins>
        </build>
</project>
EOF

    # Create directory structure and source files
    mkdir -p src/main/java/com/example
    mkdir -p src/main/resources

else
    # Gradle project
    # Create settings and build files at project root
    cat > settings.gradle <<EOF
rootProject.name = '$PROJECT_NAME'
EOF

    cat > build.gradle <<'EOF'
plugins {
    id 'org.springframework.boot' version '3.1.5'
    id 'io.spring.dependency-management' version '1.1.0'
    id 'java'
}

group = 'com.example'
version = '1.0.0'

repositories {
    mavenCentral()
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}

java {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}

tasks.named('test') { useJUnitPlatform() }
EOF

    mkdir -p src/main/java/com/example
    mkdir -p src/main/resources

    # If gradle is available, create wrapper
    if command -v gradle &> /dev/null; then
        echo "Initializing Gradle wrapper..."
        gradle wrapper
    fi
fi

# Create main application class
cat > src/main/java/com/example/Application.java << 'EOF'
package com.example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class Application {
        public static void main(String[] args) {
                SpringApplication.run(Application.class, args);
        }
}
EOF

# Create a simple controller
cat > src/main/java/com/example/HelloController.java << 'EOF'
package com.example;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {
        @GetMapping("/")
        public String hello() {
                return "Hello, SpringBoot!";
        }
}
EOF

# Create application.properties
cat > src/main/resources/application.properties << 'EOF'
spring.application.name=$PROJECT_NAME
server.port=8080
EOF

# Print success and next steps
if [[ "$BUILD_TOOL" == "maven" ]]; then
    echo "✓ SpringBoot (Maven) project created successfully!"
    echo "✓ Location: $PROJECT_DIR/$PROJECT_NAME"
    echo ""
    echo "Next steps:"
    echo "  cd $PROJECT_NAME"
    echo "  mvn clean install"
    echo "  mvn spring-boot:run"
else
    echo "✓ SpringBoot (Gradle) project created successfully!"
    echo "✓ Location: $PROJECT_DIR"
    echo ""
    echo "Next steps:"
    echo "  cd $PROJECT_DIR"
    if [ -f ./gradlew ]; then
        echo "  ./gradlew build"
        echo "  ./gradlew bootRun"
    else
        echo "  gradle build (or install Gradle and run 'gradle wrapper' to create ./gradlew)"
        echo "  gradle bootRun"
    fi
fi