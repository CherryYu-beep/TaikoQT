cmake_minimum_required(VERSION 3.16)

project(TaikoGame LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

#find_package(Qt6 REQUIRED COMPONENTS Quick)
find_package(Qt6 REQUIRED COMPONENTS Quick Multimedia)



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
        music.mp3
        don.wav
        kat.wav


        music1.mp3
        notes1.json
        music2.mp3
        notes2.json
        music3.mp3
        notes3.json
        taiko-bar-right.png

        badapple.jpg
        renatus.jpg
        angel.jpg
)

target_link_libraries(TaikoGame PRIVATE Qt6::Quick Qt6::Multimedia)
