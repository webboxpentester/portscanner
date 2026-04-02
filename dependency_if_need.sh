#for_settings_up 10101010

set -e

# Detect if running in Termux
IS_TERMUX=false
if [ -d "/data/data/com.termux" ] || command -v termux-info >/dev/null 2>&1; then
    IS_TERMUX=true
    echo "[*] Termux environment detected"
else
    echo "[*] Linux environment detected"
fi

echo "[*] Starting nmap installation..."

# Function to check if nmap is installed
check_nmap() {
    if command -v nmap >/dev/null 2>&1; then
        echo "[✓] nmap is already installed"
        nmap --version | head -n1
        return 0
    else
        return 1
    fi
}

# Check if already installed
if check_nmap; then
    echo "[*] Installation not needed"
    echo "done"
    exit 0
fi

# Package manager selection
if [ "$IS_TERMUX" = true ]; then
    echo "[*] Installing nmap via Termux pkg..."
    pkg update -y
    pkg install -y nmap
else
    # Detect Linux distribution and install accordingly
    if command -v apt >/dev/null 2>&1; then
        echo "[*] Debian/Ubuntu detected - installing via apt..."
        sudo apt update -y
        sudo apt install -y nmap
        
    elif command -v dnf >/dev/null 2>&1; then
        echo "[*] Fedora/RHEL detected - installing via dnf..."
        sudo dnf install -y nmap
        
    elif command -v yum >/dev/null 2>&1; then
        echo "[*] CentOS/RHEL detected - installing via yum..."
        sudo yum install -y nmap
        
    elif command -v pacman >/dev/null 2>&1; then
        echo "[*] Arch Linux detected - installing via pacman..."
        sudo pacman -Syu --noconfirm
        sudo pacman -S --noconfirm nmap
        
    elif command -v zypper >/dev/null 2>&1; then
        echo "[*] openSUSE detected - installing via zypper..."
        sudo zypper refresh
        sudo zypper install -y nmap
        
    elif command -v apk >/dev/null 2>&1; then
        echo "[*] Alpine Linux detected - installing via apk..."
        sudo apk update
        sudo apk add nmap
        
    else
        echo "[!] Unsupported package manager"
        echo "[*] Trying to install from source..."
        
        # Install from source as fallback
        cd /tmp
        echo "[*] Downloading nmap source..."
        wget https://nmap.org/dist/nmap-7.94.tar.bz2
        tar -xjf nmap-7.94.tar.bz2
        cd nmap-7.94
        echo "[*] Configuring..."
        ./configure
        echo "[*] Compiling (this may take a while)..."
        make
        echo "[*] Installing..."
        sudo make install
        cd ~
        rm -rf /tmp/nmap-7.94*
        echo "[*] Installed from source"
    fi
fi

# Verify installation
echo ""
if check_nmap; then
    echo "[✓] nmap installation successful"
    
    # Create a simple alias or wrapper if needed (optional)
    SHELL_CONFIG="$HOME/.bashrc"
    if [ -f "$HOME/.zshrc" ]; then
        SHELL_CONFIG="$HOME/.zshrc"
    fi
    
    # Add nmap common aliases if not exists (optional feature)
    if ! grep -q "alias nmap-scan=" "$SHELL_CONFIG" 2>/dev/null; then
        echo "" >> "$SHELL_CONFIG"
        echo "# Nmap aliases" >> "$SHELL_CONFIG"
        echo "alias nmap-quick='nmap -T4 -F'" >> "$SHELL_CONFIG"
        echo "alias nmap-full='nmap -T4 -p-'" >> "$SHELL_CONFIG"
        echo "alias nmap-os='nmap -O -sV'" >> "$SHELL_CONFIG"
        echo "[*] Added nmap aliases to $SHELL_CONFIG"
    fi
    
else
    echo "[✗] nmap installation failed"
    exit 1
fi

echo ""
echo "done"