#include "IrsdkDataProvider.h"
#include "irsdk_defines.h"
#include "irsdk_client.h"

using namespace ApexifyHUD::Model;

IrsdkDataProvider::IrsdkDataProvider(QObject* parent)
    : QObject(parent)
{
    connect(&m_timer, &QTimer::timeout, this, &IrsdkDataProvider::onTimerTick);
    m_timer.setInterval(16); // ~60 Hz - single poll for all consumers
    m_timer.setTimerType(Qt::CoarseTimer);
}

void IrsdkDataProvider::start()
{
    m_timer.start();
}

void IrsdkDataProvider::onTimerTick()
{
    irsdkClient& c = irsdkClient::instance();

    const bool hasNew = c.waitForData(0);

    const int status = c.getStatusID();
    if (status != m_statusId) {
        m_statusId = status;
        emit statusChanged();
    }

    if (!hasNew || !c.isConnected())
        return;

    emit dataReady();
}