# DCV Server Container

Ubuntu 22.04 container with GNOME desktop, NICE DCV server, and SSH access.

## Contents

- **Base**: Ubuntu 22.04 LTS
- **Desktop**: GNOME 42
- **Display Server**: X11 (Wayland disabled)
- **DCV Server**: NICE DCV 2023.1
- **SSH Server**: OpenSSH
- **Pre-installed Apps**:
  - Firefox
  - Visual Studio Code
  - GNOME Terminal
  - Nautilus file manager
  - Git, Vim, Curl, Wget

## Configuration Files

### dcv.conf

Main DCV server configuration:
- **Session Management**: Automatic console session creation
- **Authentication**: System (PAM) authentication
- **Connectivity**: QUIC enabled, web client on port 8443
- **Display**: 25 FPS target, configurable resolution
- **Input**: Clipboard, stylus, and touch support

Key settings you can modify:
```ini
[display]
target-fps=25  # Adjust for performance/quality tradeoff

[connectivity]
web-port=8443  # DCV web client port

[security]
authentication="system"  # Use system PAM authentication
```

### entrypoint.sh

Startup script that:
1. Sets ubuntu user password
2. Creates PAM service for DCV authentication
3. Starts SSH service
4. Starts D-Bus daemon
5. Configures display environment
6. Starts GDM3 display manager
7. Starts DCV server
8. Creates console session for ubuntu user

## User Configuration

### Default User

- **Username**: ubuntu
- **UID**: 1000
- **Password**: brevdemo123
- **Shell**: /bin/bash
- **Sudo**: Passwordless sudo enabled
- **Groups**: sudo, video, render

### Changing Password

Edit `entrypoint.sh`:
```bash
echo "ubuntu:YOUR_NEW_PASSWORD" | chpasswd
```

Current default password is `brevdemo123`.

Or set via environment variable in docker-compose.yml:
```yaml
environment:
  - UBUNTU_PASSWORD=newpassword
```

Then update entrypoint.sh to use it:
```bash
echo "ubuntu:${UBUNTU_PASSWORD:-1234}" | chpasswd
```

## GPU Configuration

The container has access to NVIDIA GPUs via Docker's GPU runtime:

```yaml
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: all
          capabilities: [gpu, utility, compute, graphics, display]
```

### Verify GPU Access

Inside container:
```bash
nvidia-smi
glxinfo | grep "OpenGL renderer"
```

### GPU Requirements

- NVIDIA GPU with driver 450+ installed on host
- NVIDIA Container Toolkit installed
- Docker configured with nvidia runtime

## Display Configuration

### X11 vs Wayland

The container is configured to use X11 instead of Wayland for better DCV compatibility:

```
/etc/gdm3/custom.conf:
[daemon]
WaylandEnable=false
```

### Display Environment

```bash
DISPLAY=:0
XDG_SESSION_TYPE=x11
XDG_RUNTIME_DIR=/run/user/1000
```

## Networking

### Exposed Ports

- **22**: SSH
- **8443**: DCV server

### Host Network Mode

The container uses `network_mode: "host"` for:
- Simplified networking
- Direct port access
- Better performance
- GPU/display manager compatibility

## Volumes

### Persistent Data

- **/home/ubuntu**: User home directory (mounted as dcv-home volume)
- **/var/cache**: System cache (mounted as dcv-cache volume)

### Temporary

- **/tmp/.X11-unix**: X11 socket (mounted from host)

## Troubleshooting

### DCV Server Won't Start

Check prerequisites:
```bash
# Verify dbus is running
pgrep dbus-daemon

# Check display manager
pgrep gdm3

# Check DCV server logs
tail -f /var/log/dcv/server.log
```

### Session Creation Fails

Manual session creation:
```bash
dcv create-session --type=console --owner ubuntu mysession
dcv list-sessions
```

Delete and recreate:
```bash
dcv close-session console
dcv create-session --type=console --owner ubuntu console
```

### Display Issues

Check X11:
```bash
echo $DISPLAY
ls -la /tmp/.X11-unix/
xrandr  # List displays
```

Restart display manager:
```bash
systemctl restart gdm3
```

### GPU Not Working

Verify GPU access:
```bash
nvidia-smi
ls -la /dev/nvidia*
groups ubuntu  # Should include video and render
```

Test OpenGL:
```bash
glxinfo
glxgears
```

## Customization

### Installing Additional Software

Add to Dockerfile:
```dockerfile
RUN apt-get update && apt-get install -y \
    package-name \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
```

### Desktop Environment Changes

To use a different desktop environment, modify the Dockerfile:
```dockerfile
# Instead of ubuntu-desktop, use:
RUN apt-get install -y xfce4  # For XFCE
# or
RUN apt-get install -y kde-plasma-desktop  # For KDE
```

### DCV Version

To use a different DCV version, update the download URL in Dockerfile:
```dockerfile
RUN wget https://d1uj6qtbmh3dt5.cloudfront.net/YYYY.X/Servers/nice-dcv-YYYY.X-XXXXX-ubuntu2204-x86_64.tgz
```

Check available versions: https://download.nice-dcv.com/

## Security

### PAM Authentication

DCV uses PAM (Pluggable Authentication Modules) for authentication. The PAM service file `/etc/pam.d/dcv` is created by the entrypoint script.

### SSH Security

- Root login disabled
- Password authentication enabled (for ubuntu user)
- Consider adding SSH key authentication for production

### Sudo Access

The ubuntu user has passwordless sudo. To require password:
```bash
# Remove from /etc/sudoers.d/ or change line to:
ubuntu ALL=(ALL) ALL
```

## Performance Tuning

### DCV Frame Rate

Adjust in dcv.conf:
```ini
[display]
target-fps=30  # Higher = smoother, more bandwidth
```

### Compression

Adjust in dcv.conf:
```ini
[display]
target-quality=80  # 0-100, higher = better quality, more bandwidth
```

### Resolution

Set at connection time or via DCV console:
```bash
dcv set-display-layout --session console --width 1920 --height 1080
```

## References

- [NICE DCV Documentation](https://docs.aws.amazon.com/dcv/)
- [NICE DCV Downloads](https://download.nice-dcv.com/)
- [Ubuntu Desktop Guide](https://ubuntu.com/desktop)
- [GNOME Documentation](https://help.gnome.org/)
