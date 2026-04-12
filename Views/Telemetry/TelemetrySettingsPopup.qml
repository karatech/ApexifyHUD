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

            CustomCheckBox { text: "Throttle bar"; checked: settings.showThrottleBar; compact: true
                onCheckedChanged: settings.showThrottleBar = checked
            }

            CustomCheckBox { text: "Brake bar"; checked: settings.showBrakeBar; compact: true
                onCheckedChanged: settings.showBrakeBar = checked
            }

            CustomCheckBox { text: "Horizontal"; checked: settings.horizontalPedalInput; compact: true
                enabled: settings.showThrottleBar || settings.showBrakeBar
                onCheckedChanged: settings.horizontalPedalInput = checked
            }

            ColumnLayout { Layout.fillWidth: true; Layout.bottomMargin: 10
                Controls.Label { text: "Thickness"; color: "#999"; font.pixelSize: 12; Layout.alignment: Qt.AlignHCenter }
                Controls.Slider { id: thicknessSlider; from: 0.2; to: 3.0; stepSize: 0.1
                    value: settings.lineThickness; Layout.fillWidth: true
                    implicitHeight: 6
                    onMoved: settings.lineThickness = value
                    background: Rectangle { x: thicknessSlider.leftPadding; width: thicknessSlider.availableWidth
                        y: thicknessSlider.topPadding + thicknessSlider.availableHeight / 2 - height / 2
                        implicitWidth: 120; implicitHeight: 2; radius: 1; color: "#444"
                        Rectangle { width: thicknessSlider.visualPosition * parent.width; height: parent.height; radius: 1; color: "#7F3B2E" }
                    }
                    handle: Rectangle { x: thicknessSlider.leftPadding + thicknessSlider.visualPosition * (thicknessSlider.availableWidth - width)
                        y: thicknessSlider.topPadding + thicknessSlider.availableHeight / 2 - height / 2
                        implicitWidth: 10; implicitHeight: 10; radius: 5; color: "#CCCCCC"
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: "#444"; Layout.topMargin: 10; Layout.bottomMargin: 10 }

            Controls.Label { text: "Labels"; color: "#999"; font.pixelSize: 12; font.bold: true }

            CustomCheckBox { text: "Brake peaks"; checked: settings.showPeaks; compact: true
                onCheckedChanged: settings.showPeaks = checked
            }

            CustomCheckBox { text: "Pedal values"; checked: settings.showPedalValues; compact: true
                onCheckedChanged: settings.showPedalValues = checked
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
                        settings.showPeaks = true
                        settings.horizontalPedalInput = false
                        settings.showThrottleBar = true
                        settings.showBrakeBar = true
                        settings.showPedalValues = true
                        settings.throttleColor = "#00FF00"
                        settings.brakeColor = "#FF0000"
                        settings.absColor = "#5555FF"
                        settings.lineThickness = 1.4
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