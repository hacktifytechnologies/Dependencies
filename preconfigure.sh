#!/bin/bash
# =============================================================================
# pre_install_dependencies.sh
# Pre-installs ALL packages needed by every OS challenge setup.sh.
# Bake this into your base VM snapshot BEFORE launching any challenge.
#
# Packages installed:
#   apache2          — Rootbound, Revroot, TOCTOU, RepoLeak
#   libapache2-mod-php — Rootbound
#   php              — Rootbound, Revroot, TOCTOU, RepoLeak
#   php-mysql        — RepoLeak
#   gcc              — Revroot
#   libcap2-bin      — Revroot (setcap)
#   openssh-server   — Revroot, TOCTOU, RotateSu, RepoLeak
#   git              — RepoLeak
#   docker.io        — RepoLeak
#   wget             — RepoLeak
#   curl             — RepoLeak
#   unzip            — RepoLeak
# =============================================================================

set -e

echo "[*] Waiting for apt lock..."
while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
    sleep 2
done

echo "[*] Updating package index..."
apt update -y

echo "[*] Installing all challenge dependencies..."
apt install -y \
    apache2 \
    libapache2-mod-php \
    php \
    php-mysql \
    gcc \
    libcap2-bin \
    openssh-server \
    git \
    docker.io \
    wget \
    curl \
    unzip \ 
    python3-pip \
    curl \
    git \
    wget \
    ca-certificates \
    gnupg \
    lsb-release \
    apt-transport-https \
    software-properties-common \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin \
    nodejs

pip3 install flask random paramiko  --break-system-packages

echo "[*] Enabling services at boot..."
systemctl enable apache2 ssh docker 2>/dev/null || true

echo "[*] Enabling SSH password authentication..."
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

echo "[*] Applying PHP config for lab use..."
sed -i 's/allow_url_include = Off/allow_url_include = On/' /etc/php/*/apache2/php.ini 2>/dev/null || true
sed -i 's/open_basedir =.*/open_basedir = ;/' /etc/php/*/apache2/php.ini 2>/dev/null || true

echo "[*] Enabling Apache rewrite module..."
a2enmod rewrite

echo ""
echo "============================================"
echo "  All dependencies installed successfully."
echo "  Take your VM snapshot NOW."
echo "============================================"
