cmake_minimum_required(VERSION 3.21)
project(ApexifyHUD VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(QT NAMES Qt6 REQUIRED COMPONENTS Quick)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Quick)

qt_add_executable(ApexifyHUD
    src/main.cpp
    res/apexify_hud.qrc      # AUTORCC will compile the resources
)


# if you added PCH earlier:
target_precompile_headers(ApexifyHUD PRIVATE src/pch.h)

target_link_libraries(ApexifyHUD PRIVATE Qt${QT_VERSION_MAJOR}::Quick)

# (optional) control the .exe name shown on disk:
set_target_properties(ApexifyHUD PROPERTIES OUTPUT_NAME "ApexifyHUD")
# if you really want a space on disk: OUTPUT_NAME "Apexify HUD"
