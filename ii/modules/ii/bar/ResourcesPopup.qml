import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls 2.15

StyledPopup {
    id: root

    // Helper function to format KB to GB
    function formatKB(kb) {
        return (kb / (1024 * 1024)).toFixed(1) + " GB";
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 12

        ColumnLayout {
            id: ramColumn
            spacing: 8
            Layout.alignment: Qt.AlignVCenter

            StyledPopupHeaderRow {
                icon: "memory"
                label: "RAM"
            }

            ColumnLayout {
                spacing: 0

                StyledText {
                    text: root.formatKB(ResourceUsage.memoryUsed)
                    color: Appearance.colors.colOnSurfaceVariant
                    opacity: 0.95
                    font.pixelSize: Math.round(Appearance.font.pixelSize.large * 1.25)
                    font.bold: true
                }

                StyledText {
                    text: " / " + root.formatKB(ResourceUsage.memoryTotal)
                    color: Appearance.colors.colOnSurfaceVariant
                    opacity: 0.9
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.italic: true
                }
            }
            RowLayout {
                spacing: 8

                Rectangle {
                    id: ramBarBg
                    width: 80
                    height: 10
                    radius: 6
                    color: Appearance.colors.colOnSurfaceVariant
                    opacity: 0.12  
                    
                    Rectangle {
                        id: ramBarFill
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: parent.width * ((ResourceUsage.memoryTotal > 0) ? (ResourceUsage.memoryUsed / ResourceUsage.memoryTotal) : 0)
                        radius: 6
                        color: Appearance.colors.colPrimary
                    }
                }
                StyledText {
                    text: Math.round((ResourceUsage.memoryTotal > 0) ? ((ResourceUsage.memoryUsed / ResourceUsage.memoryTotal) * 100) : 0) + "%"
                    color: Appearance.colors.colOnSurfaceVariant
                    opacity: 0.8
                    font.pixelSize: Appearance.font.pixelSize.small
                }
            }
        }

        VerticalSeparator {
            asLine: true
            implicitHeight: Math.max(ramColumn.implicitHeight, swapColumn ? swapColumn.implicitHeight : cpuColumn.implicitHeight)
            width: 1
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            id: swapColumn
            visible: ResourceUsage.swapTotal > 0
            spacing: 8
            Layout.alignment: Qt.AlignVCenter

            StyledPopupHeaderRow {
                icon: "swap_horiz"
                label: "Swap"
            }
                ColumnLayout {
                    spacing: 0
                    visible: ResourceUsage.swapTotal > 0

                    StyledText {
                        text: root.formatKB(ResourceUsage.swapUsed)
                        color: Appearance.colors.colOnSurfaceVariant
                        opacity: 0.95
                        font.pixelSize: Math.round(Appearance.font.pixelSize.large * 1.25)
                        font.bold: true
                    }

                    StyledText {
                        text: " / " + root.formatKB(ResourceUsage.swapTotal)
                        color: Appearance.colors.colOnSurfaceVariant
                        opacity: 0.9
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        font.italic: true
                    }
                }

                StyledText {
                    visible: !(ResourceUsage.swapTotal > 0)
                    text: Translation.tr("No swap")
                    color: Appearance.colors.colOnSurfaceVariant
                    opacity: 0.9
                    font.pixelSize: Appearance.font.pixelSize.normal
                }
            RowLayout {
                spacing: 8
                Rectangle {
                    id: swapBarBg
                    width: 80
                    height: 10
                    radius: 6
                    color: Appearance.colors.colOnSurfaceVariant
                    opacity: 0.12

                    Rectangle {
                        id: swapBarFill
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: parent.width * ((ResourceUsage.swapTotal > 0) ? (ResourceUsage.swapUsed / ResourceUsage.swapTotal) : 0)
                        radius: 6
                        color: Appearance.colors.colPrimary
                        opacity: 0.95
                    }
                }
                StyledText {
                    text: ResourceUsage.swapTotal > 0 ? (Math.round((ResourceUsage.swapUsed / ResourceUsage.swapTotal) * 100) + "%") : Translation.tr("—")
                    color: Appearance.colors.colOnSurfaceVariant
                    opacity: 0.85
                    font.pixelSize: Appearance.font.pixelSize.small
                }
            }
        }

        VerticalSeparator {
            asLine: true
            implicitHeight: Math.max(swapColumn.visible ? swapColumn.implicitHeight : 0, cpuColumn.implicitHeight)
            width: 1
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            id: cpuColumn
            spacing: 8
            Layout.alignment: Qt.AlignVCenter

            StyledPopupHeaderRow {
                icon: "planner_review"
                label: "CPU"
            }
            ColumnLayout {
                spacing: 4
                StyledPopupValueRow {
                    icon: "bolt"
                    label: Translation.tr("Load:")
                    value: Math.round(ResourceUsage.cpuUsage * 100) + "%"
                }
                StyledPopupValueRow {
                    icon: "device_thermostat"
                    label: Translation.tr("Temp:")
                    value: Math.round(ResourceUsage.cpuTempC) + "°C"
                }
            }
        }
    }
}
