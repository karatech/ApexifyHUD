import QtQuick 6.9
import QtQuick.Controls 6.9 as Controls

Controls.CheckBox {
    id: control
    opacity: 1; padding: 0
    indicator: Rectangle { opacity: control.enabled ? 1.0 : 0.38
        x: 0; y: (control.height - height) / 2 + 1
        implicitWidth: 13; implicitHeight: 13
        radius: 2; border.width: 1
        border.color: control.checked ? "#7F3B2E" : "#b0b0b0"
        color: control.checked ? "#7F3B2E" : "transparent"
        Text { anchors.centerIn: parent
            text: "✓"; visible: control.checked
            font.pixelSize: 9; color: "white"
        }
    }
}