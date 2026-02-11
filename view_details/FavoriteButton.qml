import QtQuick 2.0
// FavoriteButton: clickable button to toggle games favorite status
Rectangle {
    id: root
    focus: true
    anchors {
        left: parent.left
        right:  parent.right
        rightMargin: defaultPadding
    }

    height: vpx(26)
    color: activeFocus ? colorAmigaOrange :
        (favoriteButtonArea.containsMouse ? colorAmigaOrange : "white")

    Image {
        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
        source: currentGame.favorite ?
            "../images/assets/fav_filled.svg" : "../images/assets/fav_hollow.svg"
        sourceSize.height: detailsTextHeight
        height: vpx(20)
    }

    MouseArea {
        id: favoriteButtonArea
        anchors.fill: parent
        onClicked: toggleFavorite()
        hoverEnabled: true
    }

    // favoriteButton move focus
    KeyNavigation.tab: boxart
    Keys.onUpPressed: {
        if (currentGameIndex > 0) currentGameIndex--;
        gameList.forceActiveFocus();
    }
    Keys.onDownPressed: {
        if (currentGameIndex < gameList.count - 1) currentGameIndex++;
        gameList.forceActiveFocus();
    }
    Keys.onPressed: {
        if (event.isAutoRepeat) {
            return;
        } else if (api.keys.isAccept(event)) {
            event.accepted = true;
            toggleFavorite();
            return;
        } else if (api.keys.isDetails(event)) {
            event.accepted = true;
            launchButton.forceActiveFocus();
            return;
        }
    }
} // end favoriteButton rectangle
