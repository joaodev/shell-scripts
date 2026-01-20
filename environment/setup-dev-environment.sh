#!/bin/bash

################################################################################
# Development Environment Setup Script
# Description: Installs and configures a complete development environment
# Author: João Augusto Bonfante
# GitHub: https://github.com/joaodev
# Date: January 2026
################################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print header
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

# Function to print success
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function to print error
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Function to print warning
print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Function to confirm action
confirm() {
    while true; do
        read -p "$(echo -e ${YELLOW}"$1 (y/n): "${NC})" yn
        case $yn in
            [YySs]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer y (yes) or n (no).";;
        esac
    done
} 

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root (sudo)"
        exit 1
    fi
}

# Update system
update_system() {
    print_header "STEP 1: System Update"
    
    if confirm "Do you want to update system packages?"; then
        print_warning "Updating repositories..."
        apt update
        
        if confirm "Do you want to upgrade the installed packages?"; then
            apt upgrade -y
            print_success "System updated successfully!"
        fi
    else
        print_warning "System update skipped"
    fi
}

# Install Apache
install_apache() {
    print_header "STEP 2: Apache Installation"
    
    if confirm "Do you want to install the Apache Web Server?"; then
        print_warning "Installing Apache..."
        apt install apache2 -y
        
        if confirm "Enable Apache to start at boot?"; then
            systemctl enable apache2
        fi
        
        systemctl start apache2
        
        if systemctl is-active --quiet apache2; then
            print_success "Apache installed and started successfully!"
            echo -e "Access: ${GREEN}http://localhost${NC}"
        else
            print_error "Failed to start Apache"
        fi
    else
        print_warning "Apache installation skipped"
    fi
}

# Install MySQL
install_mysql() {
    print_header "STEP 3: MySQL Installation"
    
    if confirm "Do you want to install the MySQL Server?"; then
        print_warning "Installing MySQL..."
        apt install mysql-server -y
        
        if confirm "Enable MySQL to start at boot?"; then
            systemctl enable mysql
        fi
        
        systemctl start mysql
        
        if systemctl is-active --quiet mysql; then
            print_success "MySQL installed and started successfully!"
            
            if confirm "Do you want to run the MySQL secure installation (mysql_secure_installation)?"; then
                print_warning "Run manually: sudo mysql_secure_installation"
                echo "It is recommended to set the root password, remove anonymous users, etc."
            fi
        else
            print_error "Failed to start MySQL"
        fi
    else
        print_warning "MySQL installation skipped"
    fi
}

# Install PostgreSQL
install_postgresql() {
    print_header "STEP 4: PostgreSQL Installation"
    
    if confirm "Do you want to install PostgreSQL?"; then
        print_warning "Installing PostgreSQL..."
        apt install postgresql postgresql-contrib -y
        
        if confirm "Enable PostgreSQL to start at boot?"; then
            systemctl enable postgresql
        fi
        
        systemctl start postgresql
        
        if systemctl is-active --quiet postgresql; then
            print_success "PostgreSQL installed and started successfully!"
            echo -e "To access: ${GREEN}sudo -u postgres psql${NC}"
        else
            print_error "Failed to start PostgreSQL"
        fi
    else
        print_warning "PostgreSQL installation skipped"
    fi
}

# Install PHP
install_php() {
    print_header "STEP 5: PHP Installation"
    
    if confirm "Do you want to install PHP?"; then
        echo "Select PHP version:"
        echo "1) PHP 8.3 (latest)"
        echo "2) PHP 8.2"
        echo "3) PHP 8.1"
        read -p "Choose (1-3): " php_version
        
        case $php_version in
            1) PHP_VERSION="8.3";;
            2) PHP_VERSION="8.2";;
            3) PHP_VERSION="8.1";;
            *) PHP_VERSION="8.3";;
        esac
        
        print_warning "Installing PHP $PHP_VERSION..."
        apt install software-properties-common -y
        add-apt-repository ppa:ondrej/php -y
        apt update
        
        apt install php${PHP_VERSION} php${PHP_VERSION}-cli php${PHP_VERSION}-common -y libapache2-mod-php${PHP_VERSION}
        
        if confirm "Do you want to install common PHP extensions? (mysql, pgsql, curl, xml, mbstring, zip, gd, intl, imap)"; then
            apt install php${PHP_VERSION}-mysql php${PHP_VERSION}-pgsql php${PHP_VERSION}-curl \
                        php${PHP_VERSION}-xml php${PHP_VERSION}-mbstring php${PHP_VERSION}-zip \
                        php${PHP_VERSION}-gd php${PHP_VERSION}-intl php${PHP_VERSION}-imap libapache2-mod-php${PHP_VERSION} -y
        fi
        
        if command -v php &> /dev/null; then
            print_success "PHP installed successfully!"
            php -v
            
            if confirm "Do you want to install Composer (PHP dependency manager)?"; then
                curl -sS https://getcomposer.org/installer | php
                mv composer.phar /usr/local/bin/composer
                chmod +x /usr/local/bin/composer
                print_success "Composer installed!"
            fi
        else
            print_error "Failed to install PHP"
        fi
        
        # Restart Apache if installed
        if systemctl is-active --quiet apache2; then
            systemctl restart apache2
        fi
    else
        print_warning "PHP installation skipped"
    fi
} 

# Install Node.js
install_nodejs() {
    print_header "STEP 6: Node.js Installation"
    
    if confirm "Do you want to install Node.js?"; then
        echo "Select Node.js version:"
        echo "1) Node.js 22.x LTS (recommended)"
        echo "2) Node.js 24.x LTS"
        echo "3) Node.js 25.x (current)"
        read -p "Choose (1-3): " node_version
        
        case $node_version in
            1) NODE_VERSION="22";;
            2) NODE_VERSION="24";;
            3) NODE_VERSION="25";;
            *) NODE_VERSION="22";;
        esac
        
        print_warning "Installing Node.js ${NODE_VERSION}.x..."
        curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -
        apt install nodejs -y
        
        if command -v node &> /dev/null; then
            print_success "Node.js installed successfully!"
            echo -e "Node.js: $(node -v)"
            echo -e "npm: $(npm -v)"
            
            if confirm "Do you want to install Yarn (alternative package manager)?"; then
                npm install -g yarn
                print_success "Yarn installed!"
            fi
        else
            print_error "Failed to install Node.js"
        fi
    else
        print_warning "Node.js installation skipped"
    fi
} 

# Install Docker
install_docker() {
    print_header "STEP 7: Docker Installation"
    
    if confirm "Do you want to install Docker?"; then
        print_warning "Installing Docker..."
        
        # Remove old versions
        apt remove docker docker-engine docker.io containerd runc 2>/dev/null
        
        # Install dependencies
        apt install ca-certificates curl gnupg lsb-release -y
        
        # Add Docker official GPG key
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        chmod a+r /etc/apt/keyrings/docker.gpg
        
        # Add repository
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        apt update
        apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
        
        if command -v docker &> /dev/null; then
            print_success "Docker installed successfully!"
            docker --version
            
            if confirm "Do you want to add your user to the docker group (avoid using sudo)?"; then
                read -p "Enter your username: " username
                usermod -aG docker $username
                print_success "User $username added to docker group"
                print_warning "Log out and log back in to apply the changes"
            fi
            
            if confirm "Enable Docker to start at boot?"; then
                systemctl enable docker
            fi
            
            systemctl start docker
        else
            print_error "Failed to install Docker"
        fi
    else
        print_warning "Docker installation skipped"
    fi
} 

# Install Python
install_python() {
    print_header "STEP 8: Python Installation"
    
    if confirm "Do you want to install/update Python?"; then
        print_warning "Installing Python 3 and tools..."
        apt install python3 python3-pip python3-venv python3-dev -y
        
        if command -v python3 &> /dev/null; then
            print_success "Python installed successfully!"
            python3 --version
            pip3 --version
            
            if confirm "Do you want to create an alias 'python' for 'python3'?"; then
                update-alternatives --install /usr/bin/python python /usr/bin/python3 1
                print_success "Alias created!"
            fi
            
            if confirm "Do you want to install pipenv (virtual environment manager)?"; then
                pip3 install pipenv
                print_success "Pipenv installed!"
            fi
        else
            print_error "Failed to install Python"
        fi
    else
        print_warning "Python installation skipped"
    fi
} 

# Install Git
install_git() {
    print_header "STEP 9: Git Installation"
    
    if confirm "Do you want to install Git?"; then
        print_warning "Installing Git..."
        apt install git -y
        
        if command -v git &> /dev/null; then
            print_success "Git installed successfully!"
            git --version
            
            if confirm "Do you want to configure Git now?"; then
                read -p "Enter your name: " git_name
                read -p "Enter your email: " git_email
                
                git config --global user.name "$git_name"
                git config --global user.email "$git_email"
                
                print_success "Git configured!"
                echo -e "Name: ${GREEN}$git_name${NC}"
                echo -e "Email: ${GREEN}$git_email${NC}"
                
                if confirm "Do you want to set the default editor to nano?"; then
                    git config --global core.editor nano
                fi
            fi
        else
            print_error "Failed to install Git"
        fi
    else
        print_warning "Git installation skipped"
    fi
} 

# Generate SSH key
generate_ssh_key() {
    print_header "STEP 10: SSH Key Generation"
    
    if confirm "Do you want to generate an SSH key?"; then
        read -p "Enter the email for the SSH key: " ssh_email
        read -p "Enter the filename (press Enter for default 'id_rsa'): " ssh_filename
        
        if [ -z "$ssh_filename" ]; then
            ssh_filename="id_rsa"
        fi
        
        # Ask which user to create the key for
        read -p "Enter the username (press Enter for root): " ssh_user
        if [ -z "$ssh_user" ]; then
            ssh_user="root"
            ssh_home="/root"
        else
            ssh_home="/home/$ssh_user"
        fi
        
        ssh_dir="$ssh_home/.ssh"
        
        # Create .ssh directory if it doesn't exist
        if [ ! -d "$ssh_dir" ]; then
            mkdir -p "$ssh_dir"
            chmod 700 "$ssh_dir"
            if [ "$ssh_user" != "root" ]; then
                chown $ssh_user:$ssh_user "$ssh_dir"
            fi
        fi
        
        ssh_file="$ssh_dir/$ssh_filename"
        
        if [ -f "$ssh_file" ]; then
            print_warning "An SSH key already exists at $ssh_file"
            if ! confirm "Do you want to overwrite it?"; then
                print_warning "SSH key generation cancelled"
                return
            fi
        fi
        
        echo "Select key type:"
        echo "1) RSA 4096 bits (recommended)"
        echo "2) ED25519 (more modern)"
        read -p "Choose (1-2): " key_type
        
        case $key_type in
            1)
                su - $ssh_user -c "ssh-keygen -t rsa -b 4096 -C '$ssh_email' -f '$ssh_file'"
                ;;
            2)
                su - $ssh_user -c "ssh-keygen -t ed25519 -C '$ssh_email' -f '$ssh_file'"
                ;;
            *)
                su - $ssh_user -c "ssh-keygen -t rsa -b 4096 -C '$ssh_email' -f '$ssh_file'"
                ;;
        esac
        
        if [ -f "$ssh_file" ]; then
            print_success "SSH key generated successfully!"
            echo -e "\nPublic key:"
            echo -e "${GREEN}$(cat ${ssh_file}.pub)${NC}"
            echo -e "\nKey locations:"
            echo -e "Private: ${GREEN}$ssh_file${NC}"
            echo -e "Public: ${GREEN}${ssh_file}.pub${NC}"
            
            print_warning "IMPORTANT: Never share your private key!"
            
            if confirm "Do you want to copy the public key to the clipboard?"; then
                if command -v xclip &> /dev/null; then
                    cat ${ssh_file}.pub | xclip -selection clipboard
                    print_success "Key copied to clipboard!"
                else
                    print_warning "xclip not installed. Please copy the key above manually."
                fi
            fi
        else
            print_error "Failed to generate SSH key"
        fi
    else
        print_warning "SSH key generation skipped"
    fi
} 

# Final summary
show_summary() {
    print_header "INSTALLATION SUMMARY"
    
    echo -e "${BLUE}Installed services and their status:${NC}\n"
    
    if command -v apache2 &> /dev/null; then
        if systemctl is-active --quiet apache2; then
            print_success "Apache: Installed and Running"
        else
            echo -e "${YELLOW}Apache: Installed but Stopped${NC}"
        fi
    fi
    
    if command -v mysql &> /dev/null; then
        if systemctl is-active --quiet mysql; then
            print_success "MySQL: Installed and Running"
        else
            echo -e "${YELLOW}MySQL: Installed but Stopped${NC}"
        fi
    fi
    
    if command -v psql &> /dev/null; then
        if systemctl is-active --quiet postgresql; then
            print_success "PostgreSQL: Installed and Running"
        else
            echo -e "${YELLOW}PostgreSQL: Installed but Stopped${NC}"
        fi
    fi
    
    if command -v php &> /dev/null; then
        print_success "PHP: Installed ($(php -v | head -n 1))"
    fi
    
    if command -v node &> /dev/null; then
        print_success "Node.js: Installed ($(node -v))"
    fi
    
    if command -v docker &> /dev/null; then
        print_success "Docker: Installed ($(docker --version))"
    fi
    
    if command -v python3 &> /dev/null; then
        print_success "Python: Installed ($(python3 --version))"
    fi
    
    if command -v git &> /dev/null; then
        print_success "Git: Installed ($(git --version))"
    fi
    
    echo -e "\n${GREEN}Installation completed!${NC}"
    echo -e "\n${YELLOW}Suggested next steps:${NC}"
    echo "1. Secure MySQL: sudo mysql_secure_installation"
    echo "2. Test Apache by visiting http://localhost"
    echo "3. If you installed Docker, log out and back in to use it without sudo"
    echo "4. Configure your applications in the appropriate directories"
    echo ""
} 

# Main function
main() {
    clear
    echo -e "${BLUE}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   Development Environment Setup Script                    ║
║                                                           ║
║   • Apache Web Server                                     ║
║   • MySQL Database                                        ║
║   • PostgreSQL Database                                   ║
║   • PHP                                                   ║
║   • Node.js                                               ║
║   • Docker                                                ║
║   • Python 3                                              ║
║   • Git                                                   ║
║   • SSH Key Generation                                    ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}\n"
    
    print_warning "This script will install and configure several development tools."
    print_warning "Ensure you have a stable internet connection."
    
    if ! confirm "Do you want to continue?"; then
        print_error "Installation cancelled by user"
        exit 0
    fi
    
    check_root
    
    # Run steps
    update_system
    install_apache
    install_mysql
    install_postgresql
    install_php
    install_nodejs
    install_docker
    install_python
    install_git
    generate_ssh_key
    
    # Show summary
    show_summary
}

# Executar script
main
