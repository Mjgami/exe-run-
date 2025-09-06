#!/usr/bin/env bash
set -euo pipefail

# Start script - sets up Xvfb, XFCE, x11vnc, launches wine app, then websockify
VNC_PASSWORD="${VNC_PASSWORD:-changeme123}"
PORT="${PORT:-10000}"
DISPLAY="${DISPLAY:-:0}"

export DISPLAY WINEPREFIX

echo "[startup] VNC_PASSWORD length=${#VNC_PASSWORD}"

# Init wine prefix (idempotent)
if [ ! -d "$WINEPREFIX" ]; then
  echo "[startup] Initializing wine prefix..."
  wineboot --init || true
fi

# Store VNC password file (non-interactive)
mkdir -p /root/.vnc
python3 - <<PY
import subprocess, os
pw = os.environ.get("VNC_PASSWORD", "changeme123")
pfile = "/root/.vnc/passwd"
subprocess.run(["x11vnc","-storepasswd", pw, pfile], check=True)
print("[startup] x11vnc password saved to", pfile)
PY

# Start Xvfb
echo "[startup] Starting Xvfb on $DISPLAY..."
Xvfb "$DISPLAY" -screen 0 1280x720x16 &

# give X time to initialize
sleep 1

# Start dbus (XFCE uses dbus)
if ! pgrep -x dbus-launch > /dev/null 2>&1; then
  eval $(dbus-launch --sh-syntax)
fi

# Start XFCE session in background (so we have panels, workspace, cursor)
echo "[startup] Starting xfce4-session..."
# startxfce4 may block; use dbus-run-session for a clean session
dbus-run-session -- bash -lc "startxfce4" &

sleep 2

# Start x11vnc (listen on localhost only, websockify will proxy)
echo "[startup] Starting x11vnc (localhost:5900)..."
x11vnc -display "$DISPLAY" -rfbauth /root/.vnc/passwd -forever -shared -localhost -noxdamage -o /var/log/x11vnc.log &

sleep 1

# Launch your Windows app (if present) under wine in background
if [ -f /root/app/myapp.exe ]; then
  echo "[startup] Launching /root/app/myapp.exe under Wine..."
  nohup wine /root/app/myapp.exe &>/var/log/wine_app.log &
else
  echo "[startup] No EXE found at /root/app/myapp.exe - skipping launch"
fi

sleep 1

# Run websockify bound to $PORT and proxying to localhost:5900
echo "[startup] Starting websockify (noVNC) -> 0.0.0.0:${PORT} -> localhost:5900"
# Exec so supervisord sees the process as foreground (this keeps container alive)
exec websockify --web /usr/share/novnc "${PORT}" localhost:5900 --heartbeat=30
