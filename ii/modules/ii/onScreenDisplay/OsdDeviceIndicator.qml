import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    required property string icon
    required property string title

    property real indicatorVerticalPadding: 9
    property real indicatorLeftPadding: 10
    property real indicatorRightPadding: 20

    implicitWidth: Math.max(contentRow.implicitWidth + 2 * Appearance.sizes.elevationMargin, Appearance.sizes.osdWidth + 2 * Appearance.sizes.elevationMargin)
    implicitHeight: deviceIndicator.implicitHeight + 2 * Appearance.sizes.elevationMargin

    StyledRectangularShadow {
        target: deviceIndicator
    }

    Rectangle {
        id: deviceIndicator
        anchors.fill: parent
        anchors.margins: Appearance.sizes.elevationMargin
        radius: Appearance.rounding.full
        // Use standard layer color for background
        color: Appearance.colors.colLayer0

        implicitWidth: contentRow.implicitWidth
        implicitHeight: contentRow.implicitHeight

        RowLayout {
            id: contentRow
            anchors.fill: parent
            Layout.margins: 10
            spacing: 10

            Item {
                implicitHeight: 30
                implicitHeight: 30
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: indicatorLeftPadding
                Layout.topMargin: indicatorVerticalPadding
                Layout.bottomMargin: indicatorVerticalPadding

                Rectangle {
                    id: iconBadge
                    anchors.fill: parent
                    radius: width / 2
                    color: Appearance.m3colors.m3primaryContainer
                    opacity: 0.9
                }

                MaterialSymbol {
                    anchors.centerIn: parent
                    text: root.icon
                    color: Appearance.m3colors.m3onPrimaryContainer
                    iconSize: 20
                }
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: indicatorRightPadding
                spacing: 0

                StyledText {
                    color: Appearance.colors.colOnLayer0
                    font.pixelSize: Appearance.font.pixelSize.small
                    text: root.title
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }
    }
}
