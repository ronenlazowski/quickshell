import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

StyledPopup {
    id: root
    property string formattedDate: Qt.locale().toString(DateTime.clock.date, "dddd, MMMM dd")
    property string formattedTime: DateTime.time
    // property string formattedTime: Qt.locale().toString(DateTime.clock.date, "h:mm ")
    // 24-hour format: "HH:mm", 12-hour format: "h:mm", with AM/PM: "h:mm ap"
    property string formattedUptime: DateTime.uptime
    property string todosSection: getUpcomingTodos()

    function getUpcomingTodos() {
        const unfinishedTodos = Todo.list.filter(function (item) { return !item.done; });
        if (unfinishedTodos.length === 0) {
            return Translation.tr("All Tasks Done");
        }

        const limited = unfinishedTodos.slice(0, 5);
        let out = limited.map(function (it, i) { return `  ${i+1}. ${it.content}`; }).join('\n');
        if (unfinishedTodos.length > 5) {
            out += `\n  ${Translation.tr("... and %1 more").arg(unfinishedTodos.length - 5)}`;
        }
        return out;
    }

    RowLayout {
        id: mainRow
        anchors.centerIn: parent
        spacing: 18

        ColumnLayout {
            id: leftColumn
            spacing: 1

            Text {
                text: root.formattedTime
                font.pixelSize: 38
                font.bold: true
                color: Appearance.colors.colOnSurfaceVariant
                horizontalAlignment: Text.AlignLeft
                elide: Text.ElideRight
            }

            Text {
                text: root.formattedDate
                opacity: 0.6
                font.pixelSize: 16
                color: Appearance.colors.colOnSurfaceVariant
                horizontalAlignment: Text.AlignLeft
            }
        }
    
        VerticalSeparator {
            id: centeredSeparator
            asLine: true
            implicitHeight: Math.max(leftColumn.implicitHeight, rightColumn.implicitHeight)
            Layout.alignment: Qt.AlignVCenter
            width: 1
        }

        ColumnLayout {
            id: rightColumn
            spacing: 8

            StyledPopupValueRow {
                icon: "timelapse"
                label: Translation.tr("Uptime:")
                value: root.formattedUptime
            }

            // Tasks area
            ColumnLayout {
                spacing: 4
                Layout.fillWidth: true

                StyledPopupValueRow {
                    icon: "checklist"
                    label: Translation.tr("Tasks:")
                    value: root.todosSection
                    spacing: 8
                }
            }
        }
    }
}