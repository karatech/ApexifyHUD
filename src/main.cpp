#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QIcon>
#include <QSurfaceFormat>
#include <QUrl>
#include "TelemetryChartData.h"
#include "FastTelemetryChart.h"
#include "IbtSimulator.h"
#include "MainWindowBackend.h"

int main(int argc, char* argv[]) {

    IbtSimulator sim;
    sim.setLoop(true);
    sim.open("ibt log files/test_iRacing_SDK.ibt");  // starts the background thread

    // Request 4x MSAA for smooth Scene Graph lines
    QSurfaceFormat format;
    format.setSamples(4);
    QSurfaceFormat::setDefaultFormat(format);

    QApplication app(argc, argv);

    QCoreApplication::setOrganizationName("Apexify");
    QCoreApplication::setApplicationName("ApexifyHUD");

    app.setWindowIcon(QIcon(":/ico.png"));

    qmlRegisterType<FastTelemetryChart>("App", 1, 0, "FastTelemetryChart");

    QQmlApplicationEngine engine;

    TelemetryChartData telemetryChartData;
    MainWindowBackend mainWindowBackend;

    const QUrl ibtLogFolderUrl = QUrl::fromLocalFile(QCoreApplication::applicationDirPath() + "/ibt log files");

    engine.rootContext()->setContextProperty("telemetryChartData", &telemetryChartData);
    engine.rootContext()->setContextProperty("mainWindowBackend", &mainWindowBackend);
    engine.rootContext()->setContextProperty("ibtLogFolderUrl", ibtLogFolderUrl);

    engine.loadFromModule("ApexifyHUD", "MainWindow");

    if (engine.rootObjects().isEmpty()) return -1;

    telemetryChartData.start();

    auto ret = app.exec();

    sim.close();  // stop and clean up

    return ret;
}
