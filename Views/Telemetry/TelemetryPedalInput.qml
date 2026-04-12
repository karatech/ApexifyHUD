import QtQuick 6.9
import QtQuick.Controls 6.9
import QtQuick.Layouts 6.9

Item {
    id: pedalInput

    property bool horizontal: false
    property bool showThrottleBar: true
    property bool showBrakeBar: true
    property bool showPedalValues: true
    property color throttleColor
    property color brakeColor
    property color absColor

    readonly property int _visibleBarCount: (showThrottleBar ? 1 : 0) + (showBrakeBar ? 1 : 0)

    // Shared bar sizing — reference dimension rotates with the bars
    readonly property real _pedalAreaSize: horizontal
        ? Math.max(parent.height * 0.17, vTextMetrics.width * 1.5)
        : Math.max(parent.width  * 0.17, vTextMetrics.width * 2.5)
    readonly property real barThickness: _pedalAreaSize * 0.35

    implicitWidth: {
        if (horizontal || _visibleBarCount === 0) return 0
        let col = Math.max(barThickness, vTextMetrics.width)
        return col * _visibleBarCount + (_visibleBarCount - 1) * 2 + 6
    }
    implicitHeight: horizontal ? hLayout.implicitHeight + 6 : 0

    TextMetrics {
        id: vTextMetrics
        font.bold: true;
        text: "100"
    }

    TextMetrics {
        id: hTextMetrics
        font { bold: true; pixelSize: 10 }
        text: "100"
    }

    // ---- Vertical mode (bars on the left) ----
    RowLayout {
        visible: !pedalInput.horizontal
        anchors.fill: parent
        anchors.margins: 3
        spacing: 2

        ColumnLayout {
            visible: pedalInput.showBrakeBar
            Layout.preferredHeight: pedalInput.height * 0.95
            spacing: 0

            Rectangle {
                id: brakebar; radius: 4

                Layout.preferredWidth: pedalInput.barThickness
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter

                border.color: telemetryChartVM.abs ? pedalInput.absColor : pedalInput.brakeColor
                border.width: 2

                color: "transparent"

                Rectangle { radius: 4
                    color: brakebar.border.color
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: parent.height * (telemetryChartVM.brake / 100)
                }
            }

            Label {
                id: brakeText
                visible: pedalInput.showPedalValues

                Layout.preferredWidth: vTextMetrics.width
                Layout.alignment: Qt.AlignHCenter

                horizontalAlignment: Label.AlignHCenter
                verticalAlignment: Label.AlignVCenter

                font.bold: true

                text: telemetryChartVM.brake
                color: brakebar.border.color
            }
        }

        ColumnLayout {
            visible: pedalInput.showThrottleBar
            Layout.preferredHeight: pedalInput.height * 0.9
            spacing: 0

            Rectangle {
                id: throttleBar; radius: 4

                Layout.preferredWidth: pedalInput.barThickness
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter

                border.color: pedalInput.throttleColor
                border.width: 2

                color: "transparent"

                Rectangle { radius: 4
                    color: throttleBar.border.color
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: parent.height * (telemetryChartVM.throttle / 100)
                }
            }

            Label {
                id: throttleText
                visible: pedalInput.showPedalValues

                Layout.preferredWidth: vTextMetrics.width
                Layout.alignment: Qt.AlignHCenter

                horizontalAlignment: Label.AlignHCenter
                verticalAlignment: Label.AlignVCenter

                font.bold: true

                text: telemetryChartVM.throttle
                color: throttleBar.border.color
            }
        }
    }

    // ---- Horizontal mode (bars on top) ----
    ColumnLayout {
        id: hLayout
        visible: pedalInput.horizontal
        anchors.fill: parent
        anchors.margins: 3
        spacing: 2

        RowLayout {
            visible: pedalInput.showBrakeBar
            Layout.fillWidth: true
            spacing: 4

            Label {
                visible: pedalInput.showPedalValues
                Layout.preferredWidth: hTextMetrics.width
                horizontalAlignment: Label.AlignRight
                verticalAlignment: Label.AlignVCenter
                font.bold: true; font.pixelSize: 10
                text: telemetryChartVM.brake
                color: brakeBarH.border.color
            }

            Rectangle {
                id: brakeBarH; radius: 4

                Layout.fillWidth: true
                Layout.preferredHeight: pedalInput.barThickness

                border.color: telemetryChartVM.abs ? pedalInput.absColor : pedalInput.brakeColor
                border.width: 2

                color: "transparent"

                Rectangle { radius: 4
                    color: brakeBarH.border.color
                    anchors.left: parent.left
                    height: parent.height
                    width: parent.width * (telemetryChartVM.brake / 100)
                }
            }
        }

        RowLayout {
            visible: pedalInput.showThrottleBar
            Layout.fillWidth: true
            spacing: 4

            Label {
                visible: pedalInput.showPedalValues
                Layout.preferredWidth: hTextMetrics.width
                horizontalAlignment: Label.AlignRight
                verticalAlignment: Label.AlignVCenter
                font.bold: true; font.pixelSize: 10
                text: telemetryChartVM.throttle
                color: pedalInput.throttleColor
            }

            Rectangle {
                id: throttleBarH; radius: 4

                Layout.fillWidth: true
                Layout.preferredHeight: pedalInput.barThickness

                border.color: pedalInput.throttleColor
                border.width: 2

                color: "transparent"

                Rectangle { radius: 4
                    color: throttleBarH.border.color
                    anchors.left: parent.left
                    height: parent.height
                    width: parent.width * (telemetryChartVM.throttle / 100)
                }
            }
        }
    }
}