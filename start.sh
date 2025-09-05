#!/usr/bin/env bash
set -euo pipefail


# Ensure VNC password is set
if [ -z "${VNC_PASSWORD:-}" ]; then
echo "VNC_PASSWORD env var not set. Set it in Render dashboard."
exit 1
fi


# Prepare a clean X display
export DISPLAY=${DISPLAY:-:0}
export GEOMETRY=${GEOMETRY:-1366x768x24}


# Create Wine prefix (isolated Windows environment)
export WINEPREFIX=/app/.wine
if [ ! -d "$WINEPREFIX" ]; then
echo "Initializing Wine prefix..."
wineboot --init || true
fi


# Start everything under supervisord
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
