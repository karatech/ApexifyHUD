#include "Telemetry.h"

#ifdef USE_IRSDK

#include "irsdk_defines.h"
#include "irsdk_client.h"     // your singleton header
#endif

Telemetry::Telemetry(QObject* parent)
    : QObject(parent)
{
    connect(&m_timer, &QTimer::timeout, this, &Telemetry::tick);
    m_timer.setInterval(16);          // ~60 Hz
    m_timer.setTimerType(Qt::CoarseTimer);
}

void Telemetry::start() {
#ifndef USE_IRSDK
    m_mockLap.start();
#endif
    m_timer.start();
}

void Telemetry::resetLap() {
#ifndef USE_IRSDK
    m_mockLap.restart();
    m_currentLapTime = 0.0;
    emit currentLapTimeChanged();
#endif
}

void Telemetry::tick() {
#ifdef USE_IRSDK
    // Get the singleton
    irsdkClient& c = irsdkClient::instance();

    // Poll for new data without blocking. Returns true if a new frame (or IBT line) is ready.
    bool hasNew = c.waitForData(0);

    // Detect status/session changes and force a re-lookup of the var index.
    int status = c.getStatusID();
    if (status != m_lastStatusId) {
        m_lastStatusId = status;
        m_varIdx = -1;
    }

    if (!hasNew || !c.isConnected())
        return; // not ready or not connected yet

    // Resolve the variable index once after (re)connect/session change.
    if (m_varIdx < 0) {
        m_varIdx = c.getVarIdx("LapCurrentLapTime");
        if (m_varIdx < 0) return; // variable not available yet
    }

    // Read the value (SDK converts to requested type for us).
    float f = c.getVarFloat(m_varIdx);       // seconds
    double value = static_cast<double>(f);
    if (value < 0) value = 0.0;

    if (value != m_currentLapTime) {
        m_currentLapTime = value;
        emit currentLapTimeChanged();
    }
#else
    // Mock mode: just count up
    m_currentLapTime = m_mockLap.elapsed() / 1000.0;
    emit currentLapTimeChanged();
#endif
}
