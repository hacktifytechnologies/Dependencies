#!/bin/bash
# =============================================================================
# pre_install_dependencies.sh
# =============================================================================

set -e

export DEBIAN_FRONTEND=noninteractive

echo "[*] Waiting for apt lock..."
while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
    sleep 2
done

echo "[*] Updating package index..."
apt update

echo "[*] Installing base dependencies..."
apt install -y \
    apache2 \
    libapache2-mod-php \
    php \
    php-mysql \
    gcc \
    libcap2-bin \
    openssh-server \
    git \
    wget \
    curl \
    unzip \
    python3-pip \
    ca-certificates \
    gnupg \
    lsb-release \
    apt-transport-https \
    software-properties-common \
    nodejs

# -----------------------------------------------------------------------------
# Install Docker (official repo - docker-ce)
# -----------------------------------------------------------------------------
echo "[*] Installing Docker (official repo)..."

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    gpg --dearmor -o /etc/apt/keyrings/docker.gpg

chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update

apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# -----------------------------------------------------------------------------
# Python dependencies
# -----------------------------------------------------------------------------
echo "[*] Installing Python packages..."
pip3 install flask paramiko --break-system-packages

# -----------------------------------------------------------------------------
# Enable services
# -----------------------------------------------------------------------------
echo "[*] Enabling services at boot..."
systemctl enable apache2 ssh docker || true

# -----------------------------------------------------------------------------
# SSH Configuration
# -----------------------------------------------------------------------------
echo "[*] Enabling SSH password authentication..."

sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config

systemctl restart ssh

# -----------------------------------------------------------------------------
# PHP Configuration
# -----------------------------------------------------------------------------
echo "[*] Applying PHP config for lab use..."

find /etc/php/ -type f -name php.ini -exec sed -i \
    -e 's/allow_url_include = Off/allow_url_include = On/' \
    -e 's|^open_basedir =.*|open_basedir = ;|' {} + 2>/dev/null || true

# -----------------------------------------------------------------------------
# Apache Configuration
# -----------------------------------------------------------------------------
echo "[*] Enabling Apache rewrite module..."
a2enmod rewrite
systemctl restart apache2

# -----------------------------------------------------------------------------
echo ""
echo "============================================"
echo "  All dependencies installed successfully."
echo "  Take your VM snapshot NOW."
echo "============================================"
