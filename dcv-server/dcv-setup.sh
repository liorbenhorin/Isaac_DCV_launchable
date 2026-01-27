#!/bin/bash
# Initial setup script run once by systemd

# Set ubuntu user password
echo "ubuntu:brevdemo123" | chpasswd

# Create DCV log directory
mkdir -p /var/log/dcv
chown -R dcv:dcv /var/log/dcv

# Setup runtime directory for ubuntu user
mkdir -p /run/user/1000
chown ubuntu:ubuntu /run/user/1000
chmod 700 /run/user/1000

echo "DCV initial setup complete"
