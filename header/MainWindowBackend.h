#pragma once
#include <QObject>
#include <QString>
#include "IbtSimulator.h"

class MainWindowBackend : public QObject
{
    Q_OBJECT

public:
    explicit MainWindowBackend(QObject* parent = nullptr);
    ~MainWindowBackend() override;

    Q_INVOKABLE void simulateSelectedIbt(const QString& fileName);

private:
    IbtSimulator m_ibtSimulator;
};