#pragma once
#include <QObject>

#include "irsdk_defines.h"

namespace ApexifyHUD::ViewModels::Telemetry
{
    class TelemetryChartVM : public QObject
    {
        Q_OBJECT
            Q_PROPERTY(int throttle READ throttle NOTIFY throttleChanged)
            Q_PROPERTY(int brake READ brake NOTIFY brakeChanged)
            Q_PROPERTY(bool abs READ abs NOTIFY absChanged)

    public:
        explicit TelemetryChartVM(QObject* parent = nullptr);

        int throttle() const { return m_throttle; }
        int brake() const { return m_brake; }
        bool abs() const { return m_abs; }

    public slots:
        void onStatusChanged();
        void onDataReady();

    signals:
        void tick();

        void throttleChanged();
        void brakeChanged();
        void absChanged();

    private:
        static int toPercent(float value01);

        int m_throttle = 0;
        int m_brake = 0;
        bool m_abs = false;

        int m_varIdxThrottle = -1;
        int m_varIdxBrake = -1;
        int m_varIdxAbs = -1;
    };
}
