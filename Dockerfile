FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:0

# Install core dependencies
RUN apt-get update && apt-get install -y \
    x11vnc xvfb fluxbox novnc websockify wget curl supervisor \
    wine-stable software-properties-common \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Configure VNC password
RUN mkdir -p /root/.vnc && \
    x11vnc -storepasswd StrongPassword123 /root/.vnc/passwd

# Copy your EXE into the container
COPY myapp.exe /root/myapp.exe

# Copy startup script
COPY start.sh /root/start.sh
RUN chmod +x /root/start.sh

# Copy auto-redirect HTML
COPY index.html /usr/share/novnc/index.html

# Expose noVNC port
EXPOSE 6080

# Start everything
CMD ["/root/start.sh"]
