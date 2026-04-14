#pragma once
#include <QObject>

#include "irsdk_defines.h"

namespace ApexifyHUD::ViewModels::Essentials
{
    class EssentialsVM : public QObject
    {
        Q_OBJECT
            Q_PROPERTY(int speed READ speed NOTIFY dataChanged)
            Q_PROPERTY(int gear READ gear NOTIFY dataChanged)
            Q_PROPERTY(double lapTimeSeconds READ lapTimeSeconds NOTIFY dataChanged)
            Q_PROPERTY(int position READ position NOTIFY dataChanged)
            Q_PROPERTY(double fuelLevel READ fuelLevel NOTIFY dataChanged)
            Q_PROPERTY(double trackTemp READ trackTemp NOTIFY dataChanged)
            Q_PROPERTY(double airTemp READ airTemp NOTIFY dataChanged)
            Q_PROPERTY(double rpmPercent READ rpmPercent NOTIFY dataChanged)

    public:
        explicit EssentialsVM(QObject* parent = nullptr);

        int speed() const { return m_speed; }
        int gear() const { return m_gear; }
        double lapTimeSeconds() const { return m_lapTimeSeconds; }
        int position() const { return m_position; }
        double fuelLevel() const { return m_fuelLevel; }
        double trackTemp() const { return m_trackTemp; }
        double airTemp() const { return m_airTemp; }
        double rpmPercent() const { return m_rpmPercent; }

    public slots:
        void onStatusChanged();
        void onDataReady();

    signals:
        void dataChanged();

    private:
        void refreshShiftLightRpm();

        int m_speed = 0;
        int m_gear = 0;
        double m_lapTimeSeconds = 0.0;
        int m_position = 0;
        double m_fuelLevel = 0.0;
        double m_trackTemp = 0.0;
        double m_airTemp = 0.0;
        double m_rpmPercent = 0.0;

        int m_varIdxSpeed = -1;
        int m_varIdxGear = -1;
        int m_varIdxLapTime = -1;
        int m_varIdxPosition = -1;
        int m_varIdxFuelLevel = -1;
        int m_varIdxTrackTemp = -1;
        int m_varIdxAirTemp = -1;
        int m_varIdxRpm = -1;

        bool m_sessionInfoRead = false;

        float m_slFirstRpm = 3000.0f;
        float m_slBlinkRpm = 8000.0f;
    };
}