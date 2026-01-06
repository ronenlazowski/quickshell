import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property bool borderless: Config.options.bar.borderless
    property bool showDate: Config.options.bar.verbose
    // Provided by BarContent so popups can map correctly
    property var qsWindow: null
    implicitWidth: rowLayout.implicitWidth
    implicitHeight: Appearance.sizes.barHeight
    property int now: Date.now()

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 4

        StyledText {
            visible: root.showDate
            font.pixelSize: Appearance.font.pixelSize.normal
            color: Appearance.colors.colOnLayer1
            text: Qt.locale().toString(DateTime.clock.date, "h:mm ap")
        }

        StyledText {
            visible: root.showDate
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnLayer1
            text: "·"
        }

        StyledText {
            visible: root.showDate
            font.pixelSize: Appearance.font.pixelSize.normal
            color: Appearance.colors.colOnLayer1
            text: Qt.locale().toString(DateTime.clock.date, "ddd, MM/dd")
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: !Config.options.bar.tooltips.clickToShow

        ClockWidgetPopup {
            hoverTarget: mouseArea
            qsWindow: root.qsWindow
        }
    }
}
