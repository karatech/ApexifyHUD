import QtQuick.Controls.Material 2.15
import QtQuick 6.9
import QtQuick.Controls 6.9
import QtQuick.Layouts 6.9
import Qt.labs.settings 1.1
import App 1.0

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
    property bool horizontalPedalInput: false
    property bool showThrottleBar: true
    property bool showBrakeBar: true
    property bool showPedalValues: true
    property alias lineThickness: telemetryChart.lineThickness
    property alias throttleColor: telemetryChart.throttleColor
    property alias brakeColor: telemetryChart.brakeColor
    property alias absColor: telemetryChart.absColor
    property color backgroundColor: "#1E1E1E"

    readonly property bool _anyBarVisible: root.showThrottleBar || root.showBrakeBar

    function clampOpacity(v) { return Math.min(1.0, Math.max(0.4, v)); }
    Component.onCompleted: { root.opacity = clampOpacity(windowSettings.opacity) }
    onOpacityChanged: windowSettings.opacity = clampOpacity(root.opacity)

    // Resize the window when switching pedal input orientation so bars keep their thickness
    onHorizontalPedalInputChanged: {
        if (!_anyBarVisible) return
        let pedalW = Math.max(root.width * 0.17, 60)
        let barT   = pedalW * 0.35
        let hDelta = Math.round(2 * barT + 9)   // two bars + spacing + margins + separator
        let wDelta = Math.round(pedalW + 11)     // pedal area + vertical separator

        if (horizontalPedalInput) {
            root.width  = Math.max(root.minimumWidth,  root.width  - wDelta)
            root.height += hDelta
        } else {
            root.width  += wDelta
            root.height = Math.max(root.minimumHeight, root.height - hDelta)
        }
    }

    Rectangle { id: telemetryRectangle; radius: 4; clip: true
        anchors.fill: parent; color: root.backgroundColor

        ColumnLayout { anchors.fill: parent; spacing: 0

            // ---- Horizontal pedal bars (top) ----
            TelemetryPedalInput {
                visible: root._anyBarVisible && root.horizontalPedalInput
                horizontal: true
                showThrottleBar: root.showThrottleBar
                showBrakeBar: root.showBrakeBar
                showPedalValues: root.showPedalValues
                Layout.fillWidth: true
                throttleColor: root.throttleColor; brakeColor: root.brakeColor; absColor: root.absColor
            }
            Rectangle {
                visible: root._anyBarVisible && root.horizontalPedalInput
                Layout.fillWidth: true
                Layout.leftMargin: 6; Layout.rightMargin: 6
                Layout.preferredHeight: 1
                color: Qt.rgba(1, 1, 1, 0.3)
            }

            // ---- Chart row (with optional vertical pedal bars on the left) ----
            RowLayout { Layout.fillWidth: true; Layout.fillHeight: true; spacing: 0
                TelemetryPedalInput {
                    visible: root._anyBarVisible && !root.horizontalPedalInput
                    horizontal: false
                    showThrottleBar: root.showThrottleBar
                    showBrakeBar: root.showBrakeBar
                    showPedalValues: root.showPedalValues
                    Layout.fillHeight: true
                    throttleColor: root.throttleColor; brakeColor: root.brakeColor; absColor: root.absColor
                }
                Rectangle {
                    visible: root._anyBarVisible && !root.horizontalPedalInput
                    Layout.fillHeight: true
                    Layout.margins: 5
                    Layout.preferredWidth: 1
                    color: Qt.rgba(1, 1, 1, 0.3)
                }
                CustomChartControl { id: telemetryChart; Layout.fillHeight: true; Layout.fillWidth: true; Layout.margins: 3; maxPoints: 500
                }
                Connections { target: telemetryChartVM
                    function onTick() {
                        telemetryChart.appendData(telemetryChartVM.throttle, telemetryChartVM.brake, telemetryChartVM.abs)
                    }
                }
            }
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