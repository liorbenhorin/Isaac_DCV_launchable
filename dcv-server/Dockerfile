FROM liorbenhorin/isaac-dcv-base:latest

# Setup Isaac environment with Python 3.11 and uv
COPY scripts/setup-isaac.sh /tmp/setup-isaac.sh
RUN chmod +x /tmp/setup-isaac.sh && /tmp/setup-isaac.sh && rm /tmp/setup-isaac.sh

# Auto-activate isaac venv in bashrc
RUN echo "" >> /home/ubuntu/.bashrc \
    && echo "# Auto-activate isaac virtual environment" >> /home/ubuntu/.bashrc \
    && echo "source /home/ubuntu/.isaac/isaac/bin/activate" >> /home/ubuntu/.bashrc

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
