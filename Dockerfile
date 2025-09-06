# Dockerfile - optimized for Render noVNC + XFCE + Wine
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:0 \
    TZ=Etc/UTC \
    WINEPREFIX=/root/.wine

# Enable 32-bit architecture and install required packages
RUN dpkg --add-architecture i386 && apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      ca-certificates apt-utils curl gnupg2 software-properties-common \
      x11vnc xvfb xfce4 xfce4-terminal xfce4-session dbus-x11 \
      supervisor wget unzip git net-tools procps xterm locales \
      websockify novnc python3 python3-pip python3-setuptools \
      wine64 wine32 winbind cabextract p7zip-full fonts-wqy-zenhei \
      fontconfig libgl1-mesa-dri libgl1-mesa-glx libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Ensure websockify CLI is the python3 one (fresh)
RUN pip3 install --no-cache-dir websockify

# Create app dir
WORKDIR /root
COPY app/ /root/app/
COPY start.sh /root/start.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY index.html /usr/share/novnc/index.html

RUN chmod +x /root/start.sh

# Expose one port (Render will map public port -> container $PORT)
EXPOSE 10000

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
