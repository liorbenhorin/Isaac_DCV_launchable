#!/bin/bash
# Setup Isaac environment with Python 3.11 and uv

set -e

# Install Python 3.11
apt-get update
apt-get install -y software-properties-common
add-apt-repository -y ppa:deadsnakes/ppa
apt-get update
apt-get install -y python3.11 python3.11-venv python3.11-dev
apt-get clean
rm -rf /var/lib/apt/lists/*

# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Copy uv to system-wide location
cp /root/.local/bin/uv /usr/local/bin/
cp /root/.local/bin/uvx /usr/local/bin/

# Create uv venv called isaac in /opt/isaac
mkdir -p /opt/isaac
cd /opt/isaac
uv venv isaac --python python3.11

# Install Isaac Sim packages
source isaac/bin/activate
uv pip install "isaacsim[all,extscache]==5.1.0" --extra-index-url https://pypi.nvidia.com
uv pip install -U torch==2.7.0 torchvision==0.22.0 --index-url https://download.pytorch.org/whl/cu128

# Make the venv owned by ubuntu user with proper write permissions
chmod -R u+w /opt/isaac/isaac
chown -R ubuntu:ubuntu /opt/isaac

echo "Isaac environment setup complete"
