import QtQuick.Controls.Material 2.15
import Qt.labs.settings 1.0
import Qt.labs.folderlistmodel 2.15
import QtQuick 6.9
import QtQuick.Controls 6.9 as Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "Controls"
import "Telemetry" as Telemetry

ApplicationWindow { id: mainWindow; title: "ApexifyHUD"
    width: 640; height: 800; visible: true; minimumHeight: 500; minimumWidth: 470

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

    // --- Telemetry settings popup (extracted) ---
    Telemetry.TelemetrySettingsPopup { id: settingsPopup
        settings: mainWindow
        x: settingsBtn.x + 16; y: settingsBtn.y + settingsBtn.height + 20
        onTelemetryWindowResetRequested: {
            if (telemetryWinLoader.item) {
                telemetryWinLoader.item.width = 250
                telemetryWinLoader.item.height = 100
                telemetryWinLoader.item.opacity = 0.9
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