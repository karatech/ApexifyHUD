import QtQuick 6.9
import QtQuick.Controls 6.9 as Controls

Controls.CheckBox {
    id: control

    property color accentColor: "#777"
    property color textColor: accentColor
    property color checkmarkColor: "#FFFFFF"

    padding: 0; topPadding: 2; bottomPadding: 2

    contentItem: Text {
        text: control.text; color: control.textColor; font.pixelSize: 12
        leftPadding: control.indicator.width + 6; verticalAlignment: Text.AlignVCenter
    }

    indicator: Rectangle {
        implicitWidth: 13; implicitHeight: 13; x: 0
        y: (control.height - height) / 2; radius: 2
        border.width: 1
        border.color: control.checked ? control.accentColor : "#888"
        color: control.checked ? control.accentColor : "transparent"
        Text {
            anchors.centerIn: parent; text: "✓"; visible: control.checked
            font.pixelSize: 9; color: control.checkmarkColor
        }
    }
}