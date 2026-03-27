import QtQuick 6.9
import QtQuick.Controls 6.9 as Controls
import QtQuick.Layouts

Controls.Popup {
    id: picker
    property color currentColor
    signal colorPicked(color c)

    property real pickerHue: 0
    property real pickerSat: 1
    property real pickerVal: 1
    readonly property color liveColor: Qt.hsva(pickerHue, pickerSat, pickerVal, 1)

    width: 186; padding: 6
    background: Rectangle { radius: 6; color: "#EE1E1E1E"; border.color: "#555"; border.width: 1 }

    ColumnLayout { spacing: 6

        // --- Saturation / Value plane ---
        Item { id: svArea; width: 170; height: 130
            Rectangle { anchors.fill: parent; radius: 3
                color: Qt.hsva(picker.pickerHue, 1, 1, 1)
            }
            Rectangle { anchors.fill: parent; radius: 3
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: "#FFFFFFFF" }
                    GradientStop { position: 1; color: "#00FFFFFF" }
                }
            }
            Rectangle { anchors.fill: parent; radius: 3
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0; color: "#00000000" }
                    GradientStop { position: 1; color: "#FF000000" }
                }
            }

            // Crosshair
            Rectangle {
                x: picker.pickerSat * svArea.width - 6
                y: (1 - picker.pickerVal) * svArea.height - 6
                width: 12; height: 12; radius: 6
                color: "transparent"
                border.width: 2; border.color: "white"
                Rectangle { anchors.centerIn: parent
                    width: 10; height: 10; radius: 5
                    color: "transparent"
                    border.width: 1; border.color: "black"
                }
            }

            MouseArea {
                anchors.fill: parent; cursorShape: Qt.CrossCursor
                function pick(mouse) {
                    picker.pickerSat = Math.max(0, Math.min(1, mouse.x / width))
                    picker.pickerVal = Math.max(0, Math.min(1, 1 - mouse.y / height))
                }
                onPressed: (mouse) => pick(mouse)
                onPositionChanged: (mouse) => { if (pressed) pick(mouse) }
            }
        }

        // --- Hue bar ---
        Item { id: hueArea; width: 170; height: 14
            Rectangle { anchors.fill: parent; radius: 3
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.000; color: Qt.hsva(0,     1, 1, 1) }
                    GradientStop { position: 0.167; color: Qt.hsva(0.167, 1, 1, 1) }
                    GradientStop { position: 0.333; color: Qt.hsva(0.333, 1, 1, 1) }
                    GradientStop { position: 0.500; color: Qt.hsva(0.5,   1, 1, 1) }
                    GradientStop { position: 0.667; color: Qt.hsva(0.667, 1, 1, 1) }
                    GradientStop { position: 0.833; color: Qt.hsva(0.833, 1, 1, 1) }
                    GradientStop { position: 1.000; color: Qt.hsva(1,     1, 1, 1) }
                }
            }
            // Hue indicator
            Rectangle {
                x: picker.pickerHue * hueArea.width - 3; y: -1
                width: 6; height: hueArea.height + 2; radius: 2
                color: "transparent"
                border.width: 2; border.color: "white"
            }
            MouseArea {
                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                function pick(mouse) {
                    picker.pickerHue = Math.max(0, Math.min(0.9999, mouse.x / width))
                }
                onPressed: (mouse) => pick(mouse)
                onPositionChanged: (mouse) => { if (pressed) pick(mouse) }
            }
        }

        // --- Preview + Confirm ---
        RowLayout { spacing: 4; Layout.alignment: Qt.AlignHCenter
            Rectangle { width: 18; height: 18; radius: 3; color: picker.liveColor
                border.width: 1; border.color: "#888"
            }
            Rectangle { width: 18; height: 18; radius: 3; color: "#444"; border.width: 1; border.color: "#555"
                Text { anchors.centerIn: parent; text: "✓"; color: "#CCCCCC"; font.pixelSize: 11 }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        picker.colorPicked(picker.liveColor)
                        picker.close()
                    }
                }
            }
        }
    }

    onAboutToShow: {
        var c = currentColor
        pickerHue = c.hsvHue >= 0 ? c.hsvHue : 0
        pickerSat = c.hsvSaturation
        pickerVal = c.hsvValue
    }
}