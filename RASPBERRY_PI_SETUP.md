# Raspberry Pi Setup Guide - Obra Colectiva

## Hardware Requirements

### What You Need:
- **Raspberry Pi 4** (4GB RAM recommended) or Raspberry Pi 5
- **MicroSD Card** (32GB minimum, Class 10)
- **Power Supply** (Official Raspberry Pi power adapter)
- **Display** (HDMI monitor/TV/projector)
- **HDMI Cable**
- **Keyboard & Mouse** (for initial setup only)
- **Internet Connection** (WiFi or Ethernet)

### Optional:
- **Case** for Raspberry Pi
- **Cooling fan** (recommended for continuous operation)

---

## Step 1: Install Raspberry Pi OS

### 1.1 Download Raspberry Pi Imager
1. On your laptop, download from: https://www.raspberrypi.com/software/
2. Install and open Raspberry Pi Imager

### 1.2 Flash the OS
1. Insert microSD card into your laptop
2. Open Raspberry Pi Imager
3. Click **"Choose OS"** → **"Raspberry Pi OS (64-bit)"** (with desktop)
4. Click **"Choose Storage"** → Select your microSD card
5. Click **⚙️ Settings** (gear icon):
   - Enable SSH
   - Set username: `pi`
   - Set password: (create your password)
   - Configure WiFi (optional - enter your WiFi name and password)
   - Set timezone: Your timezone
6. Click **"Write"** and wait for completion

### 1.3 First Boot
1. Insert microSD card into Raspberry Pi
2. Connect keyboard, mouse, and display
3. Connect power - Pi will boot automatically
4. Complete the initial setup wizard if it appears

---

## Step 2: Basic Raspberry Pi Configuration

### 2.1 Update System
Open terminal and run:
```bash
sudo apt update
sudo apt upgrade -y
```

### 2.2 Install Chromium Browser (if not installed)
```bash
sudo apt install -y chromium-browser unclutter xdotool
```

### 2.3 Configure Auto-Login (if needed)
```bash
sudo raspi-config
```
- Navigate to: **System Options** → **Boot / Auto Login**
- Select: **Desktop Autologin**
- Reboot when prompted

---

## Step 3: Deploy Your Viewer Files

### Option A: Using USB Drive
1. Copy `viewer.html` to USB drive
2. Insert USB into Raspberry Pi
3. Copy to home directory:
```bash
cp /media/pi/USB_NAME/viewer.html ~/viewer.html
```

### Option B: Using Git (Recommended)
```bash
cd ~
git clone YOUR_REPOSITORY_URL
# Or download directly
wget https://YOUR_SERVER/viewer.html
```

### Option C: Host Online (Best Option)
Upload `viewer.html` to a web server or GitHub Pages:
- **GitHub Pages**: Free hosting at `https://yourusername.github.io/project/viewer.html`
- **Firebase Hosting**: Free hosting with your Firebase project
- **Any web server**: Upload the single HTML file

---

## Step 4: Configure Kiosk Mode (Fullscreen Display)

### 4.1 Create Startup Script
```bash
mkdir -p ~/scripts
nano ~/scripts/start-kiosk.sh
```

Paste this content:
```bash
#!/bin/bash

# Wait for network
sleep 10

# Hide mouse cursor
unclutter -idle 0 &

# Disable screen blanking
xset s off
xset -dpms
xset s noblank

# Start Chromium in kiosk mode
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
  # Or use your hosted URL:
  # "https://yourusername.github.io/obra-colectiva/viewer.html"
```

**If using a hosted URL, change the last line to:**
```bash
  "https://YOUR_HOSTED_URL/viewer.html"
```

Make it executable:
```bash
chmod +x ~/scripts/start-kiosk.sh
```

### 4.2 Auto-Start on Boot
```bash
mkdir -p ~/.config/autostart
nano ~/.config/autostart/kiosk.desktop
```

Paste this content:
```ini
[Desktop Entry]
Type=Application
Name=Obra Colectiva Kiosk
Exec=/home/pi/scripts/start-kiosk.sh
X-GNOME-Autostart-enabled=true
```

### 4.3 Test the Script
```bash
~/scripts/start-kiosk.sh
```

The viewer should open fullscreen. Press `Alt+F4` to close and return to desktop.

---

## Step 5: Configure Your Viewer

### 5.1 Update OBRA_ID (if needed)
Before deploying, edit `viewer.html` and change:
```javascript
const CONFIG = {
  OBRA_ID: 'your-artwork-id',  // Change this to match your manifest
  // ... rest of config
};
```

### 5.2 Remove Test Controls for Production
Edit `viewer.html` and remove these lines:
```html
<!-- Remove this section for production -->
<div id="controls">
  <button id="simPlus">+1 Vote</button>
  <button id="simReset">Reset</button>
  <span style="margin-left:6px">Test Controls</span>
</div>
```

And remove the button handlers:
```javascript
// Remove these lines
document.getElementById('simPlus').onclick = ...
document.getElementById('simReset').onclick = ...
```

---

## Step 6: Google Forms Integration

**Good News:** The Google Forms integration already works! No Pi configuration needed.

### How It Works:
1. **Google Forms** → Collects votes with voter IDs
2. **Apps Script** → Runs in Google's cloud, updates Firebase
3. **Firebase** → Stores vote data in real-time
4. **Raspberry Pi** → Displays viewer.html, listens to Firebase
5. **Viewer Updates** → Automatically when new votes arrive

### Setup Apps Script (Do this on your laptop):
```javascript
function onFormSubmit(e) {
  var voterId = e.values[1]; // Adjust index for your form
  var obraId = 'obra-demo'; // Match your OBRA_ID
  var url = 'https://arte-digital-d704e-default-rtdb.firebaseio.com/stats/' + obraId + '.json';
  
  // Get current votes
  var response = UrlFetchApp.fetch(url);
  var data = JSON.parse(response.getContentText());
  var currentVotes = (data.currentVotes || 0) + 1;
  
  // Update Firebase
  UrlFetchApp.fetch(url, {
    method: 'patch',
    contentType: 'application/json',
    payload: JSON.stringify({
      currentVotes: currentVotes,
      lastVoterId: voterId
    })
  });
}
```

Set trigger: **Form → On form submit → Run onFormSubmit**

---

## Step 7: Testing & Troubleshooting

### 7.1 Test Network Connection
```bash
ping -c 4 google.com
```

### 7.2 Test Firebase Connection
Open browser and visit:
```
https://arte-digital-d704e-default-rtdb.firebaseio.com/stats/obra-demo.json
```
You should see your vote data.

### 7.3 View Browser Console
To debug, temporarily remove `--kiosk` from the startup script and use `F12` for developer tools.

### 7.4 Check Logs
```bash
# View system logs
journalctl -xe

# Check if script is running
ps aux | grep chromium
```

### 7.5 Restart Kiosk
```bash
killall chromium-browser
~/scripts/start-kiosk.sh
```

---

## Step 8: Production Deployment

### 8.1 Upload Manifest (From your laptop)
1. Open `manifest.html` in browser
2. Select your artwork image
3. Set OBRA_ID (e.g., "expo-2026")
4. Set expected votes (e.g., 500)
5. Click "Generar & Subir a Firebase"
6. Verify upload in Firebase console

### 8.2 Update Raspberry Pi Viewer
If using local file:
```bash
nano ~/viewer.html
# Update OBRA_ID to match manifest
```

If using hosted URL:
- Update your hosted `viewer.html`
- Restart Pi (it will fetch latest version)

### 8.3 Final Reboot
```bash
sudo reboot
```

The Pi will:
1. Boot to desktop
2. Auto-login
3. Wait 10 seconds for network
4. Launch viewer in fullscreen
5. Connect to Firebase
6. Display artwork and wait for votes

---

## Step 9: Ongoing Operations

### Start/Stop Viewer
```bash
# Stop
killall chromium-browser

# Start
~/scripts/start-kiosk.sh
```

### Update Artwork
1. Upload new manifest with `manifest.html` (use new OBRA_ID)
2. Update `CONFIG.OBRA_ID` in viewer.html
3. Restart viewer on Pi

### Monitor Votes (from laptop)
Visit Firebase console:
```
https://console.firebase.google.com
→ Your project
→ Realtime Database
→ /stats/your-obra-id
```

### Remote Access (Optional)
Enable SSH and access remotely:
```bash
# From your laptop
ssh pi@raspberrypi.local
# Or use IP address: ssh pi@192.168.1.XX
```

---

## Optimization Tips

### Reduce Screen Burn-In
Add screensaver for overnight:
```bash
nano ~/scripts/start-kiosk.sh
# Change: xset s off
# To: xset s 3600  # Blank after 1 hour
```

### Performance Boost
```bash
# Disable unnecessary services
sudo systemctl disable bluetooth
sudo systemctl disable avahi-daemon

# Overclock (optional, may void warranty)
sudo nano /boot/config.txt
# Add: arm_freq=1800
```

### Auto-Refresh Daily
Add to crontab:
```bash
crontab -e
# Add: 0 4 * * * killall chromium-browser && ~/scripts/start-kiosk.sh
```

---

## Complete Architecture Diagram

```
┌─────────────────┐
│  Google Forms   │ ← People vote here
│  (Public URL)   │
└────────┬────────┘
         │ On Submit
         ▼
┌─────────────────┐
│  Apps Script    │ ← Runs in Google Cloud
│  (Cloud)        │    Processes vote
└────────┬────────┘
         │ Updates
         ▼
┌─────────────────┐
│    Firebase     │ ← Cloud Database
│  Realtime DB    │    /stats/obra-id
└────────┬────────┘
         │ Real-time sync
         ▼
┌─────────────────┐
│  Raspberry Pi   │ ← Display Device
│  Chromium       │    Runs viewer.html
│  Kiosk Mode     │
└────────┬────────┘
         │ HDMI
         ▼
┌─────────────────┐
│  Monitor/TV/    │ ← Audience sees art
│  Projector      │    reveal live
└─────────────────┘
```

---

## Checklist Before Going Live

- [ ] Raspberry Pi boots and auto-launches viewer
- [ ] Viewer connects to Firebase (check debug info)
- [ ] Manifest uploaded with correct OBRA_ID
- [ ] Google Form created with voter ID field
- [ ] Apps Script installed and trigger configured
- [ ] Test vote from form → See tile reveal on Pi
- [ ] Screen set to never sleep
- [ ] Mouse cursor hidden
- [ ] Test controls removed from viewer (production)
- [ ] Network connection stable
- [ ] Display properly positioned for audience
- [ ] Backup viewer.html saved somewhere safe

---

## Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| Pi won't boot | Check power supply, try different SD card |
| No display | Check HDMI cable, try different port |
| Viewer doesn't load | Check network, verify file path in script |
| Firebase not connecting | Check internet, verify Firebase URL |
| Votes don't update | Check Apps Script trigger, verify OBRA_ID matches |
| Screen goes black | Disable DPMS in startup script |
| Mouse cursor visible | Install `unclutter` package |

---

## Support & Next Steps

### Resources:
- **Raspberry Pi Documentation**: https://www.raspberrypi.com/documentation/
- **Firebase Console**: https://console.firebase.google.com
- **Your Code**: Check README.md for usage details

### Need Help?
1. Check Firebase console for vote data
2. SSH into Pi and check logs: `journalctl -xe`
3. Test viewer in regular browser first
4. Verify network connectivity

**Your installation is ready! The Raspberry Pi will display the artwork and it will reveal progressively as people vote through Google Forms. Everything syncs automatically through Firebase. ✨**
