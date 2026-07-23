<p align="center">
  <img src="preview.gif" alt="wallsync picker preview" width="800"/>
</p>

<h1 align="center">🎨 wallsync-dms</h1>

<p align="center">
  <b>Dynamic dual-monitor wallpaper synchronizer ported as a native DankMaterialShell (DMS) background daemon.</b>
</p>

---

## ✨ Features

- **🎨 Dynamic Material You colors** — Fully integrated with Matugen and DankMaterialShell settings.
- **🎠 Efficient 3D Coverflow** — Recalculated scaling, rendering and shadows only for the main card to guarantee a clean 0% GPU/CPU footprint in standby.
- **⚡ Wayland Standalone Overlay** — The Coverflow picker overlay runs in an isolated Quickshell process under demand and is completely killed on select or ESC to free resources.
- **🖥️ Perceptual HSL matching** — Coordinating monitor pairings according to human HSL vision perception weights.
- **📦 No Python pip requirements** — Developed purely using python standard libraries.

---

## ⚙️ Settings

Configurable directly from your DMS Settings Panel -> Plugins -> Wallsync:
- **Wallpaper Directories**: Set directories as comma-separated values (e.g. `~/Pictures/Wallpapers`).
- **Transition Settings**: Configure swww/awww transition type (grow, fade, wave, wipe, outer, etc.) and speed step.
- **HSL Matching Weights**: Fine-tune the Hue, Saturation and Lightness weights.
- **Index Workers**: Optimize the threading pool according to your CPU core count.

---

## 📥 Installation

```bash
git clone https://github.com/Zhainy/wallsync-dms.git
cd wallsync-dms
chmod +x install.sh
./install.sh
```

### Enable the plugin
1. Open DMS Settings (Super + Space -> Settings -> Plugins).
2. Click **Scan for Plugins**.
3. Toggle the switch for **Wallsync** to enable the daemon.
4. Set up your custom wallpaper directories inside the settings section.
5. Generate the database using `wallsync index` from terminal (or bind it to a script).

---

## ⌨️ Binds (Niri config)

Add the following inside your `config.kdl` to map keybindings:

```kdl
binds {
    // Launch picker
    Mod+Y { spawn "wallsync" "gui"; }
    // Apply coordinated random wallpaper
    Mod+Shift+Y { spawn "wallsync" "random"; }
}
```

---

## 📄 License

MIT License. See [LICENSE](LICENSE) for details.
