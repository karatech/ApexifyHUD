#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QIcon>
#include <QSurfaceFormat>
#include <QUrl>
#include "Model/IrsdkDataProvider.h"
#include "ViewModels/Telemetry/TelemetryChartVM.h"
#include "ViewModels/Essentials/EssentialsVM.h"
#include "Views/Telemetry/CustomChartControl.h"
#include "ViewModels/MainWindowVM.h"

using namespace ApexifyHUD::Model;
using namespace ApexifyHUD::ViewModels::Telemetry;
using namespace ApexifyHUD::ViewModels::Essentials;
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

    // Single SDK poller — one timer, one waitForData call
    IrsdkDataProvider dataProvider;
    TelemetryChartVM telemetryChartVM;
    EssentialsVM essentialsVM;
    MainWindowVM mainWindowVM;

    // Both VMs driven by the shared provider
    QObject::connect(&dataProvider, &IrsdkDataProvider::statusChanged,
                     &telemetryChartVM, &TelemetryChartVM::onStatusChanged);
    QObject::connect(&dataProvider, &IrsdkDataProvider::dataReady,
                     &telemetryChartVM, &TelemetryChartVM::onDataReady);

    QObject::connect(&dataProvider, &IrsdkDataProvider::statusChanged,
                     &essentialsVM, &EssentialsVM::onStatusChanged);
    QObject::connect(&dataProvider, &IrsdkDataProvider::dataReady,
                     &essentialsVM, &EssentialsVM::onDataReady);

    const QUrl ibtLogFolderUrl = QUrl::fromLocalFile(QCoreApplication::applicationDirPath() + "/ibt log files");

    engine.rootContext()->setContextProperty("telemetryChartVM", &telemetryChartVM);
    engine.rootContext()->setContextProperty("essentialsVM", &essentialsVM);
    engine.rootContext()->setContextProperty("mainWindowVM", &mainWindowVM);
    engine.rootContext()->setContextProperty("ibtLogFolderUrl", ibtLogFolderUrl);

    engine.loadFromModule("ApexifyHUD", "MainWindow");

    if (engine.rootObjects().isEmpty()) return -1;

    dataProvider.start();

    auto ret = app.exec();

    return ret;
}
