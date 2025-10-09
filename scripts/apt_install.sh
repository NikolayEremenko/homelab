#!/usr/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

print_status "Updating package list..."
sudo apt update

print_status "Installing required dependencies..."
sudo apt install -y curl wget apt-transport-https ca-certificates gnupg lsb-release

# Install Helm
print_status "Installing Helm..."
if command_exists helm; then
    print_warning "Helm is already installed. Skipping..."
else
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

    print_status "Helm installed successfully!"
fi

# Install kubectl
print_status "Installing Kubectl..."
if command_exists kubectl; then
    print_warning "Kubectl is already installed. Skipping..."
else
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo apt update
    sudo apt install -y kubectl

    print_status "Add completion to zsh"
    echo 'source <(kubectl completion zsh)' >> ~/.kctlcomplection
    echo 'alias k=kubectl' > ~/.kctlcomplection
    echo 'source ~/.kctlcomplection' >> ~/.zshrc
    source ~/.zshrc

    print_status "kubectl installed successfully!"
fi