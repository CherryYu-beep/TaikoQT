import QtQuick
import QtQuick.Controls

Window {
    width: 250
    height: 200
    visible: true
    title: "METANIT.COM"

    Column {
        CheckBox {
            checked: true   // флажок отмечен
            font {family: "Verdana"; pixelSize:16}
            text: "С++"
        }
        CheckBox {
            font {family: "TimesNewRoman"; pixelSize:16}
            text: "Java"
        }
        CheckBox {
            font {family: "Verdana"; pixelSize:16}
            checked: true   // флажок отмечен
            text: "JavaScript"
        }
    }
}
