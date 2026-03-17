cmake_minimum_required(VERSION 3.16)

set(APP_TARGET ApexifyHUD)

project(${APP_TARGET} VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Charts Widgets)

file(GLOB_RECURSE SOURCE_FILES "src/*.cpp")
file(GLOB_RECURSE HEADER_FILES "header/*.h")

set(IRSDK_SOURCES
    "irsdk 1.18/irsdk/irsdk_client.cpp"
    "irsdk 1.18/irsdk/irsdk_utils.cpp"
    "irsdk 1.18/irsdk/yaml_parser.cpp"
    "irsdk 1.18/irsdk/irsdk_diskclient.cpp")

qt_add_executable(${APP_TARGET} WIN32
    MANUAL_FINALIZATION
    ${SOURCE_FILES} ${HEADER_FILES} ${IRSDK_SOURCES})

qt_add_resources(${APP_TARGET} "app_resources"
    PREFIX "/"
    BASE resources
    FILES resources/ico.png)

qt_add_qml_module(${APP_TARGET} URI ${APP_TARGET} VERSION 1.0
    QML_FILES
        qml/TelemetryWindow.qml
        qml/TelemetryChart.qml)

target_include_directories(${APP_TARGET} PRIVATE header "irsdk 1.18/irsdk")

target_precompile_headers(${APP_TARGET} PRIVATE src/pch.h)

target_link_libraries(${APP_TARGET} PRIVATE
    Qt6::Quick Qt6::Charts Qt6::Widgets winmm)

if(WIN32)
    get_target_property(_qt_qmake_exe Qt6::qmake IMPORTED_LOCATION)
    get_filename_component(_qt_bin_dir "${_qt_qmake_exe}" DIRECTORY)
    set(_windeployqt "${_qt_bin_dir}/windeployqt.exe")

    add_custom_command(TARGET ${APP_TARGET} POST_BUILD
        COMMAND "${CMAKE_COMMAND}" -E echo "Running windeployqt..."
        COMMAND "${_windeployqt}"
                --no-translations
                --qmldir "${CMAKE_SOURCE_DIR}/qml"
                "$<TARGET_FILE:${APP_TARGET}>"
        VERBATIM
    )
endif()
