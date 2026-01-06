import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts
import qs.modules.ii.bar

StyledPopup {
    id: root

    RowLayout {
        id: mainRow
        spacing: 6
        anchors.verticalCenter: parent ? parent.verticalCenter : undefined
        anchors.fill: parent ? parent.fill : undefined

        MaterialSymbol {
            id: batteryIcon
            iconSize: 48
            fill: 1
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            text: {
                if (Battery.isCharging) {
                    var p = Battery.percentage;
                    if (p <= 0.05)
                        return "battery_charging_full";
                    if (p <= 0.20)
                        return "battery_charging_20";
                    if (p <= 0.30)
                        return "battery_charging_30";
                    if (p <= 0.50)
                        return "battery_charging_50";
                    if (p <= 0.60)
                        return "battery_charging_60";
                    if (p <= 0.80)
                        return "battery_charging_80";
                    if (p <= 0.99)
                        return "battery_charging_90";
                    return "battery_full";
                }
                if (Battery.isCriticalAndNotCharging)
                    return "battery_alert";
                var p = Battery.percentage;
                if (p <= 0.05)
                    return "battery_0_bar";
                if (p <= 0.20)
                    return "battery_1_bar";
                if (p <= 0.30)
                    return "battery_2_bar";
                if (p <= 0.50)
                    return "battery_3_bar";
                if (p <= 0.60)
                    return "battery_4_bar";
                if (p <= 0.80)
                    return "battery_5_bar";
                if (p <= 0.99)
                    return "battery_6_bar";
                return "battery_full";
            }
        }
            
        ColumnLayout {
            id: leftColumn
            spacing: 0
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter


            StyledText {
                id: percentageText
                Layout.alignment: Qt.AlignLeft
                text: Math.round(Battery.percentage * 100) + "%"
                font.pixelSize: 28
                font.bold: true
                color: Appearance.colors.colOnSurfaceVariant
            }

            StyledText {
                id: stateText
                Layout.alignment: Qt.AlignLeft
                text: (Battery.chargeState == 4) ? Translation.tr("Fully charged") : (Battery.isCharging ? Translation.tr("Charging") : Translation.tr("Discharging"))
                font.pixelSize: 16
                color: Appearance.colors.colOnSurfaceVariant
                opacity: 0.6
            }
        }

        Item { width: 8 }

        VerticalSeparator {
            asLine: true
            implicitHeight: Math.max(leftColumn.implicitHeight, mainColumn.implicitHeight)
            width: 1
            Layout.alignment: Qt.AlignVCenter
        }

        Item { width: 8 }

        ColumnLayout {
            id: mainColumn
            spacing: 4
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            Layout.rightMargin: -8
            Layout.fillWidth: true

            StyledPopupValueRow {
                Layout.fillWidth: true
                Layout.minimumHeight: 24
                icon: "schedule"
                label: Battery.isCharging ? Translation.tr("Time to full:") : Translation.tr("Time to empty:")
                value: {
                    function formatTime(seconds) {
                        var h = Math.floor(seconds / 3600);
                        var m = Math.floor((seconds % 3600) / 60);
                        if (h > 0) return h + "h, " + m + "m";
                        else return m + "m";
                    }
                    return Battery.isCharging ? formatTime(Battery.timeToFull) : formatTime(Battery.timeToEmpty);
                }
            }

            StyledPopupValueRow {
                Layout.fillWidth: true
                Layout.minimumHeight: 24
                icon: "bolt"
                label: Battery.chargeState == 1 ? Translation.tr("Charging:") : Translation.tr("Discharging:")
                value: Battery.energyRate.toFixed(2) + "W"
            }
        }
    }
}
