FROM ubuntu:22.04


ENV DEBIAN_FRONTEND=noninteractive \
DISPLAY=:0 \
GEOMETRY=1366x768x24 \
VNC_PASSWORD=changeme \
TZ=Etc/UTC


# System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
ca-certificates wget curl xz-utils gnupg2 software-properties-common \
supervisor \
xvfb x11vnc fluxbox \
net-tools procps \
python3 python3-pip \
git \
# noVNC + websockify
novnc websockify \
# Wine
wine64 winbind cabextract unzip \
&& rm -rf /var/lib/apt/lists/*


# Optional: winetricks for better compatibility
RUN apt-get update && apt-get install -y --no-install-recommends winetricks && rm -rf /var/lib/apt/lists/*


# noVNC lives in /usr/share/novnc; create a simple index redirect
RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html || true


# App directory; place your .exe here at build time or mount at runtime
WORKDIR /app
COPY ./app ./app


# Start scripts & supervisor
COPY ./start.sh /usr/local/bin/start.sh
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod +x /usr/local/bin/start.sh


# Expose web (noVNC) port for Render
EXPOSE 8080


# Healthcheck: ensure websockify is listening
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD bash -lc 'nc -z 127.0.0.1 8080'


CMD ["/usr/local/bin/start.sh"]
