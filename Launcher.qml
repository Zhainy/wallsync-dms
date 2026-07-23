import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services

QtObject {
    id: root

    property var pluginService: null
    property string pluginId: "wallsync"
    property string trigger: pluginService?.loadPluginData(pluginId, "launcherTrigger", "!wp") ?? "!wp"
    signal itemsChanged

    readonly property string homeDir: Env.homePath
    readonly property string indexFile: homeDir + "/.cache/wallsync/index.json"
    readonly property string thumbDir: homeDir + "/.local/share/wallsync/thumbnails/"
    readonly property string pluginDir: homeDir + "/.config/DankMaterialShell/plugins/wallsync"
    readonly property string pythonScript: pluginDir + "/daemon/wallsync"

    property var _cachedItems: []
    property var _cachedCategories: []
    property var _indexData: null

    Component.onCompleted: {
        loadIndex()
    }

    function loadIndex() {
        Proc.runCommand("wallsync.loadIndex", ["cat", indexFile], (stdout, exitCode) => {
        Proc.runCommand("wallsync.loadIndex", ["cat", indexPath], (stdout, exitCode) => {
            if (exitCode === 0 && stdout.length > 0) {
                try {
                    _indexData = JSON.parse(stdout)
                    buildCategories()
                    _cachedItems = buildItems()
                    itemsChanged()
                } catch (e) {
                    console.warn("[wallsync] Index parse error:", e)
                    _indexData = null
                }
            } else {
                _indexData = null
                console.info("[wallsync] No index found, run 'wallsync index' first")
            }
        })
    }

    function buildCategories() {
        var vibeCount = {}
        var images = _indexData?.images ?? {}
        for (var path in images) {
            var entry = images[path]
            var vibes = entry.vibes ?? []
            for (var i = 0; i < vibes.length; i++) {
                vibeCount[vibes[i]] = (vibeCount[vibes[i]] ?? 0) + 1
            }
        }

        _cachedCategories = [{ id: "", name: I18n.tr("All"), searchTerm: "" }]
        var sorted = Object.keys(vibeCount).sort((a, b) => vibeCount[b] - vibeCount[a])
        for (var j = 0; j < sorted.length; j++) {
            _cachedCategories.push({
                id: sorted[j],
                name: sorted[j].charAt(0).toUpperCase() + sorted[j].slice(1),
                searchTerm: sorted[j]
            })
        }
    }

    function buildItems(filterVibe) {
        var items = []
        var images = _indexData?.images ?? {}
        var count = 0

        for (var path in images) {
            if (count >= 200) break
            var entry = images[path]
            if (filterVibe && filterVibe !== "") {
                var vibes = entry.vibes ?? []
                if (vibes.indexOf(filterVibe) < 0) continue
            }

            var filename = path
            var idx = path.lastIndexOf("/")
            if (idx >= 0) filename = path.substring(idx + 1)

            var thumbUrl = ""
            var thumbRaw = entry.thumbnail ?? ""
            if (thumbRaw !== "") {
                if (thumbRaw.charAt(0) === "/") {
                    thumbUrl = "file://" + encodeURI(thumbRaw)
                } else {
                    thumbUrl = "file://" + thumbDir + encodeURI(thumbRaw)
                }
            }

            items.push({
                name: filename,
                icon: thumbUrl !== "" ? thumbUrl : "material:wallpaper",
                comment: (entry.vibes ?? []).join(" • ") + (entry.width ? "  (" + entry.width + "×" + entry.height + ")" : ""),
                action: "custom:match|" + path,
                categories: ["Wallsync"],
                keywords: [filename, ...(entry.vibes ?? [])]
            })
            count++
        }

        items.unshift({
            name: I18n.tr("🎠 Open Coverflow"),
            icon: "material:palette",
            comment: I18n.tr("Launch the 3D wallpaper picker"),
            action: "custom:gui",
            categories: ["Wallsync"]
        })

        items.unshift({
            name: I18n.tr("🎲 Random Pair"),
            icon: "material:shuffle",
            comment: I18n.tr("Set a random color-coordinated wallpaper pair"),
            action: "custom:random",
            categories: ["Wallsync"]
        })

        return items
    }

    function getItems(query) {
        if (!query || query.trim().length === 0) return []

        var q = query.trim().toLowerCase()

        var filtered = _cachedItems.filter(function(item) {
            var nameMatch = item.name.toLowerCase().indexOf(q) >= 0
            var kwMatch = (item.keywords ?? []).some(function(kw) {
                return kw.toLowerCase().indexOf(q) >= 0
            })
            return nameMatch || kwMatch
        })

        return filtered
    }

    function getCategories() {
        return _cachedCategories
    }

    function setCategory(categoryId) {
        _cachedItems = buildItems(categoryId)
        itemsChanged()
    }

    function executeItem(item) {
        if (!item?.action) return

        var parts = item.action.split("|")
        var actionType = parts[0]?.replace("custom:", "") ?? ""

        if (actionType === "match" && parts[1]) {
            var path = parts[1]
            Quickshell.execDetached([pythonScript, "match", path])
            ToastService.showInfo("Wallsync", "Applying wallpaper...")
        } else if (actionType === "random") {
            Quickshell.execDetached([pythonScript, "random"])
            ToastService.showInfo("Wallsync", "Setting random pair...")
        } else if (actionType === "gui") {
            Quickshell.execDetached(["quickshell", "-n", "-p", pluginDir + "/Overlay.qml"])
        }
    }

    function getContextMenuActions(item) {
        if (!item?.action) return []

        var parts = item.action.split("|")
        var actionType = parts[0]?.replace("custom:", "") ?? ""

        if (actionType === "match" && parts[1]) {
            return [
                {
                    icon: "content_copy",
                    text: I18n.tr("Copy path"),
                    closeLauncher: true,
                    action: function() {
                        Quickshell.execDetached(["sh", "-c", "echo -n '" + parts[1] + "' | wl-copy"])
                        ToastService.showInfo("Copied to clipboard")
                    }
                }
            ]
        }

        return []
    }

    function getPasteText(item) {
        if (!item?.action) return null
        var parts = item.action.split("|")
        if (parts[0] === "custom:match" && parts[1]) return parts[1]
        return null
    }
}
