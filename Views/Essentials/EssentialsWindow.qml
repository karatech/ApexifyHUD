import QtQuick.Controls.Material 2.15
import QtQuick 6.9
import QtQuick.Controls 6.9
import QtQuick.Layouts 6.9
import Qt.labs.settings 1.1
import "../Controls"

Window { id: root; width: 340; height: 170; x: 400; y: 100; minimumWidth: 200; minimumHeight: 120
    flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"

    transientParent: null

    property color backgroundColor: "#1E1E1E"

    property var snapTargets: []

    function clampOpacity(v) { return Math.min(1.0, Math.max(0.4, v)); }
    Component.onCompleted: { root.opacity = clampOpacity(windowSettings.opacity) }
    onOpacityChanged: windowSettings.opacity = clampOpacity(root.opacity)

    function formatLapTime(seconds) {
        if (seconds <= 0) return "0:00.000"
        let mins = Math.floor(seconds / 60)
        let secs = seconds - mins * 60
        let secsStr = secs.toFixed(3)
        if (secs < 10) secsStr = "0" + secsStr
        return mins + ":" + secsStr
    }

    function gearText(g) {
        if (g < 0) return "R"
        if (g === 0) return "N"
        return g.toString()
    }

    Rectangle { id: bg; radius: 6; clip: true
        anchors.fill: parent; color: root.backgroundColor

        ColumnLayout { anchors.fill: parent; anchors.margins: 8; spacing: 4

            // ---- Rev LEDs bar ----
            RowLayout { Layout.fillWidth: true; spacing: 2
                Repeater { model: 15
                    Rectangle {
                        required property int index
                        Layout.fillWidth: true; implicitHeight: 8; radius: 2

                        readonly property bool lit: essentialsVM.rpmPercent >= (index + 1) / 15.0

                        color: {
                            if (!lit) return "#333333"
                            if (index < 5) return "#00CC00"
                            if (index < 10) return "#FF8800"
                            return "#FF0000"
                        }
                        opacity: lit ? 1.0 : 0.3
                    }
                }
            }

            // ---- Speed + Gear ----
            RowLayout { Layout.fillWidth: true; Layout.fillHeight: true; spacing: 0

                Item { Layout.fillWidth: true; Layout.fillHeight: true
                    ColumnLayout { anchors.centerIn: parent; spacing: -2
                        Text {
                            text: essentialsVM.speed
                            color: "white"; font.pixelSize: 42; font.bold: true; font.family: "Consolas"
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: "km/h"; color: "#777777"; font.pixelSize: 10
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                Rectangle { Layout.fillHeight: true; Layout.margins: 8; width: 1; color: Qt.rgba(1, 1, 1, 0.15) }

                Item { Layout.preferredWidth: 70; Layout.fillHeight: true
                    ColumnLayout { anchors.centerIn: parent; spacing: -2
                        Text {
                            text: gearText(essentialsVM.gear)
                            color: "#FF6600"; font.pixelSize: 42; font.bold: true; font.family: "Consolas"
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: "gear"; color: "#777777"; font.pixelSize: 10
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }

            // ---- Lap time + Position ----
            RowLayout { Layout.fillWidth: true; spacing: 4
                Text {
                    text: "⏱ " + root.formatLapTime(essentialsVM.lapTimeSeconds)
                    color: "#CCCCCC"; font.pixelSize: 13; font.bold: true
                    Layout.fillWidth: true
                }
                Text {
                    text: "P" + essentialsVM.position
                    color: "#FFD700"; font.pixelSize: 13; font.bold: true
                }
            }

            // ---- Fuel + Temperatures ----
            RowLayout { Layout.fillWidth: true; spacing: 6
                Text {
                    text: "⛽ " + essentialsVM.fuelLevel.toFixed(1) + " L"
                    color: "#CCCCCC"; font.pixelSize: 12
                    Layout.fillWidth: true
                }
                Text { text: "T:" + essentialsVM.trackTemp.toFixed(0) + "°"; color: "#FF8844"; font.pixelSize: 12 }
                Text { text: "A:" + essentialsVM.airTemp.toFixed(0) + "°"; color: "#44AAFF"; font.pixelSize: 12 }
            }
        }
    }

    // Snap-aware drag, resize, hide, opacity
    SnapDragArea { targetWindow: root; snapTargets: root.snapTargets }

    Settings { id: windowSettings; category: "EssentialsWindow"
        property alias x: root.x
        property alias y: root.y
        property alias width: root.width
        property alias height: root.height
        property real opacity: 1.0
    }
}