#include "TelemetryChartVM.h"

#include "irsdk_client.h"

using namespace ApexifyHUD::ViewModels::Telemetry;

TelemetryChartVM::TelemetryChartVM(QObject* parent)
    : QObject(parent)
{
}

int TelemetryChartVM::toPercent(float value01)
{
    if (value01 < 0.0f)
        value01 = 0.0f;
    if (value01 > 1.0f)
        value01 = 1.0f;

    return static_cast<int>(value01 * 100.0f + 0.5f);
}

void TelemetryChartVM::onStatusChanged()
{
    m_varIdxThrottle = -1;
    m_varIdxBrake = -1;
    m_varIdxAbs = -1;
}

void TelemetryChartVM::onDataReady()
{
    irsdkClient& c = irsdkClient::instance();

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
