cmake_minimum_required(VERSION 3.21)

set(APP_TARGET ApexifyHUD)

project(${APP_TARGET} VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(QT NAMES Qt6 REQUIRED COMPONENTS Quick)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Quick)
# 1. Add 'Charts' to find_package
find_package(Qt6 REQUIRED COMPONENTS Quick Charts Widgets)

# This command grabs all .cpp files in src/ and saves them to a variable
file(GLOB_RECURSE SOURCE_FILES "src/*.cpp")

# This command grabs all .h files in header/
file(GLOB_RECURSE HEADER_FILES "header/*.h")

#  Define the iRacing Source files (Note the quotes because of the space in "irsdk 1.18")
set(IRSDK_SOURCES
    "irsdk 1.18/irsdk/irsdk_client.cpp"
    "irsdk 1.18/irsdk/irsdk_utils.cpp"
    "irsdk 1.18/irsdk/yaml_parser.cpp"
)

qt_add_executable(${APP_TARGET} WIN32
    MANUAL_FINALIZATION 
    ${SOURCE_FILES} 
    ${HEADER_FILES}
    ${IRSDK_SOURCES}   # <-- Add the SDK sources here
)

qt_add_qml_module(${APP_TARGET}
    URI ${APP_TARGET}
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/TelemetryChart.qml
)


# Tells CMake: "Look inside the 'header' folder for .h files"
target_include_directories(${APP_TARGET} PRIVATE header)
target_include_directories(${APP_TARGET} PRIVATE "irsdk 1.18/irsdk")

# if you added PCH earlier:
target_precompile_headers(${APP_TARGET} PRIVATE src/pch.h)

target_link_libraries(${APP_TARGET} PRIVATE
    Qt${QT_VERSION_MAJOR}::Quick
    Qt${QT_VERSION_MAJOR}::Charts
    Qt${QT_VERSION_MAJOR}::Widgets
)

# (optional) control the .exe name shown on disk:
set_target_properties(${APP_TARGET} PROPERTIES OUTPUT_NAME "ApexifyHUD")
# if you really want a space on disk: OUTPUT_NAME "Apexify HUD"
