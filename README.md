# Wallsync — DMS Plugin

Dual-monitor wallpaper manager with 3D coverflow picker, color-coordinated pairing, and Material You theming, packaged as a DankMaterialShell plugin.

## Features

- **DMS Launcher Integration** — Type `!wp` in Spotlight to browse and apply wallpapers
- **3D Coverflow Picker** — Fullscreen overlay with perspective transforms and vibe filtering
- **Color-Coordinated Pairing** — Automatically finds HSL-matched companions for multi-monitor setups
- **Material You Theming** — Integrates with Matugen for dynamic color scheme generation
- **Smooth Transitions** — GPU-accelerated wallpaper transitions via awww
- **Live Wallpapers** — MP4 and GIF support via mpvpaper

## Requirements

- DankMaterialShell >= 1.5.0
- awww (swww fork) — wallpaper daemon
- Matugen — Material You color generator
- ImageMagick — thumbnail generation and color extraction
- ffmpeg — video frame extraction
- mpvpaper (optional) — live video wallpapers

## Installation

### From GitHub

```bash
mkdir -p ~/.config/DankMaterialShell/plugins
cd ~/.config/DankMaterialShell/plugins
git clone https://github.com/Zhainy/wallsync-dms.git wallsync
dms restart
```

### Enable

1. Open DMS Settings → Plugins
2. Click **Scan for Plugins**
3. Toggle **Wallsync** on
4. Restart shell: `dms restart`

## Usage

### Index your wallpapers

The plugin needs an index of your wallpapers first. Run from a terminal:

```bash
~/.config/DankMaterialShell/plugins/wallsync/daemon/wallsync index
```

Or click **Re-index Wallpapers** in the plugin settings.

### Browse with Coverflow

- Launch from the DMS launcher: open Spotlight and select **🎠 Open Coverflow**
- Navigate with arrow keys, scroll wheel, or click
- Press Enter or click the center card to apply

### Quick Switch via Launcher

- Type `!wp` in DMS Spotlight
- Browse wallpapers with live search
- Press Enter to apply the selected wallpaper
- Right-click for context actions

### Random Pair

- Type `!wp` and select **🎲 Random Pair**
- Or click **Random Pair** in the launcher

## Configuration

Access settings via DMS Settings → Plugins → Wallsync:

- **Wallpaper Directories** — Comma-separated paths (default: `~/Pictures/Wallpapers`)
- **Transition Type/Speed** — awww transition configuration
- **Color Matching Weights** — Hue, saturation, and lightness importance
- **Launcher Trigger** — Spotlight prefix (default: `!wp`)

## Architecture

```
plugin.json          → Composite manifest (daemon + launcher + settings)
Daemon.qml           → Background service, IPC handlers, awww lifecycle
Launcher.qml         → Spotlight integration with !wp trigger
Overlay.qml          → Standalone 3D coverflow picker
Settings.qml         → DMS-native settings panel
StartupCheck.qml     → Dependency validation on enable
daemon/wallsync      → Python backend (indexing, color analysis, transitions)
```

## License

MIT
