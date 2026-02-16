import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick
import QtCharts

Window { id: root; width: 250; height: 100; visible: true; color: "black"

    TelemetryChart { id: telemetryChart; anchors { fill: parent } }

    // drag anywhere to move the *window*
    MouseArea { anchors.fill: parent
        onPressed: root.startSystemMove(mouse);
    }

    function timeToString(sec) {
        if (!sec || sec <= 0) return "--:--.---";
        var m = Math.floor(sec / 60);
        var s = sec - m*60;
        var sInt = Math.floor(s);
        var ms = Math.round((s - sInt) * 1000);
        var sStr = (sInt < 10 ? "0" : "") + sInt;
        var msStr = ms.toString().padStart(3, "0");
        return m + ":" + sStr + "." + msStr;
    }
}