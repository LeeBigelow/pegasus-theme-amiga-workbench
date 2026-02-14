import QtQuick 2.0
// AmigaTitlebar: main screen title for both views
Rectangle {
    id: root
    anchors {
        top: parent.top
        left: parent.left
        right: parent.right
    }
    height: vpx(20)
    color: "white"

    // left main label
    Text {
        anchors {
            top: parent.top
            left: parent.left
            leftMargin: vpx(5)
            verticalCenter: parent.verticalCenter
        }
        text: "Pegasus - Amiga Workbench."
        verticalAlignment: Text.AlignVCenter
        color: colorAmigaBlue
        font.pixelSize: vpx(16)
        font.family: amigaFont.name
    }

    // game count in titlebar
    Text {
        anchors.centerIn: parent
        text: "%1: %2 GAMES".arg(currentCollection.shortName).arg(currentCollection.games.count)
        color: colorAmigaBlue
        font.pixelSize: vpx(16)
        font.family: amigaFont.name
    }

    Image {
        anchors.top: parent.top
        anchors.right: parent.right
        source: "../images/assets/window-parts/top-right.png"
        width: vpx(56)
        height: vpx(20)
    }
}
