import QtQuick
import QtQuick.Controls
import QtMultimedia

Item {
    id: gameArea
    width: 800
    height: 600
    focus: true

    // Game parameters
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
    property int selectedSongIndex: 0
    property string noteSource: ""
    property int totalNotes: 0
    property int missCount: 0

    // Song list
    property var songList: [
        { name: "Bad Apple", music: "qrc:/music1.mp3", notes: "qrc:/notes1.json", image: "qrc:/badapple.jpg" },
        { name: "Renatus Muzikashii", music: "qrc:/music2.mp3", notes: "qrc:/notes2.json", image: "qrc:/renatus.jpg" },
        { name: "Angel Dream", music: "qrc:/music3.mp3", notes: "qrc:/notes3.json", image: "qrc:/angel.jpg" },
        { name: "Matryoshka", music: "qrc:/music3.mp3", notes: "qrc:/notes3.json", image: "qrc:/angel.jpg" }
    ]

    // Main menu (unchanged)
    Rectangle {
        id: startScreen
        anchors.fill: parent
        color: "gray"
        visible: true
        z: 999
        opacity: 0.95

        Column {
            spacing: 5
            Rectangle {
                width: 250
                height: startScreen.height
                color: "#222222CC"
                radius: 10
                border.width: 2
                border.color: "#FFFFFF"
                clip: true

                Column {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10

                    Text {
                        text: "Таблица лидеров"
                        font.pixelSize: 28
                        font.bold: true
                        color: "#FFD700"
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: "#FFFFFF"
                    }

                    Row {
                        width: parent.width
                        spacing: 5
                        Text { text: "#"; font.pixelSize: 16; color: "white"; width: 30; horizontalAlignment: Text.AlignHCenter }
                        Text { text: "Игрок"; font.pixelSize: 16; color: "white"; width: 80 }
                        Text { text: "Очки"; font.pixelSize: 16; color: "white"; width: 60; horizontalAlignment: Text.AlignRight }
                        Text { text: "%"; font.pixelSize: 16; color: "white"; width: 40; horizontalAlignment: Text.AlignRight }
                    }

                    Repeater {
                        model: [
                            { rank: 1, name: "Player1", score: 143200, accuracy: 98 },
                            { rank: 2, name: "Player2", score: 132850, accuracy: 95 },
                            { rank: 3, name: "Player3", score: 127400, accuracy: 94 },
                            { rank: 4, name: "Player4", score: 114000, accuracy: 91 },
                            { rank: 5, name: "Player5", score: 105000, accuracy: 88 },
                            { rank: 6, name: "Player6", score: 99000, accuracy: 85 },
                            { rank: 7, name: "Player7", score: 92000, accuracy: 82 },
                            { rank: 8, name: "Player8", score: 85000, accuracy: 79 }
                        ]
                        delegate: Row {
                            width: parent.width
                            spacing: 5
                            height: 25
                            Text { text: modelData.rank; font.pixelSize: 16; color: "white"; width: 30; horizontalAlignment: Text.AlignHCenter }
                            Text { text: modelData.name; font.pixelSize: 16; color: "white"; width: 80 }
                            Text { text: modelData.score; font.pixelSize: 16; color: "white"; width: 60; horizontalAlignment: Text.AlignRight }
                            Text { text: modelData.accuracy + "%"; font.pixelSize: 16; color: "white"; width: 40; horizontalAlignment: Text.AlignRight }
                        }
                    }
                }
            }
        }

        Column {
            anchors.centerIn: parent

            ListView {
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
                        z: 100
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            gameArea.selectedSongIndex = index
                            songListView.currentIndex = index
                        }
                    }
                }

                focus: true
                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Up)
                        songListView.decrementCurrentIndex()
                    else if (event.key === Qt.Key_Down)
                        songListView.incrementCurrentIndex()
                }
            }

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

                Text {
                    anchors.centerIn: parent
                    text: "Нет изображения"
                    color: "white"
                    visible: gameArea.songList[gameArea.selectedSongIndex].image === undefined
                }
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Начать игру"
                width: 200
                height: 60
                font.pixelSize: 20
                onClicked: startGame()
            }
        }

        Keys.onPressed: {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                startGame()
            }
        }
    }

    function startGame() {
        score = 0
        combo = 0
        maxCombo = 0
        totalNotes = 0
        missCount = 0
        activeNotes = []

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

            Text { text: "Результаты"; font.pixelSize: 40; color: "white" }
            Text { text: "Очки: " + score; font.pixelSize: 24; color: "white" }
            Text { text: "Макс комбо: " + maxCombo; font.pixelSize: 24; color: "white" }
            Text { text: "Точность: " + accuracyPercent() + "%"; font.pixelSize: 24; color: "white" }
            Text { text: "Промахи: " + missCount; font.pixelSize: 24; color: "white" }
            Text {
                text: "Ранг: " + getRank()
                font.pixelSize: 36
                font.bold: true
                color: {
                    var rank = getRank()
                    if (rank === "S") return "#FFD700"
                    else if (rank === "A") return "#C0C0C0"
                    else if (rank === "B") return "#CD7F32"
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
    SoundEffect { id: spinnerSound; source: "qrc:/spinner.wav"; volume: 1.0 }

    Image {
        anchors.fill: parent
        source: gameArea.songList[gameArea.selectedSongIndex].image
        fillMode: Image.PreserveAspectCrop
    }

    Item {
        id: topArea
        width: parent.width
        height: parent.height * 0.2

        Row {
            Image { id: paralaxTop; source: "taiko-Slider.png"; z: 1 }
            Image { id: paralaxTop1; source: "taiko-Slider.png"; z: 1 }
        }

        Text {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 10
            text: "Score: " + score
            font.pixelSize: 30
            color: "white"
            style: Text.Outline
            styleColor: "black"
        }

        Text {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 10
            text: "Combo: " + combo + " (Max: " + maxCombo + ")"
            font.pixelSize: 20
            color: "white"
            style: Text.Outline
            styleColor: "black"
        }

        Text {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 10
            text: "Accuracy: " + accuracyPercent() + "%"
            font.pixelSize: 20
            color: "white"
            style: Text.Outline
            styleColor: "black"
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
            spawnNote(noteData[noteIndex].type, noteData[noteIndex].duration || 0)
            noteIndex++
        }
    }

    function spawnNote(drumType, duration) {
        totalNotes++
        var note
        if (drumType === 2) {
            // Drumroll note
            var noteWidth = Math.max(100, duration * noteSpeed)
            note = Qt.createQmlObject(`
                import QtQuick 2.0
                Rectangle {
                    property int type: 2
                    property real progress: 0
                    property int hitCount: 0
                    property int minHits: 3
                    property int duration: ${duration}
                    width: ${noteWidth}
                    height: 60
                    radius: 60
                    opacity: 0.9
                    color: "#FFAA00"
                    border.color: "white"
                    border.width: 2
                    x: middleArea.width
                    y: ${hitLine.y + hitLine.height / 2 - 30}

                    Timer {
                        interval: 16
                        running: true
                        repeat: true
                        onTriggered: {
                            parent.x -= ${noteSpeed * 15}
                            parent.progress = parent.x / middleArea.width
                            if (parent.x + parent.width < ${hitLine.x}) {
                                if (parent.hitCount < parent.minHits) {
                                    createHitEffect("MISS!", 0)
                                    paralaxMiss()
                                    combo = 0
                                    missCount++
                                } else {
                                    createHitEffect("DRUMROLL END!", 2)
                                    if (combo > maxCombo) maxCombo = combo
                                }
                                parent.destroy()
                                removeNote(parent)
                            }
                        }
                    }
                }
            `, middleArea)
        } else if (drumType === 3) {
            // Spinner note
            note = Qt.createQmlObject(`
                import QtQuick 2.0
                Item {
                    property int type: 3
                    property real progress: 0
                    property int hitCount: 0
                    property int minHits: Math.max(5, Math.floor(${duration} / 200))
                    property int duration: ${duration}
                    width: 120
                    height: 120
                    x: ${hitLine.x + hitLine.width / 2 - 60}
                    y: ${hitLine.y + hitLine.height / 2 - 60}

                    // Background circle
                    Rectangle {
                        width: parent.width
                        height: parent.height
                        radius: 60
                        color: "transparent"
                        border.color: "white"
                        border.width: 4
                    }

                    // Filling arc
                    Canvas {
                        id: spinnerCanvas
                        width: parent.width
                        height: parent.height
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            ctx.beginPath()
                            ctx.arc(width / 2, height / 2, 50, -Math.PI / 2, -Math.PI / 2 + 2 * Math.PI * parent.progress)
                            ctx.lineWidth = 8
                            ctx.strokeStyle = "#00FFFF"
                            ctx.stroke()
                        }
                    }

                    // Rotation animation
                    transform: Rotation {
                        id: spinnerRotation
                        origin.x: 60
                        origin.y: 60
                        angle: 0
                    }

                    NumberAnimation {
                        target: spinnerRotation
                        property: "angle"
                        from: 0
                        to: 360
                        duration: 1000
                        loops: Animation.Infinite
                        running: true
                    }

                    Timer {
                        interval: ${duration}
                        running: true
                        repeat: false
                        onTriggered: {
                            if (parent.hitCount < parent.minHits) {
                                createHitEffect("MISS!", 0)
                                paralaxMiss()
                                combo = 0
                                missCount++
                            } else {
                                createHitEffect("SPINNER CLEARED!", 3)
                                score += parent.hitCount * 100
                                combo++
                                if (combo > maxCombo) maxCombo = combo
                                paralaxHit()
                            }
                            parent.destroy()
                            removeNote(parent)
                        }
                    }
                }
            `, middleArea)
        } else {
            // Regular note (Don or Kat)
            note = Qt.createQmlObject(`
                import QtQuick 2.0
                Rectangle {
                    property int type: ${drumType}
                    property real progress: 0
                    width: 60
                    height: 60
                    radius: 30
                    color: type === 0 ? "#ff3333" : "#3333ff"
                    border.color: "white"
                    border.width: 2
                    x: middleArea.width
                    y: ${hitLine.y + hitLine.height / 2 - 30}

                    Timer {
                        interval: 16
                        running: true
                        repeat: true
                        onTriggered: {
                            parent.x -= ${noteSpeed * 15}
                            parent.progress = parent.x / middleArea.width
                            if (parent.x + parent.width < 100) {
                                createHitEffect("MISS!", 0)
                                paralaxMiss()
                                combo = 0
                                missCount++
                                parent.destroy()
                                removeNote(parent)
                            }
                        }
                    }
                }
            `, middleArea)
        }
        activeNotes.push(note)
    }

    function paralaxMiss() {
        paralaxTop.source = "taiko-Slider-fail.png"
        paralaxTop1.source = "taiko-Slider-fail.png"
    }

    function paralaxHit() {
        paralaxTop.source = "taiko-Slider.png"
        paralaxTop1.source = "taiko-Slider.png"
    }

    function handleKeyPress(key) {
        var drumType = -1
        if (key === Qt.Key_F || key === Qt.Key_J) {
            drumType = 0
            hitSoundDon.play()
            leftFlash.opacity = 0.8
            leftFlashTimer.restart()
        } else if (key === Qt.Key_D || key === Qt.Key_K) {
            drumType = 1
            hitSoundKat.play()
            rightFlash.opacity = 0.8
            rightFlashTimer.restart()
        }
        if (drumType !== -1) checkNoteHit(drumType)
    }

    function checkNoteHit(drumType) {
        var bestNote = null
        var bestDiff = hitWindow
        for (var i = 0; i < activeNotes.length; i++) {
            var note = activeNotes[i]
            if (note.type === 2) {
                // Handle drumroll note
                var noteCenter = note.x + note.width / 2
                var hitCenter = hitLine.x + hitLine.width / 2
                if (note.x <= hitLine.x + hitLine.width && note.x + note.width >= hitLine.x) {
                    note.hitCount++
                    score += 100
                    combo++
                    createHitEffect("HIT!", 2)
                    paralaxHit()
                    continue
                }
            } else if (note.type === 3) {
                // Handle spinner note
                note.hitCount++
                spinnerSound.play()
                note.progress = Math.min(1.0, note.hitCount / note.minHits)
                note.children[1].requestPaint()
                continue
            } else if (note.type === drumType) {
                // Handle regular note
                var diff = Math.abs((note.x + note.width / 2) - (hitLine.x + hitLine.width / 2))
                if (diff < bestDiff) {
                    bestDiff = diff
                    bestNote = note
                }
            }
        }
        if (bestNote) {
            var scoreAdd = bestDiff < 30 ? 300 : (bestDiff < 60 ? 200 : 100)
            score += scoreAdd
            combo++
            if (combo > maxCombo) maxCombo = combo
            paralaxHit()
            createHitEffect(bestDiff < 30 ? "PERFECT!" : (bestDiff < 60 ? "GOOD!" : "OK!"), drumType)
            bestNote.destroy()
            removeNote(bestNote)
        } else if (!bestNote && drumType !== -1) {
            // No valid regular note hit, check if it breaks combo
            var drumrollHit = false
            var spinnerHit = false
            for (var i = 0; i < activeNotes.length; i++) {
                if (activeNotes[i].type === 2 && activeNotes[i].x <= hitLine.x + hitLine.width && activeNotes[i].x + activeNotes[i].width >= hitLine.x) {
                    drumrollHit = true
                    break
                }
                if (activeNotes[i].type === 3) {
                    spinnerHit = true
                    break
                }
            }
            if (!drumrollHit && !spinnerHit) combo = 0
        }
    }

    function accuracyPercent() {
        return totalNotes > 0 ? Math.round((1 - missCount / totalNotes) * 100) : 100
    }

    function createHitEffect(text, drumType) {
        var color = drumType === 0 ? "#ff3333" : (drumType === 1 ? "#3333ff" : (drumType === 3 ? "#00FFFF" : "#FFFF00"))
        var effect = Qt.createQmlObject(`
            import QtQuick 2.0
            Text {
                property int type: ${drumType}
                text: "${text}"
                font.pixelSize: 24
                color: "${color}"
                x: ${hitLine.x + hitLine.width / 2 - 40}
                y: ${hitLine.y - 50}
                opacity: 1
                style: Text.Outline
                styleColor: "black"

                Behavior on opacity {
                    NumberAnimation { duration: 500; to: 0 }
                }

                NumberAnimation on y {
                    from: ${hitLine.y - 50}
                    to: ${hitLine.y - 75}
                    duration: 500
                    easing.type: Easing.OutCubic
                    running: true
                }

                Timer {
                    interval: 500
                    running: true
                    onTriggered: parent.destroy()
                }
            }
        `, middleArea)
    }

    function removeNote(note) {
        var index = activeNotes.indexOf(note)
        if (index !== -1) {
            activeNotes.splice(index, 1)
        }
    }
}
