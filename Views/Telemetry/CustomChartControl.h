#pragma once
#include <QQuickPaintedItem>
#include <QVector>
#include <QColor>


namespace ApexifyHUD::Views::Telemetry
{
    struct BrakePeakAnnotation {
        int globalIndex;   // absolute sample index where the peak was detected
        int value;         // brake percentage 0–100
    };

    class CustomChartControl : public QQuickPaintedItem {
        Q_OBJECT
        Q_PROPERTY(QColor throttleColor READ throttleColor WRITE setThrottleColor NOTIFY throttleColorChanged)
        Q_PROPERTY(QColor brakeColor READ brakeColor WRITE setBrakeColor NOTIFY brakeColorChanged)
        Q_PROPERTY(QColor absColor READ absColor WRITE setAbsColor NOTIFY absColorChanged)
        Q_PROPERTY(int maxPoints READ maxPoints WRITE setMaxPoints NOTIFY maxPointsChanged)
        Q_PROPERTY(bool showThrottle READ showThrottle WRITE setShowThrottle NOTIFY showThrottleChanged)
        Q_PROPERTY(bool showBrake READ showBrake WRITE setShowBrake NOTIFY showBrakeChanged)
        Q_PROPERTY(bool showAbs READ showAbs WRITE setShowAbs NOTIFY showAbsChanged)
        Q_PROPERTY(bool showGridH READ showGridH WRITE setShowGridH NOTIFY showGridHChanged)
        Q_PROPERTY(bool showGridV READ showGridV WRITE setShowGridV NOTIFY showGridVChanged)
        Q_PROPERTY(bool showPeaks READ showPeaks WRITE setShowPeaks NOTIFY showPeaksChanged)
        Q_PROPERTY(qreal lineThickness READ lineThickness WRITE setLineThickness NOTIFY lineThicknessChanged)
        Q_PROPERTY(bool showValues READ showValues WRITE setShowValues NOTIFY showValuesChanged)

    public:
        CustomChartControl(QQuickItem* parent = nullptr);

        QColor throttleColor() const { return m_throttleColor; }
        void setThrottleColor(const QColor& color);

        QColor brakeColor() const { return m_brakeColor; }
        void setBrakeColor(const QColor& color);

        QColor absColor() const { return m_absColor; }
        void setAbsColor(const QColor& color);

        int maxPoints() const { return m_maxPoints; }
        void setMaxPoints(int points);

        bool showThrottle() const { return m_showThrottle; }
        void setShowThrottle(bool show);

        bool showBrake() const { return m_showBrake; }
        void setShowBrake(bool show);

        bool showAbs() const { return m_showAbs; }
        void setShowAbs(bool show);

        bool showGridH() const { return m_showGridH; }
        void setShowGridH(bool show);

        bool showGridV() const { return m_showGridV; }
        void setShowGridV(bool show);

        bool showPeaks() const { return m_showPeaks; }
        void setShowPeaks(bool show);

        qreal lineThickness() const { return m_lineThickness; }
        void setLineThickness(qreal thickness);

        bool showValues() const { return m_showValues; }
        void setShowValues(bool show);

        Q_INVOKABLE void appendData(float throttle, float brake, bool abs);

    signals:
        void throttleColorChanged();
        void brakeColorChanged();
        void absColorChanged();
        void maxPointsChanged();
        void showThrottleChanged();
        void showBrakeChanged();
        void showAbsChanged();
        void showGridHChanged();
        void showGridVChanged();
        void showPeaksChanged();
        void lineThicknessChanged();
        void showValuesChanged();

    protected:
        void paint(QPainter* painter) override;

    private:
        void paintGrid(QPainter* painter, float w, float pad, float chartH, float drawH) const;

        QVector<float> m_throttleData;
        QVector<float> m_brakeData;
        QVector<float> m_absData;

        QColor m_throttleColor = QColor("#00FF00");
        QColor m_brakeColor = QColor("#FF0000");
        QColor m_absColor = QColor("#0000FF");
        int m_maxPoints = 500;

        bool m_showThrottle = true;
        bool m_showBrake = true;
        bool m_showAbs = true;
        bool m_showGridH = true;
        bool m_showGridV = true;
        bool m_showPeaks = true;
        qreal m_lineThickness = 1.2;
        bool m_showValues = true;

        // Grid / guide styling
        static constexpr QColor kGuideColor  = QColor(119, 119, 119, 75);
        static constexpr int    kGridHLines  = 3;   // inner horizontal lines (25%, 50%, 75%)
        static constexpr int    kGridVLines  = 5;   // inner vertical lines

        // Peak detection — 2 s before + 2 s after at ~60 Hz
        static constexpr int kHalfWindow = 85;
        static constexpr float kMinBrake  = 10.0f;   // ignore trivial taps
        int m_globalSampleCount = 0;
        QVector<BrakePeakAnnotation> m_peakAnnotations;
    };
}
