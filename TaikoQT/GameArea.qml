import QtQuick
import QtQuick.Controls

Item {
    id: gameArea

    Image {
        anchors.fill: parent
        source: "background.jpg"
        fillMode: Image.PreserveAspectCrop
    }

    property int score: 0
    property var notes: [] // Массив для хранения нот

    Text {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Score: " + gameArea.score
        font.pixelSize: 36
        color: "white"
        style: Text.Outline
        styleColor: "black"
    }

    TaikoDrum {
        id: drumLeft
        x: parent.width / 3 - width / 2
        y: parent.height / 2 - height / 2
        keyToPress: Qt.Key_D
        onHit: {
            gameArea.score += 100;
            checkHit(0); // Проверяем попадание по нотам для левого барабана
        }
    }

    TaikoDrum {
        id: drumRight
        x: parent.width * 2 / 3 - width / 2
        y: parent.height / 2 - height / 2
        keyToPress: Qt.Key_K
        onHit: {
            gameArea.score += 100;
            checkHit(1); // Проверяем попадание по нотам для правого барабана
        }
    }

    // Функция создания ноты
    function spawnNote(drumIndex) {
        var note = Qt.createQmlObject(`
            import QtQuick 2.0
            Rectangle {
                property int targetDrum: ${drumIndex}
                width: 60
                height: 30
                color: targetDrum === 0 ? "red" : "blue"
                radius: height/2
                x: targetDrum === 0 ? drumLeft.x + drumLeft.width/2 - width/2
                                   : drumRight.x + drumRight.width/2 - width/2
                y: 0
                Behavior on y {
                    NumberAnimation { duration: 2000 }
                }
            }
        `, gameArea);
        note.y = gameArea.height;
        notes.push(note);
        note.y = drumLeft.y;
        note.destroy(2000); // Уничтожить после достижения цели
    }

    // Функция проверки попадания по нотам
    function checkHit(drumIndex) {
        for (var i = 0; i < notes.length; i++) {
            var note = notes[i];
            if (note.targetDrum === drumIndex &&
                Math.abs(note.y - drumLeft.y) < 30) {
                // Попадание в ноту!
                gameArea.score += 300; // Бонус за точное попадание
                note.destroy();
                notes.splice(i, 1);
                break;
            }
        }
    }

    // Таймер для генерации нот
    Timer {
        id: noteSpawner
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            // Случайным образом выбираем, для какого барабана создать ноту
            var drumIndex = Math.random() > 0.5 ? 1 : 0;
            spawnNote(drumIndex);
        }
    }
}
