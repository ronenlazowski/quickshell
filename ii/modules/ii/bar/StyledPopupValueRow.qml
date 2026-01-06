import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

RowLayout {
    id: root
    required property string icon
    required property string label
    required property string value
    spacing: 8
    
    Rectangle {
        Layout.preferredWidth: 32
        Layout.preferredHeight: 32
        radius: 8
        color: Qt.rgba(
            Appearance.colors.colOnSurfaceVariant.r,
            Appearance.colors.colOnSurfaceVariant.g,
            Appearance.colors.colOnSurfaceVariant.b,
            0.1
        )
        
        MaterialSymbol {
            anchors.centerIn: parent
            text: root.icon
            color: Appearance.colors.colOnSurfaceVariant
            iconSize: 18
            fill: 1
        }
    }
    
    RowLayout {
        Layout.fillWidth: true
        spacing: 6
        
        StyledText {
            text: root.label
            color: Appearance.colors.colOnSurfaceVariant
            font.pixelSize: Appearance.font.pixelSize.normal
        }
        
        StyledText {
            color: Appearance.colors.colOnSurface
            text: root.value
            font.pixelSize: Appearance.font.pixelSize.normal
            font.weight: Font.Medium
        }
    }
}