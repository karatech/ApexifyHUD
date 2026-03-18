#pragma once

#include <QObject>
#include <QString>
#include "../Model/IbtLogSimulator/IbtLogSimulator.h"

using namespace ApexifyHUD::Model::IbtLogSimulator;

namespace ApexifyHUD::ViewModels
{
    class MainWindowVM : public QObject
    {
        Q_OBJECT

    public:
        explicit MainWindowVM(QObject* parent = nullptr);
        ~MainWindowVM() override;

        Q_INVOKABLE void simulateSelectedIbt(const QString& fileName);

    private:
        IbtLogSimulator m_ibtSimulator;
    };
}