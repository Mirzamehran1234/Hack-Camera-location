#!/bin/bash
# HACK-CAMERA Setup
# Production-grade dependencies and binary installer
# Supports: x86_64, arm64, armv7 (Kali, Ubuntu, Arch, WSL, Termux)

# --- Configuration ---
TUNNEL_DIR="$HOME/.tunnels"
BIN_DIR="$TUNNEL_DIR/bin"
LOG_DIR="$TUNNEL_DIR/logs"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Detect environment
detect_env() {
    ARCH=$(uname -m)
    if [[ -d "/data/data/com.termux/files/home" ]]; then
        ENV_TYPE="termux"
    elif grep -qi "microsoft" /proc/version 2>/dev/null; then
        ENV_TYPE="wsl"
    else
        ENV_TYPE="linux"
    fi
    log_info "Detected Architecture: $ARCH ($ENV_TYPE)"
}

# Install system dependencies
install_deps() {
    log_info "Updating system and installing dependencies..."
    
    if [[ "$ENV_TYPE" == "termux" ]]; then
        pkg update -y && pkg upgrade -y
        pkg install -y php curl wget unzip openssh proot termux-chroot
    else
        if command -v apt-get &>/dev/null; then
            sudo apt-get update -y
            sudo apt-get install -y php curl wget unzip openssh-client tar
        elif command -v pacman &>/dev/null; then
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm php curl wget unzip openssh tar
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y php curl wget unzip openssh-clients tar
        else
            log_error "Unsupported package manager. Please install php, curl, wget, unzip, openssh, tar manually."
        fi
    fi
}

# Download tunneling binaries
download_binaries() {
    mkdir -p "$BIN_DIR" "$LOG_DIR"
    
    # 1. Cloudflared
    if [[ ! -f "$BIN_DIR/cloudflared" ]]; then
        log_info "Downloading cloudflared..."
        local cf_url=""
        case "$ARCH" in
            x86_64)  cf_url="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64" ;;
            aarch64|arm64) cf_url="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64" ;;
            armv7l|armhf) cf_url="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm" ;;
            *) log_error "Cloudflared not available for $ARCH";;
        esac
        if [[ -n "$cf_url" ]]; then
            curl -L "$cf_url" -o "$BIN_DIR/cloudflared" && chmod +x "$BIN_DIR/cloudflared"
        fi
    fi

    # 2. Ngrok
    if [[ ! -f "$BIN_DIR/ngrok" ]]; then
        log_info "Downloading ngrok..."
        local nk_url=""
        case "$ARCH" in
            x86_64)  nk_url="https://bin.equinox.io/c/bPRBhCQUSTH/ngrok-v3-stable-linux-amd64.tgz" ;;
            aarch64|arm64) nk_url="https://bin.equinox.io/c/bPRBhCQUSTH/ngrok-v3-stable-linux-arm64.tgz" ;;
            armv7l|armhf) nk_url="https://bin.equinox.io/c/bPRBhCQUSTH/ngrok-v3-stable-linux-arm.tgz" ;;
            *) log_error "Ngrok not available for $ARCH";;
        esac
        if [[ -n "$nk_url" ]]; then
            curl -L "$nk_url" -o "$BIN_DIR/ngrok.tgz"
            tar -xzf "$BIN_DIR/ngrok.tgz" -C "$BIN_DIR" && rm "$BIN_DIR/ngrok.tgz"
            chmod +x "$BIN_DIR/ngrok"
        fi
    fi
}

main() {
    detect_env
    install_deps
    download_binaries
    
    if [[ "$ENV_TYPE" == "termux" ]]; then
        termux-setup-storage
        termux-fix-shebang hack_camera.sh
    fi
    
    log_success "Setup completed successfully!"
    echo -e "Run the tool with: ${YELLOW}bash hack_camera.sh${NC}"
}

main "$@"
