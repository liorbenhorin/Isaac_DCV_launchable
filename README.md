# NiceDCV Brev Launchable

A Brev launchable that provides a complete Ubuntu 22.04 GNOME desktop environment with NICE DCV remote desktop access and GPU acceleration support.

## Overview

This launchable provides:
- **Remote Desktop**: NICE DCV server with web and native client support
- **SSH Access**: Standard SSH access for terminal operations
- **GNOME Desktop**: Full Ubuntu 22.04 GNOME desktop environment
- **GPU Acceleration**: NVIDIA GPU support for graphics and compute
- **Pre-installed Software**: Firefox, VSCode, and essential development tools

## Architecture

```
User Browser/Client → Nginx (SSL) → DCV Server (GNOME Desktop + GPU)
User SSH Client → Nginx → DCV Server (SSH)
```

## Prerequisites

- Brev account with access to GPU instances
- NVIDIA GPU-enabled instance
- Docker and Docker Compose installed
- Ports 22, 80, 443, and 8443 available

## Quick Start

### 1. Clone and Deploy

```bash
git clone <repository-url>
cd DCV_launchable
docker compose up -d
```

### 2. Check Status

```bash
docker compose ps
docker compose logs -f dcv-server
```

### 3. Connect

**DCV Web Client:**
- URL: `https://<instance-ip>:8443`
- Username: `ubuntu`
- Password: `brevdemo123`

**DCV Native Client:**
- Download from: https://download.nice-dcv.com/
- Server: `<instance-ip>:8443`
- Username: `ubuntu`
- Password: `brevdemo123`

**SSH Access:**
```bash
ssh ubuntu@<instance-ip>
# Password: brevdemo123
```

## Configuration

### Default Credentials

- **Username**: `ubuntu`
- **Password**: `brevdemo123`
- **Sudo**: Passwordless sudo enabled

### Ports

- **22**: SSH access
- **80**: HTTP (redirects to HTTPS)
- **443**: HTTPS (proxies to DCV)
- **8443**: DCV server (internal)

### DCV Settings

The DCV server is configured with:
- Console session for `ubuntu` user
- System authentication (PAM)
- 25 FPS target frame rate
- QUIC protocol enabled
- Clipboard integration
- Stylus and touch input support

Configuration file: `dcv-server/dcv.conf`

## GPU Support

The container has access to all NVIDIA GPUs with full capabilities:
- GPU compute
- Graphics acceleration
- Display output
- CUDA support

Verify GPU access:
```bash
docker compose exec dcv-server nvidia-smi
```

## Volumes

- `dcv-home`: Persistent home directory for ubuntu user
- `dcv-cache`: System cache directory

## Troubleshooting

### DCV Server Not Starting

Check logs:
```bash
docker compose logs dcv-server
```

Verify DCV server is running:
```bash
docker compose exec dcv-server pgrep dcvserver
```

List DCV sessions:
```bash
docker compose exec dcv-server dcv list-sessions
```

### Cannot Connect to DCV

1. Verify nginx is running:
```bash
docker compose logs nginx
```

2. Check port accessibility:
```bash
netstat -tlnp | grep -E '(443|8443)'
```

3. Verify SSL certificate:
```bash
docker compose exec nginx ls -la /etc/nginx/ssl/
```

### SSH Connection Issues

1. Verify SSH service is running:
```bash
docker compose exec dcv-server pgrep sshd
```

2. Test SSH locally:
```bash
ssh -p 22 ubuntu@localhost
```

### Display Issues

1. Check DISPLAY environment:
```bash
docker compose exec dcv-server echo $DISPLAY
```

2. Verify GDM3 is running:
```bash
docker compose exec dcv-server pgrep gdm3
```

3. Check X11 socket:
```bash
docker compose exec dcv-server ls -la /tmp/.X11-unix/
```

### GPU Not Detected

1. Verify NVIDIA runtime:
```bash
docker info | grep -i nvidia
```

2. Check GPU access in container:
```bash
docker compose exec dcv-server nvidia-smi
```

3. Verify video group membership:
```bash
docker compose exec dcv-server groups ubuntu
```

## Customization

### Change Password

Edit `dcv-server/entrypoint.sh` and change the line:
```bash
echo "ubuntu:1234" | chpasswd
```

### Install Additional Software

Add packages to `dcv-server/Dockerfile`:
```dockerfile
RUN apt-get update && apt-get install -y \
    your-package-here \
    && apt-get clean
```

### Modify DCV Settings

Edit `dcv-server/dcv.conf` to customize:
- Frame rate: `target-fps`
- Authentication: `authentication`
- Clipboard: `primary-selection-paste`
- And more...

## Brev Integration

### Brev Setup Script

Create a `brev-setup.sh` in your Brev instance:

```bash
#!/bin/bash
set -e

echo "Setting up DCV Launchable..."

# Clone repository
git clone <your-repo-url> ~/dcv-launchable
cd ~/dcv-launchable

# Start services
docker compose up -d

# Wait for services to be ready
echo "Waiting for services to start..."
sleep 30

# Show connection info
echo "=========================================="
echo "DCV Server is ready!"
echo "=========================================="
echo "DCV Web: https://$(curl -s ifconfig.me):8443"
echo "SSH: ssh ubuntu@$(curl -s ifconfig.me)"
echo "Username: ubuntu"
echo "Password: brevdemo123"
echo "=========================================="
```

Make it executable:
```bash
chmod +x brev-setup.sh
```

## Security Considerations

⚠️ **Important Security Notes:**

1. **Default Password**: The default password `brevdemo123` is insecure. Change it for production use.
2. **Self-Signed Certificate**: Nginx uses a self-signed SSL certificate. Your browser will show a warning.
3. **Privileged Container**: The DCV container runs in privileged mode for display manager access.
4. **Host Network**: Containers use host networking for simplicity. Consider bridge networking for isolation.

## Development

### Build Images

```bash
docker compose build
```

### Rebuild and Restart

```bash
docker compose down
docker compose up -d --build
```

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f dcv-server
docker compose logs -f nginx
```

### Shell Access

```bash
docker compose exec dcv-server bash
docker compose exec nginx sh
```

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

[Your License Here]

## Support

For issues and questions:
- GitHub Issues: [Your Repo URL]
- Documentation: [Your Docs URL]

## Acknowledgments

- NICE DCV by AWS
- Ubuntu and GNOME projects
- OpenResty/Nginx
- Brev.dev platform
