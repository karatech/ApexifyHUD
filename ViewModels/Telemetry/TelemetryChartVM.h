#pragma once
#include <QObject>
#include <QTimer>
#include <QVector>

#include "irsdk_defines.h"

namespace ApexifyHUD::ViewModels::Telemetry
{
    class TelemetryChartVM : public QObject
    {
        Q_OBJECT
            Q_PROPERTY(int throttle READ throttle NOTIFY throttleChanged)
            Q_PROPERTY(int brake READ brake NOTIFY brakeChanged)
            Q_PROPERTY(bool abs READ abs NOTIFY absChanged)
            Q_PROPERTY(int maxBrake4s READ maxBrake4s NOTIFY maxBrake4sChanged)

    public:
        explicit TelemetryChartVM(QObject* parent = nullptr);

        int throttle() const { return m_throttle; }
        int brake() const { return m_brake; }
        bool abs() const { return m_abs; }
        int maxBrake4s() const { return m_maxBrake4s; }

        void start();

    signals:
        // Emitted after a tick updates the properties
        void tick();

        void throttleChanged();
        void brakeChanged();
        void absChanged();
        void maxBrake4sChanged();

    private slots:
        void onTimerTick();

    private:
        static int toPercent(float value01);

        QTimer m_timer;
        int m_throttle = 0;
        int m_brake = 0;
        bool m_abs = false;
        int m_maxBrake4s = 0;

        // Rolling window of brake samples (~250 entries at 60 Hz = 4 seconds)
        static constexpr int kBrakeWindowSize = 250;
        QVector<int> m_brakeWindow;

        int m_varIdxThrottle = -1;
        int m_varIdxBrake = -1;
        int m_varIdxAbs = -1;
        int m_lastStatusId = -1;
    };
}
