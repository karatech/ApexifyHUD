#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QIcon>
#include "TelemetryChartData.h"

int main(int argc, char* argv[]) {

    QApplication app(argc, argv);

    QCoreApplication::setOrganizationName("Apexify");
    QCoreApplication::setApplicationName("ApexifyHUD");

    app.setWindowIcon(QIcon(":/ico.png"));

    QQmlApplicationEngine engine;
    TelemetryChartData telemetryChartData;
    engine.rootContext()->setContextProperty("telemetryChartData", &telemetryChartData);
    engine.loadFromModule("ApexifyHUD", "Main");

    if (engine.rootObjects().isEmpty()) return -1;

    telemetryChartData.start();
    return app.exec();
}
