import QtQuick 6.9
import QtQuick.Controls 6.9 as Controls
import QtQuick.Layouts

Controls.Popup {
    id: settingsPopup

    required property QtObject settings
    signal telemetryWindowResetRequested()

    padding: 6
    background: Rectangle { radius: 6; color: "#DD1E1E1E"; border.color: "#555555"; border.width: 1 }

    // --- Inline HSV gradient color picker popup ---
    component ColorPickerPopup : Controls.Popup {
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
                Controls.CheckBox { id: chkThrottle; text: "Throttle"; checked: settings.showThrottle
                    padding: 0; topPadding: 2; bottomPadding: 2; Layout.fillWidth: true
                    onCheckedChanged: settings.showThrottle = checked
                    contentItem: Text { text: parent.text; color: settings.throttleColor; font.pixelSize: 12
                        leftPadding: parent.indicator.width + 6; verticalAlignment: Text.AlignVCenter
                    }
                    indicator: Rectangle { implicitWidth: 13; implicitHeight: 13; x: 0
                        y: (parent.height - height) / 2; radius: 2
                        border.width: 1; border.color: chkThrottle.checked ? settings.throttleColor : "#888"
                        color: chkThrottle.checked ? settings.throttleColor : "transparent"
                        Text { anchors.centerIn: parent; text: "✓"; visible: chkThrottle.checked
                            font.pixelSize: 9; color: "#000000"
                        }
                    }
                }
                Rectangle { width: 14; height: 14; radius: 3; color: settings.throttleColor
                    border.width: 1; border.color: "#888"
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: throttleColorPicker.visible ? throttleColorPicker.close() : throttleColorPicker.open()
                    }
                }
            }

            RowLayout { spacing: 4; Layout.fillWidth: true
                Controls.CheckBox { id: chkBrake; text: "Brake"; checked: settings.showBrake
                    padding: 0; topPadding: 2; bottomPadding: 2; Layout.fillWidth: true
                    onCheckedChanged: settings.showBrake = checked
                    contentItem: Text { text: parent.text; color: settings.brakeColor; font.pixelSize: 12
                        leftPadding: parent.indicator.width + 6; verticalAlignment: Text.AlignVCenter
                    }
                    indicator: Rectangle { implicitWidth: 13; implicitHeight: 13; x: 0
                        y: (parent.height - height) / 2; radius: 2
                        border.width: 1; border.color: chkBrake.checked ? settings.brakeColor : "#888"
                        color: chkBrake.checked ? settings.brakeColor : "transparent"
                        Text { anchors.centerIn: parent; text: "✓"; visible: chkBrake.checked
                            font.pixelSize: 9; color: "#FFFFFF"
                        }
                    }
                }
                Rectangle { width: 14; height: 14; radius: 3; color: settings.brakeColor
                    border.width: 1; border.color: "#888"
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: brakeColorPicker.visible ? brakeColorPicker.close() : brakeColorPicker.open()
                    }
                }
            }

            RowLayout { spacing: 4; Layout.fillWidth: true
                Controls.CheckBox { id: chkAbs; text: "ABS"; checked: settings.showAbs
                    padding: 0; topPadding: 2; bottomPadding: 2; Layout.fillWidth: true
                    onCheckedChanged: settings.showAbs = checked
                    contentItem: Text { text: parent.text; color: settings.absColor; font.pixelSize: 12
                        leftPadding: parent.indicator.width + 6; verticalAlignment: Text.AlignVCenter
                    }
                    indicator: Rectangle { implicitWidth: 13; implicitHeight: 13; x: 0
                        y: (parent.height - height) / 2; radius: 2
                        border.width: 1; border.color: chkAbs.checked ? settings.absColor : "#888"
                        color: chkAbs.checked ? settings.absColor : "transparent"
                        Text { anchors.centerIn: parent; text: "✓"; visible: chkAbs.checked
                            font.pixelSize: 9; color: "#FFFFFF"
                        }
                    }
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

            Controls.CheckBox { id: chkValues; text: "Values"; checked: settings.showValues
                padding: 0; topPadding: 2; bottomPadding: 2
                onCheckedChanged: settings.showValues = checked
                contentItem: Text { text: parent.text; color: "#AAAAAA"; font.pixelSize: 12
                    leftPadding: parent.indicator.width + 6; verticalAlignment: Text.AlignVCenter
                }
                indicator: Rectangle { implicitWidth: 13; implicitHeight: 13; x: 0
                    y: (parent.height - height) / 2; radius: 2
                    border.width: 1; border.color: chkValues.checked ? "#777" : "#888"
                    color: chkValues.checked ? "#777" : "transparent"
                    Text { anchors.centerIn: parent; text: "✓"; visible: chkValues.checked
                        font.pixelSize: 9; color: "#FFFFFF"
                    }
                }
            }

            Controls.CheckBox { id: chkPeaks; text: "Brake peaks"; checked: settings.showPeaks
                padding: 0; topPadding: 2; bottomPadding: 2
                onCheckedChanged: settings.showPeaks = checked
                contentItem: Text { text: parent.text; color: "#AAAAAA"; font.pixelSize: 12
                    leftPadding: parent.indicator.width + 6; verticalAlignment: Text.AlignVCenter
                }
                indicator: Rectangle { implicitWidth: 13; implicitHeight: 13; x: 0
                    y: (parent.height - height) / 2; radius: 2
                    border.width: 1; border.color: chkPeaks.checked ? "#777" : "#888"
                    color: chkPeaks.checked ? "#777" : "transparent"
                    Text { anchors.centerIn: parent; text: "✓"; visible: chkPeaks.checked
                        font.pixelSize: 9; color: "#FFFFFF"
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: "#444"; Layout.topMargin: 2; Layout.bottomMargin: 2 }

            Controls.Label { text: "Grid"; color: "#999"; font.pixelSize: 10; font.bold: true }

            Controls.CheckBox { id: chkGridH; text: "Horizontal"; checked: settings.showGridH
                padding: 0; topPadding: 2; bottomPadding: 2
                onCheckedChanged: settings.showGridH = checked
                contentItem: Text { text: parent.text; color: "#AAAAAA"; font.pixelSize: 12
                    leftPadding: parent.indicator.width + 6; verticalAlignment: Text.AlignVCenter
                }
                indicator: Rectangle { implicitWidth: 13; implicitHeight: 13; x: 0
                    y: (parent.height - height) / 2; radius: 2
                    border.width: 1; border.color: chkGridH.checked ? "#777" : "#888"
                    color: chkGridH.checked ? "#777" : "transparent"
                    Text { anchors.centerIn: parent; text: "✓"; visible: chkGridH.checked
                        font.pixelSize: 9; color: "#FFFFFF"
                    }
                }
            }

            Controls.CheckBox { id: chkGridV; text: "Vertical"; checked: settings.showGridV
                padding: 0; topPadding: 2; bottomPadding: 2
                onCheckedChanged: settings.showGridV = checked
                contentItem: Text { text: parent.text; color: "#AAAAAA"; font.pixelSize: 12
                    leftPadding: parent.indicator.width + 6; verticalAlignment: Text.AlignVCenter
                }
                indicator: Rectangle { implicitWidth: 13; implicitHeight: 13; x: 0
                    y: (parent.height - height) / 2; radius: 2
                    border.width: 1; border.color: chkGridV.checked ? "#777" : "#888"
                    color: chkGridV.checked ? "#777" : "transparent"
                    Text { anchors.centerIn: parent; text: "✓"; visible: chkGridV.checked
                        font.pixelSize: 9; color: "#FFFFFF"
                    }
                }
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