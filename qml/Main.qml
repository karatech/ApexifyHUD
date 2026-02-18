import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick
import QtCharts

Window { id: root; width: 250; height: 100; visible: true;
    TelemetryChart { id: telemetryChart; anchors { fill: parent } 
    }

    // drag anywhere to move the *window*
    MouseArea { anchors.fill: parent
        onPressed: root.startSystemMove(mouse);
        
    }
}