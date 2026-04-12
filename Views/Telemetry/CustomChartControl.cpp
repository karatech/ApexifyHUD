#include "CustomChartControl.h"
#include <QPainter>
#include <QPainterPath>
#include <QPen>
#include <QPointF>
#include <QFontMetricsF>
#include <cmath>

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

void CustomChartControl::setLineThickness(qreal thickness) {
    thickness = qBound(0.2, thickness, 3.0);
    if (!qFuzzyCompare(m_lineThickness, thickness)) {
        m_lineThickness = thickness;
        emit lineThicknessChanged();
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

void CustomChartControl::paintGrid(QPainter *painter, float w, float pad, float chartH, float drawH) const {
    // solid boundary lines (0 % and 100 %) — always drawn
    QPen guidePen(kGuideColor, 1);
    painter->setPen(guidePen);
    painter->drawLine(QLineF(0, pad, w, pad));                     // 100 %
    painter->drawLine(QLineF(0, chartH - pad, w, chartH - pad));   // 0 %

    // inner grid (same colour, thinner)
    QPen gridPen(kGuideColor, 0.6, Qt::SolidLine);
    painter->setPen(gridPen);

    // horizontal lines — 3 evenly spaced (25 %, 50 %, 75 %)
    if (m_showGridH) {
        for (int i = 1; i <= kGridHLines; ++i) {
            const float y = pad + drawH - (i / static_cast<float>(kGridHLines + 1) * drawH);
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
                painter->drawLine(QLineF(x, pad, x, chartH - pad));
        }
    }
}

void CustomChartControl::paint(QPainter *painter) {
    painter->setRenderHint(QPainter::Antialiasing);

    const float totalW = width();
    const float h = height();

    const float leftPad    = 0.0f;
    const float w          = totalW - leftPad;
    const float pad        = 3.0f;
    const float annotationH = m_showPeaks ? 13.0f : 0.0f;
    const float chartH = h - annotationH;
    const float drawH = chartH - 2 * pad;  // usable height between the two guides

    // Offset all chart drawing to the right of the value labels
    painter->save();
    painter->translate(leftPad, 0);

    paintGrid(painter, w, pad, chartH, drawH);

    auto drawLine = [painter, w, pad, drawH, this](const QVector<float> &data, const QColor &color) {
        if (data.isEmpty()) return;

        QPen pen(color);
        pen.setWidthF(m_lineThickness);
        pen.setCapStyle(Qt::RoundCap);
        pen.setJoinStyle(Qt::RoundJoin);
        painter->setPen(pen);

        const float dx = data.size() > 1 ? w / static_cast<float>(m_maxPoints - 1) : 0;

        QPolygonF polygon;
        for (int i = 0; i < data.size(); ++i) {
            float x   = i * dx;
            float val = qBound(0.0f, data[i], 100.0f);
            float y   = pad + drawH - (val / 100.0f * drawH);

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

    // Throttle: always normal compositing (drawn first, nothing beneath)
    if (m_showThrottle) drawLine(m_throttleData, m_throttleColor);

    // Brake: split into segments — use CompositionMode_Plus only where it overlaps throttle
    if (m_showBrake && !m_brakeData.isEmpty()) {
        const bool canOverlap = m_showThrottle && !m_throttleData.isEmpty();

        QPen pen(m_brakeColor);
        pen.setWidthF(m_lineThickness);
        pen.setCapStyle(Qt::RoundCap);
        pen.setJoinStyle(Qt::RoundJoin);
        painter->setPen(pen);

        const int count = m_brakeData.size();
        const int tCount = m_throttleData.size();
        const float dx = count > 1 ? w / static_cast<float>(m_maxPoints - 1) : 0;

        // Tolerance in data-units matching visual line thickness on screen
        const float tolerance = (drawH > 0.0f)
            ? (m_lineThickness / drawH) * 100.0f + 1.0f
            : 1.0f;

        // Detect overlap: values are close OR the lines cross between adjacent samples
        auto isOverlap = [&](int i) -> bool {
            if (!canOverlap || i >= tCount) return false;

            const float diff = m_brakeData[i] - m_throttleData[i];

            // Values close enough that the drawn lines visually touch
            if (std::abs(diff) < tolerance) return true;

            // Lines cross in the segment leading INTO this point
            if (i > 0 && i - 1 < tCount) {
                const float prevDiff = m_brakeData[i - 1] - m_throttleData[i - 1];
                if ((prevDiff > 0.0f) != (diff > 0.0f)) return true;
            }

            // Lines cross in the segment going OUT of this point
            if (i + 1 < count && i + 1 < tCount) {
                const float nextDiff = m_brakeData[i + 1] - m_throttleData[i + 1];
                if ((diff > 0.0f) != (nextDiff > 0.0f)) return true;
            }

            return false;
        };

        QPolygonF segment;
        bool curOverlap = false;

        for (int i = 0; i < count; ++i) {
            if (m_brakeData[i] < 0.0f) {
                // Gap in ABS-filtered data — flush and skip
                if (segment.size() > 1) painter->drawPolyline(segment);
                segment.clear();
                continue;
            }

            const float x   = i * dx;
            const float val = qBound(0.0f, m_brakeData[i], 100.0f);
            const float y   = pad + drawH - (val / 100.0f * drawH);
            const QPointF pt(x, y);

            const bool overlap = isOverlap(i);

            if (segment.isEmpty()) {
                // First point of a new segment — set mode
                painter->setCompositionMode(overlap
                    ? QPainter::CompositionMode_Plus
                    : QPainter::CompositionMode_SourceOver);
                segment.append(pt);
                curOverlap = overlap;
            } else if (overlap != curOverlap) {
                // Overlap state changed — include this point to close the old segment
                segment.append(pt);
                if (segment.size() > 1) painter->drawPolyline(segment);

                // Start new segment from the same point with the new mode
                segment.clear();
                segment.append(pt);
                painter->setCompositionMode(overlap
                    ? QPainter::CompositionMode_Plus
                    : QPainter::CompositionMode_SourceOver);
                curOverlap = overlap;
            } else {
                segment.append(pt);
            }
        }

        if (segment.size() > 1) painter->drawPolyline(segment);
        painter->setCompositionMode(QPainter::CompositionMode_SourceOver);
    }

    // ABS: always normal compositing
    if (m_showAbs) drawLine(m_absData, m_absColor);

    // --- peak annotations ---
    if (m_showPeaks && m_showBrake && !m_peakAnnotations.isEmpty() && !m_brakeData.isEmpty()) {
        const float dx = w / static_cast<float>(m_maxPoints - 1);
        const int firstVisible = m_globalSampleCount - m_brakeData.size();

        QFont font;
        font.setPixelSize(11);
        font.setBold(false);
        const QFontMetricsF fm(font);

        const float textOpacity = m_lineThickness + 0.2;
        const float peakStroke  = m_lineThickness * 0.3f;

        painter->save();
        painter->setOpacity(textOpacity);

        QPen textPen(m_brakeColor);
        textPen.setJoinStyle(Qt::RoundJoin);
        if (peakStroke >= 0.5f)
            textPen.setWidthF(peakStroke);
        else
            textPen.setStyle(Qt::NoPen);
        painter->setPen(textPen);
        painter->setBrush(m_brakeColor);

        for (const auto& peak : m_peakAnnotations) {
            const int localIdx = peak.globalIndex - firstVisible;
            if (localIdx < 0 || localIdx >= m_brakeData.size()) continue;

            const float x = localIdx * dx;
            const QString text = QString::number(peak.value);
            const float textW = fm.horizontalAdvance(text);

            QPainterPath path;
            path.addText(QPointF(x - textW * 0.5f, chartH + 10.0f), font, text);
            painter->drawPath(path);
        }

        painter->restore();
    }

	painter->restore();
}
