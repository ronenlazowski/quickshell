import qs.modules.ii.bar.weather
import qs.modules.ii.bar.battery
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

Item { // Bar content region
    id: root

    // Provides the enclosing window so popups can map coordinates correctly
    property var qsWindow: null

    property var screen: root.qsWindow?.window?.screen
    property var brightnessMonitor: Brightness.getMonitorForScreen(screen)
    property real useShortenedForm: (Appearance.sizes.barHellaShortenScreenWidthThreshold >= screen?.width) ? 2 : (Appearance.sizes.barShortenScreenWidthThreshold >= screen?.width) ? 1 : 0
    readonly property int centerSideModuleWidth: (useShortenedForm === 2) ? Appearance.sizes.barCenterSideModuleWidthHellaShortened : (useShortenedForm === 1) ? Appearance.sizes.barCenterSideModuleWidthShortened : Appearance.sizes.barCenterSideModuleWidth

    component VerticalBarSeparator: Rectangle {
        Layout.topMargin: Appearance.sizes.baseBarHeight / 3
        Layout.bottomMargin: Appearance.sizes.baseBarHeight / 3
        Layout.fillHeight: true
        implicitWidth: 1
        color: Appearance.colors.colOutlineVariant
    }

    // Background shadow
    Loader {
        active: Config.options.bar.showBackground && Config.options.bar.cornerStyle === 1 && Config.options.bar.floatStyleShadow
        anchors.fill: barBackground
        sourceComponent: StyledRectangularShadow {
            anchors.fill: undefined // The loader's anchors act on this, and this should not have any anchor
            target: barBackground
        }
    }

    // Background
    Rectangle {
        id: barBackground
        anchors {
            fill: parent
            margins: Config.options.bar.cornerStyle === 1 ? Appearance.sizes.hyprlandGapsOut : 0
        }
        color: Config.options.bar.showBackground ? Appearance.colors.colLayer0 : "transparent"
        radius: Config.options.bar.cornerStyle === 1 ? Appearance.rounding.windowRounding : 0
        border.width: Config.options.bar.cornerStyle === 1 ? 1 : 0
        border.color: Appearance.colors.colLayer0Border
    }

    // Left side | scroll to change brightness
    FocusedScrollMouseArea {
        id: barLeftSideMouseArea

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: middleSection.left
        }

        implicitWidth: leftSectionRowLayout.implicitWidth
        implicitHeight: Appearance.sizes.baseBarHeight

        onScrollDown: root.brightnessMonitor.setBrightness(root.brightnessMonitor.brightness - 0.05)
        onScrollUp: root.brightnessMonitor.setBrightness(root.brightnessMonitor.brightness + 0.05)
        onMovedAway: GlobalStates.osdBrightnessOpen = false
        onPressed: event => {
            if (event.button === Qt.LeftButton) {
                GlobalStates.sidebarLeftOpen = !GlobalStates.sidebarLeftOpen;
            }
        }

        // Visual content
        ScrollHint {
            reveal: barLeftSideMouseArea.hovered
            icon: "light_mode"
            tooltipText: Translation.tr("Scroll to change brightness")
            side: "left"
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
        }

        RowLayout {
            id: leftSectionRowLayout
            anchors.fill: parent
            spacing: 10

            CustomIcon {
                    id: distroIcon
                    Layout.leftMargin: Appearance.rounding.screenRounding
                    width: 25
                    height: 25
                    source: SystemInfo.distroIcon
                    colorize: true
                    color: Appearance.colors.colOnLayer0
                }

            ActiveWindow {
                visible: root.useShortenedForm === 0
                Layout.rightMargin: Appearance.rounding.screenRounding
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }

    // Middle section
    Row {
        id: middleSection
        anchors {
            top: parent.top
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        spacing: 4

        // Battery
        Loader {
            anchors.verticalCenter: parent.verticalCenter
            active: (root.useShortenedForm < 2 && Battery.available)

            sourceComponent: BarGroup {
                BatteryBar { qsWindow: root.qsWindow }
            }
        }
        BarGroup {
            id: leftCenterGroup
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: root.centerSideModuleWidth

            Resources {
                qsWindow: root.qsWindow
                alwaysShowAllResources: root.useShortenedForm === 2
                Layout.fillWidth: root.useShortenedForm === 2
            }

            Media {
                visible: root.useShortenedForm < 2
                qsWindow: root.qsWindow
                Layout.fillWidth: true
            }
        }

        VerticalBarSeparator {
            visible: Config.options?.bar.borderless
        }

        BarGroup {
            id: middleCenterGroup
            anchors.verticalCenter: parent.verticalCenter
            padding: workspacesWidget.widgetPadding

            Workspaces {
                id: workspacesWidget
                Layout.fillHeight: true

                MouseArea {
                    // Right-click to toggle overview
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton

                    onPressed: event => {
                        if (event.button === Qt.RightButton) {
                            GlobalStates.overviewOpen = !GlobalStates.overviewOpen;
                        }
                    }
                }
            }
        }

        VerticalBarSeparator {
            visible: Config.options?.bar.borderless
        }

        MouseArea {
            id: rightCenterGroup
            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: root.centerSideModuleWidth
            implicitHeight: rightCenterGroupContent.implicitHeight

            onPressed: {
                GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen;
            }

            BarGroup {
                id: rightCenterGroupContent
                anchors.fill: parent

                RowLayout {

                    ClockWidget {
                        qsWindow: root.qsWindow
                        showDate: (Config.options.bar.verbose && root.useShortenedForm < 2)
                        Layout.leftMargin: 4
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    UtilButtons {
                        visible: (Config.options.bar.verbose && root.useShortenedForm === 0)
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    }
                }
            }
        }
    }

    // Right side | scroll to change volume
    FocusedScrollMouseArea {
        id: barRightSideMouseArea

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: middleSection.right
            right: parent.right
        }
        implicitWidth: rightSectionRowLayout.implicitWidth
        implicitHeight: Appearance.sizes.baseBarHeight

        onScrollDown: Audio.decrementVolume()
        onScrollUp: Audio.incrementVolume()
        onMovedAway: GlobalStates.osdVolumeOpen = false
        onPressed: event => {
            if (event.button === Qt.LeftButton) {
                GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen;
            }
        }

        // Visual content
        ScrollHint {
            reveal: barRightSideMouseArea.hovered
            icon: "volume_up"
            tooltipText: Translation.tr("Scroll to change volume")
            side: "right"
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
        }

        RowLayout {
            id: rightSectionRowLayout
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1
            layoutDirection: Qt.RightToLeft

            RowLayout {
                id: rightCluster
                layoutDirection: Qt.RightToLeft
                spacing: indicatorCluster.anyVisible ? 1 : 0
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                Layout.fillWidth: false

                Item {
                    id: indicatorCluster
                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: indicatorCluster.anyVisible ? Appearance.rounding.screenRounding : 0
                    Layout.minimumWidth: 0
                    Layout.preferredWidth: indicatorCluster.anyVisible ? 16 : 0
                    implicitHeight: (sharingIndicator.dotSize + micIndicator.dotSize + cameraIndicator.dotSize) + 8

                    // Guard against undefined ids/reveals to avoid undefined→bool warnings
                    property bool sharingVisible: Boolean(sharingIndicator?.reveal)
                    property bool micVisible: Boolean(micIndicator?.reveal)
                    property bool cameraVisible: Boolean(cameraIndicator?.reveal)
                    property bool anyVisible: sharingVisible || micVisible || cameraVisible
                    property int visibleCount: (sharingVisible ? 1 : 0) + (micVisible ? 1 : 0) + (cameraVisible ? 1 : 0)
                    property real offset: ((micIndicator?.dotSize ?? 10) / 2) + 2
                    property real horizontalOffset: ((cameraIndicator?.dotSize ?? 10) / 2) + 2

                    Behavior on Layout.preferredWidth {
                        NumberAnimation {
                            duration: Appearance.animation.elementMoveFast?.duration ?? 150
                            easing.type: Easing.InOutQuad
                        }
                    }

                    Behavior on Layout.rightMargin {
                        NumberAnimation {
                            duration: Appearance.animation.elementMoveFast?.duration ?? 150
                            easing.type: Easing.InOutQuad
                        }
                    }

                    SharingIndicator {
                        id: sharingIndicator
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: (parent.height - dotSize) / 2
                        spacing: 0
                        color: rightSidebarButton.colText
                        dotSize: 10
                    }

                    MicrophoneIndicator {
                        id: micIndicator
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: (parent.height - dotSize) / 2
                        spacing: 0
                        color: rightSidebarButton.colText
                        dotSize: 10
                    }

                    CameraIndicator {
                        id: cameraIndicator
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: (parent.height - dotSize) / 2
                        spacing: 0
                        color: rightSidebarButton.colText
                        dotSize: 10
                    }

                    states: [
                        State {
                            name: "three"
                            when: indicatorCluster.visibleCount === 3
                            // Triangle layout: sharing top, mic bottom-left, camera bottom-right
                            PropertyChanges { target: sharingIndicator; y: (indicatorCluster.height - sharingIndicator.dotSize) / 2 - indicatorCluster.offset; anchors.horizontalCenterOffset: 0 }
                            PropertyChanges { target: micIndicator; y: (indicatorCluster.height - micIndicator.dotSize) / 2 + indicatorCluster.offset; anchors.horizontalCenterOffset: -indicatorCluster.horizontalOffset }
                            PropertyChanges { target: cameraIndicator; y: (indicatorCluster.height - cameraIndicator.dotSize) / 2 + indicatorCluster.offset; anchors.horizontalCenterOffset: indicatorCluster.horizontalOffset }
                        },
                        State {
                            name: "shareMic"
                            when: indicatorCluster.visibleCount === 2 && indicatorCluster.sharingVisible && indicatorCluster.micVisible
                            PropertyChanges { target: sharingIndicator; y: (indicatorCluster.height - sharingIndicator.dotSize) / 2 - indicatorCluster.offset; anchors.horizontalCenterOffset: 0 }
                            PropertyChanges { target: micIndicator; y: (indicatorCluster.height - micIndicator.dotSize) / 2 + indicatorCluster.offset; anchors.horizontalCenterOffset: 0 }
                            PropertyChanges { target: cameraIndicator; y: (indicatorCluster.height - cameraIndicator.dotSize) / 2; anchors.horizontalCenterOffset: 0 }
                        },
                        State {
                            name: "shareCamera"
                            when: indicatorCluster.visibleCount === 2 && indicatorCluster.sharingVisible && indicatorCluster.cameraVisible
                            PropertyChanges { target: sharingIndicator; y: (indicatorCluster.height - sharingIndicator.dotSize) / 2 - indicatorCluster.offset; anchors.horizontalCenterOffset: 0 }
                            PropertyChanges { target: cameraIndicator; y: (indicatorCluster.height - cameraIndicator.dotSize) / 2 + indicatorCluster.offset; anchors.horizontalCenterOffset: 0 }
                            PropertyChanges { target: micIndicator; y: (indicatorCluster.height - micIndicator.dotSize) / 2; anchors.horizontalCenterOffset: 0 }
                        },
                        State {
                            name: "micCamera"
                            when: indicatorCluster.visibleCount === 2 && indicatorCluster.micVisible && indicatorCluster.cameraVisible
                            PropertyChanges { target: micIndicator; y: (indicatorCluster.height - micIndicator.dotSize) / 2 - indicatorCluster.offset; anchors.horizontalCenterOffset: 0 }
                            PropertyChanges { target: cameraIndicator; y: (indicatorCluster.height - cameraIndicator.dotSize) / 2 + indicatorCluster.offset; anchors.horizontalCenterOffset: 0 }
                            PropertyChanges { target: sharingIndicator; y: (indicatorCluster.height - sharingIndicator.dotSize) / 2; anchors.horizontalCenterOffset: 0 }
                        },
                        State {
                            name: "singleOrNone"
                            when: indicatorCluster.visibleCount <= 1
                            PropertyChanges { target: sharingIndicator; y: (indicatorCluster.height - sharingIndicator.dotSize) / 2; anchors.horizontalCenterOffset: 0 }
                            PropertyChanges { target: micIndicator; y: (indicatorCluster.height - micIndicator.dotSize) / 2; anchors.horizontalCenterOffset: 0 }
                            PropertyChanges { target: cameraIndicator; y: (indicatorCluster.height - cameraIndicator.dotSize) / 2; anchors.horizontalCenterOffset: 0 }
                        }
                    ]

                    transitions: Transition {
                        NumberAnimation {
                            properties: "y,anchors.horizontalCenterOffset"
                            duration: Appearance.animation.elementMoveFast?.duration ?? 150
                            easing.type: Easing.InOutQuad
                        }
                    }
                }

                RippleButton { // Right sidebar button
                    id: rightSidebarButton

                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    Layout.rightMargin: indicatorCluster.anyVisible ? 0 : Math.max(0, Appearance.rounding.screenRounding - 12)
                    Layout.fillWidth: false

                    implicitWidth: indicatorsRowLayout.implicitWidth + 6 * 2
                    implicitHeight: indicatorsRowLayout.implicitHeight + 2 * 2

                    buttonRadius: Appearance.rounding.full
                    colBackground: barRightSideMouseArea.hovered ? Appearance.colors.colLayer1Hover : ColorUtils.transparentize(Appearance.colors.colLayer1Hover, 1)
                    colBackgroundHover: Appearance.colors.colLayer1Hover
                    colRipple: Appearance.colors.colLayer1Active
                    colBackgroundToggled: Appearance.colors.colSecondaryContainer
                    colBackgroundToggledHover: Appearance.colors.colSecondaryContainerHover
                    colRippleToggled: Appearance.colors.colSecondaryContainerActive
                    toggled: GlobalStates.sidebarRightOpen
                    property color colText: toggled ? Appearance.m3colors.m3onSecondaryContainer : Appearance.colors.colOnLayer0

                    Behavior on colText {
                        animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                    }

                    Behavior on Layout.rightMargin {
                        NumberAnimation {
                            duration: Appearance.animation.elementMoveFast?.duration ?? 150
                            easing.type: Easing.InOutQuad
                        }
                    }

                    onPressed: {
                        GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen;
                    }

                    RowLayout {
                        id: indicatorsRowLayout
                        anchors.centerIn: parent
                        property real realSpacing: 4
                        spacing: 0

                        Revealer {
                            reveal: Audio.sink?.audio?.muted ?? false
                            Layout.alignment: Qt.AlignVCenter
                            Layout.rightMargin: reveal ? indicatorsRowLayout.realSpacing : 0
                            Behavior on Layout.rightMargin {
                                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                            }
                            MaterialSymbol {
                                text: "volume_off"
                                iconSize: Appearance.font.pixelSize.larger
                                color: rightSidebarButton.colText
                            }
                        }
                        Revealer {
                            reveal: Audio.source?.audio?.muted ?? false
                            Layout.alignment: Qt.AlignVCenter
                            Layout.rightMargin: reveal ? indicatorsRowLayout.realSpacing : 0
                            Behavior on Layout.rightMargin {
                                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                            }
                            MaterialSymbol {
                                text: "mic_off"
                                iconSize: Appearance.font.pixelSize.larger
                                color: rightSidebarButton.colText
                            }
                        }
                        HyprlandXkbIndicator {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.rightMargin: indicatorsRowLayout.realSpacing
                            color: rightSidebarButton.colText
                        }
                        Revealer {
                            reveal: Notifications.silent || Notifications.unread > 0
                            Layout.alignment: Qt.AlignVCenter
                            Layout.rightMargin: reveal ? indicatorsRowLayout.realSpacing : 0
                            implicitHeight: reveal ? notificationUnreadCount.implicitHeight : 0
                            implicitWidth: reveal ? notificationUnreadCount.implicitWidth : 0
                            Behavior on Layout.rightMargin {
                                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                            }
                            NotificationUnreadCount {
                                id: notificationUnreadCount
                            }
                        }
                        MaterialSymbol {
                        text: Network.materialSymbol
                        iconSize: Appearance.font.pixelSize.larger
                        color: rightSidebarButton.colText
                    }

                        MaterialSymbol {
                            Layout.leftMargin: indicatorsRowLayout.realSpacing
                            visible: BluetoothStatus.available
                            text: BluetoothStatus.connected ? "bluetooth_connected" : BluetoothStatus.enabled ? "bluetooth" : "bluetooth_disabled"
                            iconSize: Appearance.font.pixelSize.larger
                            color: rightSidebarButton.colText
                        }
                        
                    }
                }

                SysTray {
                    qsWindow: root.qsWindow
                    visible: root.useShortenedForm === 0
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignVCenter
                    invertSide: Config?.options.bar.bottom
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
            }

            // Weather
            Loader {
                Layout.leftMargin: 4
                active: Config.options.bar.weather.enable

                sourceComponent: BarGroup {
                    WeatherBar { qsWindow: root.qsWindow }
                }
            }
        }
    }
}
