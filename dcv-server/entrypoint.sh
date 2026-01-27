#!/bin/bash
set -e

echo "Starting DCV Server container..."

# Set ubuntu user password
echo "ubuntu:brevdemo123" | chpasswd
echo "Ubuntu user password set"

# Start SSH service
echo "Starting SSH service..."
/usr/sbin/sshd
if [ $? -eq 0 ]; then
    echo "SSH service started successfully"
else
    echo "Failed to start SSH service"
fi

# Start dbus (required for GNOME)
echo "Starting dbus..."
mkdir -p /run/dbus
rm -f /var/run/dbus/pid
dbus-daemon --system --fork
sleep 2

# Configure display and runtime directory
export DISPLAY=:0
export XDG_SESSION_TYPE=x11
export XDG_RUNTIME_DIR=/run/user/1000
mkdir -p $XDG_RUNTIME_DIR
chown ubuntu:ubuntu $XDG_RUNTIME_DIR
chmod 700 $XDG_RUNTIME_DIR

# Create DCV log directory
mkdir -p /var/log/dcv
chown -R dcv:dcv /var/log/dcv

# Start X server directly
echo "Starting X server..."
rm -f /tmp/.X0-lock /tmp/.X11-unix/X0
Xorg :0 -seat seat0 -auth /run/user/1000/gdm/Xauthority -nolisten tcp vt1 -novtswitch &
X_PID=$!
sleep 5

# Verify X is running
if ! ps -p $X_PID > /dev/null; then
    echo "ERROR: X server failed to start!"
    exit 1
fi
echo "X server started (PID: $X_PID)"

# Wait for X server to be ready
echo "Waiting for X server to be ready..."
for i in {1..30}; do
    if xdpyinfo -display :0 >/dev/null 2>&1; then
        echo "X server is ready"
        break
    fi
    sleep 1
done

# Start GNOME session as ubuntu user
echo "Starting GNOME session..."
runuser -u ubuntu -- env DISPLAY=:0 XDG_SESSION_TYPE=x11 XDG_RUNTIME_DIR=/run/user/1000 gnome-session &
GNOME_PID=$!
sleep 5
echo "GNOME session started (PID: $GNOME_PID)"

# Start DCV server (must run as dcv user, using wrapper script)
echo "Starting DCV server..."
# Run in foreground initially to see errors
su -s /bin/bash dcv -c "DISPLAY=:0 /usr/bin/dcvserver 2>&1 | tee /tmp/dcv-startup.log" &
DCV_PID=$!
sleep 10

# Check if DCV server process exists
if pgrep -x dcvserver > /dev/null; then
    echo "DCV server is running (PID: $(pgrep dcvserver))"
else
    echo "ERROR: DCV server failed to start!"
    echo "Startup log:"
    cat /tmp/dcv-startup.log 2>/dev/null || echo "No startup log found"
    cat /var/log/dcv/server.log 2>/dev/null || echo "No server log found"
    exit 1
fi

# Wait for DCV to be fully ready
echo "Waiting for DCV server to be ready..."
sleep 10

# List sessions
echo "=============================================="
echo "Active DCV sessions:"
dcv list-sessions || echo "No sessions yet (will be created automatically)"
echo "=============================================="
echo "DCV Server is ready!"
echo "=============================================="
echo "Access via:"
echo "  DCV: https://<host>:8443"
echo "  SSH: ssh ubuntu@<host>"
echo "Credentials:"
echo "  Username: ubuntu"
echo "  Password: brevdemo123"
echo "=============================================="

# Keep container running
echo "Container is running. Tailing logs..."
tail -f /var/log/dcv/server.log /var/log/dcv/sessionlauncher.log 2>/dev/null || tail -f /dev/null
