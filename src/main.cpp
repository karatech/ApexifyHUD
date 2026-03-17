#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QIcon>
#include <QSurfaceFormat>
#include "TelemetryChartData.h"
#include "FastTelemetryChart.h" // ADD THIS
#include "IbtSimulator.h"

int main(int argc, char* argv[]) {

    IbtSimulator sim;
    sim.setLoop(true);
    sim.open("C:/Users/danielc/Desktop/test_iRacing_SDK.ibt");  // starts the background thread


    // Request 4x MSAA for smooth Scene Graph lines
    QSurfaceFormat format;
    format.setSamples(4);
    QSurfaceFormat::setDefaultFormat(format); 

    QApplication app(argc, argv);

    QCoreApplication::setOrganizationName("Apexify");
    QCoreApplication::setApplicationName("ApexifyHUD");

    app.setWindowIcon(QIcon(":/ico.png"));

    // ADD THIS LINE
    qmlRegisterType<FastTelemetryChart>("App", 1, 0, "FastTelemetryChart");

    QQmlApplicationEngine engine;
    TelemetryChartData telemetryChartData;
    engine.rootContext()->setContextProperty("telemetryChartData", &telemetryChartData);
    engine.loadFromModule("ApexifyHUD", "TelemetryWindow");

    if (engine.rootObjects().isEmpty()) return -1;

    telemetryChartData.start();

	auto ret = app.exec();

    sim.close();  // stop and clean up

    return ret;
}
