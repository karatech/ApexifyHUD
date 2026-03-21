#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QIcon>
#include <QSurfaceFormat>
#include <QUrl>
#include "ViewModels/Telemetry/TelemetryChartVM.h"
#include "Views/Telemetry/CustomChartControl.h"
#include "ViewModels/MainWindowVM.h"

using namespace ApexifyHUD::ViewModels::Telemetry;
using namespace ApexifyHUD::ViewModels;
using namespace ApexifyHUD::Views::Telemetry;

int main(int argc, char* argv[]) {
    // Global Qt Quick Controls style/theme (must be set before QApplication)
    qputenv("QT_QUICK_CONTROLS_STYLE", "Material");
    qputenv("QT_QUICK_CONTROLS_MATERIAL_THEME", "Dark");
    qputenv("QT_QUICK_CONTROLS_MATERIAL_ACCENT", "DeepOrange");
    qputenv("QT_QUICK_CONTROLS_MATERIAL_PRIMARY", "Grey");

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

    TelemetryChartVM telemetryChartVM;
    MainWindowVM mainWindowVM;

    const QUrl ibtLogFolderUrl = QUrl::fromLocalFile(QCoreApplication::applicationDirPath() + "/ibt log files");

    engine.rootContext()->setContextProperty("telemetryChartVM", &telemetryChartVM);
    engine.rootContext()->setContextProperty("mainWindowVM", &mainWindowVM);
    engine.rootContext()->setContextProperty("ibtLogFolderUrl", ibtLogFolderUrl);

    engine.loadFromModule("ApexifyHUD", "MainWindow");

    if (engine.rootObjects().isEmpty()) return -1;

    telemetryChartVM.start();

    auto ret = app.exec();

    return ret;
}
