#!/bin/bash
echo "Starting virtual display..."
Xvfb :0 -screen 0 1024x768x16 &

sleep 2
echo "Starting window manager..."
fluxbox &

sleep 2
echo "Starting VNC server..."
x11vnc -display :0 -rfbauth /root/.vnc/passwd -forever -shared -rfbport 5900 &

sleep 2
echo "Starting noVNC server..."
websockify --web /usr/share/novnc --heartbeat=15 6080 localhost:5900 &

sleep 3
echo "Launching EXE with Wine..."
wine /root/myapp.exe

wait
