#include "TelemetryChartVM.h"

#include "irsdk_client.h"

#include <algorithm>

using namespace ApexifyHUD::ViewModels::Telemetry;

TelemetryChartVM::TelemetryChartVM(QObject* parent)
    : QObject(parent)
{
    m_brakeWindow.reserve(kBrakeWindowSize);

    connect(&m_timer, &QTimer::timeout, this, &TelemetryChartVM::onTimerTick);
    m_timer.setInterval(16); // use 16 for ~60 Hz
    m_timer.setTimerType(Qt::CoarseTimer);
}

void TelemetryChartVM::start()
{
    m_timer.start();
}

int TelemetryChartVM::toPercent(float value01)
{
    if (value01 < 0.0f)
        value01 = 0.0f;
    if (value01 > 1.0f)
        value01 = 1.0f;

    return static_cast<int>(value01 * 100.0f + 0.5f);
}

void TelemetryChartVM::onTimerTick()
{
    irsdkClient& c = irsdkClient::instance();

    const bool hasNew = c.waitForData(0);

    const int status = c.getStatusID();
    if (status != m_lastStatusId) {
        m_lastStatusId = status;
        m_varIdxThrottle = -1;
        m_varIdxBrake = -1;
        m_varIdxAbs = -1;
    }

    if (!hasNew || !c.isConnected())
        return;

    if (m_varIdxThrottle < 0)
        m_varIdxThrottle = c.getVarIdx("Throttle");
    if (m_varIdxBrake < 0)
        m_varIdxBrake = c.getVarIdx("Brake");
    if (m_varIdxAbs < 0)
        m_varIdxAbs = c.getVarIdx("BrakeABSactive");

    if (m_varIdxThrottle >= 0) {
        const int value = toPercent(c.getVarFloat(m_varIdxThrottle));
        if (value != m_throttle) {
            m_throttle = value;
            emit throttleChanged();
        }
    }

    if (m_varIdxBrake >= 0) {
        const int value = toPercent(c.getVarFloat(m_varIdxBrake));
        if (value != m_brake) {
            m_brake = value;
            emit brakeChanged();
        }

        // Update rolling 4-second brake window
        if (m_brakeWindow.size() >= kBrakeWindowSize)
            m_brakeWindow.removeFirst();
        m_brakeWindow.append(value);

        const int newMax = *std::max_element(m_brakeWindow.cbegin(), m_brakeWindow.cend());
        if (newMax != m_maxBrake4s) {
            m_maxBrake4s = newMax;
            emit maxBrake4sChanged();
        }
    }

    if (m_varIdxAbs >= 0) {
        const bool value = c.getVarBool(m_varIdxAbs);
        if (value != m_abs) {
            m_abs = value;
            emit absChanged();
        }
    }

    emit tick();
}
