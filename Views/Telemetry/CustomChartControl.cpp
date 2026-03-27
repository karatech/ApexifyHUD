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

void CustomChartControl::setShowThrottle(bool show) {
    if (m_showThrottle != show) {
        m_showThrottle = show;
        emit showThrottleChanged();
        update();
    }
}

void CustomChartControl::setShowBrake(bool show) {
    if (m_showBrake != show) {
        m_showBrake = show;
        emit showBrakeChanged();
        update();
    }
}

void CustomChartControl::setShowAbs(bool show) {
    if (m_showAbs != show) {
        m_showAbs = show;
        emit showAbsChanged();
        update();
    }
}

void CustomChartControl::setShowGridH(bool show) {
    if (m_showGridH != show) {
        m_showGridH = show;
        emit showGridHChanged();
        update();
    }
}

void CustomChartControl::setShowGridV(bool show) {
    if (m_showGridV != show) {
        m_showGridV = show;
        emit showGridVChanged();
        update();
    }
}

void CustomChartControl::setShowPeaks(bool show) {
    if (m_showPeaks != show) {
        m_showPeaks = show;
        emit showPeaksChanged();
        update();
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

void CustomChartControl::paintGrid(QPainter *painter, float w, float topPad, float chartH, float drawH) const {
    // solid boundary lines (0 % and 100 %) — always drawn
    QPen guidePen(kGuideColor, 1);
    painter->setPen(guidePen);
    painter->drawLine(QLineF(0, topPad, w, topPad));       // 100 %
    painter->drawLine(QLineF(0, chartH, w, chartH));       // 0 %

    // inner grid (same colour, thinner)
    QPen gridPen(kGuideColor, 0.6, Qt::SolidLine);
    painter->setPen(gridPen);

    // horizontal lines — 3 evenly spaced (25 %, 50 %, 75 %)
    if (m_showGridH) {
        for (int i = 1; i <= kGridHLines; ++i) {
            const float y = topPad + drawH - (i / static_cast<float>(kGridHLines + 1) * drawH);
            painter->drawLine(QLineF(0, y, w, y));
        }
    }

    // vertical lines — anchored to sample indices so they scroll with the data
    if (m_showGridV) {
        const float dx = w / static_cast<float>(m_maxPoints - 1);
        const int gridSpacing = m_maxPoints / (kGridVLines + 1);
        const int firstVisible = m_globalSampleCount - m_throttleData.size();

        // first grid line at or after the left edge
        const int firstLine = ((firstVisible / gridSpacing) + 1) * gridSpacing;

        // scan across the full viewport, not just the current data extent
        const int lastVisible = firstVisible + m_maxPoints - 1;

        for (int g = firstLine; g <= lastVisible; g += gridSpacing) {
            const float x = (g - firstVisible) * dx;
            if (x > 0.0f && x < w)
                painter->drawLine(QLineF(x, topPad, x, chartH));
        }
    }
}

void CustomChartControl::paint(QPainter *painter) {
    painter->setRenderHint(QPainter::Antialiasing);

    const float w = width();
    const float h = height();

    const float topPad     = 3.0f;
    const float annotationH = m_showPeaks ? 16.0f : 0.0f;
    const float chartH = h - annotationH;
    const float drawH = chartH - topPad;  // usable height between the two guides

    paintGrid(painter, w, topPad, chartH, drawH);

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

    painter->setCompositionMode(QPainter::CompositionMode_Plus);
    if (m_showThrottle) drawLine(m_throttleData, m_throttleColor);
    if (m_showBrake)    drawLine(m_brakeData,    m_brakeColor);
    if (m_showAbs)      drawLine(m_absData,      m_absColor);
    painter->setCompositionMode(QPainter::CompositionMode_SourceOver);

    // --- peak annotations ---
    if (m_showPeaks && m_showBrake && !m_peakAnnotations.isEmpty() && !m_brakeData.isEmpty()) {
        const float dx = w / static_cast<float>(m_maxPoints - 1);
        const int firstVisible = m_globalSampleCount - m_brakeData.size();

        QFont font;
        font.setPixelSize(11);
        font.setBold(false);
        painter->setFont(font);
        painter->setPen(m_brakeColor);
        const QFontMetricsF fm(font);

        for (const auto& peak : m_peakAnnotations) {
            const int localIdx = peak.globalIndex - firstVisible;
            if (localIdx < 0 || localIdx >= m_brakeData.size()) continue;

            const float x = localIdx * dx;
            const QString text = QString::number(peak.value);
            const float textW = fm.horizontalAdvance(text);
            painter->drawText(QPointF(x - textW * 0.5f, chartH + 15.0f), text);
        }
    }
}
