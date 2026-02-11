import QtQuick 2.7
// GameListDelegate: rectangle containing game title that changes color with focus
Rectangle {
    id: root
    // rectangle for each gameList item
    readonly property bool selected: ListView.isCurrentItem

    width: ListView.view.width
    height: gameTitle.height
    color: selected ?
        (gameList.activeFocus ? "white" : colorAmigaBlue) :
        "transparent"

    Text {
        id: gameTitle
        text: (modelData.favorite ? "♥" : " ") + " " + modelData.title
        color: selected ?
            (gameList.activeFocus ? colorAmigaBlue : "black") :
            "white"

        font.pixelSize: vpx(20)
        font.capitalization: Font.AllUppercase
        font.family: amigaFont.name
        font.weight: Font.DemiBold

        // set nice fixed height for amiga font
        // some utf8 chars in game titles will cause line
        // to not center vertically
        lineHeightMode: Text.FixedHeight
        lineHeight: vpx(30)
        verticalAlignment: Text.AlignVCenter

        width: parent.width
        elide: Text.ElideRight
        leftPadding: vpx(5)
        rightPadding: vpx(10)
    }

    MouseArea {
        // gameList mouse actions
        // focus on click, launch on double click
        anchors.fill: parent
        onClicked: {
            gameList.currentIndex=index;
            gameList.forceActiveFocus();
        }
        onDoubleClicked: launchGame()
    }
} // end gameList delegate rectangle
