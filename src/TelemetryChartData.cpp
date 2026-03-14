#include "TelemetryChartData.h"

#include "irsdk_client.h"

TelemetryChartData::TelemetryChartData(QObject* parent)
    : QObject(parent)
{
    connect(&m_timer, &QTimer::timeout, this, &TelemetryChartData::tick);
    m_timer.setInterval(5); // use 16 for ~60 Hz
    m_timer.setTimerType(Qt::CoarseTimer);
}

void TelemetryChartData::start()
{
    m_timer.start();
}

int TelemetryChartData::toPercent(float value01)
{
    if (value01 < 0.0f)
        value01 = 0.0f;
    if (value01 > 1.0f)
        value01 = 1.0f;

    return static_cast<int>(value01 * 100.0f + 0.5f);
}

void TelemetryChartData::tick()
{
    irsdkClient& c = irsdkClient::instance();

    const bool hasNew = c.waitForData(0);

    const int status = c.getStatusID();
    if (status != m_lastStatusId) {
        m_lastStatusId = status;
        m_varIdxThrottle = -1;
        m_varIdxBrake = -1;
    }

  //  if (m_randomValue == 50)
  //  {
  //      m_randomValue--;
  //      m_upTrend = false;
  //  }
  //  if (m_randomValue == 0)
  //  {
  //      m_randomValue++;
  //      m_upTrend = true;
  //  }
  //  if (m_upTrend)
  //  {
  //      m_randomValue++;

  //  }
  //  else
  //  {
		//m_randomValue--;
  //  }
  //  m_throttle = m_randomValue + 50;
  //  emit throttleChanged();
  //  m_brake = m_randomValue;
  //  emit brakeChanged();

    if (!hasNew || !c.isConnected())
        return;

    if (m_varIdxThrottle < 0)
        m_varIdxThrottle = c.getVarIdx("Throttle");
    if (m_varIdxBrake < 0)
        m_varIdxBrake = c.getVarIdx("Brake");

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
}