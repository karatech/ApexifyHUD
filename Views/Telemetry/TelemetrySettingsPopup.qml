import QtQuick 6.9
import QtQuick.Controls 6.9 as Controls
import QtQuick.Layouts
import "../Controls"

Controls.Popup {
    id: settingsPopup

    required property QtObject settings
    signal telemetryWindowResetRequested()

    padding: 6
    background: Rectangle { radius: 6; color: "#DD1E1E1E"; border.color: "#555555"; border.width: 1 }

    function openPickerAt(picker, item, mouse) {
        var pos = item.mapToItem(picker.parent, mouse.x, mouse.y)
        picker.x = pos.x
        picker.y = pos.y
        picker.open()
    }

    ColorPickerPopup { id: throttleColorPicker; currentColor: settings.throttleColor
        onColorPicked: (c) => { settings.throttleColor = c }
    }
    ColorPickerPopup { id: brakeColorPicker; currentColor: settings.brakeColor
        onColorPicked: (c) => { settings.brakeColor = c }
    }
    ColorPickerPopup { id: absColorPicker; currentColor: settings.absColor
        onColorPicked: (c) => { settings.absColor = c }
    }

    RowLayout { spacing: 0

        // ---- Left: settings ----
        ColumnLayout { spacing: 0; Layout.alignment: Qt.AlignTop; width: 120; Layout.margins: 10

            Controls.Label { text: "Traces"; color: "#999"; font.pixelSize: 12; font.bold: true }

            RowLayout { spacing: 4; Layout.fillWidth: true
                CustomCheckBox { text: "Throttle"; checked: settings.showThrottle; compact: true
                    Layout.fillWidth: true
                    onCheckedChanged: settings.showThrottle = checked
                }
                Rectangle { width: 14; height: 14; radius: 3; color: settings.throttleColor
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: (mouse) => throttleColorPicker.visible ? throttleColorPicker.close() : openPickerAt(throttleColorPicker, this, mouse)
                    }
                }
            }

            RowLayout { spacing: 4; Layout.fillWidth: true
                CustomCheckBox { text: "Brake"; checked: settings.showBrake; compact: true
                    Layout.fillWidth: true
                    onCheckedChanged: settings.showBrake = checked
                }
                Rectangle { width: 14; height: 14; radius: 3; color: settings.brakeColor
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: (mouse) => brakeColorPicker.visible ? brakeColorPicker.close() : openPickerAt(brakeColorPicker, this, mouse)
                    }
                }
            }

            RowLayout { spacing: 4; Layout.fillWidth: true
                CustomCheckBox { text: "ABS"; checked: settings.showAbs; compact: true
                    Layout.fillWidth: true
                    onCheckedChanged: settings.showAbs = checked
                }
                Rectangle { width: 14; height: 14; radius: 3; color: settings.absColor
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: (mouse) => absColorPicker.visible ? absColorPicker.close() : openPickerAt(absColorPicker, this, mouse)
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: "#444"; Layout.topMargin: 10; Layout.bottomMargin: 10 }

            Controls.Label { text: "Labels"; color: "#999"; font.pixelSize: 12; font.bold: true }

            CustomCheckBox { text: "Values"; checked: settings.showValues; compact: true
                onCheckedChanged: settings.showValues = checked
            }

            CustomCheckBox { text: "Brake peaks"; checked: settings.showPeaks; compact: true
                onCheckedChanged: settings.showPeaks = checked
            }

            Rectangle { width: parent.width; height: 1; color: "#444"; Layout.topMargin: 10; Layout.bottomMargin: 10 }

            Controls.Label { text: "Grid"; color: "#999"; font.pixelSize: 12; font.bold: true }

            CustomCheckBox { text: "Horizontal"; checked: settings.showGridH; compact: true
                onCheckedChanged: settings.showGridH = checked
            }

            CustomCheckBox { text: "Vertical"; checked: settings.showGridV; compact: true
                onCheckedChanged: settings.showGridV = checked
            }

            Rectangle { width: parent.width; height: 1; color: "#444"; Layout.topMargin: 10; Layout.bottomMargin: 10 }

            Rectangle { width: parent.width; height: 18; radius: 3; color: resetArea.containsMouse ? "#333" : "transparent"
                Text { anchors.centerIn: parent; text: "Reset"; color: "#999"; font.pixelSize: 14 }
                MouseArea { id: resetArea; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true
                    onClicked: {
                        settings.showThrottle = true
                        settings.showBrake = true
                        settings.showAbs = true
                        settings.showGridH = false
                        settings.showGridV = false
                        settings.showValues = false
                        settings.showPeaks = true
                        settings.throttleColor = "#00FF00"
                        settings.brakeColor = "#FF0000"
                        settings.absColor = "#5555FF"
                        settingsPopup.telemetryWindowResetRequested()
                    }
                }
            }
        }

        // ---- Vertical delimiter ----
        Rectangle { width: 1; Layout.fillHeight: true; color: "#444"; Layout.leftMargin: 6; Layout.rightMargin: 6 }

        // ---- Right: shortcuts info ----
        ColumnLayout { spacing: 4; Layout.alignment: Qt.AlignTop; Layout.preferredWidth: 80; Layout.margins: 10

            Controls.Label { text: "Shortcuts"; color: "#999"; font.pixelSize: 12; font.bold: true }

            ColumnLayout { spacing: 1
                Repeater {
                    model: [
                        { key: "Drag",           desc: "Move window" },
                        { key: "Ctrl + Drag",    desc: "Resize" },
                        { key: "Middle Click",   desc: "Hide" },
                        { key: "Scroll Wheel",   desc: "Opacity" }
                    ]
                    delegate: ColumnLayout { spacing: 0
                        required property var modelData
                        Text { text: modelData.key;  color: "#CCCCCC"; font.pixelSize: 12; font.bold: true }
                        Text { text: modelData.desc; color: "#777";    font.pixelSize: 12; bottomPadding: 3 }
                    }
                }
            }
        }
    }
}