import QtQuick 6.9
import QtQuick.Controls 6.9
import QtQuick.Layouts 6.9

Item {
    id: pedalInput

    property color throttleColor
    property color brakeColor
    property color absColor

    implicitWidth: Math.max(parent.width * 0.17, textMetrics.width * 2.5)

    TextMetrics {
        id: textMetrics
        font.bold: true
        text: "100"
    }

    RowLayout {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        ColumnLayout {
            Layout.preferredHeight: pedalInput.height * 0.95
            spacing: 0

            Rectangle {
                id: brakebar

                Layout.preferredWidth: pedalInput.width * 0.35
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter

                border.color: telemetryChartVM.abs ? pedalInput.absColor : pedalInput.brakeColor
                border.width: 2

                color: "transparent"

                Rectangle {
                    color: brakebar.border.color
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: parent.height * (telemetryChartVM.brake / 100)
                }
            }

            Label {
                id: brakeText

                Layout.preferredWidth: textMetrics.width
                Layout.alignment: Qt.AlignHCenter

                horizontalAlignment: Label.AlignHCenter
                verticalAlignment: Label.AlignVCenter

                font.bold: true

                text: telemetryChartVM.brake
                color: brakebar.border.color
            }
        }

        ColumnLayout {
            Layout.preferredHeight: pedalInput.height * 0.9
            spacing: 0

            Rectangle {
                id: throttleBar

                Layout.preferredWidth: pedalInput.width * 0.35
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter

                border.color: pedalInput.throttleColor
                border.width: 2

                color: "transparent"

                Rectangle {
                    color: throttleBar.border.color
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: parent.height * (telemetryChartVM.throttle / 100)
                }
            }

            Label {
                id: throttleText

                Layout.preferredWidth: textMetrics.width
                Layout.alignment: Qt.AlignHCenter

                horizontalAlignment: Label.AlignHCenter
                verticalAlignment: Label.AlignVCenter

                font.bold: true

                text: telemetryChartVM.throttle
                color: throttleBar.border.color
            }
        }
    }
}
