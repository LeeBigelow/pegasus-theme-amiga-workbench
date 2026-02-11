import QtQuick 2.0
// Boxart: show game images, cycle images on click or swipe
Rectangle {
    // need container to control boxart size
    id: boxart
    focus: true
    property var order: 0
    property var boxWidth: vpx(428)
    property var boxHeight: vpx(321)
    width: boxartImage.status === Image.Ready ? boxWidth : vpx(5)
    height: boxHeight
    color: "transparent"
    border.width: vpx(1)
    border.color: activeFocus ? "white" : "transparent"
    KeyNavigation.tab: gameList
    // boxart focuses gameList on up/down
    Keys.onUpPressed: {
        if (currentGameIndex > 0) currentGameIndex--;
        gameList.forceActiveFocus();
    }
    Keys.onDownPressed: {
        if (currentGameIndex < gameList.count - 1) currentGameIndex++;
        gameList.forceActiveFocus();
    }
    Keys.onPressed: {
        if (api.keys.isAccept(event)) {
            // cycle boxart
            event.accepted = true;
            (order < 2) ? order++ : order=0;
            return;
        } else if (api.keys.isDetails(event)) {
            event.accepted = true;
            favoriteButton.forceActiveFocus();
            return;
        }
    }

    MouseArea {
        // swipe gestures for box art
        // left, right, and double click switches art
        anchors.fill: parent
        property int startX
        onPressed: startX = mouse.x
        onReleased: {
            if (mouse.x - startX > vpx(50))
                (boxart.order < 2) ? boxart.order++ : boxart.order=0;
            else if (startX - mouse.x > vpx(50))
                (boxart.order > 0) ? boxart.order-- : boxart.order=2;
        }
        onClicked: boxart.forceActiveFocus()
        onDoubleClicked: (boxart.order < 2) ? boxart.order++ : boxart.order=0;
    }

    Image {
        id: boxartImage

        anchors.fill: parent
        anchors.centerIn: parent
        anchors.margins: vpx(2)
        fillMode: Image.PreserveAspectFit
        // keep alternative images available when
        // switching art preference
        source: switch (boxart.order) {
            case 0: return (
                currentGame.assets.boxFront ||
                currentGame.assets.screenshot ||
                currentGame.assets.marquee
            );
            case 1: return (
                currentGame.assets.screenshot ||
                currentGame.assets.marquee ||
                currentGame.assets.boxFront
            );
            case 2: return (
                currentGame.assets.marquee ||
                currentGame.assets.screenshot ||
                currentGame.assets.boxFront
            );
        }
        sourceSize.width: boxart.boxWidth
        sourceSize.height: boxart.boxHeight
        width: sourceSize.width
        height: sourceSize.height
    } // end boxartImage
} // end boxart rectangle
