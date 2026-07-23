import QtQuick
import qs.Common
import qs.Modules.Plugins
import qs.Widgets

PluginSettings {
    id: root
    pluginId: "wallsync"

    Component.onCompleted: {
        saveValue("wallpaperDirs", "~/Pictures/Wallpapers")
        saveValue("transitionType", "grow")
        saveValue("transitionStep", 90)
        saveValue("indexWorkers", 4)
        saveValue("launcherTrigger", "!wp")
        saveValue("hueWeight", 0.60)
        saveValue("satWeight", 0.25)
        saveValue("litWeight", 0.15)
    }

    StyledText {
        width: parent.width
        text: "Wallsync Settings"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: "Configure wallpaper directories, transitions, and color matching"
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
        bottomPadding: Theme.spacingM
    }

    StringSetting {
        settingKey: "wallpaperDirs"
        label: "Wallpaper Directories"
        description: "Comma-separated paths to wallpaper folders"
        placeholder: "~/Pictures/Wallpapers"
        defaultValue: "~/Pictures/Wallpapers"
    }

    StyledText {
        width: parent.width
        text: "Transitions"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.Bold
        color: Theme.primary
        topPadding: Theme.spacingM
        bottomPadding: Theme.spacingXS
    }

    SelectionSetting {
        settingKey: "transitionType"
        label: "Transition Type"
        description: "awww wallpaper transition effect"
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
        defaultValue: "grow"
    }

    SliderSetting {
        settingKey: "transitionStep"
        label: "Transition Speed"
        description: "Animation speed (lower = faster)"
        defaultValue: 90
        minimum: 20
        maximum: 300
        unit: ""
    }

    StyledText {
        width: parent.width
        text: "Indexing"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.Bold
        color: Theme.primary
        topPadding: Theme.spacingM
        bottomPadding: Theme.spacingXS
    }

    SliderSetting {
        settingKey: "indexWorkers"
        label: "Index Workers"
        description: "Parallel workers for thumbnail generation"
        defaultValue: 4
        minimum: 1
        maximum: 16
        unit: ""
    }

    StyledText {
        width: parent.width
        text: "Launcher"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.Bold
        color: Theme.primary
        topPadding: Theme.spacingM
        bottomPadding: Theme.spacingXS
    }

    StringSetting {
        settingKey: "launcherTrigger"
        label: "Launcher Trigger"
        description: "Prefix to activate wallsync in Spotlight"
        placeholder: "!wp"
        defaultValue: "!wp"
    }

    StyledText {
        width: parent.width
        text: "Color Matching"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.Bold
        color: Theme.primary
        topPadding: Theme.spacingM
        bottomPadding: Theme.spacingXS
    }

    SliderSetting {
        settingKey: "hueWeight"
        label: "Hue Weight"
        description: "Importance of hue in color matching (0.0 - 1.0)"
        defaultValue: 0.60
        minimum: 0.0
        maximum: 1.0
        stepSize: 0.05
        unit: ""
    }

    SliderSetting {
        settingKey: "satWeight"
        label: "Saturation Weight"
        description: "Importance of saturation in color matching (0.0 - 1.0)"
        defaultValue: 0.25
        minimum: 0.0
        maximum: 1.0
        stepSize: 0.05
        unit: ""
    }

    SliderSetting {
        settingKey: "litWeight"
        label: "Lightness Weight"
        description: "Importance of lightness in color matching (0.0 - 1.0)"
        defaultValue: 0.15
        minimum: 0.0
        maximum: 1.0
        stepSize: 0.05
        unit: ""
    }
}
