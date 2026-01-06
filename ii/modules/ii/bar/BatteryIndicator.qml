pragma ComponentBehavior: Bound

import qs.modules.common
import qs.modules.common.widgets
import qs.services
import Quickshell
import QtQuick
import QtQuick.Layouts

/* Card-style Battery Indicator similar to WeatherCard
   - Rectangle card for consistent look
   - icon + percentage in a row
   - bolt pulses while charging
   - MouseArea for hover/click and BatteryPopup integration
*/

Rectangle {
    id: root
    radius: Appearance.rounding.small
    color: Appearance.colors.colSurfaceContainerHigh
    property var qsWindow: null
    readonly property bool isCharging: Battery.isCharging
    readonly property bool isPluggedIn: Battery.isPluggedIn
    readonly property real percentage: Battery.percentage
    readonly property bool isLow: percentage <= Config.options.battery.low / 100

    implicitWidth: rowLayout.implicitWidth + 12 * 2
    implicitHeight: rowLayout.implicitHeight + 8 * 2
    Layout.fillWidth: parent

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 8

        MaterialSymbol {
            id: batterySymbol
            fill: 0
            text: (isCharging && percentage < 1) ? "bolt" : "battery_full"
            iconSize: Appearance.font.pixelSize.normal
            color: (isLow && !isCharging) ? Appearance.m3colors.m3error : Appearance.colors.colOnSurfaceVariant
            Layout.alignment: Qt.AlignVCenter

            scale: 1.0
            NumberAnimation { property: "scale"; from: 1.0; to: 1.08; duration: 700; loops: Animation.Infinite; easing.type: Easing.InOutQuad; running: isCharging && percentage < 1 }
        }

        StyledText {
            id: percentText
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: Appearance.font.pixelSize.small
            color: (isLow && !isCharging) ? Appearance.m3colors.m3error : Appearance.colors.colOnSurfaceVariant
            text: Math.round(percentage * 100) + "%"
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: !Config.options.bar.tooltips.clickToShow
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: {
            if (mouse.button === Qt.RightButton) {
                Battery.refresh && Battery.refresh()
                Quickshell.execDetached(["notify-send", Translation.tr("Battery"), Translation.tr("Refreshing (manually triggered)"), "-a", "Shell"])
                mouse.accepted = false
            }
        }
    }

    BatteryPopup {
        id: batteryPopup
        hoverTarget: mouseArea
        qsWindow: root.qsWindow
    }
}
