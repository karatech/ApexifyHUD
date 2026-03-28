import QtQuick 6.9
import QtQuick.Controls 6.9 as Controls

Controls.CheckBox {
    id: control

    property bool compact: false
    property color accentColor: "#7F3B2E"
    property color textColor: "#CCCCCC"
    property color checkmarkColor: "#FFFFFF"

    opacity: 1; padding: 0

    contentItem: Text { opacity: control.enabled ? 1.0 : 0.38
        text: control.text; color: control.textColor
        font.pixelSize: control.compact ? 12 : 14
        leftPadding: control.indicator.width + (control.compact ? 4 : 6)
        verticalAlignment: Text.AlignVCenter
    }

    indicator: Rectangle { opacity: control.enabled ? 1.0 : 0.38
        x: 0; y: (control.height - height) / 2 + 1
        implicitWidth: control.compact ? 12 : 14; implicitHeight: control.compact ? 12 : 14
        radius: 2; border.width: 1
        border.color: control.checked ? control.accentColor : "#b0b0b0"
        color: control.checked ? control.accentColor : "transparent"
            Text { anchors.centerIn: parent
                text: "✓"; visible: control.checked
                font.pixelSize: control.compact ? 7 : 9; color: control.checkmarkColor
            }
    }
}