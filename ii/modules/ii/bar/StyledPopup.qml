import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland

LazyLoader {
    id: root

    property Item hoverTarget
    default property Item contentItem
    property real popupBackgroundMargin: 0
    // The bar window that owns the hover target; used for coordinate mapping
    property var qsWindow: null

    active: hoverTarget && hoverTarget.containsMouse

    component: PanelWindow {
        id: popupWindow
        color: "transparent"

        // Top bar: anchor to top/left; vertical bars fall back to left/right
        anchors.left: true
        anchors.right: Config.options.bar.vertical
        anchors.top: !Config.options.bar.bottom
        anchors.bottom: Config.options.bar.bottom

        implicitWidth: popupBackground.implicitWidth + Appearance.sizes.elevationMargin * 2 + root.popupBackgroundMargin
        implicitHeight: popupBackground.implicitHeight + Appearance.sizes.elevationMargin * 2 + root.popupBackgroundMargin

        mask: Region {
            item: popupBackground
        }

        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: 0
        function mapTargetItem() {
            if (root.qsWindow) {
                return (root.qsWindow.contentItem !== undefined && root.qsWindow.contentItem !== null)
                       ? root.qsWindow.contentItem
                       : root.qsWindow;
            }
            // Fallback: if no qsWindow provided, map relative to the hoverTarget's parent
            if (root.hoverTarget) {
                return root.hoverTarget.parent ? root.hoverTarget.parent : root.hoverTarget;
            }
            return null;
        }

        function safeMapX(offsetX) {
            if (!root.hoverTarget) return null;
            const target = mapTargetItem();
            if (!target || !root.hoverTarget.mapToItem) return null;
            return root.hoverTarget.mapToItem(target, offsetX, 0).x;
        }

        function safeMapY(offsetY) {
            if (!root.hoverTarget) return null;
            const target = mapTargetItem();
            if (!target || !root.hoverTarget.mapToItem) return null;
            return root.hoverTarget.mapToItem(target, 0, offsetY).y;
        }

        readonly property real horizLeftMargin: {
            var hoverWidth = (root.hoverTarget && root.hoverTarget.width) ? root.hoverTarget.width : 0;
            const mapped = safeMapX((hoverWidth - popupBackground.implicitWidth) / 2);
            if (mapped !== null && mapped !== undefined) return mapped;
            var winW = 0;
            if (root.qsWindow) {
                if (root.qsWindow.width !== undefined && root.qsWindow.width !== null) winW = root.qsWindow.width;
                else if (root.qsWindow.window && root.qsWindow.window.width !== undefined && root.qsWindow.window.width !== null) winW = root.qsWindow.window.width;
            }
            return Math.max(0, (winW - popupBackground.implicitWidth) / 2);
        }

        margins {
            left: horizLeftMargin
            right: 0
            top: Appearance.sizes.barHeight
            bottom: 0
        }
        WlrLayershell.namespace: "quickshell:popup"
        WlrLayershell.layer: WlrLayer.Overlay

        StyledRectangularShadow {
            target: popupBackground
        }

        Rectangle {
            id: popupBackground
            readonly property real margin: 10
            anchors {
                fill: parent
                leftMargin: Appearance.sizes.elevationMargin + root.popupBackgroundMargin * (!popupWindow.anchors.left)
                rightMargin: Appearance.sizes.elevationMargin + root.popupBackgroundMargin * (!popupWindow.anchors.right)
                topMargin: Appearance.sizes.elevationMargin + root.popupBackgroundMargin * (!popupWindow.anchors.top)
                bottomMargin: Appearance.sizes.elevationMargin + root.popupBackgroundMargin * (!popupWindow.anchors.bottom)
            }
            implicitWidth: root.contentItem.implicitWidth + margin * 2
            implicitHeight: root.contentItem.implicitHeight + margin * 2
            color: Appearance.m3colors.m3surfaceContainer
            radius: Appearance.rounding.small
            children: [root.contentItem]

            border.width: 1
            border.color: Appearance.colors.colLayer0Border
        }
    }
}
