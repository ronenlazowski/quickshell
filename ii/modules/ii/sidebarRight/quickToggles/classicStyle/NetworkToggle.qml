import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.modules.ii.sidebarRight.quickToggles
import qs
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

QuickToggleButton {
    toggled: Network.wifiStatus !== "disabled"
    buttonIcon: Network.materialSymbol
    onClicked: Network.toggleWifi()
    altAction: () => {
        Quickshell.execDetached(["iwgtk"])
        GlobalStates.sidebarRightOpen = false
    }
    StyledToolTip {
        text: Network.wifiStatus === "connected" ? Translation.tr("Connected to %1 | Right-click to configure").arg(Network.networkName) : Translation.tr("%1 | Right-click to configure").arg(Network.networkName)
    }
}
