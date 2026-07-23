import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Modules.Plugins

PluginComponent {
    id: root

    readonly property string pluginDir: pluginService?.pluginPath(pluginId) ?? ""
    readonly property string pythonScript: pluginDir + "/daemon/wallsync"
    readonly property string statePath: Env.pathHome + "/.cache/wallsync/state.json"
    readonly property string indexCache: Env.pathHome + "/.cache/wallsync/index.json"

    Component.onCompleted: {
        ensureAwwwDaemon()
        restoreState()
        registerIpcHandlers()
    }

    function ensureAwwwDaemon() {
        Proc.runCommand("wallsync.checkAwww", ["awww", "query"], (stdout, exitCode) => {
            if (exitCode !== 0) {
                console.info("[wallsync] awww-daemon not running, starting...")
                Quickshell.execDetached(["awww-daemon"])
            } else {
                console.info("[wallsync] awww-daemon is running")
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

    function registerIpcHandlers() {
        IpcHandler {
            id: matchHandler
            endpoint: "wallsync.match"
            handle: (path) => {
                if (!path || path === "") return { error: "No path provided" }
                runMatch(path)
                return { status: "ok" }
            }
        }

        IpcHandler {
            endpoint: "wallsync.random"
            handle: (vibe) => {
                runRandom(vibe ?? "")
                return { status: "ok" }
            }
        }

        IpcHandler {
            endpoint: "wallsync.index"
            handle: (force) => {
                runIndex(force === "true")
                return { status: "ok" }
            }
        }

        IpcHandler {
            endpoint: "wallsync.gui"
            handle: () => {
                launchOverlay()
                return { status: "ok" }
            }
        }
    }

    function scriptPath(): string {
        return pythonScript
    }

    function runMatch(path: string) {
        console.info("[wallsync] match:", path)
        var proc = matchProcessComponent.createObject(root, { targetPath: path })
        proc.start()
    }

    function runRandom(vibe: string) {
        console.info("[wallsync] random, vibe:", vibe)
        var args = [scriptPath(), "random"]
        if (vibe && vibe !== "") {
            args.push("--vibe", vibe)
        }
        Quickshell.execDetached(args)
        refreshGlobalState()
    }

    function runIndex(force: bool) {
        console.info("[wallsync] index, force:", force)
        var args = [scriptPath(), "index"]
        if (force) args.push("--force")
        Quickshell.execDetached(args)
    }

    function launchOverlay() {
        var overlayPath = pluginDir + "/Overlay.qml"
        Quickshell.execDetached([
            "quickshell", "-n", "-p", pluginDir, overlayPath
        ])
    }

    function refreshGlobalState() {
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

    Component {
        id: matchProcessComponent

        Process {
            id: proc
            property string targetPath: ""

            command: [scriptPath(), "match", targetPath]

            stdout: SplitParser {
                onRead: (line) => console.log("[wallsync]", line)
            }

            stderr: SplitParser {
                onRead: (line) => {
                    if (line.trim()) console.warn("[wallsync]", line.trim())
                }
            }

            onExited: (code) => {
                if (code === 0) {
                    root.refreshGlobalState()
                } else {
                    ToastService.showError("Wallsync", "Failed to apply wallpaper")
                }
                proc.destroy()
            }
        }
    }
}
