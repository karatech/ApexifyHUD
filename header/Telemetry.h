#pragma once
#include <QObject>
#include <QTimer>
#include <QElapsedTimer>

#define USE_IRSDK

class Telemetry : public QObject {
    Q_OBJECT
        Q_PROPERTY(double currentLapTime READ currentLapTime NOTIFY currentLapTimeChanged)
public:
    explicit Telemetry(QObject* parent = nullptr);

    double currentLapTime() const { return m_currentLapTime; }

    // For the mock mode only (when USE_IRSDK is not defined)
    Q_INVOKABLE void resetLap();

    // Start ticking (polling iRacing or advancing the mock timer)
    void start();

signals:
    void currentLapTimeChanged();

private slots:
    void tick();

private:
    double   m_currentLapTime = 0.0;
    QTimer   m_timer;
    QElapsedTimer m_mockLap;

#ifdef USE_IRSDK
    int m_varIdx = -1;        // cached index for LapCurrentLapTime
    int m_lastStatusId = -1;  // to detect session changes and re-resolve index
#endif
};
