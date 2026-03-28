import QtQuick 6.9
import QtQuick.Controls.Material 2.15
import App 1.0  // Imports our newly registered class

Rectangle { id: telemetryChart; radius: 4; anchors { fill: parent; margins: 0 } clip: true
    color: telemetryChart.Material.background

    property int currentThrottle: telemetryChartVM ? telemetryChartVM.throttle : 0
    property int currentBrake: telemetryChartVM ? telemetryChartVM.brake : 0

    property alias showThrottle: fastChart.showThrottle
    property alias showBrake: fastChart.showBrake
    property alias showAbs: fastChart.showAbs
    property alias showGridH: fastChart.showGridH
    property alias showGridV: fastChart.showGridV
    property alias showPeaks: fastChart.showPeaks
    property alias lineThickness: fastChart.lineThickness
    property bool showValues: true
    property alias throttleColor: fastChart.throttleColor
    property alias brakeColor: fastChart.brakeColor
    property alias absColor: fastChart.absColor

    CustomChartControl { id: fastChart; anchors.fill: parent; anchors.margins: 3;
        anchors.leftMargin: telemetryChart.showValues ? 37 : 3
        maxPoints: 500
    }

    Text { id: throttleValue; text: currentThrottle; color: telemetryChart.throttleColor; font.pixelSize: 14; font.bold: true
        visible: telemetryChart.showValues
        anchors.top: fastChart.top; anchors.topMargin: -7; anchors.left: parent.left; anchors.leftMargin: 7;
    }
    Text { id: brakeValue; text: currentBrake; color: telemetryChart.brakeColor; font.pixelSize: 14; font.bold: true
        visible: telemetryChart.showValues
        anchors.bottom: fastChart.bottom; anchors.bottomMargin: (fastChart.showPeaks ? 13 : 0) - 6; anchors.left: parent.left; anchors.leftMargin: 7;
    }

    Connections {
        target: telemetryChartVM

        function onTick() {
            fastChart.appendData(telemetryChartVM.throttle, telemetryChartVM.brake, telemetryChartVM.abs)
        }
    }
}