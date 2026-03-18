#include "MainWindowVM.h"

#include <QCoreApplication>
#include <QDebug>
#include <QDir>

using namespace ApexifyHUD::ViewModels;


MainWindowVM::MainWindowVM(QObject* parent)
    : QObject(parent)
{
}

void MainWindowVM::simulateSelectedIbt(const QString& fileName)
{
	if (m_ibtSimulator.isRunning()) 
        m_ibtSimulator.close();

    m_ibtSimulator.setLoop(true);
    m_ibtSimulator.open(fileName.toStdString()); // starts the background thread
}

MainWindowVM::~MainWindowVM() 
{
    if (m_ibtSimulator.isRunning())
        m_ibtSimulator.close();
}