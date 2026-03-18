#pragma once
#include <QObject>

class MainWindowBackend : public QObject
{
    Q_OBJECT

public:
    explicit MainWindowBackend(QObject* parent = nullptr);
};