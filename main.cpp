#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QIcon>
#include <QSurfaceFormat>
#include <QUrl>
#include "ViewModels/Telemetry/TelemetryChartVM.h"
#include "Views/Telemetry/CustomChartControl.h"
#include "../Model/IbtLogSimulator/IbtLogSimulator.h"
#include "ViewModels/MainWindowVM.h"

using namespace ApexifyHUD::ViewModels::Telemetry;
using namespace ApexifyHUD::ViewModels;
using namespace ApexifyHUD::Views::Telemetry;

int main(int argc, char* argv[]) {
    // Request 4x MSAA for smooth Scene Graph lines
    QSurfaceFormat format;
    format.setSamples(4);
    QSurfaceFormat::setDefaultFormat(format); 

    QApplication app(argc, argv);

    QCoreApplication::setOrganizationName("Apexify"); 
    QCoreApplication::setApplicationName("ApexifyHUD");

    app.setWindowIcon(QIcon(":/ico.png"));

    qmlRegisterType<CustomChartControl>("App", 1, 0, "CustomChartControl");

    QQmlApplicationEngine engine;

    TelemetryChartVM telemetryChartData;
    MainWindowVM mainWindowVM;

    const QUrl ibtLogFolderUrl = QUrl::fromLocalFile(QCoreApplication::applicationDirPath() + "/ibt log files");

    engine.rootContext()->setContextProperty("telemetryChartData", &telemetryChartData);
    engine.rootContext()->setContextProperty("mainWindowVM", &mainWindowVM);
    engine.rootContext()->setContextProperty("ibtLogFolderUrl", ibtLogFolderUrl);

    engine.loadFromModule("ApexifyHUD", "MainWindow");

    if (engine.rootObjects().isEmpty()) return -1;

    telemetryChartData.start();

    auto ret = app.exec();

    return ret;
}
