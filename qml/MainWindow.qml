

import QtQuick.Controls.Material 2.15
import Qt.labs.settings 1.0
import Qt.labs.folderlistmodel 2.15
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

    property string selectedIbtFileName: ""

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
        opacity: 1
        padding: 0
        spacing: 8

        indicator: Rectangle {
            opacity: control.enabled ? 1.0 : 0.38
            x: 0
            y: (control.height - height) / 2 + 1
            implicitWidth: 13
            implicitHeight: 13
            radius: width / 2
            border.width: 1
            border.color: control.checked ? "#7F3B2E" : "#b0b0b0"
            color: control.checked ? "#7F3B2E" : "transparent"

            Rectangle {
                anchors.centerIn: parent
                width: 5; height: 5
                radius: width / 2
                visible: control.checked
                color: "white"
            }
        }

        contentItem: Text {
            text: control.text
            color: "white"
            font: control.font
            verticalAlignment: Text.AlignVCenter
            leftPadding: control.indicator.width + control.spacing
            elide: Text.ElideRight
        }
    }

    FolderListModel {
        id: ibtFilesModel
        folder: ibtLogFolderUrl
        nameFilters: ["*.ibt"]   // remove this line if you want all files
        showDirs: false
        showDotAndDotDot: false
        sortField: FolderListModel.Name
    }

    Controls.ButtonGroup {
        id: ibtButtonGroup
    }

    Column {
        anchors.fill: parent; anchors.margins: 16; spacing: 12
        CustomCheckBox { id: telemetryGraphCheck; text: "Telemetry Graph"; enabled: true
            onCheckedChanged: {
                telemetryWinLoader.active = checked
                if (checked && telemetryWinLoader.item) telemetryWinLoader.item.visible = true
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

        Controls.Label {
            text: "IBT log files"
            color: "white"
            font.bold: true
        }

        Rectangle {
            width: parent.width
            height: 240
            radius: 4
            color: "transparent"
            border.color: "transparent"

            ListView {
                id: ibtListView
                anchors.fill: parent
                anchors.margins: 8
                clip: true
                model: ibtFilesModel

                delegate: CustomRadioButton {
                    required property string fileName

                    ButtonGroup.group: ibtButtonGroup
                    text: fileName
                    checked: mainWindow.selectedIbtFileName === fileName
                    width: ibtListView.width
                    onToggled: {
                        if (checked) mainWindow.selectedIbtFileName = fileName
                    }
                }
            }
        }

        Controls.Label {
            visible: mainWindow.selectedIbtFileName.length > 0
            text: "Selected: " + mainWindow.selectedIbtFileName
            color: "#BBBBBB"
            wrapMode: Text.WrapAnywhere
        }

        Controls.Label {
            visible: ibtFilesModel.count === 0
            text: "No .ibt files found in: " + ibtLogFolderUrl
            color: "#BBBBBB"
            wrapMode: Text.WrapAnywhere
        }
    }



    Loader {
        id: telemetryWinLoader
        active: telemetryGraphCheck.checked
        source: "TelemetryWindow.qml"

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
    }
}