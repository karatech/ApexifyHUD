import QtQuick 2.15
import QtCharts

ChartView { id: telemetryChart; anchors { fill: parent; margins: -9 }
    antialiasing: true;  legend.visible: false
    backgroundColor: "gray"; plotAreaColor: "transparent"
    theme: ChartView.ChartThemeDark; backgroundRoundness: 10
    dropShadowEnabled: false; clip: true 

    // Define the X Axis (Time)
    ValueAxis { id: axisX; min: 0; max: 10; labelFormat: "%.0f"; labelsColor: "red"
        gridVisible: false; labelsVisible: false; shadesVisible:false; visible:false
    }

    // Define the Y Axis (Value 0 to 100)
    ValueAxis { id: axisY; min: 0; max: 100; labelFormat: "%.0f"; labelsColor: "red"
        gridVisible: false; labelsVisible: false; shadesVisible:false; visible:false
    }

    LineSeries { id: throttleLine; name: "Throttle"; axisX: axisX; axisY: axisY
        color: "#00FF00"; /* Green line */ width: 1.2
    }
    LineSeries { id: brakeLine; name: "Brake"; axisX: axisX; axisY: axisY
        color: "#FF0000"; /* Green line */ width: 1.2
    }

    // --- MOCK DATA GENERATOR (Remove this when connecting to C++) ---
    Timer {
        interval: 500 // Update every 25ms
        running: true; repeat: true; property int xPos1: 0; property int xPos2: 0
        onTriggered: {
            // Generate a random value between 0 and 100
            var yValue1 = Math.random() * 100;
            var yValue2 = Math.random() * 100;

            // Add point to line
            throttleLine.append(xPos1, yValue1);
            brakeLine.append(xPos2, yValue2);

            // Scroll the graph: Move X axis window
            if (xPos1 > axisX.max) { axisX.min++; axisX.max++; }
            xPos1++;

            // Scroll the graph: Move X axis window
            if (xPos2 > axisX.max) { axisX.min++; axisX.max++; }
            xPos2++;

            // Optional: Keep memory low by removing old points
            if (throttleLine.count > 200) { throttleLine.remove(0); }
        }
    }
}