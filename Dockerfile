# Use Ubuntu LTS
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:0 \
    TZ=Etc/UTC

# Ensure i386 support & install dependencies (wine32+wine64, Xvfb, x11vnc, noVNC)
RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y --no-install-recommends \
      apt-utils ca-certificates curl gnupg2 software-properties-common \
      x11vnc xvfb fluxbox supervisor wget unzip git net-tools procps \
      python3 python3-pip python3-setuptools \
      websockify novnc \
      wine64 wine32 winbind cabextract p7zip-full fonts-wqy-zenhei \
      xterm \
    && rm -rf /var/lib/apt/lists/*

# Make sure websockify (python) entrypoint exists
RUN pip3 install --no-cache-dir websockify

# Create app directory and noVNC location
WORKDIR /root

# Copy files (your exe, start scripts, and optional index.html)
COPY ./app/ /root/app/
COPY start.sh /root/start.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY index.html /usr/share/novnc/index.html

RUN chmod +x /root/start.sh

# Expose the port Render will route to via $PORT (Render assigns public port -> internal $PORT)
# We don't hardcode a port here; websockify will read $PORT at runtime.
EXPOSE 10000

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
