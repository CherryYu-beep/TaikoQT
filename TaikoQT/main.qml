import QtQuick
import QtQuick.Window
import QtQuick.Controls


Window {
    width: 800
    height: 600
    visible: true
    title: qsTr("Taiko Game")

    GameArea {
        anchors.fill: parent
    }
}
