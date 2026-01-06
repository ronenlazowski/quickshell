pragma ComponentBehavior: Bound

import qs.modules.common
import qs.modules.common.widgets
import qs.services
import Quickshell
import QtQuick
import QtQuick.Layouts

MouseArea {
    id: root
    property bool hovered: false
    // Provided by BarContent so popups map to the correct window
    property var qsWindow: null

    implicitWidth: rowLayout.implicitWidth + 10 * 2
    implicitHeight: Appearance.sizes.barHeight

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    hoverEnabled: !Config.options.bar.tooltips.clickToShow

    onPressed: {
        if (mouse.button === Qt.RightButton) {
            Battery.refresh && Battery.refresh();
            Quickshell.execDetached(["notify-send",
                Translation.tr("Battery"),
                Translation.tr("Refreshing (manually triggered)"),
                "-a", "Shell"
            ])
            mouse.accepted = false
        }
    }

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent

        MaterialSymbol {
            fill: 0
            text: (Battery.isCharging && Battery.percentage < 1) ? "bolt" : "battery_full"
            iconSize: Appearance.font.pixelSize.large
            color: (Battery.percentage <= Config.options.battery.low / 100 && !Battery.isCharging) ? Appearance.m3colors.m3error : Appearance.colors.colOnLayer1
            Layout.alignment: Qt.AlignVCenter

            // pulse while charging
            scale: 1.0
            NumberAnimation { property: "scale"; from: 1.0; to: 1.08; duration: 700; loops: Animation.Infinite; easing.type: Easing.InOutQuad; running: Battery.isCharging && Battery.percentage < 1 }
        }

        StyledText {
            visible: true
            font.pixelSize: Appearance.font.pixelSize.small
            color: (Battery.percentage <= Config.options.battery.low / 100 && !Battery.isCharging) ? Appearance.m3colors.m3error : Appearance.colors.colOnLayer1
            text: Math.round(Battery.percentage * 100) + "%"
            Layout.alignment: Qt.AlignVCenter
        }
    }

    BatteryPopup {
        id: batteryPopup
        hoverTarget: root
        qsWindow: root.qsWindow
    }
}
