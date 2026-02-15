#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include "Telemetry.h"
#ifdef _WIN32
#include "WinClickThrough.h"
#endif

int main(int argc, char* argv[]) {

    QQuickWindow::setDefaultAlphaBuffer(true);

    //    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);

    QSurfaceFormat fmt = QSurfaceFormat::defaultFormat();
    fmt.setAlphaBufferSize(8);                  // ← important
    QSurfaceFormat::setDefaultFormat(fmt);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    Telemetry telemetry;
    engine.rootContext()->setContextProperty("telemetry", &telemetry);

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

    telemetry.start();            // mock timer now; iRacing later
    return app.exec();
}
