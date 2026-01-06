import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire

Scope {
    id: root
    property string protectionMessage: ""
    property var focusedScreen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name)

    property string currentIndicator: "volume"
    property var indicators: [
        {
            id: "volume",
            sourceUrl: "indicators/VolumeIndicator.qml",
            globalStateValue: "osdVolumeOpen"
        },
        {
            id: "brightness",
            sourceUrl: "indicators/BrightnessIndicator.qml",
            globalStateValue: "osdBrightnessOpen"
        },
    ]

    function showIndicator(indicatorId) {
        const indicator = root.indicators.find(i => i.id === indicatorId);
        if (!indicator) return;
        root.currentIndicator = indicator.id;
        // Close other indicators, open the requested one
        root.indicators.forEach(i => {
            GlobalStates[i.globalStateValue] = i.id === indicator.id;
        });
        osdTimeout.restart();
    }

    function closeIndicators() {
        root.indicators.forEach(i => GlobalStates[i.globalStateValue] = false);
        osdTimeout.stop();
    }

    Timer {
        id: osdTimeout
        interval: Config.options.osd.timeout
        repeat: false
        running: false
        onTriggered: root.closeIndicators()
    }

    Connections {
        // Listen to protection triggers
        target: Audio
        function onSinkProtectionTriggered(reason) {
            root.protectionMessage = reason;
            root.currentIndicator = "volume";
            root.showIndicator("volume");
        }
    }

    Loader {
        id: osdLoader
        active: GlobalStates.osdVolumeOpen || GlobalStates.osdBrightnessOpen

        sourceComponent: PanelWindow {
            id: osdRoot
            color: "transparent"

            Connections {
                target: root
                function onFocusedScreenChanged() {
                    osdRoot.screen = root.focusedScreen;
                }
            }

            WlrLayershell.namespace: "quickshell:onScreenDisplay"
            WlrLayershell.layer: WlrLayer.Overlay
            anchors {
                top: !Config.options.bar.bottom
                bottom: Config.options.bar.bottom
            }
            mask: Region {
                item: osdValuesWrapper
            }

            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            margins {
                top: Appearance.sizes.barHeight
                bottom: Appearance.sizes.barHeight
            }

            implicitWidth: columnLayout.implicitWidth
            implicitHeight: columnLayout.implicitHeight
            visible: osdLoader.active

            ColumnLayout {
                id: columnLayout
                anchors.horizontalCenter: parent.horizontalCenter

                Item {
                    id: osdValuesWrapper
                    // Extra space for shadow
                    implicitHeight: contentColumnLayout.implicitHeight
                    implicitWidth: contentColumnLayout.implicitWidth
                    clip: true

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: root.closeIndicators()
                    }

                    Column {
                        id: contentColumnLayout
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                        }
                        spacing: 0

                        Loader {
                            id: osdIndicatorLoader
                            source: root.indicators.find(i => i.id === root.currentIndicator)?.sourceUrl
                        }

                        Item {
                            id: protectionMessageWrapper
                            anchors.horizontalCenter: parent.horizontalCenter
                            implicitHeight: protectionMessageBackground.implicitHeight
                            implicitWidth: protectionMessageBackground.implicitWidth
                            opacity: root.protectionMessage !== "" ? 1 : 0

                            StyledRectangularShadow {
                                target: protectionMessageBackground
                            }
                            Rectangle {
                                id: protectionMessageBackground
                                anchors.centerIn: parent
                                color: Appearance.m3colors.m3error
                                property real padding: 10
                                implicitHeight: protectionMessageRowLayout.implicitHeight + padding * 2
                                implicitWidth: protectionMessageRowLayout.implicitWidth + padding * 2
                                radius: Appearance.rounding.normal

                                RowLayout {
                                    id: protectionMessageRowLayout
                                    anchors.centerIn: parent
                                    MaterialSymbol {
                                        id: protectionMessageIcon
                                        text: "dangerous"
                                        iconSize: Appearance.font.pixelSize.hugeass
                                        color: Appearance.m3colors.m3onError
                                    }
                                    StyledText {
                                        id: protectionMessageTextWidget
                                        horizontalAlignment: Text.AlignHCenter
                                        color: Appearance.m3colors.m3onError
                                        wrapMode: Text.Wrap
                                        text: root.protectionMessage
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "osdVolume"

        function trigger() {
            root.showIndicator("volume");
        }

        function hide() {
            root.closeIndicators();
        }

        function toggle() {
            if (GlobalStates.osdVolumeOpen || GlobalStates.osdBrightnessOpen) {
                root.closeIndicators();
            } else {
                root.showIndicator("volume");
            }
        }
    }
    GlobalShortcut {
        name: "osdVolumeTrigger"
        description: "Triggers volume OSD on press"

        onPressed: {
            root.showIndicator("volume");
        }
    }
    GlobalShortcut {
        name: "osdVolumeHide"
        description: "Hides volume OSD on press"

        onPressed: {
            root.closeIndicators();
        }
    }

    // Auto-open on volume change
    Connections {
        target: Audio.sink?.audio ?? null
        function onVolumeChanged() {
            if (Audio.ready) root.showIndicator("volume");
        }
        function onMutedChanged() {
            if (Audio.ready) root.showIndicator("volume");
        }
    }

    // Auto-open on brightness change
    Connections {
        target: Brightness
        function onBrightnessChanged() {
            root.showIndicator("brightness");
        }
    }

    // Keep indicator selection in sync when state toggled externally
    Connections {
        target: GlobalStates
        function onOsdBrightnessOpenChanged() {
            if (GlobalStates.osdBrightnessOpen) root.currentIndicator = "brightness";
        }
        function onOsdVolumeOpenChanged() {
            if (GlobalStates.osdVolumeOpen) root.currentIndicator = "volume";
        }
    }
}
