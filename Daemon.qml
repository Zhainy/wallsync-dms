import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services

QtObject {
    id: root

    property var pluginService: null
    property string pluginId: "wallsync"

    readonly property string statePath: Env.homePath + "/.cache/wallsync/state.json"

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
                } catch (e) {
                    console.warn("[wallsync] Failed to parse state:", e)
                }
            }
        })
    }

    function refreshState() {
        Proc.runCommand("wallsync.refreshState", ["cat", statePath], (stdout, exitCode) => {
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
}
