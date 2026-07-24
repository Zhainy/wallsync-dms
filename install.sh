#!/bin/bash
# wallsync-dms installer

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/.config/DankMaterialShell/plugins/wallsyncDms"

echo "🎨 Installing wallsync-dms to DMS plugin directory..."
echo "Target path: $TARGET_DIR"

mkdir -p "$TARGET_DIR"
mkdir -p "$HOME/.cache/wallsync"
mkdir -p "$HOME/.local/share/wallsync/thumbnails"

# Copy QML files
cp "$SCRIPT_DIR/plugin.json" "$TARGET_DIR/"
cp "$SCRIPT_DIR/Daemon.qml" "$TARGET_DIR/"
cp "$SCRIPT_DIR/Overlay.qml" "$TARGET_DIR/"
cp "$SCRIPT_DIR/WallsyncSettings.qml" "$TARGET_DIR/"
cp "$SCRIPT_DIR/StartupCheck.qml" "$TARGET_DIR/"

# Copy python backend
cp "$SCRIPT_DIR/wallsync" "$TARGET_DIR/wallsync"
chmod +x "$TARGET_DIR/wallsync"

# Copy preview resources
cp "$SCRIPT_DIR/preview.png" "$TARGET_DIR/" 2>/dev/null || true


echo "Checking system dependency status..."
deps=(python3 magick ffmpeg awww matugen)
for dep in "${deps[@]}"; do
    if command -v "$dep" &>/dev/null; then
        echo "  ✅ $dep"
    else
        if [ "$dep" = "magick" ] && command -v "convert" &>/dev/null; then
            echo "  ✅ magick (via convert fallback)"
        else
            echo "  ❌ $dep (MISSING)"
        fi
    fi
done

echo ""
echo "🎉 wallsync-dms installation completed!"
echo "Please reload DMS or scan for plugins in your Settings Modal to activate it."
