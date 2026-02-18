import QtQuick 2.15
import QtCharts

ChartView { id: telemetryChart; anchors { fill: parent; margins: 0 }
    antialiasing: true;  legend.visible: false

    theme: ChartView.ChartThemeDark; clip: true

    margins {left: 30; right: 10; top: 10; bottom: 10;}

    property int currentThrottle: telemetryChartData ? telemetryChartData.throttle : 0
    property int currentBrake: telemetryChartData ? telemetryChartData.brake : 0

    // Define the X Axis (Time)
    ValueAxis { id: axisX; min: 0; max: 70
        gridVisible: false; labelsVisible: false; shadesVisible:false; visible:false
    }

    // Define the Y Axis (Value 0 to 100)
    ValueAxis { id: axisY; min: 0; max: 100
        gridVisible: false; labelsVisible: false; shadesVisible:false; visible:false
    }

    LineSeries { id: throttleLine; name: "Throttle"; axisX: axisX; axisY: axisY
        color: "#00FF00"; /* Green line */ width: 1.2
    }
    LineSeries { id: brakeLine; name: "Brake"; axisX: axisX; axisY: axisY
        color: "#FF0000"; /* Green line */ width: 1.2
    }

    // Top/bottom guide lines
    LineSeries { id: topGuideLine; name: "TopGuide"; axisX: axisX; axisY: axisY
        color: "#00FF00"; width: 0.5
    }
    LineSeries { id: bottomGuideLine; name: "BottomGuide"; axisX: axisX; axisY: axisY
        color: "#FF0000"; width: 0.5
    }

    function updateGuideLines() {
        topGuideLine.clear(); bottomGuideLine.clear();
        topGuideLine.append(axisX.min, axisY.max); topGuideLine.append(axisX.max, axisY.max);
        bottomGuideLine.append(axisX.min, axisY.min); bottomGuideLine.append(axisX.max, axisY.min);
    }

    Component.onCompleted: updateGuideLines()

    // current values overlay
    Text { id: throttleValue; text: currentThrottle; color: "#00FF00"; font.pixelSize: 14; font.bold: true
        anchors.top: parent.top; anchors.topMargin: 10; anchors.left: parent.left; anchors.leftMargin: 15;
    }
    Text { id: brakeValue; text: currentBrake; color: "#FF0000"; font.pixelSize: 14; font.bold: true
        anchors.bottom: parent.bottom; anchors.bottomMargin: 10; anchors.left: parent.left; anchors.leftMargin: 15;
    }

    Timer {
        interval: 50
        running: true; repeat: true; property int xPos1: 0; property int xPos2: 0
        onTriggered: {
            var yValue1 = currentThrottle
            var yValue2 = currentBrake

            throttleLine.append(xPos1, yValue1)
            brakeLine.append(xPos2, yValue2)

            var scrolled = false;
            if (xPos1 > axisX.max) { axisX.min++; axisX.max++; scrolled = true; }
            xPos1++;

            if (xPos2 > axisX.max) { axisX.min++; axisX.max++; scrolled = true; }
            xPos2++;

            if (scrolled) updateGuideLines();

            if (throttleLine.count > 200) { throttleLine.remove(0); }
            if (brakeLine.count > 200) { brakeLine.remove(0); }
        }
    }
}