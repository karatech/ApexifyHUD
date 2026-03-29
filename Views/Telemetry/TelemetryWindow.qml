import QtQuick.Controls.Material 2.15
import QtQuick 6.9
import QtQuick.Controls 6.9
import QtQuick.Layouts 6.9
import Qt.labs.settings 1.1

Window { id: root; width: 250; height: 100; x: 100; y: 100; minimumWidth: 100; minimumHeight: 50
    flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"

    // Break the link to the main window so they raise independently
    transientParent: null

    property alias showThrottle: telemetryChart.showThrottle
    property alias showBrake: telemetryChart.showBrake
    property alias showAbs: telemetryChart.showAbs
    property alias showGridH: telemetryChart.showGridH
    property alias showGridV: telemetryChart.showGridV
    property alias showPeaks: telemetryChart.showPeaks
    property alias showValues: telemetryChart.showValues
    property alias showPedalInput: pedalInput.visible
    property alias lineThickness: telemetryChart.lineThickness
    property alias throttleColor: telemetryChart.throttleColor
    property alias brakeColor: telemetryChart.brakeColor
    property alias absColor: telemetryChart.absColor

    function clampOpacity(v) { return Math.min(1.0, Math.max(0.4, v)); }

    Component.onCompleted: { root.opacity = clampOpacity(windowSettings.opacity) }

    onOpacityChanged: windowSettings.opacity = clampOpacity(root.opacity)

    Rectangle {
        id: background
        anchors.fill: parent
        color: Material.background
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        TelemetryPedalInput {
            id: pedalInput

            Layout.fillHeight: true

            throttleColor: root.throttleColor
            brakeColor: root.brakeColor
            absColor: root.absColor
        }

        Rectangle {
            id: seperator
            Layout.preferredWidth: 2
            Layout.preferredHeight: parent.height * 0.9
            color: "#444"
        }

        TelemetryChart {
            id: telemetryChart
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }


    // drag anywhere to move the *window*
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onPressed: (mouse) => {
            if (mouse.button === Qt.MiddleButton) {
                root.visible = false // Middle Click to Hide
                return
            }
            if (mouse.button === Qt.LeftButton) {
                if (mouse.modifiers & Qt.CTRL) {
                    // Ctrl + Left Click to Resize
                    root.startSystemResize(Qt.RightEdge | Qt.BottomEdge)
                } else {
                    // Normal Left Click override to Move
                    root.startSystemMove()
                }
            }
        }

        onWheel: (wheel) => {
            let step = wheel.angleDelta.y > 0 ? 0.05 : -0.05
            root.opacity = clampOpacity(root.opacity + step)
        }
    }

        Settings { id: windowSettings; category: "TelemetryWindow"

        // Using aliases automatically restores values on load and saves on change
        property alias x: root.x
        property alias y: root.y
        property alias width: root.width
        property alias height: root.height
        
        // Opacity requires custom clamping logic, so we keep it as a value property
        property real opacity: 1.0
    }
}
