import QtQuick
import Quickshell
import qs.Common
import qs.Services

QtObject {
    id: root

    property var pluginService: null
    property string pluginId: "wallsync"

    // Path resolving helper
    readonly property string pythonScript: Quickshell.pluginPath + "/daemon/wallsync"
    readonly property string overlayPath: Quickshell.pluginPath + "/Overlay.qml"

    Component.onCompleted: {
        console.info("[wallsync] Daemon started")
        ensureDaemonState()
    }

    function ensureDaemonState() {
        // Query current state or run checks if needed on startup
        Quickshell.execDetached(["awww", "query"])
    }

    // IPC Command Handlers registered dynamically inside DMS
    function matchWallpaper(path, outputName) {
        let args = [pythonScript, "match", path]
        if (outputName) {
            args.push("-o")
            args.push(outputName)
        }
        console.log("[wallsync IPC] Running match:", args.join(" "))
        Quickshell.execDetached(args)
    }

    function randomPair(vibe) {
        let args = [pythonScript, "random"]
        if (vibe) {
            args.push("-v")
            args.push(vibe)
        }
        console.log("[wallsync IPC] Running random:", args.join(" "))
        Quickshell.execDetached(args)
    }

    function reindex(force, regen, workers) {
        let args = [pythonScript, "index"]
        if (force) args.push("--force")
        if (regen) args.push("--regen")
        if (workers) {
            args.push("--workers")
            args.push(workers.toString())
        }
        console.log("[wallsync IPC] Running index:", args.join(" "))
        Quickshell.execDetached(args)
    }

    function launchCoverflow() {
        console.log("[wallsync IPC] Launching standalone 3D Coverflow picker...")
        Quickshell.execDetached(["quickshell", "-n", "-p", Quickshell.pluginPath, "Overlay.qml"])
    }
}
