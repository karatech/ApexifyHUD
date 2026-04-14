#pragma once
#include <QObject>
#include <QTimer>

namespace ApexifyHUD::Model
{
    class IrsdkDataProvider : public QObject
    {
        Q_OBJECT

    public:
        explicit IrsdkDataProvider(QObject* parent = nullptr);

        void start();

        int statusId() const { return m_statusId; }

    signals:
        void dataReady();
        void statusChanged();

    private slots:
        void onTimerTick();

    private:
        QTimer m_timer;
        int m_statusId = -1;
    };
}