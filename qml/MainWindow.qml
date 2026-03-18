

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

    component CustomCheckBox : Controls.CheckBox {
        id: control
        opacity: 1; padding: 0
        indicator: Rectangle { opacity: control.enabled ? 1.0 : 0.38
            x: 0; y: (control.height - height) / 2 + 1
            implicitWidth: 13; implicitHeight: 13
            radius: 2; border.width: 1
            border.color: control.checked ? "#7F3B2E" : "#b0b0b0"
            color: control.checked ? "#7F3B2E" : "transparent"
            Text { anchors.centerIn: parent
                text: "✓"; visible: control.checked
                font.pixelSize: 9; color: "white"
            }
        }
    }

    Column {
        anchors.fill: parent; anchors.margins: 16; spacing: 12
        CustomCheckBox { id: telemetryGraphCheck; text: "Telemetry Graph"; enabled: true
            onCheckedChanged: {
                if (telemetryWin.visible !== checked) telemetryWin.visible = checked
            }
        }
        CustomCheckBox { id: liveRadar; text: "Live Radar"; enabled: false
            onCheckedChanged: {
                if (liveRadar.checked !== visible) liveRadar.checked = visible
            }
        }

        CustomCheckBox { id: map; text: "Map"; enabled: false
            onCheckedChanged: {
                if (map.checked !== visible) map.checked = visible
            }
        }
    }

    TelemetryWindow {
        id: telemetryWin
        onVisibleChanged: {
            if (telemetryGraphCheck.checked !== visible) telemetryGraphCheck.checked = visible
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