#include "FastTelemetryChart.h"
#include <QPainter>
#include <QPen>
#include <QPointF>

FastTelemetryChart::FastTelemetryChart(QQuickItem *parent) : QQuickPaintedItem(parent) {
    // Enable antialiasing out of the box for QPainter lines
    setAntialiasing(true); 
    setRenderTarget(QQuickPaintedItem::FramebufferObject); // Best performance mode
}

void FastTelemetryChart::setThrottleColor(const QColor &color) {
    if (m_throttleColor != color) {
        m_throttleColor = color;
        emit throttleColorChanged();
        update();
    }
}

void FastTelemetryChart::setBrakeColor(const QColor &color) {
    if (m_brakeColor != color) {
        m_brakeColor = color;
        emit brakeColorChanged();
        update();
    }
}

void FastTelemetryChart::setMaxPoints(int points) {
    if (m_maxPoints != points) {
        m_maxPoints = points;
        emit maxPointsChanged();
    }
}

void FastTelemetryChart::appendData(float throttle, float brake) {
    m_throttleData.append(throttle);
    m_brakeData.append(brake);

    if (m_throttleData.size() > m_maxPoints) m_throttleData.removeFirst();
    if (m_brakeData.size() > m_maxPoints) m_brakeData.removeFirst();

    update(); // Triggers a call to paint()
}

void FastTelemetryChart::paint(QPainter *painter) {
    painter->setRenderHint(QPainter::Antialiasing);

    const float w = width();
    const float h = height();

    // Draw Helper Guidelines
    QPen guidePen(QColor("#00FF00"), 1);
    painter->setPen(guidePen);
    painter->drawLine(QLineF(0, 0, w, 0)); // Top line (100%)

    guidePen.setColor(QColor("#FF0000"));
    painter->setPen(guidePen);
    painter->drawLine(QLineF(0, h, w, h)); // Bottom line (0%)

    // Helper to draw a data line
    auto drawLine = [painter, w, h, this](const QVector<float> &data, const QColor &color) {
        if (data.isEmpty()) return;

        // Set your desired thick line properties here
        QPen pen(color);
        pen.setWidth(1.2); // VERY THICK LINES
        pen.setCapStyle(Qt::RoundCap);
        pen.setJoinStyle(Qt::RoundJoin);
        painter->setPen(pen);

        const float dx = data.size() > 1 ? w / static_cast<float>(m_maxPoints - 1) : 0;
        
        QPolygonF polygon;
        for (int i = 0; i < data.size(); ++i) {
            float x = i * dx;
            float val = qBound(0.0f, data[i], 100.0f);
            float y = h - (val / 100.0f * h);
            polygon.append(QPointF(x, y));
        }

        painter->drawPolyline(polygon);
    };

    drawLine(m_throttleData, m_throttleColor);
    drawLine(m_brakeData, m_brakeColor);
}