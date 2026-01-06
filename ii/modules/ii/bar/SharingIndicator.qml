import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Revealer {
	id: root

	// Color of the icon; inherited from parent button text color
	property color color: Appearance.colors.colOnLayer0
	// Spacing applied when the indicator is visible
	property real spacing: 0
	// Dot styling
	property color dotColor: "#7163FF"
	property color dotBorderColor: Appearance.colors.colLayer0Border
	property real dotSize: 10

	// Show the indicator when PipeWire reports screen capture (covers sharing/recording/streaming)
	reveal: !!Privacy.screenSharing
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