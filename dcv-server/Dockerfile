FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install base packages and GNOME desktop
RUN apt-get update && apt-get install -y \
    ubuntu-desktop \
    gnome-shell \
    gnome-terminal \
    nautilus \
    firefox \
    openssh-server \
    sudo \
    wget \
    curl \
    unzip \
    vim \
    git \
    software-properties-common \
    mesa-utils \
    x11-apps \
    dbus-x11 \
    xvfb \
    x11vnc \
    metacity \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install VSCode
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/packages.microsoft.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list \
    && apt-get update \
    && apt-get install -y code \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download and install Nice DCV server
RUN wget https://d1uj6qtbmh3dt5.cloudfront.net/2023.1/Servers/nice-dcv-2023.1-16388-ubuntu2204-x86_64.tgz \
    && tar -xvzf nice-dcv-2023.1-16388-ubuntu2204-x86_64.tgz \
    && cd nice-dcv-2023.1-16388-ubuntu2204-x86_64 \
    && apt-get update \
    && apt-get install -y ./nice-dcv-server_2023.1.16388-1_amd64.ubuntu2204.deb \
    && apt-get install -y ./nice-dcv-web-viewer_2023.1.16388-1_amd64.ubuntu2204.deb \
    && apt-get install -y ./nice-xdcv_2023.1.565-1_amd64.ubuntu2204.deb \
    && apt-get install -y ./nice-dcv-gl_2023.1.1047-1_amd64.ubuntu2204.deb \
    && cd .. \
    && rm -rf nice-dcv-2023.1-16388-ubuntu2204-x86_64* \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create ubuntu user with UID 1000
RUN useradd -m -u 1000 -s /bin/bash ubuntu \
    && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && usermod -aG video,render ubuntu

# Configure SSH
RUN mkdir -p /run/sshd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Configure GDM3 to use X11 instead of Wayland
RUN echo "[daemon]" > /etc/gdm3/custom.conf \
    && echo "WaylandEnable=false" >> /etc/gdm3/custom.conf \
    && echo "AutomaticLoginEnable=false" >> /etc/gdm3/custom.conf

# Create DCV configuration directory
RUN mkdir -p /etc/dcv

# Copy DCV configuration
COPY dcv.conf /etc/dcv/dcv.conf

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose ports
EXPOSE 22 8443

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
