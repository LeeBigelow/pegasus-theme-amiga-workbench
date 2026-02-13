import QtQuick 2.0
import QtGraphicalEffects 1.15
// FavoriteButton: clickable button to toggle games favorite status
Rectangle {
    id: root
    focus: true
    anchors {
        left: parent.left
    }

    width: vpx(160)
    height: vpx(26)
    color: activeFocus ? colorAmigaOrange :
        (favoriteButtonArea.containsMouse ? colorAmigaOrange : "white")
    visible: currentGameIndex >= 0

    Image {
        id: favoriteStar
        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
        source: currentGame.favorite ?
            "../images/assets/star_filled.svg" : "../images/assets/star_hollow.svg"
        sourceSize.height: detailsTextHeight
        height: vpx(20)
        asynchronous: true
    }

    ColorOverlay {
        anchors.fill: favoriteStar
        source: favoriteStar
        color: parent.activeFocus ? "#000000" :
            (favoriteButtonArea.containsMouse ? "#000000" : colorAmigaBlue)
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
