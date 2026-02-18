import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick
import QtCharts

Window { id: root; width: 250; height: 100; visible: true; minimumWidth: 100; minimumHeight: 80;
        flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
        color: "transparent"

        TelemetryChart { id: telemetryChart; anchors.fill: parent }

        // drag anywhere to move the *window*
        MouseArea { anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            onPressed: (mouse) => {
                if (mouse.button === Qt.MiddleButton) {
                    Qt.quit()
                    return
                }
                if (mouse.button === Qt.LeftButton) {
                    if (mouse.modifiers & Qt.CTRL) {
                        // Shift + Left Click to Resize
                        root.startSystemResize(Qt.RightEdge | Qt.BottomEdge)
                    } else {
                        // Normal Left Click override to Move
                        root.startSystemMove()
                    }
                }
            }
            onWheel: (wheel) => {
                // angleDelta.y is usually 120 per notch. 
                // We use a step of 0.05 (5%) per notch.
                let step = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
                let newOpacity = root.opacity + step;
                // Clamp between 0.2 (20%) and 1.0 (100%)
                root.opacity = Math.min(1.0, Math.max(0.4, newOpacity));
            }
        }
}