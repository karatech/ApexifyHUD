import QtQuick 2.15
import QtQuick.Controls 2.15

Window {
    id: root
    width: 260; height: 80
    visible: true
    color: "transparent" 

    Rectangle {
        anchors.fill: parent
        radius: height/2
        color: "#80000000"  
        border.width: 1
        border.color: "#40FFFFFF"

        Text {
            anchors.centerIn: parent
            font.pixelSize: 36; font.bold: true
            color: "white"
            text: timeToString(telemetry.currentLapTime)
        }
    }

    // drag anywhere to move the *window*
    MouseArea {
        anchors.fill: parent
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
