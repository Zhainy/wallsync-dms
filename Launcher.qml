import QtQuick
import Quickshell
import qs.Common
import qs.Services

QtObject {
    id: root

    property var pluginService: null
    property string pluginId: "wallsync"
    property string trigger: "!wp"
    signal itemsChanged

    readonly property string homeDir: Env.homePath
    readonly property string pluginDir: homeDir + "/.config/DankMaterialShell/plugins/wallsync"
    readonly property string pythonScript: pluginDir + "/daemon/wallsync"
    readonly property string statePath: homeDir + "/.cache/wallsync/state.json"

    Component.onCompleted: {
        ensureAwwwDaemon()
        restoreState()
    }

    function ensureAwwwDaemon() {
        Proc.runCommand("wallsync.checkAwww", ["awww", "query"], (stdout, exitCode) => {
            if (exitCode !== 0) {
                console.info("[wallsync] awww-daemon not running, starting...")
                Quickshell.execDetached(["awww-daemon"])
            }
        })
    }

    function restoreState() {
        Proc.runCommand("wallsync.loadState", ["cat", statePath], (stdout, exitCode) => {
            if (exitCode === 0 && stdout.length > 0) {
                try {
                    var state = JSON.parse(stdout)
                    if (state?.current?.primary) {
                        pluginService?.setGlobalVar(pluginId, "lastPrimary", state.current.primary)
                        pluginService?.setGlobalVar(pluginId, "lastSecondary", state.current.secondary ?? "")
                    }
                } catch (_) {}
            }
        })
    }

    function getItems(query) {
        if (!query || query.trim().length === 0) return []

        return [
            {
                name: "Wallsync",
                icon: "material:wallpaper",
                comment: "Dual-monitor wallpaper manager",
                action: "custom:info",
                categories: ["Wallsync"]
            }
        ]
    }

    function executeItem(item) {
        if (!item?.action) return
        ToastService.showInfo("Wallsync", "Run 'wallsync index' first, then 'wallsync gui'")
    }
}
