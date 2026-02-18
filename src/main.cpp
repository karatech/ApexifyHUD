#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include "TelemetryChartData.h"
#ifdef _WIN32
#include "WinClickThrough.h"
#endif

int main(int argc, char* argv[]) {

    QQuickWindow::setDefaultAlphaBuffer(true);

    //    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);

    QSurfaceFormat fmt = QSurfaceFormat::defaultFormat();
    fmt.setAlphaBufferSize(8);                  // ← important
    QSurfaceFormat::setDefaultFormat(fmt);

    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    TelemetryChartData telemetryChartData;
    engine.rootContext()->setContextProperty("telemetryChartData", &telemetryChartData);

    // This finds the "Main" file inside the "ApexifyHUD" module automatically
    engine.loadFromModule("ApexifyHUD", "Main");

    if (engine.rootObjects().isEmpty()) return -1;

    auto* win = qobject_cast<QQuickWindow*>(engine.rootObjects().first());
    if (win) {
        win->setFlags(win->flags()
            | Qt::FramelessWindowHint
            | Qt::WindowStaysOnTopHint);
        win->setColor(Qt::transparent);
//#ifdef ENABLE_CLICK_THROUGH   // optional
//#ifdef _WIN32
//        Win::setClickThrough(win, true);
//#endif
//#endif
        win->show();
    }

    telemetryChartData.start();
    return app.exec();
}
