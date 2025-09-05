#!/bin/bash
set -e

# Default VNC password if not provided
VNC_PASSWD=${VNC_PASSWORD:-"changeme123"}

echo ">>> Starting virtual framebuffer (Xvfb)..."
Xvfb :0 -screen 0 1366x768x16 &

sleep 2

echo ">>> Setting VNC password..."
mkdir -p ~/.vnc
x11vnc -storepasswd $VNC_PASSWD ~/.vnc/passwd

echo ">>> Starting Fluxbox window manager..."
fluxbox &

sleep 2

echo ">>> Starting Wine application..."
# Run your Windows application
wine /root/app/myapp.exe &

sleep 3

echo ">>> Starting noVNC WebSocket proxy..."
websockify --web=/root/novnc 8080 localhost:5900 &

echo ">>> All services started successfully!"
wait

