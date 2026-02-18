#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include "TelemetryChartData.h"

int main(int argc, char* argv[]) {

    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    TelemetryChartData telemetryChartData;
    engine.rootContext()->setContextProperty("telemetryChartData", &telemetryChartData);
    engine.loadFromModule("ApexifyHUD", "Main");

    if (engine.rootObjects().isEmpty()) return -1;

    telemetryChartData.start();
    return app.exec();
}
