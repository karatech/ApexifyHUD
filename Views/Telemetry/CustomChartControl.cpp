#include "CustomChartControl.h"
#include <QPainter>
#include <QPen>
#include <QPointF>
#include <QFontMetricsF>

using namespace ApexifyHUD::Views::Telemetry;

CustomChartControl::CustomChartControl(QQuickItem *parent) : QQuickPaintedItem(parent) {
    setAntialiasing(true);
    setRenderTarget(QQuickPaintedItem::FramebufferObject);
}

void CustomChartControl::setThrottleColor(const QColor &color) {
    if (m_throttleColor != color) {
        m_throttleColor = color;
        emit throttleColorChanged();
        update();
    }
}

void CustomChartControl::setBrakeColor(const QColor &color) {
    if (m_brakeColor != color) {
        m_brakeColor = color;
        emit brakeColorChanged();
        update();
    }
}

void CustomChartControl::setAbsColor(const QColor &color)
{
    if (m_absColor != color) {
        m_absColor = color;
        emit absColorChanged();
        update();
    }
}

void CustomChartControl::setMaxPoints(int points) {
    if (m_maxPoints != points) {
        m_maxPoints = points;
        emit maxPointsChanged();
    }
}

void CustomChartControl::appendData(float throttle, float brake, bool abs) {
    m_throttleData.append(throttle);
    m_brakeData.append(brake);
    m_absData.append(abs ? brake : -1.0f);

    if (m_throttleData.size() > m_maxPoints) m_throttleData.removeFirst();
    if (m_brakeData.size() > m_maxPoints) m_brakeData.removeFirst();
    if (m_absData.size() > m_maxPoints) m_absData.removeFirst();

    m_globalSampleCount++;

    // --- confirmed-peak detection (2 s look-back + 2 s look-ahead) ---
    if (m_brakeData.size() >= 2 * kHalfWindow + 1) {
        const int candidateLocal = m_brakeData.size() - 1 - kHalfWindow;
        const float candidateVal = m_brakeData[candidateLocal];

        if (candidateVal >= kMinBrake) {
            const int winStart = candidateLocal - kHalfWindow;
            const int winEnd   = candidateLocal + kHalfWindow;

            bool isMax = true;
            for (int i = winStart; i <= winEnd; ++i) {
                if (i != candidateLocal && m_brakeData[i] > candidateVal) {
                    isMax = false;
                    break;
                }
            }

            if (isMax) {
                const int globalIdx = m_globalSampleCount - 1 - kHalfWindow;
                // avoid duplicate annotations for equal-value plateaus
                if (m_peakAnnotations.isEmpty() ||
                    (globalIdx - m_peakAnnotations.last().globalIndex) >= kHalfWindow) {
                    m_peakAnnotations.append({ globalIdx, static_cast<int>(candidateVal + 0.5f) });
                }
            }
        }
    }

    // discard annotations that scrolled past the left edge
    const int firstVisible = m_globalSampleCount - m_brakeData.size();
    while (!m_peakAnnotations.isEmpty() && m_peakAnnotations.first().globalIndex < firstVisible)
        m_peakAnnotations.removeFirst();

    update();
}

void CustomChartControl::paint(QPainter *painter) {
    painter->setRenderHint(QPainter::Antialiasing);

    const float w = width();
    const float h = height();

    const float topPad     = 3.0f;
    const float annotationH = 16.0f;
    const float chartH = h - annotationH;

    QPen guidePen(QColor(119, 119, 119, 75), 1);
    painter->setPen(guidePen);
    painter->drawLine(QLineF(0, topPad, w, topPad));       // 100 %
    painter->drawLine(QLineF(0, chartH, w, chartH));       // 0 %

    const float drawH = chartH - topPad;  // usable height between the two guides

    auto drawLine = [painter, w, topPad, drawH, this](const QVector<float> &data, const QColor &color) {
        if (data.isEmpty()) return;

        QPen pen(color);
        pen.setWidth(2);
        pen.setCapStyle(Qt::RoundCap);
        pen.setJoinStyle(Qt::RoundJoin);
        painter->setPen(pen);

        const float dx = data.size() > 1 ? w / static_cast<float>(m_maxPoints - 1) : 0;

        QPolygonF polygon;
        for (int i = 0; i < data.size(); ++i) {
            float x   = i * dx;
            float val = qBound(0.0f, data[i], 100.0f);
            float y   = topPad + drawH - (val / 100.0f * drawH);

            if (data[i] >= 0.0f)
            {
                polygon.append(QPointF(x, y));
            }
            else if (polygon.size() > 1)
            {
                painter->drawPolyline(polygon);
                polygon.clear();
            }
        }

        painter->drawPolyline(polygon);
    };

    drawLine(m_throttleData, m_throttleColor);
    drawLine(m_brakeData,    m_brakeColor);
    drawLine(m_absData,      m_absColor);

    // --- peak annotations ---
    if (!m_peakAnnotations.isEmpty() && !m_brakeData.isEmpty()) {
        const float dx = w / static_cast<float>(m_maxPoints - 1);
        const int firstVisible = m_globalSampleCount - m_brakeData.size();

        QFont font;
        font.setPixelSize(11);
        font.setBold(true);
        painter->setFont(font);
        painter->setPen(m_brakeColor);
        const QFontMetricsF fm(font);

        for (const auto& peak : m_peakAnnotations) {
            const int localIdx = peak.globalIndex - firstVisible;
            if (localIdx < 0 || localIdx >= m_brakeData.size()) continue;

            const float x = localIdx * dx;
            const QString text = QString::number(peak.value) + "%";
            const float textW = fm.horizontalAdvance(text);
            painter->drawText(QPointF(x - textW * 0.5f, chartH + 15.0f), text);
        }
    }
}
