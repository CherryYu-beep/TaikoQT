import QtQuick
import QtQuick.Controls

Item {
    id: drum
    width: 150
    height: 150

    property int keyToPress: Qt.Key_Space
    signal hit

    Image {
        id: drumImage
        anchors.fill: parent
        source: "drum.png"
    }

    Image {
        id: hitEffect
        anchors.fill: parent
        source: "hit_effect.png"
        opacity: 0
    }

    SequentialAnimation {
        id: hitAnimation
        PropertyAnimation {
            target: hitEffect
            property: "opacity"
            to: 1
            duration: 50
        }
        PropertyAnimation {
            target: hitEffect
            property: "opacity"
            to: 0
            duration: 150
        }
    }

    function hitDrum() {
        hitAnimation.start()
        hit()
    }

    Keys.onPressed: (event) => {
        if (event.key === keyToPress) {
            hitDrum()
            event.accepted = true
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: hitDrum()
    }

    // Для обработки клавиш нужно установить фокус
    Component.onCompleted: forceActiveFocus()
}
