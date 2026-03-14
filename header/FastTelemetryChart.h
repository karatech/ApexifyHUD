#pragma once
#include <QQuickPaintedItem> // Changed from QQuickItem
#include <QVector>
#include <QColor>

class FastTelemetryChart : public QQuickPaintedItem { // Changed from QQuickItem
    Q_OBJECT
    Q_PROPERTY(QColor throttleColor READ throttleColor WRITE setThrottleColor NOTIFY throttleColorChanged)
    Q_PROPERTY(QColor brakeColor READ brakeColor WRITE setBrakeColor NOTIFY brakeColorChanged)
    Q_PROPERTY(int maxPoints READ maxPoints WRITE setMaxPoints NOTIFY maxPointsChanged)

public:
    FastTelemetryChart(QQuickItem *parent = nullptr);

    QColor throttleColor() const { return m_throttleColor; }
    void setThrottleColor(const QColor &color);

    QColor brakeColor() const { return m_brakeColor; }
    void setBrakeColor(const QColor &color);

    int maxPoints() const { return m_maxPoints; }
    void setMaxPoints(int points);

    Q_INVOKABLE void appendData(float throttle, float brake);

signals:
    void throttleColorChanged();
    void brakeColorChanged();
    void maxPointsChanged();

protected:
    // We override paint() instead of updatePaintNode()
    void paint(QPainter *painter) override; 

private:
    QVector<float> m_throttleData;
    QVector<float> m_brakeData;
    
    QColor m_throttleColor = QColor("#00FF00");
    QColor m_brakeColor = QColor("#FF0000");
    int m_maxPoints = 500;
};