# 🎨 Obra Colectiva Digital - Interactive Art Installation

A collaborative digital art installation where each vote from the audience progressively reveals a hidden artwork. Built for Raspberry Pi kiosk displays with real-time Firebase synchronization.

## ✨ Features

- **Progressive Reveal**: Artwork unveils piece-by-piece with each vote
- **Hexagonal Tessellation**: Beautiful hexagonal tile pattern algorithm
- **Real-time Sync**: Firebase Realtime Database for instant vote updates
- **Google Forms Integration**: Collect votes via Google Forms with voter identification
- **Raspberry Pi Ready**: Complete kiosk mode setup for unattended displays
- **Responsive Design**: Adapts to any screen size (HD, 4K, projectors)
- **Visual Feedback**: Animated notifications, vote counters, and tile highlighting

## 🖼️ Live Demo

**Production Viewer**: Open [viewer-production.html](viewer-production.html) in a browser  
**Development Viewer**: Open [viewer.html](viewer.html) (includes test controls)  
**Manifest Generator**: Open [manifest.html](manifest.html) to create new artworks

## 🚀 Quick Start

### 1. Configure Firebase
Update the `CONFIG.OBRA_ID` in your viewer files to match your artwork ID.

### 2. Generate Manifest
1. Open `manifest.html` in browser
2. Select your image
3. Set artwork ID (e.g., "expo-2026")
4. Set expected votes (e.g., 500)
5. Click "Generar & Subir a Firebase"

### 3. Test Locally
1. Open `viewer.html` in browser
2. Use +1 Vote button to test reveal
3. Check Firebase console for data sync

### 4. Deploy to Raspberry Pi
Follow the complete guide in [RASPBERRY_PI_SETUP.md](RASPBERRY_PI_SETUP.md)

## 📁 Project Structure

```
digital_art/
├── viewer.html              # Development viewer with test controls
├── viewer-production.html   # Clean production viewer for exhibitions
├── manifest.html            # Hexagonal tile manifest generator
├── index.html               # Simple MVP demo
├── start-kiosk.sh          # Raspberry Pi kiosk startup script
├── kiosk.desktop           # Linux autostart configuration
├── RASPBERRY_PI_SETUP.md   # Complete Pi deployment guide
├── README.md               # This file
└── .gitignore              # Git ignore rules
```

## 🛠️ Technology Stack

- **Frontend**: Pure HTML5, CSS3, JavaScript (ES6+)
- **Rendering**: [PixiJS v8.1.1](https://pixijs.com/) (WebGL)
- **Database**: [Firebase Realtime Database](https://firebase.google.com/products/realtime-database)
- **Forms**: Google Forms + Apps Script
- **Display**: Raspberry Pi 4/5 + Chromium Browser (Kiosk Mode)

## 🎯 How It Works

```
┌─────────────────┐
│  Google Forms   │  ← Audience votes with voter ID
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│  Apps Script    │  ← Cloud function triggers on form submit
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│    Firebase     │  ← Real-time database stores votes
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│  Raspberry Pi   │  ← Displays viewer.html in fullscreen
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│  HDMI Display   │  ← Audience sees artwork reveal
└─────────────────┘
```

## 🔧 Configuration

### Firebase Setup
1. Create project at [Firebase Console](https://console.firebase.google.com)
2. Enable Realtime Database
3. Update `CONFIG.FIREBASE` in viewer files with your credentials

### Google Forms Setup
1. Create form with voter ID field
2. Open Tools → Script Editor
3. Add the Apps Script from [RASPBERRY_PI_SETUP.md](RASPBERRY_PI_SETUP.md#step-6-google-forms-integration)
4. Set trigger: Form → On form submit

### Artwork Configuration
Update in viewer files:
```javascript
const CONFIG = {
  OBRA_ID: 'your-artwork-id',  // Match with manifest ID
  FIREBASE: { /* your config */ }
};
```

## 📊 File Sizes & Performance

- **viewer-production.html**: ~35KB (minified: ~25KB)
- **PixiJS**: ~1.2MB (CDN cached)
- **Firebase SDK**: ~180KB (CDN cached)
- **Manifest**: ~50-200KB (depends on tile count)
- **Image Data**: Embedded in manifest as JPEG (92% quality)

**Performance**: 60fps on Raspberry Pi 4, supports 1000+ tiles

## 🎨 Hexagonal Algorithm Details

The manifest generator uses an optimized hexagonal tessellation:

- **Aspect Ratio**: 1:0.866 (hex width to height)
- **Vertical Step**: 0.75 × hex height (overlapping)
- **Offset Pattern**: Odd rows shifted by 50% hex width
- **Boundary Coverage**: Starts from column -1, ±50% margins
- **Expansion Factor**: 1.15 × hex size (prevents gaps)
- **Color Sampling**: Averages pixels in radius (accurate colors)
- **Shuffle**: Fisher-Yates algorithm (random reveal order)

**Grid Calculation**:
```javascript
columns = ceil(sqrt(desiredVotes × aspect × 1.2))
rows = ceil(canvasHeight / verticalStep) + 1
```

## 🖥️ Raspberry Pi Hardware Requirements

- **Raspberry Pi 4** (4GB RAM) or **Raspberry Pi 5**
- **MicroSD Card**: 32GB Class 10
- **Power Supply**: Official 15W adapter
- **Display**: HDMI monitor/TV/projector
- **Estimated Cost**: ~$83 USD

See [RASPBERRY_PI_SETUP.md](RASPBERRY_PI_SETUP.md) for complete hardware list.

## 📱 Responsive Design

The viewer automatically adapts to:
- **HD Displays**: 1280×720, 1920×1080
- **4K Displays**: 3840×2160
- **Projectors**: Any resolution
- **Touch Screens**: Works with touch (no interaction needed)
- **Portrait/Landscape**: Maintains aspect ratio

## 🧪 Testing

### Development Mode
`viewer.html` includes test controls:
- **+1 Vote**: Simulate vote increment
- **Reset**: Reset votes to 0
- **Debug Panel**: Live stats (votes, tiles revealed)

### Production Mode
`viewer-production.html` is clean:
- No test buttons
- No debug panel
- Professional appearance

## 🚀 Deployment Options

### Option A: Local File (Simple)
- Copy `viewer-production.html` to Raspberry Pi
- Launch with `file:///home/pi/viewer.html`
- Works offline (except Firebase sync)

### Option B: GitHub Pages (Recommended)
- Push to GitHub repository
- Enable GitHub Pages in settings
- Update `start-kiosk.sh` with URL
- Easier remote updates

### Option C: Firebase Hosting
- `firebase init hosting`
- Deploy with `firebase deploy`
- Same domain as your database

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Tiles not revealing | Check Firebase connection, verify OBRA_ID match |
| Image not loading | Verify manifest uploaded, check sourceDataUrl |
| Votes not updating | Check Google Forms trigger, Apps Script logs |
| Performance lag | Reduce tile count, lower image resolution |
| Screen blanking | Run: `xset s off; xset -dpms` (on Pi) |

See [RASPBERRY_PI_SETUP.md](RASPBERRY_PI_SETUP.md#step-7-testing--troubleshooting) for complete troubleshooting guide.

## 📝 License

This project is open source. Feel free to use, modify, and distribute for artistic and educational purposes.

## 👤 Author

**Gabriel Guerra**  
GitHub: [@GabrielGuerra06](https://github.com/GabrielGuerra06)

## 🙏 Acknowledgments

- Built with [PixiJS](https://pixijs.com/)
- Powered by [Firebase](https://firebase.google.com/)
- Inspired by collaborative digital art installations

## 📚 Documentation

- [RASPBERRY_PI_SETUP.md](RASPBERRY_PI_SETUP.md) - Complete Pi deployment guide
- [manifest.html](manifest.html) - Manifest generator (open in browser)
- [viewer.html](viewer.html) - Development viewer with docs in code
- [viewer-production.html](viewer-production.html) - Production-ready viewer

## 🔮 Future Enhancements

- [ ] Multi-artwork playlist mode
- [ ] Analytics dashboard
- [ ] Mobile app for voting
- [ ] Social media integration
- [ ] Audio feedback on votes
- [ ] Video reveal animations

---

**Ready to create collaborative art? Start with `manifest.html` and bring your audience together! 🎨✨**
