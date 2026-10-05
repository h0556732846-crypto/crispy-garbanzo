#!/bin/bash
set -e

sudo apt-get update

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y 
  chromium 
  xfce4 
  xfce4-goodies 
  x11vnc 
  xvfb 
  novnc 
  websockify 
  dbus-x11

mkdir -p "$HOME/.vnc"

cat > "$HOME/start-browser.sh" <<'EOF'
#!/bin/bash

export DISPLAY=:1

Xvfb :1 -screen 0 1280x800x24 -ac &
sleep 2

startxfce4 >/tmp/xfce.log 2>&1 &
sleep 5

chromium 
  --no-sandbox 
  --disable-dev-shm-usage 
  --start-maximized 
  --user-data-dir="$HOME/chromium-profile" \
  >/tmp/chromium.log 2>&1 &

sleep 3

x11vnc 
  -display :1 
  -forever 
  -shared 
  -rfbport 5900 
  -localhost \
  >/tmp/x11vnc.log 2>&1 &

websockify 
  --web=/usr/share/novnc/ 
  6080 
  localhost:5900 \
  >/tmp/websockify.log 2>&1 &

echo ""
echo "=========================================="
echo "REMOTE CHROMIUM IS RUNNING"
echo "=========================================="
echo "Open the forwarded port 6080"
echo "=========================================="

wait
EOF

chmod +x "$HOME/start-browser.sh"

echo ""
echo "=========================================="
echo "SETUP COMPLETE"
echo "=========================================="
echo "Run:"
echo "~/start-browser.sh"
echo "=========================================="
