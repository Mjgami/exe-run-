#!/usr/bin/env bash
set -euo pipefail

# default VNC password
VNC_PASSWORD="${VNC_PASSWORD:-changeme123}"
PORT="${PORT:-10000}"        # Render injects $PORT automatically
DISPLAY="${DISPLAY:-:0}"

export DISPLAY

# Create Wine prefix and ensure wineboot run (idempotent)
WINEPREFIX=/root/.wine
export WINEPREFIX
if [ ! -d "$WINEPREFIX" ]; then
  echo "[startup] Initializing wine prefix..."
  wineboot --init || true
fi

# Store VNC password
mkdir -p /root/.vnc
# x11vnc -storepasswd expects interactive; create passwd file non-interactively
python3 - <<PY
import os, sys,crypt,subprocess
pw = os.environ.get("VNC_PASSWORD","changeme123")
pfile="/root/.vnc/passwd"
# use x11vnc utility to store properly
subprocess.run(["x11vnc","-storepasswd",pw,pfile], check=True)
PY

# Start Xvfb
echo "[startup] Starting Xvfb on $DISPLAY..."
Xvfb "$DISPLAY" -screen 0 1280x720x16 &

# Wait for X server to start
sleep 1

# Start fluxbox window manager (so windows behave properly)
echo "[startup] Starting fluxbox..."
fluxbox &

sleep 1

# Start x11vnc listening **on localhost only** and using the stored password
# -nolookup reduces DNS delays. -ncache can help responsiveness; adjust if needed.
echo "[startup] Starting x11vnc on localhost:5900..."
x11vnc -display "$DISPLAY" -rfbauth /root/.vnc/passwd -forever -shared -localhost -noxdamage -bg -o /var/log/x11vnc.log

# Wait a bit for x11vnc
sleep 1

# Start websockify (noVNC WebSocket proxy) bound to 0.0.0.0:$PORT and proxying to localhost:5900
# Use --web to serve noVNC client files from the system installation
echo "[startup] Starting websockify (noVNC) proxy -> listening on port $PORT..."
# If $PORT is not numeric, websockify will error; default handled above
exec websockify --web /usr/share/novnc ${PORT} localhost:5900 --heartbeat=30
