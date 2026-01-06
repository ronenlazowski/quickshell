import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Revealer {
	id: root

	property color color: Appearance.colors.colOnLayer0
	property real spacing: 0
	property color dotColor: "#11FA00"
	property color dotBorderColor: Appearance.colors.colLayer0Border
	property real dotSize: 10

	// Show when a camera capture link is active (Privacy.cameraActive)
	reveal: !!Privacy.cameraActive
	Layout.fillHeight: true
	Layout.rightMargin: spacing
	implicitHeight: dotSize
	implicitWidth: dotSize
	visible: reveal || opacity > 0
	opacity: reveal ? 1 : 0

	Behavior on opacity {
		NumberAnimation {
			duration: Appearance.animation.elementMoveFast?.duration ?? 150
			easing.type: Easing.InOutQuad
		}
	}


	Rectangle {
		id: dot
		anchors.verticalCenter: parent.verticalCenter
		implicitHeight: dotSize
		implicitWidth: dotSize
		radius: dotSize / 2
		color: dotColor
		border.color: dotBorderColor
		border.width: 1
	}
}
