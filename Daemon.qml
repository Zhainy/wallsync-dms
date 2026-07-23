import QtQuick
import Quickshell
import qs.Common
import qs.Services

QtObject {
    id: root

    property var pluginService: null
    property string pluginId: "wallsync"

    Component.onCompleted: {
        console.info("[wallsync] Daemon started")
    }
}
