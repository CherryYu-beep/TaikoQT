cmake_minimum_required(VERSION 3.16)

project(TaikoGame LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup()

qt_add_executable(TaikoGame
    main.cpp
)

# Добавляем QML файлы как ресурсы
qt_add_resources(TaikoGame "qml"
    PREFIX "/"
    FILES
        main.qml
        TaikoDrum.qml
        GameArea.qml
        drum.png
        hit_effect.png
        background.jpg
)

target_link_libraries(TaikoGame PRIVATE Qt6::Quick)
