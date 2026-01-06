import qs.services
import qs.modules.common
import qs.modules.common.widgets

import QtQuick
import QtQuick.Layouts
import qs.modules.ii.bar

StyledPopup {
    id: root

    RowLayout {
        id: columnLayout
        anchors.verticalCenter: parent ? parent.verticalCenter : undefined
        anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
        spacing: 6
        implicitWidth: header.implicitWidth + gridLayout.implicitWidth + 12 + 12 + 6
        implicitHeight: Math.max(header.implicitHeight, gridLayout.implicitHeight)

        ColumnLayout {
            id: header
            spacing: 6

            RowLayout {
                Layout.alignment: Qt.AlignVCenter
                spacing: 8

                MaterialSymbol {
                    id: cityIcon
                    fill: 0
                    font.weight: Font.Medium
                    text: "location_on"
                    iconSize: Appearance.font.pixelSize.large
                    color: Appearance.colors.colOnSurfaceVariant
                    opacity: 0.9
                }

                StyledText {
                    id: cityName
                    text: Weather.data ? Weather.data.city : ""
                    font {
                        weight: Font.Medium
                        pixelSize: Appearance.font.pixelSize.large
                    }
                    color: Appearance.colors.colOnSurfaceVariant
                }
            }
            StyledText {
                id: temp
                text: Weather.data ? Weather.data.temp : ""
                font.pixelSize: 48
                font.bold: true
                color: Appearance.colors.colOnSurfaceVariant
            }

            StyledText {
                id: feelsLike
                text: (Weather.data && Weather.data.tempFeelsLike != null)
                      ? Translation.tr("Feels like %1").arg(Weather.data.tempFeelsLike)
                      : (Weather.data ? Weather.data.feelsLike : "")
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.colors.colOnSurfaceVariant
                opacity: 0.75
                font.italic: true
                visible: (text !== "")
            }
            
            StyledText {
                id: condition
                text: Weather.data ? Weather.data.condition : ""
                font.pixelSize: Appearance.font.pixelSize.smallest
                color: Appearance.colors.colOnSurfaceVariant
                opacity: 0.75
                font.italic: true
                visible: (text !== "")
            }
        }

        Item { width: 6 }

        VerticalSeparator {
            Layout.alignment: Qt.AlignVCenter
            implicitHeight: Math.max(header.implicitHeight, gridLayout.implicitHeight)
            width: 1
            asLine: true
        }

        Item { width: 6 }

        GridLayout {
            id: gridLayout
            Layout.alignment: Qt.AlignVCenter
            columns: 2
            rowSpacing: 8
            columnSpacing: 8
            uniformCellWidths: false

            WeatherCard {
                title: Translation.tr("UV Index")
                symbol: "wb_sunny"
                value: (Weather.data && Weather.data.uv != null) ? Weather.data.uv : "0"
            }

            WeatherCard {
                title: Translation.tr("Wind")
                symbol: "air"
                value: (Weather.data && Weather.data.windDir != null) ? ("(" + Weather.data.windDir + ") " + Weather.data.wind) : ""
            }

            WeatherCard {
                title: Translation.tr("Rainfall")
                symbol: "rainy_light"
                value: Weather.data ? Weather.data.precip : ""
            }

            WeatherCard {
                title: Translation.tr("Humidity")
                symbol: "humidity_low"
                value: Weather.data ? Weather.data.humidity : ""
            }
        }
    }
}
