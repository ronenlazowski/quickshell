import QtQuick

QtObject {
    // Accept missing fields gracefully. parsers may supply partial objects.
    property var lastIpcObject: ({ ssid: "", bssid: "", strength: 0, frequency: 0, active: false, security: "" })
    readonly property string ssid: (lastIpcObject && lastIpcObject.ssid) ? lastIpcObject.ssid : ""
    readonly property string bssid: (lastIpcObject && lastIpcObject.bssid) ? lastIpcObject.bssid : ""
    readonly property int strength: (lastIpcObject && typeof lastIpcObject.strength === "number") ? lastIpcObject.strength : 0
    readonly property int frequency: (lastIpcObject && typeof lastIpcObject.frequency === "number") ? lastIpcObject.frequency : 0
    readonly property bool active: (lastIpcObject && !!lastIpcObject.active) ? true : false
    readonly property string security: (lastIpcObject && lastIpcObject.security) ? lastIpcObject.security : ""
    readonly property bool isSecure: (security && security.length > 0) ? true : false
    // Detailed parsed capability flags from `iw` scan (object map of flags -> true)
    readonly property var securityInfo: (lastIpcObject && lastIpcObject.securityInfo) ? lastIpcObject.securityInfo : null

    property bool askingPassword: false
}
