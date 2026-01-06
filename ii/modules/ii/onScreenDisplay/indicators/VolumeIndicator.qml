import qs.services
import QtQuick
import qs.modules.ii.onScreenDisplay

OsdValueIndicator {
    id: osdValues
    value: Audio.sink?.audio.volume ?? 0
    icon: Audio.sink?.audio.muted
          ? "volume_off"
          : (value <= 0 ? "volume_mute"
                        : (value < 0.5 ? "volume_down" : "volume_up"))
    name: Translation.tr("Volume")
}
