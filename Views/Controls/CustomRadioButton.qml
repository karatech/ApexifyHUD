import QtQuick 6.9
import QtQuick.Controls 6.9 as Controls

Controls.RadioButton {
    id: control
    opacity: 1; padding: 0; spacing: 8

    indicator: Rectangle {
        opacity: control.enabled ? 1.0 : 0.38
        x: 0; y: (control.height - height) / 2 + 1
        implicitWidth: 13; implicitHeight: 13
        radius: width / 2
        border.width: 1
        border.color: control.checked ? "#7F3B2E" : "#b0b0b0"
        color: control.checked ? "#7F3B2E" : "transparent"

        Rectangle {
            anchors.centerIn: parent; width: 5; height: 5
            radius: width / 2; visible: control.checked
            color: "white"
        }
    }

    contentItem: Text {
        text: control.text; color: "white"; font: control.font; verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing; elide: Text.ElideRight
    }
}