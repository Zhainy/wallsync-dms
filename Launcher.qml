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
