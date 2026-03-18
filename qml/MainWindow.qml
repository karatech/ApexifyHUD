

import QtQuick.Controls.Material 2.15
import Qt.labs.settings 1.0

import QtQuick 6.9
import QtQuick.Controls 6.9 as Controls

import QtQuick.Layouts
import QtQuick.Dialogs

ApplicationWindow {
    id: mainWindow
    width: 640; height: 800
    visible: true
    title: "ApexifyHUD"
    Material.theme: Material.Dark; Material.accent: Material.DeepOrange; Material.primary: Material.Grey

    Column {
        anchors.fill: parent; anchors.margins: 16; spacing: 12
        Controls.CheckBox { id: telemetryGraphCheck
            text: "Telemetry Graph"
            opacity: 1
            enabled: true
            padding: 0
            onCheckedChanged: {
                if (telemetryWin.visible !== checked) {
                    telemetryWin.visible = checked
                }
            }
            indicator: Rectangle {
                opacity: telemetryGraphCheck.enabled ? 1.0 : 0.38
                x: 0
                y: (parent.height - height) / 2 + 1
                implicitWidth: 13; implicitHeight: 13
                radius: 2; border.width: 1
                border.color: telemetryGraphCheck.checked ? "#7F3B2E" : "#b0b0b0"
                color: telemetryGraphCheck.checked ? "#7F3B2E" : "transparent"
                Text { anchors.centerIn: parent
                    text: "✓"; visible: telemetryGraphCheck.checked
                    font.pixelSize: 9; color: "white"
                }
            }
        }
        Controls.CheckBox { id: liveRadar
            text: "Live Radar"
            opacity: 1
            enabled: false
            padding: 0
            indicator: Rectangle {
                opacity: liveRadar.enabled ? 1.0 : 0.38
                x: 0
                y: (parent.height - height) / 2 + 1
                implicitWidth: 13; implicitHeight: 13
                radius: 2; border.width: 1
                border.color: liveRadar.checked ? "#7F3B2E" : "#b0b0b0"
                color: liveRadar.checked ? "#7F3B2E" : "transparent"
                Text { anchors.centerIn: parent
                    text: "✓"; visible: liveRadar.checked
                    font.pixelSize: 9; color: "white"
                }
            }
        }
        Controls.CheckBox { id: map
            text: "Map"
            opacity: 1

            enabled: false
            padding: 0
            indicator: Rectangle {
                opacity: map.enabled ? 1.0 : 0.38
                x: 0
                y: (parent.height - height) / 2 + 1
                implicitWidth: 13; implicitHeight: 13
                radius: 2; border.width: 1
                border.color: map.checked ? "#7F3B2E" : "#b0b0b0"
                color: map.checked ? "#7F3B2E" : "transparent"
                Text { anchors.centerIn: parent
                    text: "✓"; visible: map.checked
                    font.pixelSize: 9; color: "white"
                }
            }
        }
    }

    TelemetryWindow {
        id: telemetryWin
        onVisibleChanged: {
            if (telemetryGraphCheck.checked !== visible) {
                telemetryGraphCheck.checked = visible
            }
        }
    }

    Settings {
        id: windowSettings
        category: "MainWindow"
        
        property alias x: mainWindow.x
        property alias y: mainWindow.y
        property alias width: mainWindow.width
        property alias height: mainWindow.height

        property alias telemetryGraphChecked: telemetryGraphCheck.checked
        property alias liveRadarChecked: liveRadar.checked
        property alias mapChecked: map.checked
    }
}