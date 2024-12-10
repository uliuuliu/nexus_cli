#!/bin/bash

BOLD=$(tput bold)
NORMAL=$(tput sgr0)
PINK='\033[1;35m'

# Убедитесь, что figlet установлен
if ! command -v figlet &> /dev/null; then
    echo "Installing figlet for large text output..."
    sudo apt install figlet -y
fi

show() {
    case $2 in
        "error")
            echo -e "${PINK}${BOLD}❌ $1${NORMAL}"
            ;;
        "progress")
            echo -e "${PINK}${BOLD}⏳ $1${NORMAL}"
            ;;
        *)
            echo -e "${PINK}${BOLD}✅ $1${NORMAL}"
            ;;
    esac
}

# Приветствие с большими буквами
echo -e "${PINK}${BOLD}Welcome to the Nexus CLI installation by snoopfear!${NORMAL}"
sleep 3  # Пауза 3 секунды

# Используем figlet для большего текста
figlet -f slant "Nexus CLI"  # Вывод большими буквами

echo -e "${PINK}${BOLD}Starting the installation process...\n${NORMAL}"

SERVICE_NAME="nexus"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"
NEXUS_HOME="$HOME/.nexus"
PROVER_ID="zNbgtcBhgteJ1EzBt6L0f5mNujY2"

# Убедимся, что директория $NEXUS_HOME существует
if [ ! -d "$NEXUS_HOME" ]; then
    show "Creating Nexus home directory..." "progress"
    mkdir -p "$NEXUS_HOME"
fi

# Запишем prover-id в файл
show "Saving Prover ID to $NEXUS_HOME/prover-id..." "progress"
echo "$PROVER_ID" > $NEXUS_HOME/prover-id
show "Prover ID saved to $NEXUS_HOME/prover-id."

# Обновление пакетов и установка зависимостей
show "Updating and upgrading system..." "progress"
if ! sudo apt update && sudo apt upgrade -y; then
    show "Failed to update and upgrade system." "error"
    exit 1
fi

show "Installing essential packages..." "progress"
if ! sudo apt install build-essential pkg-config libssl-dev git-all -y; then
    show "Failed to install essential packages." "error"
    exit 1
fi

show "Installing protobuf compiler..." "progress"
if ! sudo apt install -y protobuf-compiler; then
    show "Failed to install protobuf compiler." "error"
    exit 1
fi

show "Installing cargo (Rust package manager)..." "progress"
if ! sudo apt install cargo -y; then
    show "Failed to install cargo." "error"
    exit 1
fi

# Проверка, установлен ли rustup
if ! command -v rustup &> /dev/null; then
    show "Installing Rust..." "progress"
    if ! curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y; then
        show "Failed to install Rust." "error"
        exit 1
    fi
else
    show "Rust is already installed."
fi

# Настройка Rust
source $HOME/.cargo/env
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
rustup update

show "Updating package list..." "progress"
if ! sudo apt update; then
    show "Failed to update package list." "error"
    exit 1
fi

if ! command -v git &> /dev/null; then
    show "Git is not installed. Installing git..." "progress"
    if ! sudo apt install git -y; then
        show "Failed to install git." "error"
        exit 1
    fi
else
    show "Git is already installed."
fi

if [ -d "$HOME/network-api" ]; then
    show "Deleting existing repository..." "progress"
    rm -rf "$HOME/network-api"
fi

sleep 3

show "Cloning Nexus-XYZ network API repository..." "progress"
if ! git clone https://github.com/nexus-xyz/network-api.git "$HOME/network-api"; then
   
