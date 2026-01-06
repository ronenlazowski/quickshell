pragma ComponentBehavior: Bound

import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    readonly property var keybinds: HyprlandKeybinds.keybinds
    property string filterText: ""
    property real spacing: 20
    property real titleSpacing: 7
    property real padding: 4
    implicitWidth: Math.max(row.implicitWidth, emptyState.implicitWidth) + padding * 2
    implicitHeight: Math.max(row.implicitHeight, emptyState.implicitHeight) + padding * 2
    property int matchCount: 0

    function recomputeMatchCount() {
        const needle = (root.filterText || "").toLowerCase().trim();
        let total = 0;
        const columns = keybinds && keybinds.children ? keybinds.children : [];
        for (let c = 0; c < columns.length; c++) {
            const sections = columns[c] && columns[c].children ? columns[c].children : [];
            for (let s = 0; s < sections.length; s++) {
                const binds = sections[s] && sections[s].keybinds ? sections[s].keybinds : [];
                for (let b = 0; b < binds.length; b++) {
                    const kb = binds[b];
                    const haystack = `${(kb.mods || []).join(' ')} ${kb.key || ''} ${kb.comment || ''}`.toLowerCase();
                    if (!needle || haystack.includes(needle)) {
                        total += 1;
                    }
                }
            }
        }
        root.matchCount = total;
    }

    onFilterTextChanged: recomputeMatchCount()
    onKeybindsChanged: recomputeMatchCount()
    Component.onCompleted: recomputeMatchCount()
    // Excellent symbol explaination and source :
    // http://xahlee.info/comp/unicode_computing_symbols.html
    // https://www.nerdfonts.com/cheat-sheet
    property var macSymbolMap: ({
        "Ctrl": "󰘴",
        "Alt": "󰘵",
        "Shift": "󰘶",
        "Space": "󱁐",
        "Tab": "↹",
        "Equal": "󰇼",
        "Minus": "",
        "Print": "",
        "BackSpace": "󰭜",
        "Delete": "⌦",
        "Return": "󰌑",
        "Period": ".",
        "Escape": "⎋"
      })
    property var functionSymbolMap: ({
        "F1":  "󱊫",
        "F2":  "󱊬",
        "F3":  "󱊭",
        "F4":  "󱊮",
        "F5":  "󱊯",
        "F6":  "󱊰",
        "F7":  "󱊱",
        "F8":  "󱊲",
        "F9":  "󱊳",
        "F10": "󱊴",
        "F11": "󱊵",
        "F12": "󱊶",
    })

    property var mouseSymbolMap: ({
        "mouse_up": "󱕐",
        "mouse_down": "󱕑",
        "mouse:272": "L󰍽",
        "mouse:273": "R󰍽",
        "Scroll ↑/↓": "󱕒",
        "Page_↑/↓": "⇞/⇟",
    })

    property var keyBlacklist: ["Super_L"]
    property var keySubstitutions: Object.assign({
        "Super": "",
        "mouse_up": "Scroll ↓",    // ikr, weird
        "mouse_down": "Scroll ↑",  // trust me bro
        "mouse:272": "LMB",
        "mouse:273": "RMB",
        "mouse:275": "MouseBack",
        "Slash": "/",
        "Hash": "#",
        "Return": "Enter",
        // "Shift": "",
      },
      !!Config.options.cheatsheet.superKey ? {
          "Super": Config.options.cheatsheet.superKey,
      }: {},
      Config.options.cheatsheet.useMacSymbol ? macSymbolMap : {},
      Config.options.cheatsheet.useFnSymbol ? functionSymbolMap : {},
      Config.options.cheatsheet.useMouseSymbol ? mouseSymbolMap : {},
    )

    Row { // Keybind columns
        id: row
        spacing: root.spacing
        
        Repeater {
            model: (keybinds && keybinds.children) ? keybinds.children : []
            
            delegate: Column { // Keybind sections
                spacing: root.spacing
                required property var modelData
                anchors.top: row.top

                Repeater {
                    model: modelData.children ? modelData.children : []

                    delegate: Item { // Section with real keybinds
                        id: keybindSection
                        required property var modelData
                        implicitWidth: sectionColumn.implicitWidth
                        implicitHeight: sectionColumn.implicitHeight

                        Column {
                            id: sectionColumn
                            anchors.centerIn: parent
                            spacing: root.titleSpacing
                            
                            StyledText {
                                id: sectionTitle
                                font {
                                    family: Appearance.font.family.title
                                    pixelSize: Appearance.font.pixelSize.title
                                    variableAxes: Appearance.font.variableAxes.title
                                }
                                color: Appearance.colors.colOnLayer0
                                text: keybindSection.modelData.name
                            }

                            GridLayout {
                                id: keybindGrid
                                columns: 2
                                columnSpacing: 4
                                rowSpacing: 4

                                Repeater {
                                    model: {
                                        var result = [];
                                        const needle = (root.filterText || "").toLowerCase().trim();
                                        if (!keybindSection.modelData.keybinds) return result;
                                        for (var i = 0; i < keybindSection.modelData.keybinds.length; i++) {
                                            const keybind = keybindSection.modelData.keybinds[i];
                                            const modsCopy = keybind.mods ? [...keybind.mods] : [];
                                            const displayKey = keySubstitutions[keybind.key] || keybind.key;
                                            const haystack = `${modsCopy.join(' ')} ${keybind.key} ${keybind.comment}`.toLowerCase();

                                            if (needle.length && !haystack.includes(needle)) {
                                                continue;
                                            }

                                            let displayMods = modsCopy.map(m => keySubstitutions[m] || m);
                                            const showKey = !keyBlacklist.includes(keybind.key);

                                            if (!Config.options.cheatsheet.splitButtons) {
                                                const joined = displayMods.join(' ');
                                                displayMods = [joined + (showKey && joined.length ? ' ' : '') + (showKey ? displayKey : '')];
                                            }

                                            result.push({
                                                "type": "keys",
                                                "mods": displayMods,
                                                "key": keybind.key,
                                            });
                                            result.push({
                                                "type": "comment",
                                                "comment": keybind.comment,
                                            });
                                        }
                                        return result;
                                    }
                                    delegate: Item {
                                        required property var modelData
                                        implicitWidth: keybindLoader.implicitWidth
                                        implicitHeight: keybindLoader.implicitHeight

                                        Loader {
                                            id: keybindLoader
                                            sourceComponent: (modelData.type === "keys") ? keysComponent : commentComponent
                                        }

                                        Component {
                                            id: keysComponent
                                            Row {
                                                spacing: 4
                                                Repeater {
                                                    model: modelData.mods
                                                    delegate: KeyboardKey {
                                                        required property var modelData
                                                        key: keySubstitutions[modelData] || modelData
                                                        pixelSize: Config.options.cheatsheet.fontSize.key
                                                    }
                                                }
                                                StyledText {
                                                    id: keybindPlus
                                                    visible: Config.options.cheatsheet.splitButtons && !keyBlacklist.includes(modelData.key) && modelData.mods.length > 0
                                                    text: "+"
                                                }
                                                KeyboardKey {
                                                    id: keybindKey
                                                    visible: Config.options.cheatsheet.splitButtons && !keyBlacklist.includes(modelData.key)
                                                    key: keySubstitutions[modelData.key] || modelData.key
                                                    pixelSize: Config.options.cheatsheet.fontSize.key
                                                    color: Appearance.colors.colOnLayer0
                                                }
                                            }
                                        }

                                        Component {
                                            id: commentComponent
                                            Item {
                                                id: commentItem
                                                implicitWidth: commentText.implicitWidth + 8 * 2
                                                implicitHeight: commentText.implicitHeight

                                                StyledText {
                                                    id: commentText
                                                    anchors.centerIn: parent
                                                    font.pixelSize: Config.options.cheatsheet.fontSize.comment || Appearance.font.pixelSize.smaller
                                                    text: modelData.comment
                                                }
                                            }
                                        }
                                    }

                                }
                            }
                        }
                    }

                }
            }
            
        }
    }

    StyledText {
        id: emptyState
        anchors.centerIn: parent
        visible: root.matchCount === 0
        text: Translation.tr("No keybinds match your filter")
        color: Appearance.colors.colOnLayer0
        font.pixelSize: Appearance.font.pixelSize.body
    }
    
}
