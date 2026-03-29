import QtQuick 6.9
import QtQuick.Controls.Material 2.15
import App 1.0  // Imports our newly registered class

Rectangle { id: telemetryChart; radius: 4; clip: true
    color: telemetryChart.Material.background

    property alias showThrottle: fastChart.showThrottle
    property alias showBrake: fastChart.showBrake
    property alias showAbs: fastChart.showAbs
    property alias showGridH: fastChart.showGridH
    property alias showGridV: fastChart.showGridV
    property alias showPeaks: fastChart.showPeaks
    property alias lineThickness: fastChart.lineThickness
    property alias showValues: fastChart.showValues
    property alias throttleColor: fastChart.throttleColor
    property alias brakeColor: fastChart.brakeColor
    property alias absColor: fastChart.absColor

    CustomChartControl { id: fastChart; anchors.fill: parent; anchors.margins: 3
        maxPoints: 500
    }

    Connections {
        target: telemetryChartVM

        function onTick() {
            fastChart.appendData(telemetryChartVM.throttle, telemetryChartVM.brake, telemetryChartVM.abs)
        }
    }
}
