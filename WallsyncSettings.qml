import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "wallsyncDms"

    // Reusable Slider Component verified to work natively in DMS
    component SettingSlider: Column {
        id: sliderRoot
        property string label: ""
        property string desc: ""
        property string settingKey: ""
        property int min: 0
        property int max: 100
        property int defaultVal: 0
        property string unit: ""

        width: parent.width; spacing: Theme.spacingXS
        property var val: root.loadValue(settingKey, defaultVal)

        Row {
            width: parent.width; spacing: Theme.spacingS
            StyledText { 
                text: label
                font.weight: Font.Medium
                color: Theme.surfaceText
                width: parent.width - 24 - Theme.spacingS 
            }
            DankIcon {
                name: "restart_alt"; size: 20
                opacity: String(sliderRoot.val) !== String(defaultVal) ? 0.8 : 0.0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
                MouseArea { 
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.saveValue(settingKey, defaultVal) 
                }
            }
        }
        StyledText { 
            text: desc
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.surfaceVariantText
            width: parent.width
            wrapMode: Text.WordWrap
            opacity: 0.8 
        }
        DankSlider { 
            width: parent.width
            minimum: sliderRoot.min
            maximum: sliderRoot.max
            value: Number(sliderRoot.val) || sliderRoot.defaultVal
            unit: sliderRoot.unit
            onSliderValueChanged: v => root.saveValue(sliderRoot.settingKey, v) 
        }
    }

    StringSetting {
        settingKey: "wallpaperDirs"
        label: "Wallpaper Directories"
        description: "Comma-separated paths to wallpaper folders (e.g. ~/Pictures/Wallpapers)"
        placeholder: "~/Pictures/Wallpapers"
        defaultValue: "~/Pictures/Wallpapers"
    }

    SelectionSetting {
        settingKey: "transitionType"
        label: "Transition Type"
        description: "awww wallpaper transition effect"
        defaultValue: "grow"
        options: [
            { label: "Grow", value: "grow" },
            { label: "Outer", value: "outer" },
            { label: "Wipe", value: "wipe" },
            { label: "Wave", value: "wave" },
            { label: "Fade", value: "fade" },
            { label: "Left", value: "left" },
            { label: "Right", value: "right" },
            { label: "Top", value: "top" },
            { label: "Bottom", value: "bottom" }
        ]
    }

    SettingSlider {
        label: "Transition Speed"
        desc: "Animation speed step (lower = faster, default: 90)"
        settingKey: "transitionStep"
        min: 20; max: 300; defaultVal: 90; unit: ""
    }

    SettingSlider {
        label: "Index Workers"
        desc: "Parallel threads used during thumbnail generation (default: 4)"
        settingKey: "indexWorkers"
        min: 1; max: 16; defaultVal: 4; unit: ""
    }

    SettingSlider {
        label: "Hue Importance Weight"
        desc: "HSL Hue match weighting (percentage scale, default: 60%)"
        settingKey: "hueWeight"
        min: 0; max: 100; defaultVal: 60; unit: "%"
    }

    SettingSlider {
        label: "Saturation Importance Weight"
        desc: "HSL Saturation match weighting (percentage scale, default: 25%)"
        settingKey: "satWeight"
        min: 0; max: 100; defaultVal: 25; unit: "%"
    }

    SettingSlider {
        label: "Lightness Importance Weight"
        desc: "HSL Lightness match weighting (percentage scale, default: 15%)"
        settingKey: "litWeight"
        min: 0; max: 100; defaultVal: 15; unit: "%"
    }

    SelectionSetting {
        settingKey: "vibeStyle"
        label: "Vibe Tag Style"
        description: "Choose how color vibe pills are rendered in the Coverflow picker overlay"
        defaultValue: "text"
        options: [
            { label: "Text with Color Dot", value: "text" },
            { label: "Color Dot Only (Minimalist)", value: "dot" }
        ]
    }
}
