import QtQuick.Controls.Material 2.15
import Qt.labs.settings 1.0
import Qt.labs.folderlistmodel 2.15
import QtQuick 6.9
import QtQuick.Controls 6.9 as Controls
import QtQuick.Layouts
import QtQuick.Dialogs

ApplicationWindow { id: mainWindow; title: "ApexifyHUD"
    width: 640; height: 800; visible: true

    onClosing: Qt.quit()

    property string selectedIbtFileName: ""
    property string selectedIbtFilePath: ""

    // Telemetry trace visibility (persisted via Settings below)
    property bool showThrottle: true
    property bool showBrake: true
    property bool showAbs: true
    property bool showGridH: true
    property bool showGridV: true
    property bool showValues: true
    property bool showPeaks: true
    property color throttleColor: "#00FF00"
    property color brakeColor: "#FF0000"
    property color absColor: "#5555FF"

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

    component CustomRadioButton : Controls.RadioButton {
        id: control
        opacity: 1; padding: 0; spacing: 8

        indicator: Rectangle {
            opacity: control.enabled ? 1.0 : 0.38
            x: 0; y: (control.height - height) / 2 + 1
            implicitWidth: 13; implicitHeight: 13
            radius: width / 2
            border.width: 1
            border.color: control.checked ? "#7F3B2E" : "#b0b0b0"
            color: control.checked ? "#7F3B2E" : "transparent"

            Rectangle {
                anchors.centerIn: parent; width: 5; height: 5
                radius: width / 2; visible: control.checked
                color: "white"
            }
        }

        contentItem: Text {
            text: control.text; color: "white"; font: control.font; verticalAlignment: Text.AlignVCenter
            leftPadding: control.indicator.width + control.spacing; elide: Text.ElideRight
        }
    }

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

    ColorPickerPopup { id: throttleColorPicker; currentColor: mainWindow.throttleColor
        x: settingsPopup.x + settingsPopup.width + 2; y: settingsPopup.y
        onColorPicked: (c) => { mainWindow.throttleColor = c }
    }
    ColorPickerPopup { id: brakeColorPicker; currentColor: mainWindow.brakeColor
        x: settingsPopup.x + settingsPopup.width + 2; y: settingsPopup.y
        onColorPicked: (c) => { mainWindow.brakeColor = c }
    }
    ColorPickerPopup { id: absColorPicker; currentColor: mainWindow.absColor
        x: settingsPopup.x + settingsPopup.width + 2; y: settingsPopup.y
        onColorPicked: (c) => { mainWindow.absColor = c }
    }

    FolderListModel { id: ibtFilesModel
        folder: ibtLogFolderUrl
        nameFilters: ["*.ibt"]
        showDirs: false; showDotAndDotDot: false; sortField: FolderListModel.Name
    }

    Controls.ButtonGroup { id: ibtButtonGroup }

    ColumnLayout { anchors.fill: parent; anchors.margins: 16; spacing: 12

        RowLayout { Layout.fillWidth: true; spacing: 4

            CustomCheckBox { id: telemetryGraphCheck
                text: "Telemetry Graph"; enabled: true
                onCheckedChanged: {
                    telemetryWinLoader.active = checked
                    if (checked && telemetryWinLoader.item) telemetryWinLoader.item.visible = true
                }
            }

            Controls.RoundButton { id: settingsBtn; width: 20; height: 20; radius: 10
                visible: telemetryGraphCheck.checked; flat: true; padding: 0
                text: "⚙"; font.pixelSize: 11
                opacity: settingsPopup.visible ? 1.0 : 0.5
                background: Rectangle { radius: 10; color: settingsBtn.hovered ? "#44FFFFFF" : "transparent" }
                contentItem: Text { text: settingsBtn.text; font: settingsBtn.font; color: "#CCCCCC"
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }
                onClicked: settingsPopup.visible ? settingsPopup.close() : settingsPopup.open()
            }
        }

        CustomCheckBox { id: liveRadar
            text: "Live Radar"; enabled: false; Layout.fillWidth: true
            onCheckedChanged: {
                if (liveRadar.checked !== visible) liveRadar.checked = visible
            }
        }

        CustomCheckBox { id: map
            text: "Map"; enabled: false; Layout.fillWidth: true
            onCheckedChanged: {
                if (map.checked !== visible) map.checked = visible
            }
        }

        Item { Layout.fillHeight: true }

        Controls.Label {
            text: "IBT log files"; color: "white"; font.bold: true; Layout.fillWidth: true
        }

        Rectangle {
            Layout.fillWidth: true; height: 240; radius: 4; color: "transparent"; border.color: "transparent"

            ListView { id: ibtListView
                anchors.fill: parent; anchors.margins: 8; clip: true; model: ibtFilesModel

                delegate: CustomRadioButton {
                    required property string fileName
                    required property string filePath
                    ButtonGroup.group: ibtButtonGroup
                    text: fileName
                    checked: mainWindow.selectedIbtFileName === fileName
                    width: ibtListView.width
                    onToggled: {
                        if (checked) {
                            mainWindow.selectedIbtFileName = fileName
                            mainWindow.selectedIbtFilePath = filePath   // full path saved
                        }
                    }
                }
            }
        }


        RowLayout {
            width: parent.width; spacing: 8

            Controls.Label {
                visible: true; color: "#BBBBBB"
                text: "Selected: " + mainWindow.selectedIbtFileName
                wrapMode: Text.WrapAnywhere; Layout.fillWidth: true
            }

            Controls.Button { id: simulateButton; text: "Simulate";
                enabled: mainWindow.selectedIbtFileName.length > 0
                onClicked: {
                    mainWindowVM.simulateSelectedIbt(mainWindow.selectedIbtFilePath)
                }
                background: Rectangle { color: simulateButton.down ? "dark red" : "#7F3B2E"; radius: 15; border.color: "black" }
            }
        }

        Controls.Label {
            visible: ibtFilesModel.count === 0
            text: "No .ibt files found in: " + ibtLogFolderUrl
            color: "#BBBBBB"; wrapMode: Text.WrapAnywhere; Layout.fillWidth: true
        }
    }

    // --- Telemetry settings popup ---
    Controls.Popup { id: settingsPopup
        x: settingsBtn.x + 16; y: settingsBtn.y + settingsBtn.height + 20
        padding: 6
        background: Rectangle { radius: 6; color: "#DD1E1E1E"; border.color: "#555555"; border.width: 1 }

        RowLayout { spacing: 0

            // ---- Left: settings ----
            ColumnLayout { spacing: 0; Layout.alignment: Qt.AlignTop; width: 160;

                Controls.Label { text: "Traces"; color: "#999"; font.pixelSize: 10; font.bold: true }

                RowLayout { spacing: 4; Layout.fillWidth: true
                    Controls.CheckBox { id: chkThrottle; text: "Throttle"; checked: mainWindow.showThrottle
                        padding: 0; topPadding: 2; bottomPadding: 2; Layout.fillWidth: true
                        onCheckedChanged: mainWindow.showThrottle = checked
                        contentItem: Text { text: parent.text; color: mainWindow.throttleColor; font.pixelSize: 12
                            leftPadding: parent.indicator.width + 6; verticalAlignment: Text.AlignVCenter
                        }
                        indicator: Rectangle { implicitWidth: 13; implicitHeight: 13; x: 0
                            y: (parent.height - height) / 2; radius: 2
                            border.width: 1; border.color: chkThrottle.checked ? mainWindow.throttleColor : "#888"
                            color: chkThrottle.checked ? mainWindow.throttleColor : "transparent"
                            Text { anchors.centerIn: parent; text: "✓"; visible: chkThrottle.checked
                                font.pixelSize: 9; color: "#000000"
                            }
                        }
                    }
                    Rectangle { width: 14; height: 14; radius: 3; color: mainWindow.throttleColor
                        border.width: 1; border.color: "#888"
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: throttleColorPicker.visible ? throttleColorPicker.close() : throttleColorPicker.open()
                        }
                    }
                }

                RowLayout { spacing: 4; Layout.fillWidth: true
                    Controls.CheckBox { id: chkBrake; text: "Brake"; checked: mainWindow.showBrake
                        padding: 0; topPadding: 2; bottomPadding: 2; Layout.fillWidth: true
                        onCheckedChanged: mainWindow.showBrake = checked
                        contentItem: Text { text: parent.text; color: mainWindow.brakeColor; font.pixelSize: 12
                            leftPadding: parent.indicator.width + 6; verticalAlignment: Text.AlignVCenter
                        }
                        indicator: Rectangle { implicitWidth: 13; implicitHeight: 13; x: 0
                            y: (parent.height - height) / 2; radius: 2
                            border.width: 1; border.color: chkBrake.checked ? mainWindow.brakeColor : "#888"
                            color: chkBrake.checked ? mainWindow.brakeColor : "transparent"
                            Text { anchors.centerIn: parent; text: "✓"; visible: chkBrake.checked
                                font.pixelSize: 9; color: "#FFFFFF"
                            }
                        }
                    }
                    Rectangle { width: 14; height: 14; radius: 3; color: mainWindow.brakeColor
                        border.width: 1; border.color: "#888"
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: brakeColorPicker.visible ? brakeColorPicker.close() : brakeColorPicker.open()
                        }
                    }
                }

                RowLayout { spacing: 4; Layout.fillWidth: true
                    Controls.CheckBox { id: chkAbs; text: "ABS"; checked: mainWindow.showAbs
                        padding: 0; topPadding: 2; bottomPadding: 2; Layout.fillWidth: true
                        onCheckedChanged: mainWindow.showAbs = checked
                        contentItem: Text { text: parent.text; color: mainWindow.absColor; font.pixelSize: 12
                            leftPadding: parent.indicator.width + 6; verticalAlignment: Text.AlignVCenter
                        }
                        indicator: Rectangle { implicitWidth: 13; implicitHeight: 13; x: 0
                            y: (parent.height - height) / 2; radius: 2
                            border.width: 1; border.color: chkAbs.checked ? mainWindow.absColor : "#888"
                            color: chkAbs.checked ? mainWindow.absColor : "transparent"
                            Text { anchors.centerIn: parent; text: "✓"; visible: chkAbs.checked
                                font.pixelSize: 9; color: "#FFFFFF"
                            }
                        }
                    }
                    Rectangle { width: 14; height: 14; radius: 3; color: mainWindow.absColor
                        border.width: 1; border.color: "#888"
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: absColorPicker.visible ? absColorPicker.close() : absColorPicker.open()
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#444"; Layout.topMargin: 2; Layout.bottomMargin: 2 }

                Controls.Label { text: "Labels"; color: "#999"; font.pixelSize: 10; font.bold: true }

                Controls.CheckBox { id: chkValues; text: "Values"; checked: mainWindow.showValues
                    padding: 0; topPadding: 2; bottomPadding: 2
                    onCheckedChanged: mainWindow.showValues = checked
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

                Controls.CheckBox { id: chkPeaks; text: "Brake peaks"; checked: mainWindow.showPeaks
                    padding: 0; topPadding: 2; bottomPadding: 2
                    onCheckedChanged: mainWindow.showPeaks = checked
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

                Controls.CheckBox { id: chkGridH; text: "Horizontal"; checked: mainWindow.showGridH
                    padding: 0; topPadding: 2; bottomPadding: 2
                    onCheckedChanged: mainWindow.showGridH = checked
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

                Controls.CheckBox { id: chkGridV; text: "Vertical"; checked: mainWindow.showGridV
                    padding: 0; topPadding: 2; bottomPadding: 2
                    onCheckedChanged: mainWindow.showGridV = checked
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
                            mainWindow.showThrottle = true
                            mainWindow.showBrake = true
                            mainWindow.showAbs = true
                            mainWindow.showGridH = false
                            mainWindow.showGridV = false
                            mainWindow.showValues = false
                            mainWindow.showPeaks = true
                            mainWindow.throttleColor = "#00FF00"
                            mainWindow.brakeColor = "#FF0000"
                            mainWindow.absColor = "#5555FF"
                            if (telemetryWinLoader.item) {
                                telemetryWinLoader.item.width = 250
                                telemetryWinLoader.item.height = 100
                                telemetryWinLoader.item.opacity = 0.9
                            }
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

    // Push settings down to the loaded telemetry window
    Binding { target: telemetryWinLoader.item; property: "showThrottle";  value: mainWindow.showThrottle;  when: telemetryWinLoader.item }
    Binding { target: telemetryWinLoader.item; property: "showBrake";     value: mainWindow.showBrake;     when: telemetryWinLoader.item }
    Binding { target: telemetryWinLoader.item; property: "showAbs";       value: mainWindow.showAbs;       when: telemetryWinLoader.item }
    Binding { target: telemetryWinLoader.item; property: "showGridH";     value: mainWindow.showGridH;     when: telemetryWinLoader.item }
    Binding { target: telemetryWinLoader.item; property: "showGridV";     value: mainWindow.showGridV;     when: telemetryWinLoader.item }
    Binding { target: telemetryWinLoader.item; property: "showValues";    value: mainWindow.showValues;    when: telemetryWinLoader.item }
    Binding { target: telemetryWinLoader.item; property: "showPeaks";     value: mainWindow.showPeaks;     when: telemetryWinLoader.item }
    Binding { target: telemetryWinLoader.item; property: "throttleColor"; value: mainWindow.throttleColor; when: telemetryWinLoader.item }
    Binding { target: telemetryWinLoader.item; property: "brakeColor";    value: mainWindow.brakeColor;    when: telemetryWinLoader.item }
    Binding { target: telemetryWinLoader.item; property: "absColor";      value: mainWindow.absColor;      when: telemetryWinLoader.item }

    Loader { id: telemetryWinLoader
        active: telemetryGraphCheck.checked
        source: "Telemetry/TelemetryWindow.qml"

        onLoaded: {
            if (item) {
                item.visible = true
                item.visibleChanged.connect(function() {
                    if (!item.visible && telemetryGraphCheck.checked) {
                        telemetryGraphCheck.checked = false
                    }
                })
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

        property alias showThrottle: mainWindow.showThrottle
        property alias showBrake: mainWindow.showBrake
        property alias showAbs: mainWindow.showAbs
        property alias showGridH: mainWindow.showGridH
        property alias showGridV: mainWindow.showGridV
        property alias showValues: mainWindow.showValues
        property alias showPeaks: mainWindow.showPeaks
        property alias throttleColor: mainWindow.throttleColor
        property alias brakeColor: mainWindow.brakeColor
        property alias absColor: mainWindow.absColor
    }
}