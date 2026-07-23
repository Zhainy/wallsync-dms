import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    readonly property string homeDir: Env.homePath
    readonly property string cacheDir: homeDir + "/.cache/wallsync"
    readonly property string indexPath: "file://" + cacheDir + "/index.json"
    readonly property string statePath: "file://" + cacheDir + "/state.json"
    property string _td: homeDir + "/.local/share/wallsync/thumbnails/"
    readonly property string thumbDir: _td[_td.length - 1] === "/" ? _td : _td + "/"

    WlrLayershell.layer: WlrLayershell.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.namespace: "wallsync-picker"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    color: "transparent"

    anchors { top: true; bottom: true; left: true; right: true }

    property var allEntries: []
    property string currentVibe: ""
    property real accentHue: 220
    property string selectedPath: ""

    readonly property int cardW: 360
    readonly property int cardH: 225

    ListModel { id: wallpaperModel }
    ListModel { id: vibeModel }

    Component.onCompleted: {
        mainFocusScope.forceActiveFocus()
        loadState()
        loadIndex()
    }

    function loadState() {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", root.statePath)
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.responseText && xhr.responseText.length > 0) {
                    try {
                        var p = (JSON.parse(xhr.responseText).current || {}).primary
                        if (p) resolveAccent(p)
                    } catch (_) {}
                }
            }
        }
        xhr.send()
    }

    function resolveAccent(path) {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", root.indexPath)
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.responseText && xhr.responseText.length > 0) {
                    try {
                        var e = (JSON.parse(xhr.responseText).images || {})[path]
                        if (e && e.dominant_hue != null) root.accentHue = e.dominant_hue
                    } catch (_) {}
                }
            }
        }
        xhr.send()
    }

    function loadIndex() {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", root.indexPath)
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.responseText && xhr.responseText.length > 0) {
                    try {
                        var data = JSON.parse(xhr.responseText)
                        if (data && data.images) {
                            processData(data.images)
                        }
                    } catch (e) {
                        console.error("Index parse error:", e)
                    }
                }
            }
        }
        xhr.send()
    }

    function buildThumbPath(tf) {
        if (!tf || tf === "") return ""
        if (tf.charAt(0) === "/") {
            // Absolute path: encode as proper file:// URI
            return "file://" + encodeURI(tf)
        }
        // Basename: use thumbDir prefix
        return "file://" + root.thumbDir + tf
    }

    function getBasename(path) {
        if (!path) return ""
        var idx = path.lastIndexOf('/')
        return idx >= 0 ? path.substring(idx + 1) : path
    }


    function processData(images) {
        allEntries = []
        var vc = {}
        var liveCount = 0
        var skipped = 0
        var totalPaths = 0

        for (var path in images) {
            totalPaths++
            var info = images[path]
            var ev = info.vibes
            if (!Array.isArray(ev) || ev.length === 0) { skipped++; continue }

            var mType = info.media_type || "static"
            if (mType === "video" || mType === "gif") liveCount++

            allEntries.push({
                path: path,
                filename: getBasename(path),
                thumbPath: root.buildThumbPath(info.thumbnail),
                vibes: ev,
                vibesString: ev.join(" • "),
                mediaType: mType,
                dominantHue: info.dominant_hue != null ? info.dominant_hue : 220,
                imgWidth: info.width || 0,
                imgHeight: info.height || 0
            })
            for (var i = 0; i < ev.length; i++) vc[ev[i]] = (vc[ev[i]] || 0) + 1
        }

        console.log("DIAG: processData totalPaths=" + totalPaths + " skipped=" + skipped + " valid=" + allEntries.length)

        // Sort by path for deterministic order (QML for...in order is NOT guaranteed)
        allEntries.sort(function(a, b) {
            if (a.path < b.path) return -1
            if (a.path > b.path) return 1
            return 0
        })

        var va = []
        for (var v in vc) va.push({ vibe: v, count: vc[v] })
        va.sort(function(a, b) { return b.count - a.count })

        vibeModel.clear()
        vibeModel.append({ label: "All", vibe: "", count: allEntries.length, active: true })
        
        if (liveCount > 0) {
            vibeModel.append({ label: "🎬 LIVE", vibe: "LIVE_ONLY", count: liveCount, active: false })
        }
        
        for (var j = 0; j < va.length; j++) {
            vibeModel.append({ label: va[j].vibe, vibe: va[j].vibe, count: va[j].count, active: false })
        }

        filterByVibe("")
    }

    function filterByVibe(vibe) {
        currentVibe = vibe
        wallpaperModel.clear()
        for (var i = 0; i < allEntries.length; i++) {
            var e = allEntries[i]
            if (vibe === "") {
                wallpaperModel.append(e)
            } else if (vibe === "LIVE_ONLY") {
                if (e.mediaType === "video" || e.mediaType === "gif") wallpaperModel.append(e)
            } else if (e.vibes.indexOf(vibe) >= 0) {
                wallpaperModel.append(e)
            }
        }
        for (var j = 0; j < vibeModel.count; j++) {
            vibeModel.setProperty(j, "active", vibeModel.get(j).vibe === vibe)
        }
        listView.currentIndex = 0
        var m0 = wallpaperModel.count > 0 ? wallpaperModel.get(0) : null
        root.selectedPath = m0 && m0.path ? m0.path : ""
    }

    function stepToNext() {
        var n = listView.currentIndex + 1
        if (n < wallpaperModel.count) {
            listView.currentIndex = n
        }
    }

    function stepToPrev() {
        if (listView.currentIndex > 0) {
            listView.currentIndex--
        }
    }

    function applyWallpaper(targetPath) {
        if (!targetPath || targetPath === "") return

        var cleanPath = targetPath
        if (cleanPath.indexOf("file://") === 0) {
            cleanPath = cleanPath.substring(7)
        }
        try {
            cleanPath = decodeURIComponent(cleanPath)
        } catch (_) {}

        if (cleanPath.charAt(0) !== "/") {
            console.error("applyWallpaper: ruta no absoluta: " + cleanPath)
            return
        }

        console.log("APPLY: idx=" + listView.currentIndex + " path=" + cleanPath)

        Quickshell.execDetached([
            "python3", "-c",
            "import sys; f=open('/tmp/wallsync_selection','w'); f.write(sys.argv[1]); f.close()",
            cleanPath
        ])

        var t = Qt.createQmlObject("import QtQuick; Timer {}", root)
        t.interval = 300
        t.repeat = false
        t.triggered.connect(function() { Qt.quit() })
        t.start()
    }

    function applyCurrent() {
        var idx = listView.currentIndex
        var m = (idx >= 0 && idx < wallpaperModel.count) ? wallpaperModel.get(idx) : null
        if (m && m.path) {
            root.selectedPath = m.path
            applyWallpaper(m.path)
        }
    }

    // Backdrop
    Rectangle {
        anchors.fill: parent
        color: "#050609"
        opacity: 0.78

        MouseArea {
            anchors.fill: parent
            onClicked: Qt.quit()
        }
    }

    // Top Header
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.05
        spacing: 6

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "WALLPAPER COVERFLOW"
            color: "#ffffff"
            font.pixelSize: 24
            font.weight: Font.Bold
            font.letterSpacing: 3.0
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: wallpaperModel.count + " wallpapers" + (currentVibe !== "" ? "  •  " + (currentVibe === "LIVE_ONLY" ? "🎬 LIVE" : currentVibe.toUpperCase()) : "")
            color: Qt.hsla(root.accentHue / 360, 0.75, 0.70, 0.90)
            font.pixelSize: 13
            font.weight: Font.DemiBold
            font.letterSpacing: 0.5
        }
    }

    FocusScope {
        id: mainFocusScope
        anchors.fill: parent
        focus: true

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Left || event.key === Qt.Key_H || event.key === Qt.Key_A) {
                stepToPrev()
                event.accepted = true
            } else if (event.key === Qt.Key_Right || event.key === Qt.Key_L || event.key === Qt.Key_D) {
                stepToNext()
                event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Space) {
                applyCurrent()
                event.accepted = true
            } else if (event.key === Qt.Key_Escape) {
                Qt.quit()
                event.accepted = true
            } else if (event.key === Qt.Key_Home) {
                listView.currentIndex = 0
                event.accepted = true
            } else if (event.key === Qt.Key_End) {
                listView.currentIndex = wallpaperModel.count - 1
                event.accepted = true
            }
        }

        // ─── Floating Dynamic Vibe Filter Chips Dock (Shrink-Wrapped & Centered) ───
        Rectangle {
            id: filterDock
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.15
            width: Math.min(parent.width - 60, vibeRow.implicitWidth + 32)
            height: 44
            radius: 22
            color: Qt.rgba(0.08, 0.09, 0.13, 0.85)
            border.color: Qt.rgba(1, 1, 1, 0.08)
            border.width: 1

            Flickable {
                id: filterFlickable
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                contentWidth: vibeRow.width + 12
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Row {
                    id: vibeRow
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Repeater {
                        model: vibeModel

                        delegate: Rectangle {
                            id: pill
                            required property string label
                            required property string vibe
                            required property int count
                            required property bool active

                            implicitWidth: txt.implicitWidth + 24
                            implicitHeight: 28
                            radius: 14
                            color: active
                                ? Qt.hsla(root.accentHue / 360, 0.80, 0.50, 0.95)
                                : (pillMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.06))
                            border.color: active
                                ? Qt.hsla(root.accentHue / 360, 0.70, 0.65, 1.0)
                                : Qt.rgba(1, 1, 1, 0.06)
                            border.width: 1

                            Behavior on color { ColorAnimation { duration: 150 } }

                            Text {
                                id: txt
                                anchors.centerIn: parent
                                text: label + "  " + count
                                color: active ? "#ffffff" : Qt.rgba(1, 1, 1, 0.70)
                                font.pixelSize: 11
                                font.weight: active ? Font.Bold : Font.Normal
                            }

                            MouseArea {
                                id: pillMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    filterByVibe(vibe)
                                    mainFocusScope.forceActiveFocus()
                                }
                            }
                        }
                    }
                }

                // Scroll horizontal con la rueda del ratón
                MouseArea {
                    anchors.fill: parent
                    propagateComposedEvents: true
                    onWheel: function(wh) {
                        var delta = wh.angleDelta.y !== 0 ? wh.angleDelta.y : wh.angleDelta.x
                        if (delta !== 0) {
                            var newX = filterFlickable.contentX - (delta * 0.8)
                            var maxX = Math.max(0, filterFlickable.contentWidth - filterFlickable.width)
                            filterFlickable.contentX = Math.max(0, Math.min(maxX, newX))
                        }
                    }
                    onClicked: function(mouse) { mouse.accepted = false }
                }
            }
        }

        // Full-Width 3D Coverflow View
        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: filterDock.bottom
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40

            // Floating filename badge — shows the CURRENT centered item's filename
            Rectangle {
                id: currentLabel
                anchors.horizontalCenter: parent.horizontalCenter
                y: 16
                height: 32
                radius: 16
                color: Qt.rgba(0, 0, 0, 0.70)
                border.color: Qt.hsla(root.accentHue / 360, 0.70, 0.55, 0.90)
                border.width: 1
                visible: root.selectedPath !== ""
                width: Math.min(700, lbl.implicitWidth + 32)

                Text {
                    id: lbl
                    anchors.centerIn: parent
                    text: {
                        var s = root.selectedPath
                        var idx = s.lastIndexOf('/')
                        return idx >= 0 ? s.substring(idx + 1) : s
                    }
                    color: "#ffffff"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    elide: Text.ElideMiddle
                }
            }

            ListView {
                id: listView
                orientation: ListView.Horizontal
                anchors.fill: parent

                preferredHighlightBegin: listView.width / 2 - root.cardW / 2
                preferredHighlightEnd: listView.width / 2 + root.cardW / 2
                highlightRangeMode: ListView.StrictlyEnforceRange
                snapMode: ListView.SnapToItem
                spacing: -140
                clip: false

                header: Item { width: listView.width / 2 - root.cardW / 2 }
                footer: Item { width: listView.width / 2 - root.cardW / 2 }

                model: wallpaperModel
                highlightMoveDuration: 240

                onCurrentIndexChanged: {
                    var idx = listView.currentIndex
                    if (idx >= 0 && idx < wallpaperModel.count) {
                        var m = wallpaperModel.get(idx)
                        if (m && m.path) {
                            root.selectedPath = m.path
                        }
                    }
                }

                delegate: Item {
                    id: d
                    required property int index
                    required property string path
                    required property string filename
                    required property string thumbPath
                    required property var vibes
                    required property string vibesString
                    required property string mediaType
                    required property real dominantHue
                    required property int imgWidth
                    required property int imgHeight

                    width: root.cardW
                    height: root.cardH
                    anchors.verticalCenter: parent ? parent.verticalCenter : undefined

                    readonly property real cDist: {
                        if (!ListView.view || ListView.view.width === 0) return 0
                        var vc = ListView.view.contentX + ListView.view.width / 2
                        var ic = x + width / 2
                        return (ic - vc) / (root.cardW * 0.95)
                    }

                    readonly property real absDist: Math.abs(cDist)

                    scale: Math.max(0.60, 1.0 - absDist * 0.35)
                    opacity: Math.max(0.35, 1.0 - absDist * 0.50)
                    z: Math.round(1000 - absDist * 100)

                    transform: Rotation {
                        origin.x: d.width / 2
                        origin.y: d.height / 2
                        axis { x: 0; y: 1; z: 0 }
                        angle: Math.max(-45, Math.min(45, d.cDist * -38))
                    }

                    Behavior on scale { SmoothedAnimation { duration: 200; velocity: 8 } }
                    Behavior on opacity { SmoothedAnimation { duration: 200; velocity: 6 } }

                    Rectangle {
                        id: card
                        anchors.fill: parent
                        radius: 22
                        color: Qt.hsla(dominantHue / 360, 0.25, 0.15, 0.85)
                        clip: true

                        layer.enabled: d.absDist < 0.3
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowColor: Qt.rgba(0, 0, 0, d.absDist < 0.3 ? 0.70 : 0.35)
                            shadowBlur: d.absDist < 0.3 ? 0.60 : 0.30
                            shadowVerticalOffset: d.absDist < 0.3 ? 12 : 6
                        }

                        Image {
                            id: img
                            anchors.fill: parent
                            source: thumbPath
                            asynchronous: true
                            cache: true
                            fillMode: Image.PreserveAspectCrop
                            sourceSize.width: 380
                            sourceSize.height: 240
                            visible: status === Image.Ready
                        }

                        Rectangle {
                            anchors.fill: parent
                            visible: img.status !== Image.Ready
                            color: Qt.hsla(dominantHue / 360, 0.40, 0.18, 0.90)
                            radius: 22
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: 22
                            color: "transparent"
                            border.color: d.absDist < 0.30
                                ? Qt.hsla(root.accentHue / 360, 0.85, 0.60, 0.95)
                                : Qt.rgba(1, 1, 1, 0.08)
                            border.width: d.absDist < 0.30 ? 3 : 1
                            Behavior on border.color { ColorAnimation { duration: 150 } }
                        }

                        Rectangle {
                            visible: mediaType !== "static"
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 12
                            width: btxt.implicitWidth + 16
                            height: 24
                            radius: 12
                            color: mediaType === "video"
                                ? Qt.rgba(0.0, 0.75, 0.95, 0.95)
                                : Qt.rgba(0.9, 0.2, 0.7, 0.95)

                            Text {
                                id: btxt
                                anchors.centerIn: parent
                                text: mediaType === "video" ? "▶ LIVE MP4" : "🎞 GIF"
                                color: "#ffffff"
                                font.pixelSize: 9
                                font.weight: Font.Bold
                                font.letterSpacing: 0.5
                            }
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 56
                            visible: d.absDist < 0.40
                            opacity: d.absDist < 0.40 ? (1.0 - d.absDist * 2.2) : 0

                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "transparent" }
                                GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.88) }
                            }

                            Column {
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.margins: 12
                                spacing: 2

                                Text {
                                    width: parent.width
                                    text: filename
                                    color: "#ffffff"
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                    elide: Text.ElideMiddle
                                }

                                Text {
                                    width: parent.width
                                    text: (vibesString || "") + (d.imgWidth > 0 ? "  (" + d.imgWidth + "×" + d.imgHeight + ")" : "")
                                    color: Qt.rgba(1, 1, 1, 0.65)
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            root.selectedPath = d.path
                            console.log("DIAG: onClick path=" + d.path)
                            if (index === listView.currentIndex) {
                                applyWallpaper(d.path)
                            } else {
                                listView.currentIndex = index
                                mainFocusScope.forceActiveFocus()
                            }
                        }

                        onDoubleClicked: {
                            root.selectedPath = d.path
                            console.log("DIAG: onDoubleClick path=" + d.path)
                            applyWallpaper(d.path)
                        }

                        onWheel: function(wh) {
                            if (wh.angleDelta.y < 0) stepToNext()
                            else if (wh.angleDelta.y > 0) stepToPrev()
                            wh.accepted = true
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height - 28
        width: hintTxt.implicitWidth + 28
        height: 22
        radius: 11
        color: Qt.rgba(0.0, 0.0, 0.0, 0.50)

        Text {
            id: hintTxt
            anchors.centerIn: parent
            text: "← → / H L navigate  •  scroll  •  Click / Enter select  •  Esc close"
            color: Qt.rgba(1, 1, 1, 0.50)
            font.pixelSize: 10
            font.letterSpacing: 0.3
        }
    }
}
