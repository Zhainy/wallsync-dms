import QtQuick
import qs.Common
import qs.Modules.Plugins
import qs.Widgets

PluginSettings {
    id: root
    pluginId: "wallsync"

    Component.onCompleted: {
        // Initialize and register all settings defaults in the DMS database
        // so that the controls bind and show up correctly.
        initSetting("wallpaperDirs", "~/Pictures/Wallpapers");
        initSetting("transitionType", "grow");
        initSetting("transitionStep", 90);
        initSetting("indexWorkers", 4);
        initSetting("hueWeight", 0.60);
        initSetting("satWeight", 0.25);
        initSetting("litWeight", 0.15);
    }

    function initSetting(key, defVal) {
        const val = root.loadValue(key, undefined);
        if (val === undefined) {
            root.saveValue(key, defVal);
        }
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
        text: "Configure wallpaper directories, transitions, and HSL color weights."
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
        bottomPadding: Theme.spacingM
    }

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.outline
        opacity: 0.2
    }

    StringSetting {
        settingKey: "wallpaperDirs"
        label: "Wallpaper Directories"
        description: "Comma-separated paths to wallpaper folders (e.g. ~/Pictures/Wallpapers)"
        placeholder: "~/Pictures/Wallpapers"
        defaultValue: "~/Pictures/Wallpapers"
    }

    StyledText {
        width: parent.width
        text: "Transition Settings"
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

    SliderSetting {
        settingKey: "transitionStep"
        label: "Transition Speed"
        description: "Animation speed step (lower = faster)"
        defaultValue: 90
        minimum: 20
        maximum: 300
        unit: ""
    }

    StyledText {
        width: parent.width
        text: "Indexing & Performance"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.Bold
        color: Theme.primary
        topPadding: Theme.spacingM
        bottomPadding: Theme.spacingXS
    }

    SliderSetting {
        settingKey: "indexWorkers"
        label: "Index Workers"
        description: "Parallel threads used during thumbnail generation"
        defaultValue: 4
        minimum: 1
        maximum: 16
        unit: ""
    }

    StyledText {
        width: parent.width
        text: "HSL Matching Weights"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.Bold
        color: Theme.primary
        topPadding: Theme.spacingM
        bottomPadding: Theme.spacingXS
    }

    SliderSetting {
        settingKey: "hueWeight"
        label: "Hue Importance"
        description: "HSL Hue match weighting"
        defaultValue: 0.60
        minimum: 0.0
        maximum: 1.0
        stepSize: 0.05
        unit: ""
    }

    SliderSetting {
        settingKey: "satWeight"
        label: "Saturation Importance"
        description: "HSL Saturation match weighting"
        defaultValue: 0.25
        minimum: 0.0
        maximum: 1.0
        stepSize: 0.05
        unit: ""
    }

    SliderSetting {
        settingKey: "litWeight"
        label: "Lightness Importance"
        description: "HSL Lightness match weighting"
        defaultValue: 0.15
        minimum: 0.0
        maximum: 1.0
        stepSize: 0.05
        unit: ""
    }
}
