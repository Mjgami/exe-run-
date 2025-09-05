FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:0
ENV WINEDEBUG=-all

# Enable 32-bit architecture and install Wine + required packages
RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y \
    x11vnc xvfb fluxbox supervisor wget unzip \
    novnc websockify \
    wine64 wine32 winetricks \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /root

# Copy files
COPY app/ /root/app/
COPY start.sh /start.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN chmod +x /start.sh

# Configure noVNC web files
RUN mkdir -p /root/.vnc && \
    mkdir -p /root/novnc && \
    cp -r /usr/share/novnc/* /root/novnc/

# Expose VNC and noVNC ports
EXPOSE 8080
EXPOSE 5900

# Start everything using Supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
