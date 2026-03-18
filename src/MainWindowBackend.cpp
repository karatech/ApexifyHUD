#include "MainWindowBackend.h"

#include <QCoreApplication>
#include <QDebug>
#include <QDir>
#include "IbtSimulator.h"

MainWindowBackend::MainWindowBackend(QObject* parent)
    : QObject(parent)
{
}

void MainWindowBackend::simulateSelectedIbt(const QString& fileName)
{
	if (m_ibtSimulator.isRunning()) 
        m_ibtSimulator.close();

    m_ibtSimulator.setLoop(true);
    m_ibtSimulator.open(fileName.toStdString()); // starts the background thread
}

MainWindowBackend::~MainWindowBackend() 
{
    if (m_ibtSimulator.isRunning())
        m_ibtSimulator.close();
}