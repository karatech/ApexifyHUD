#include "EssentialsVM.h"

#include "irsdk_defines.h"
#include "irsdk_client.h"

#include <cstdlib>

using namespace ApexifyHUD::ViewModels::Essentials;

EssentialsVM::EssentialsVM(QObject* parent)
    : QObject(parent)
{
}

void EssentialsVM::refreshShiftLightRpm()
{
    irsdkClient& c = irsdkClient::instance();
    char val[64] = {};

    if (c.getSessionStrVal("DriverInfo:DriverCarSLFirstRPM:", val, sizeof(val)) > 0) {
        float v = static_cast<float>(std::atof(val));
        if (v > 0.0f) m_slFirstRpm = v;
    }

    val[0] = '\0';
    if (c.getSessionStrVal("DriverInfo:DriverCarSLBlinkRPM:", val, sizeof(val)) > 0) {
        float v = static_cast<float>(std::atof(val));
        if (v > 0.0f) m_slBlinkRpm = v;
    }
}

void EssentialsVM::onStatusChanged()
{
    m_varIdxSpeed = -1;
    m_varIdxGear = -1;
    m_varIdxLapTime = -1;
    m_varIdxPosition = -1;
    m_varIdxFuelLevel = -1;
    m_varIdxTrackTemp = -1;
    m_varIdxAirTemp = -1;
    m_varIdxRpm = -1;
    m_sessionInfoRead = false;
}

void EssentialsVM::onDataReady()
{
    irsdkClient& c = irsdkClient::instance();

    if (!m_sessionInfoRead) {
        refreshShiftLightRpm();
        m_sessionInfoRead = true;
    }

    if (m_varIdxSpeed < 0)     m_varIdxSpeed = c.getVarIdx("Speed");
    if (m_varIdxGear < 0)      m_varIdxGear = c.getVarIdx("Gear");
    if (m_varIdxLapTime < 0)   m_varIdxLapTime = c.getVarIdx("LapCurrentLapTime");
    if (m_varIdxPosition < 0)  m_varIdxPosition = c.getVarIdx("PlayerCarPosition");
    if (m_varIdxFuelLevel < 0) m_varIdxFuelLevel = c.getVarIdx("FuelLevel");
    if (m_varIdxTrackTemp < 0) m_varIdxTrackTemp = c.getVarIdx("TrackTempCrew");
    if (m_varIdxAirTemp < 0)   m_varIdxAirTemp = c.getVarIdx("AirTemp");
    if (m_varIdxRpm < 0)       m_varIdxRpm = c.getVarIdx("RPM");

    bool changed = false;

    if (m_varIdxSpeed >= 0) {
        const int v = static_cast<int>(c.getVarFloat(m_varIdxSpeed) * 3.6f + 0.5f);
        if (v != m_speed) { m_speed = v; changed = true; }
    }

    if (m_varIdxGear >= 0) {
        const int v = c.getVarInt(m_varIdxGear);
        if (v != m_gear) { m_gear = v; changed = true; }
    }

    if (m_varIdxLapTime >= 0) {
        const double v = static_cast<double>(c.getVarFloat(m_varIdxLapTime));
        if (v != m_lapTimeSeconds) { m_lapTimeSeconds = v; changed = true; }
    }

    if (m_varIdxPosition >= 0) {
        const int v = c.getVarInt(m_varIdxPosition);
        if (v != m_position) { m_position = v; changed = true; }
    }

    if (m_varIdxFuelLevel >= 0) {
        const double v = static_cast<double>(c.getVarFloat(m_varIdxFuelLevel));
        if (v != m_fuelLevel) { m_fuelLevel = v; changed = true; }
    }

    if (m_varIdxTrackTemp >= 0) {
        const double v = static_cast<double>(c.getVarFloat(m_varIdxTrackTemp));
        if (v != m_trackTemp) { m_trackTemp = v; changed = true; }
    }

    if (m_varIdxAirTemp >= 0) {
        const double v = static_cast<double>(c.getVarFloat(m_varIdxAirTemp));
        if (v != m_airTemp) { m_airTemp = v; changed = true; }
    }

    if (m_varIdxRpm >= 0) {
        const float rpm = c.getVarFloat(m_varIdxRpm);
        const float range = m_slBlinkRpm - m_slFirstRpm;
        double pct = 0.0;
        if (range > 0.0f) {
            pct = static_cast<double>((rpm - m_slFirstRpm) / range);
            if (pct < 0.0) pct = 0.0;
            if (pct > 1.0) pct = 1.0;
        }
        if (pct != m_rpmPercent) { m_rpmPercent = pct; changed = true; }
    }

    if (changed)
        emit dataChanged();
}