import QtQuick 6.9

MouseArea {
    id: dragArea
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

    required property Window targetWindow
    property var snapTargets: []
    property real snapThreshold: 10

    property real _offsetX: 0
    property real _offsetY: 0
    property bool _dragging: false

    function _clampOpacity(v) { return Math.min(1.0, Math.max(0.4, v)) }

    function _snapPosition(idealX, idealY) {
        let resultX = idealX, resultY = idealY
        let w = targetWindow.width, h = targetWindow.height
        let t = snapThreshold
        let bestDx = t + 1, bestDy = t + 1

        for (let i = 0; i < snapTargets.length; ++i) {
            let s = snapTargets[i]
            if (!s || !s.visible || s === targetWindow) continue

            let sX = s.x, sY = s.y, sW = s.width, sH = s.height

            // Are the windows close enough on the perpendicular axis?
            let vClose = (idealY < sY + sH + t) && (idealY + h > sY - t)
            let hClose = (idealX < sX + sW + t) && (idealX + w > sX - t)

            if (vClose) {
                let d
                d = Math.abs((idealX + w) - sX);       if (d < t && d < bestDx) { resultX = sX - w;      bestDx = d }
                d = Math.abs(idealX - (sX + sW));       if (d < t && d < bestDx) { resultX = sX + sW;     bestDx = d }
                d = Math.abs(idealX - sX);              if (d < t && d < bestDx) { resultX = sX;           bestDx = d }
                d = Math.abs((idealX + w) - (sX + sW)); if (d < t && d < bestDx) { resultX = sX + sW - w; bestDx = d }
            }

            if (hClose) {
                let d
                d = Math.abs((idealY + h) - sY);       if (d < t && d < bestDy) { resultY = sY - h;      bestDy = d }
                d = Math.abs(idealY - (sY + sH));       if (d < t && d < bestDy) { resultY = sY + sH;     bestDy = d }
                d = Math.abs(idealY - sY);              if (d < t && d < bestDy) { resultY = sY;           bestDy = d }
                d = Math.abs((idealY + h) - (sY + sH)); if (d < t && d < bestDy) { resultY = sY + sH - h; bestDy = d }
            }
        }

        return Qt.point(resultX, resultY)
    }

    onPressed: (mouse) => {
        if (mouse.button === Qt.MiddleButton) {
            targetWindow.visible = false
            return
        }
        if (mouse.button === Qt.LeftButton) {
            if (mouse.modifiers & Qt.CTRL) {
                targetWindow.startSystemResize(Qt.RightEdge | Qt.BottomEdge)
            } else {
                _offsetX = mouse.x
                _offsetY = mouse.y
                _dragging = true
            }
        }
    }

    onPositionChanged: (mouse) => {
        if (!_dragging) return
        let g = mapToGlobal(mouse.x, mouse.y)
        let snapped = _snapPosition(g.x - _offsetX, g.y - _offsetY)
        targetWindow.x = snapped.x
        targetWindow.y = snapped.y
    }

    onReleased: (mouse) => {
        if (mouse.button === Qt.LeftButton) _dragging = false
    }

    onWheel: (wheel) => {
        let step = wheel.angleDelta.y > 0 ? 0.05 : -0.05
        targetWindow.opacity = _clampOpacity(targetWindow.opacity + step)
    }
}