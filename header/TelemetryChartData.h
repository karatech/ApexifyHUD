#pragma once
#include <QObject>
#include <QTimer>

#include "irsdk_defines.h"


class TelemetryChartData : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int throttle READ throttle NOTIFY throttleChanged)
    Q_PROPERTY(int brake READ brake NOTIFY brakeChanged)

public:
    explicit TelemetryChartData(QObject* parent = nullptr);

    int throttle() const { return m_throttle; }
    int brake() const { return m_brake; }

    void start();

signals:
    void throttleChanged();
    void brakeChanged();

private slots:
    void tick();

private:
    static int toPercent(float value01);

    QTimer m_timer;
    int m_throttle = 0;
    int m_brake = 0;


    int m_varIdxThrottle = -1;
    int m_varIdxBrake = -1;
    int m_lastStatusId = -1;

};