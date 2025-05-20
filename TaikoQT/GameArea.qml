import QtQuick
import QtQuick.Controls
import QtMultimedia

Item {
    id: gameArea
    width: 800
    height: 600
    focus: true

    MediaPlayer {
        id: bgm
        source: "qrc:/music.mp3"
        audioOutput: AudioOutput {
            id: audioOut
            volume: 0.5
        }
    }

    SoundEffect {
        id: hitSoundDon
        source: "qrc:/don.wav"
        volume: 1.0
    }

    SoundEffect {
        id: hitSoundKat
        source: "qrc:/kat.wav"
        volume: 1.0
    }

    Image {
        anchors.fill: parent
        source: "background.jpg"
        fillMode: Image.PreserveAspectCrop
    }

    property int score: 0
    property int combo: 0
    property int maxCombo: 0
    property var activeNotes: []
    property var drumKeys: ({})
    property real noteSpeed: 0.3
    property int hitWindow: 150

    property var noteData: []
    property int noteIndex: 0

    // Линия попадания
    Rectangle {
        id: hitLine
        width: 100
        height: 100
        radius: 50
        color: "#333"
        border.color: "white"
        border.width: 3
        x: parent.width * 0.2 - width / 2
        y: parent.height / 2 - height / 2
    }

    // UI
    Text {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Score: " + score
        font.pixelSize: 36
        color: "white"
        style: Text.Outline
        styleColor: "black"
    }

    Text {
        anchors.top: prev.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Combo: " + combo + " (Max: " + maxCombo + ")"
        font.pixelSize: 24
        color: "white"
        style: Text.Outline
        styleColor: "black"
        id: prev
    }

    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 50

        Rectangle {
            width: 120
            height: 120
            radius: 60
            color: drumKeys[Qt.Key_F] || drumKeys[Qt.Key_J] ? "#ff5555" : "#ff3333"
            border.color: "white"
            border.width: 3

            Text {
                anchors.centerIn: parent
                text: "F / J"
                font.pixelSize: 24
                color: "white"
            }
        }

        Rectangle {
            width: 120
            height: 120
            radius: 60
            color: drumKeys[Qt.Key_D] || drumKeys[Qt.Key_K] ? "#5555ff" : "#3333ff"
            border.color: "white"
            border.width: 3

            Text {
                anchors.centerIn: parent
                text: "D / K"
                font.pixelSize: 24
                color: "white"
            }
        }
    }

    Timer {
        id: syncTimer
        interval: 10
        repeat: true
        running: false
        onTriggered: checkNoteSpawn()
    }

    Component.onCompleted: {
        loadNotes()
    }

    Keys.onPressed: {
        drumKeys[event.key] = true;
        handleKeyPress(event.key);
    }

    Keys.onReleased: {
        drumKeys[event.key] = false;
    }

    function loadNotes() {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "qrc:/notes.json");
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                noteData = JSON.parse(xhr.responseText);
                noteIndex = 0;
                bgm.play();
                syncTimer.start();
            }
        }
        xhr.send();
    }

    function checkNoteSpawn() {
        if (!noteData || noteIndex >= noteData.length)
            return;

        var currentTime = bgm.position;

        while (noteIndex < noteData.length && noteData[noteIndex].time <= currentTime) {
            spawnNote(noteData[noteIndex].type);
            noteIndex++;
        }
    }

    function spawnNote(drumType) {
        var note = Qt.createQmlObject(`
            import QtQuick 2.0
            Rectangle {
                property int type: ${drumType}
                property real progress: 0
                width: 60
                height: 60
                radius: 30
                color: type === 0 ? "#ff3333" : "#3333ff"
                x: gameArea.width
                y: ${hitLine.y + hitLine.height / 2 - 30}

                Timer {
                    interval: 16
                    running: true
                    repeat: true
                    onTriggered: {
                        parent.x -= ${noteSpeed * 15};
                        parent.progress = parent.x / gameArea.width;
                        if (parent.x + parent.width < 0) {
                            parent.destroy();
                        }
                    }
                }
            }
        `, gameArea);

        note.progressChanged.connect(function() {
            if (note.x + note.width < 0) {
                note.destroy();
                removeNote(note);
                combo = 0;
            }
        });

        activeNotes.push(note);
    }

    function handleKeyPress(key) {
        var drumType = -1;

        if (key === Qt.Key_F || key === Qt.Key_J) {
            drumType = 0;
            hitSoundDon.play();
        } else if (key === Qt.Key_D || key === Qt.Key_K) {
            drumType = 1;
            hitSoundKat.play();
        }

        if (drumType !== -1) {
            checkNoteHit(drumType);
        }
    }

    function checkNoteHit(drumType) {
        var bestNote = null;
        var bestDiff = hitWindow;

        for (var i = 0; i < activeNotes.length; i++) {
            var note = activeNotes[i];
            if (note.type !== drumType) continue;

            var noteCenter = note.x + note.width / 2;
            var hitCenter = hitLine.x + hitLine.width / 2;
            var diff = Math.abs(noteCenter - hitCenter);

            if (diff < bestDiff) {
                bestDiff = diff;
                bestNote = note;
            }
        }

        if (bestNote) {
            var scoreAdd = 0;
            var accuracy = "";

            if (bestDiff < 30) {
                scoreAdd = 300;
                accuracy = "PERFECT!";
            } else if (bestDiff < 60) {
                scoreAdd = 200;
                accuracy = "GOOD!";
            } else {
                scoreAdd = 100;
                accuracy = "OK!";
            }

            score += scoreAdd;
            combo++;
            if (combo > maxCombo) maxCombo = combo;

            createHitEffect(accuracy, drumType);
            bestNote.destroy();
            removeNote(bestNote);
        } else {
            combo = 0;
        }
    }

    function createHitEffect(text, drumType) {
        var effect = Qt.createQmlObject(`
            import QtQuick 2.0
            Text {
                property int type: ${drumType}
                text: "${text}"
                font.pixelSize: 24
                color: type === 0 ? "#ff3333" : "#3333ff"
                x: ${hitLine.x + hitLine.width / 2 - 40}
                y: ${hitLine.y - 50}
                opacity: 1

                Behavior on opacity {
                    NumberAnimation { duration: 500; to: 0 }
                }

                Timer {
                    interval: 500
                    running: true
                    onTriggered: parent.destroy()
                }
            }
        `, gameArea);
    }

    function removeNote(note) {
        var index = activeNotes.indexOf(note);
        if (index !== -1) {
            activeNotes.splice(index, 1);
        }
    }
}
