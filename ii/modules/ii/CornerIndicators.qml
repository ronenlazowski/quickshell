import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs
import qs.services
import qs.modules.common
import qs.modules.ii.bar

Scope {
    id: root

    readonly property bool anyActive: Privacy.screenSharing || Privacy.micActive

    PanelWindow {
        id: indicatorWindow
        visible: false // overlay disabled; indicators now live in the bar
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell:cornerIndicators"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        exclusiveZone: 0

        anchors {
            top: true
            right: true
        }

        implicitWidth: contentRow.implicitWidth
        implicitHeight: contentRow.implicitHeight

        RowLayout {
            id: contentRow
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: Appearance.sizes.hyprlandGapsOut
            anchors.rightMargin: Appearance.sizes.hyprlandGapsOut
            spacing: 2

            SharingIndicator {
                spacing: 2
                color: Appearance.colors.colOnLayer0
                dotSize: 12
            }

            MicrophoneIndicator {
                spacing: 2
                color: Appearance.colors.colOnLayer0
                dotSize: 12
            }
        }
    }
}
