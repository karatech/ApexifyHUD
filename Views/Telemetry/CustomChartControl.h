#pragma once
#include <QQuickPaintedItem> // Changed from QQuickItem
#include <QVector>
#include <QColor>


namespace ApexifyHUD::Views::Telemetry
{
    class CustomChartControl : public QQuickPaintedItem { // Changed from QQuickItem
        Q_OBJECT
        Q_PROPERTY(QColor throttleColor READ throttleColor WRITE setThrottleColor NOTIFY throttleColorChanged)
        Q_PROPERTY(QColor brakeColor READ brakeColor WRITE setBrakeColor NOTIFY brakeColorChanged)
        Q_PROPERTY(QColor absColor READ absColor WRITE setAbsColor NOTIFY absColorChanged)
        Q_PROPERTY(int maxPoints READ maxPoints WRITE setMaxPoints NOTIFY maxPointsChanged)

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

        Q_INVOKABLE void appendData(float throttle, float brake, bool abs);

    signals:
        void throttleColorChanged();
        void brakeColorChanged();
        void absColorChanged();
        void maxPointsChanged();

    protected:
        // We override paint() instead of updatePaintNode()
        void paint(QPainter* painter) override;

    private:
        QVector<float> m_throttleData;
        QVector<float> m_brakeData;
        QVector<float> m_absData;

        QColor m_throttleColor = QColor("#00FF00");
        QColor m_brakeColor = QColor("#FF0000");
        QColor m_absColor = QColor("#0000FF");
        int m_maxPoints = 500;
    };
}
