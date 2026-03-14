import QtQuick 2.15
import App 1.0  // Imports our newly registered class

Rectangle { id: telemetryChart; radius: 4; anchors { fill: parent; margins: 0 } clip: true
    // Use the system palette to derive a standard background color
    SystemPalette { id: palette; colorGroup: SystemPalette.Dark }
    color: palette.window // Automatically adopts the theme's window background color
    
    property int currentThrottle: telemetryChartData ? telemetryChartData.throttle : 0
    property int currentBrake: telemetryChartData ? telemetryChartData.brake : 0

    FastTelemetryChart { id: fastChart; anchors.fill: parent; anchors.margins: 10; anchors.leftMargin: 37
        throttleColor: "#00FF00"; brakeColor: "#FF0000"; maxPoints: 500
    }

    Text { id: throttleValue; text: currentThrottle; color: "#00FF00"; font.pixelSize: 14; font.bold: true
        anchors.top: fastChart.top; anchors.topMargin: -7; anchors.left: parent.left; anchors.leftMargin: 7;
    }
    Text { id: brakeValue; text: currentBrake; color: "#FF0000"; font.pixelSize: 14; font.bold: true
        anchors.bottom: fastChart.bottom; anchors.bottomMargin: -7; anchors.left: parent.left; anchors.leftMargin: 7;
    }

    Connections {
        target: telemetryChartData
        
        function onThrottleChanged() {
            // Only append data when C++ actually has new data
            fastChart.appendData(telemetryChartData.throttle, telemetryChartData.brake)
        }
    }
}