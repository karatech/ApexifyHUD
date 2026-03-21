import QtQuick 6.9
import QtQuick.Controls.Material 2.15
import App 1.0  // Imports our newly registered class

Rectangle { id: telemetryChart; radius: 4; anchors { fill: parent; margins: 0 } clip: true
    color: telemetryChart.Material.background

    property int currentThrottle: telemetryChartVM ? telemetryChartVM.throttle : 0
    property int currentBrake: telemetryChartVM ? telemetryChartVM.brake : 0

    CustomChartControl { id: fastChart; anchors.fill: parent; anchors.margins: 10; anchors.leftMargin: 37
        throttleColor: "#00FF00"; brakeColor: "#FF0000"; absColor: "#0000BB"; maxPoints: 500
    }

    Text { id: throttleValue; text: currentThrottle; color: "#00FF00"; font.pixelSize: 14; font.bold: true
        anchors.top: fastChart.top; anchors.topMargin: -7; anchors.left: parent.left; anchors.leftMargin: 7;
    }
    Text { id: brakeValue; text: currentBrake; color: "#FF0000"; font.pixelSize: 14; font.bold: true
        anchors.bottom: fastChart.bottom; anchors.bottomMargin: -7; anchors.left: parent.left; anchors.leftMargin: 7;
    }

    Connections {
        target: telemetryChartVM
        
        function onTick() {
            // Only append data when C++ actually has new data
            fastChart.appendData(telemetryChartVM.throttle, telemetryChartVM.brake, telemetryChartVM.abs)
        }
    }
}
