import QtQuick
import QtQuick.Controls
import QtMultimedia

Item {
    id: gameArea
    width: 800
    height: 600
    focus: true

    // Игровые параметры
    property int score: 0
    property int combo: 0
    property int maxCombo: 0
    property var activeNotes: []
    property var drumKeys: ({})
    property real noteSpeed: 0.3
    property int hitWindow: 150
    property var noteData: []
    property int noteIndex: 0
    property int noteOffset: 2333

    // Для подсчёта точности
    property int totalNotes: 0
    property int missCount: 0

    // Список песен
    property var songList: [
        { name: "Bad Apple", music: "qrc:/music1.mp3", notes: "qrc:/notes1.json", image: "qrc:/badapple.jpg" },
        { name: "Renatus Muzikashii", music: "qrc:/music2.mp3", notes: "qrc:/notes2.json", image: "qrc:/renatus.jpg" },
        { name: "Angel Dream", music: "qrc:/music3.mp3", notes: "qrc:/notes3.json", image: "qrc:/angel.jpg" }
    ]

    property int selectedSongIndex: 0
    property string noteSource: ""

    // Главное меню
    Rectangle {
        id: startScreen
        anchors.fill: parent
        color: "black"
        visible: true
        z: 999


        Column {
            anchors.centerIn: parent


            Text {
                text: "Taiko Game"
                font.pixelSize: 40
                color: "white"

            }

            ListView {
                Rectangle {
                    anchors.left: songListView.right
                    width: 200
                    height: 200
                    color: "#222"
                    border.color: "white"
                    border.width: 1

                    Image {
                        anchors.fill: parent
                        source: gameArea.songList[gameArea.selectedSongIndex].image
                        fillMode: Image.PreserveAspectCrop
                        visible: gameArea.songList[gameArea.selectedSongIndex].image !== undefined
                    }

                    // Текст-заглушка, если нет изображения
                    Text {
                        anchors.centerIn: parent
                        text: "Нет изображения"
                        color: "white"
                        visible: gameArea.songList[gameArea.selectedSongIndex].image === undefined
                    }

                }
                id: songListView
                width: 300
                height: 200
                model: gameArea.songList
                currentIndex: gameArea.selectedSongIndex
                delegate: Rectangle {
                    width: parent.width
                    height: 50
                    color: ListView.isCurrentItem ? "#4444aa" : "#222"
                    border.color: "white"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: modelData.name
                        color: "white"
                        font.pixelSize: 18
                        z:100
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            gameArea.selectedSongIndex = index;
                            songListView.currentIndex = index;
                        }
                    }
                }

                focus: true
                Keys.onPressed: (event) => {
                                    if (event.key === Qt.Key_Up)
                                    songListView.decrementCurrentIndex();
                                    else if (event.key === Qt.Key_Down)
                                    songListView.incrementCurrentIndex();
                                }
            }


            Button {
                text: "Начать игру"
                width: 200
                height: 60
                font.pixelSize: 20
                onClicked: startGame()
            }

            Text {
                text: "Нажмите F/J или D/K в нужный момент, чтобы попадать по нотам."
                font.pixelSize: 16
                color: "white"
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                width: 400
            }
        }


        Keys.onPressed: {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                startGame()
            }
        }
    }

    function startGame() {
        // сброс
        score = 0; combo = 0; maxCombo = 0;
        totalNotes = 0; missCount = 0;

        var song = songList[selectedSongIndex]
        bgm.source = song.music
        noteSource = song.notes
        startScreen.visible = false
        loadNotes()
    }

    MediaPlayer {
        id: bgm
        source: "qrc:/music1.mp3"
        audioOutput: AudioOutput { volume: 0.5 }

        onPlaybackStateChanged: {
            if (playbackState === MediaPlayer.StoppedState) {
                endGame()
                console.log("music end")
            }
        }
    }

    function getRank() {
        var acc = accuracyPercent()
        if (acc >= 95) return "S"
        else if (acc >= 85) return "A"
        else if (acc >= 70) return "B"
        else if (acc >= 50) return "C"
        else return "D"
    }


    function endGame() {
        syncTimer.stop()
        // for (var i = 0; i < activeNotes.length; i++) {
        //     activeNotes[i].destroy()
        // }
        //activeNotes = []
        resultScreen.visible = true
    }

    Rectangle {
        id: resultScreen
        anchors.fill: parent
        color: "black"
        visible: false
        z: 1000

        Column {
            anchors.centerIn: parent
            spacing: 20

            Text {
                text: "Результаты"
                font.pixelSize: 40
                color: "white"
            }

            Text {
                text: "Очки: " + score
                font.pixelSize: 24
                color: "white"
            }

            Text {
                text: "Макс комбо: " + maxCombo
                font.pixelSize: 24
                color: "white"
            }

            Text {
                text: "Точность: " + accuracyPercent() + "%"
                font.pixelSize: 24
                color: "white"
            }

            Text {
                text: "Промахи: " + missCount
                font.pixelSize: 24
                color: "white"
            }

            Text {
                text: "Ранг: " + getRank()
                font.pixelSize: 36
                font.bold: true
                color: {
                    var rank = getRank()
                    if (rank === "S") return "#FFD700"   // золото
                    else if (rank === "A") return "#C0C0C0" // серебро
                    else if (rank === "B") return "#CD7F32" // бронза
                    else return "white"
                }
            }


            Button {
                text: "Вернуться в меню"
                width: 200
                height: 50
                onClicked: {
                    resultScreen.visible = false
                    startScreen.visible = true
                }
            }
        }
    }


    SoundEffect { id: hitSoundDon; source: "qrc:/don.wav"; volume: 1.0 }
    SoundEffect { id: hitSoundKat; source: "qrc:/kat.wav"; volume: 1.0 }

    Image {
        anchors.fill: parent
        source: gameArea.songList[gameArea.selectedSongIndex].image
        fillMode: Image.PreserveAspectCrop
    }

    // ВЕРХНЯЯ ОБЛАСТЬ (20%)
    Item {
        id: topArea
        width: parent.width
        height: parent.height * 0.2

        Column {
            anchors.centerIn: parent
            spacing: 10

            Text {
                text: "Score: " + score
                font.pixelSize: 30
                color: "white"
                style: Text.Outline; styleColor: "black"
            }

            Text {
                text: "Combo: " + combo + " (Max: " + maxCombo + ")"
                font.pixelSize: 20
                color: "white"
                style: Text.Outline; styleColor: "black"
            }

            Text {
                text: "Accuracy: " + accuracyPercent() + "%"
                font.pixelSize: 20
                color: "white"
                style: Text.Outline; styleColor: "black"
            }
        }
    }

    Item {
        id: middleArea
        width: parent.width
        height: parent.height * 0.3
        anchors.top: topArea.bottom

        Image {
            anchors.fill: parent
            source: "taiko-bar-right.png"
            fillMode: Image.PreserveAspectCrop
        }



        Rectangle {
            id: hitLine
            width: 100; height: 100; radius: 50
            color: "#333"; border.color: "white"; border.width: 3
            x: parent.width * 0.2 - width / 2
            y: parent.height / 2 - height / 2

            // Левая подсветка (красная)
            Rectangle {
                id: leftFlash
                radius: 50
                anchors.verticalCenter: parent.verticalCenter
                x: 0
                scale: 0.9
                width: parent.width
                height: parent.height
                color: "#ff0000"
                opacity: 0.0
                z: 1
            }

            // Правая подсветка (синяя)
            Rectangle {
                id: rightFlash
                radius: 50
                anchors.verticalCenter: parent.verticalCenter
                x: 0
                scale: 0.9
                width: parent.width
                height: parent.height
                color: "#0000ff"
                opacity: 0.0
                z: 1
            }
        }

        // Таймеры для анимации вспышки
        Timer {
            id: leftFlashTimer
            interval: 100; running: false; repeat: false
            onTriggered: leftFlash.opacity = 0
        }

        Timer {
            id: rightFlashTimer
            interval: 100; running: false; repeat: false
            onTriggered: rightFlash.opacity = 0
        }
    }


    // НИЖНЯЯ ОБЛАСТЬ (50%)
    Item {
        id: bottomArea
        width: parent.width
        height: parent.height * 0.5
        anchors.top: middleArea.bottom

    }

    Timer {
        id: syncTimer
        interval: 10; repeat: true; running: false
        onTriggered: checkNoteSpawn()
    }

    Keys.onPressed: { drumKeys[event.key] = true; handleKeyPress(event.key) }
    Keys.onReleased: { drumKeys[event.key] = false }

    function loadNotes() {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", noteSource)
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                noteData = JSON.parse(xhr.responseText)
                noteIndex = 0
                bgm.play()
                syncTimer.start()
            }
        }
        xhr.send()
    }

    function checkNoteSpawn() {
        if (!noteData || noteIndex >= noteData.length) return
        var currentTime = bgm.position + noteOffset

        while (noteIndex < noteData.length && noteData[noteIndex].time <= currentTime) {
            spawnNote(noteData[noteIndex].type)
            noteIndex++
        }
    }

    function spawnNote(drumType) {
        totalNotes++
        var note = Qt.createQmlObject(`
            import QtQuick 2.0
            Rectangle {
                property int type: ${drumType}
                property real progress: 0
                width: 60; height: 60; radius: 30
                color: type === 0 ? "#ff3333" : "#3333ff"
                border.color: "white"
                border.width: 2
                x: middleArea.width
                y: ${hitLine.y + hitLine.height / 2 - 30}

                Timer {
                    interval: 16; running: true; repeat: true
                    onTriggered: {
                        parent.x -= ${noteSpeed * 15}
                        parent.progress = parent.x / middleArea.width
                        if (parent.x + parent.width < 0) {
                            parent.destroy()
                            missCount++
                            removeNote(note)
                            combo = 0
                        }
                    }
                }
            }
        `, middleArea)
        activeNotes.push(note)
    }

    function handleKeyPress(key) {
        var drumType = -1
        if (key === Qt.Key_F || key === Qt.Key_J) { drumType = 0; hitSoundDon.play(); leftFlash.opacity = 0.8; leftFlashTimer.restart() }
        else if (key === Qt.Key_D || key === Qt.Key_K) { drumType = 1; hitSoundKat.play(); rightFlash.opacity = 0.8; rightFlashTimer.restart() }
        if (drumType !== -1) checkNoteHit(drumType)
    }

    function checkNoteHit(drumType) {
        var bestNote = null; var bestDiff = hitWindow
        for (var i = 0; i < activeNotes.length; i++) {
            var note = activeNotes[i]
            if (note.type !== drumType) continue
            var diff = Math.abs((note.x + note.width/2) - (hitLine.x + hitLine.width/2))
            if (diff < bestDiff) { bestDiff = diff; bestNote = note }
        }
        if (bestNote) {
            var scoreAdd = bestDiff < 30 ? 300 : (bestDiff < 60 ? 200 : 100)
            score += scoreAdd
            combo++
            if (combo > maxCombo) maxCombo = combo
            createHitEffect(bestDiff < 30 ? "PERFECT!" : (bestDiff < 60 ? "GOOD!" : "OK!"), drumType)
            bestNote.destroy()
            removeNote(bestNote)
        } else { combo = 0 }
    }

    function accuracyPercent() {
        return totalNotes > 0 ? Math.round((1 - missCount / totalNotes) * 100) : 100
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
           `, middleArea);
       }

    function removeNote(note) {
        var idx = activeNotes.indexOf(note)
        if (idx !== -1) activeNotes.splice(idx, 1)
    }
}
