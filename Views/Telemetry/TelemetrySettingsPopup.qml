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

    ColorPickerPopup { id: throttleColorPicker; currentColor: settings.throttleColor
        x: settingsPopup.width + 2 - settingsPopup.leftPadding
        y: -settingsPopup.topPadding
        onColorPicked: (c) => { settings.throttleColor = c }
    }
    ColorPickerPopup { id: brakeColorPicker; currentColor: settings.brakeColor
        x: settingsPopup.width + 2 - settingsPopup.leftPadding
        y: -settingsPopup.topPadding
        onColorPicked: (c) => { settings.brakeColor = c }
    }
    ColorPickerPopup { id: absColorPicker; currentColor: settings.absColor
        x: settingsPopup.width + 2 - settingsPopup.leftPadding
        y: -settingsPopup.topPadding
        onColorPicked: (c) => { settings.absColor = c }
    }

    RowLayout { spacing: 0

        // ---- Left: settings ----
        ColumnLayout { spacing: 0; Layout.alignment: Qt.AlignTop; width: 160;

            Controls.Label { text: "Traces"; color: "#999"; font.pixelSize: 10; font.bold: true }

            RowLayout { spacing: 4; Layout.fillWidth: true
                SettingsCheckBox { text: "Throttle"; checked: settings.showThrottle
                    accentColor: settings.throttleColor; checkmarkColor: "#000000"
                    Layout.fillWidth: true
                    onCheckedChanged: settings.showThrottle = checked
                }
                Rectangle { width: 14; height: 14; radius: 3; color: settings.throttleColor
                    border.width: 1; border.color: "#888"
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: throttleColorPicker.visible ? throttleColorPicker.close() : throttleColorPicker.open()
                    }
                }
            }

            RowLayout { spacing: 4; Layout.fillWidth: true
                SettingsCheckBox { text: "Brake"; checked: settings.showBrake
                    accentColor: settings.brakeColor
                    Layout.fillWidth: true
                    onCheckedChanged: settings.showBrake = checked
                }
                Rectangle { width: 14; height: 14; radius: 3; color: settings.brakeColor
                    border.width: 1; border.color: "#888"
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: brakeColorPicker.visible ? brakeColorPicker.close() : brakeColorPicker.open()
                    }
                }
            }

            RowLayout { spacing: 4; Layout.fillWidth: true
                SettingsCheckBox { text: "ABS"; checked: settings.showAbs
                    accentColor: settings.absColor
                    Layout.fillWidth: true
                    onCheckedChanged: settings.showAbs = checked
                }
                Rectangle { width: 14; height: 14; radius: 3; color: settings.absColor
                    border.width: 1; border.color: "#888"
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: absColorPicker.visible ? absColorPicker.close() : absColorPicker.open()
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: "#444"; Layout.topMargin: 2; Layout.bottomMargin: 2 }

            Controls.Label { text: "Labels"; color: "#999"; font.pixelSize: 10; font.bold: true }

            SettingsCheckBox { text: "Values"; checked: settings.showValues
                textColor: "#AAAAAA"
                onCheckedChanged: settings.showValues = checked
            }

            SettingsCheckBox { text: "Brake peaks"; checked: settings.showPeaks
                textColor: "#AAAAAA"
                onCheckedChanged: settings.showPeaks = checked
            }

            Rectangle { width: parent.width; height: 1; color: "#444"; Layout.topMargin: 2; Layout.bottomMargin: 2 }

            Controls.Label { text: "Grid"; color: "#999"; font.pixelSize: 10; font.bold: true }

            SettingsCheckBox { text: "Horizontal"; checked: settings.showGridH
                textColor: "#AAAAAA"
                onCheckedChanged: settings.showGridH = checked
            }

            SettingsCheckBox { text: "Vertical"; checked: settings.showGridV
                textColor: "#AAAAAA"
                onCheckedChanged: settings.showGridV = checked
            }

            Rectangle { width: parent.width; height: 1; color: "#444"; Layout.topMargin: 2; Layout.bottomMargin: 2 }

            Rectangle { width: parent.width; height: 18; radius: 3; color: resetArea.containsMouse ? "#333" : "transparent"
                Text { anchors.centerIn: parent; text: "Reset"; color: "#999"; font.pixelSize: 10 }
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
        ColumnLayout { spacing: 4; Layout.alignment: Qt.AlignTop; Layout.preferredWidth: 110

            Controls.Label { text: "Shortcuts"; color: "#999"; font.pixelSize: 10; font.bold: true }

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
                        Text { text: modelData.key;  color: "#CCCCCC"; font.pixelSize: 10; font.bold: true }
                        Text { text: modelData.desc; color: "#777";    font.pixelSize: 9; bottomPadding: 3 }
                    }
                }
            }
        }
    }
}