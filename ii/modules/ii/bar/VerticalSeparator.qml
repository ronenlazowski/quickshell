import QtQuick
import qs.modules.common

Item {
    id: root
    property bool asLine: true
    property color lineColor: Appearance.colors.colOnSurfaceVariant

    width: asLine ? 2 : 16

    Rectangle {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.width
        color: root.lineColor
        radius: 1
        opacity: 0.3
    }
}
