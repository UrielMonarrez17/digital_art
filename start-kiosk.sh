#!/bin/bash
# Raspberry Pi Kiosk Mode Startup Script
# For Obra Colectiva Digital Art Installation
# Place this file at: ~/scripts/start-kiosk.sh

echo "🎨 Starting Obra Colectiva Kiosk..."

# Wait for network connection
echo "⏳ Waiting for network..."
sleep 10

# Hide mouse cursor
echo "🖱️ Hiding cursor..."
unclutter -idle 0 &

# Disable screen blanking and power management
echo "🖥️ Disabling screen blanking..."
xset s off
xset -dpms
xset s noblank

# Kill any existing Chromium instances
killall chromium-browser 2>/dev/null

# Wait a moment
sleep 2

echo "🚀 Launching viewer in kiosk mode..."

# Start Chromium in fullscreen kiosk mode
chromium-browser \
  --noerrdialogs \
  --disable-infobars \
  --kiosk \
  --incognito \
  --disable-session-crashed-bubble \
  --disable-restore-session-state \
  --disable-background-networking \
  --disable-sync \
  --metrics-recording-only \
  --disable-default-apps \
  --mute-audio \
  --no-first-run \
  --fast \
  --fast-start \
  --disable-features=TranslateUI \
  --disk-cache-dir=/dev/null \
  --password-store=basic \
  --start-fullscreen \
  "file:///home/pi/viewer.html"
  
# Alternative: Use hosted version (recommended)
# Replace the line above with:
#   "https://yourusername.github.io/obra-colectiva/viewer.html"

# Note: If the viewer doesn't show, try:
#   "http://localhost:8000/viewer.html"
# And run: python3 -m http.server 8000 in the viewer directory

echo "✅ Kiosk started"
