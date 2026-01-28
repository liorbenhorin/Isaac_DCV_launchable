FROM ubuntu:22.04

ENV container=docker
ENV DEBIAN_FRONTEND=noninteractive

# Install XFCE desktop environment and themes
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-terminal \
    thunar \
    openbox \
    elementary-xfce-icon-theme \
    adwaita-icon-theme-full \
    arc-theme \
    papirus-icon-theme \
    fonts-noto \
    fonts-noto-color-emoji \
    xsettingsd \
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
    x11-xserver-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Firefox from Mozilla PPA (not snap)
RUN add-apt-repository -y ppa:mozillateam/ppa \
    && echo 'Package: *' > /etc/apt/preferences.d/mozilla-firefox \
    && echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox \
    && echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox \
    && apt-get update \
    && apt-get install -y firefox \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install VSCode
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/packages.microsoft.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list \
    && apt-get update \
    && apt-get install -y code \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Nice DCV server
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

# Create ubuntu user
RUN useradd -m -u 1000 -s /bin/bash ubuntu \
    && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && usermod -aG video,render ubuntu

# Configure GTK themes for ubuntu user
RUN mkdir -p /home/ubuntu/.config/gtk-3.0 \
    && echo '[Settings]' > /home/ubuntu/.config/gtk-3.0/settings.ini \
    && echo 'gtk-theme-name=Arc-Dark' >> /home/ubuntu/.config/gtk-3.0/settings.ini \
    && echo 'gtk-icon-theme-name=Papirus-Dark' >> /home/ubuntu/.config/gtk-3.0/settings.ini \
    && echo 'gtk-font-name=Noto Sans 10' >> /home/ubuntu/.config/gtk-3.0/settings.ini \
    && echo 'gtk-theme-name="Arc-Dark"' > /home/ubuntu/.gtkrc-2.0 \
    && echo 'gtk-icon-theme-name="Papirus-Dark"' >> /home/ubuntu/.gtkrc-2.0 \
    && echo 'gtk-font-name="Noto Sans 10"' >> /home/ubuntu/.gtkrc-2.0 \
    && chown -R ubuntu:ubuntu /home/ubuntu/.config /home/ubuntu/.gtkrc-2.0

# Copy desktop shortcuts
COPY desktop/*.desktop /home/ubuntu/Desktop/
RUN chmod +x /home/ubuntu/Desktop/*.desktop \
    && chown -R ubuntu:ubuntu /home/ubuntu/Desktop

# Configure SSH
RUN mkdir -p /run/sshd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Copy DCV configuration
RUN mkdir -p /etc/dcv
COPY dcv.conf /etc/dcv/dcv.conf
COPY dcvsessioninit /etc/dcv/dcvsessioninit
RUN chmod +x /etc/dcv/dcvsessioninit

# Copy and apply wallpapers
COPY wallpapers/*.jpg /usr/share/backgrounds/dcv/
COPY scripts/setup-wallpapers.sh /tmp/setup-wallpapers.sh
RUN chmod +x /tmp/setup-wallpapers.sh && /tmp/setup-wallpapers.sh && rm /tmp/setup-wallpapers.sh

# Copy DCV setup script and systemd service
COPY dcv-setup.sh /usr/local/bin/dcv-setup.sh
COPY dcv-setup.service /etc/systemd/system/dcv-setup.service
RUN chmod +x /usr/local/bin/dcv-setup.sh

# Setup Isaac environment with Python 3.11 and uv
COPY scripts/setup-isaac.sh /tmp/setup-isaac.sh
RUN chmod +x /tmp/setup-isaac.sh && /tmp/setup-isaac.sh && rm /tmp/setup-isaac.sh

# Configure systemd services
RUN systemctl mask systemd-udevd.service \
    && systemctl mask systemd-oomd.service \
    && systemctl mask systemd-resolved.service \
    && systemctl mask networkd-dispatcher.service \
    && systemctl mask ModemManager.service \
    && systemctl mask acpid.service \
    && systemctl mask acpid.path \
    && systemctl mask acpid.socket \
    && systemctl mask snapd.service \
    && systemctl mask snapd.socket

RUN systemctl enable dcvserver.service \
    && systemctl enable ssh.service \
    && systemctl enable dcv-setup.service \
    && systemctl set-default multi-user.target

# Create entrypoint wrapper
RUN echo '#!/bin/bash' > /entrypoint.sh \
    && echo 'echo "127.0.0.1 dcv-server" >> /etc/hosts' >> /entrypoint.sh \
    && echo 'exec /sbin/init "$@"' >> /entrypoint.sh \
    && chmod +x /entrypoint.sh

EXPOSE 22 8443

ENTRYPOINT ["/entrypoint.sh"]
