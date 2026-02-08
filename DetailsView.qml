import QtQuick 2.15 // note the version: Text padding is used below and that was added in 2.7 as per docs
import SortFilterProxyModel 0.2
import "utils.js" as Utils // some helper functions
import "collections.js" as Collections // collection definitions

// The details "view". Consists of some images, a bunch of textual info and a game list.
FocusScope {
    id: root

    // Nothing particularly interesting, see CollectionsView for more comments
    width: parent.width
    height: parent.height
    enabled: focus
    visible: y < parent.height

    readonly property int padding: vpx(20)
    readonly property int detailsTextHeight: vpx(30)
    readonly property var collectionInfo: Collections.COLLECTIONS[currentCollection.shortName]
    property var currentCollection: collectionsView.currentCollection
    // for theme.qml access
    property alias boxartOrder: boxart.order
    property alias filterText: filterInput.text
    property alias gameList: gameList
    property alias currentGameIndex: gameList.currentIndex
    property var filteredSourceIndex: filteredGames.mapToSource(currentGameIndex)
    readonly property var currentGame: {
        switch(currentCollection.shortName) {
            // extendedCollections ListModel can't hold item functions so need
            // to reference items directly.
            // "lastplayed" and "favorites" are self filtered so need their
            // item functions to get source game.
            case "auto-lastplayed":
                return lastPlayedCollection.sourceGame(filteredSourceIndex);
            case "auto-favorites":
                return favoritesCollection.sourceGame(filteredSourceIndex);
                // "all games" and original collection not self filtered so
                // can reference their games directly
            default:
                return currentCollection.games.get(filteredSourceIndex);
        }
    }

    SortFilterProxyModel {
        id: filteredGames
        sourceModel: currentCollection.games
        filters: RegExpFilter {
                roleName: "title"
                pattern: filterInput.text
                caseSensitivity: Qt.CaseInsensitive
        }
    }

    signal cancel
    signal nextCollection
    signal prevCollection
    signal launchGame
    signal toggleFavorite

    // Key handling. In addition, pressing left/right also moves to the prev/next collection.
    Keys.onLeftPressed: prevCollection()
    Keys.onRightPressed: nextCollection()
    Keys.onPressed: {
        if (event.isAutoRepeat) {
            return;
        } else if (api.keys.isAccept(event)) {
            event.accepted = true;
            launchGame();
            return;
        } else if (api.keys.isCancel(event)) {
            event.accepted = true;
            cancel();
            return;
        } else if (api.keys.isNextPage(event)) {
            event.accepted = true;
            nextCollection();
            return;
        } else if (api.keys.isPrevPage(event)) {
            event.accepted = true;
            prevCollection();
            return;
        } else if (api.keys.isFilters(event)) {
            event.accepted = true;
            toggleFavorite();
            return;
        } else if (api.keys.isPageUp(event)) {
            event.accepted = true;
            if ( (currentGameIndex - 15) < 0 ) {
                currentGameIndex = 0;
            } else {
                currentGameIndex -= 15;
            }
            return;
        } else if (api.keys.isPageDown(event)) {
            event.accepted = true;
            if ((currentGameIndex + 15) > (currentCollection.games.count - 1)) {
                currentGameIndex = (currentCollection.games.count - 1);
            } else {
                currentGameIndex += 15;
            }
            return;
        }
    } // end Keys.onPressed


    Rectangle {
        // dark background
        width: root.width
        height: root.height
        // background
        anchors.fill: parent
        color: colorAmigaBlue
    }


    Item {
        // top header for titlebar, console and logo windows
        id: header
        anchors {
            top: parent.top
            right: parent.right
            left: parent.left
        }

        height: vpx(180)

        MouseArea {
            // swipe gestures for detailsView header
            // left and right swipe switches current collection
            // down swipe switches to collectionsView
            anchors.fill: parent
            property int startX
            property int startY
            onPressed: {
                startX = mouse.x;
                startY = mouse.y;
            }
            onReleased: {
                if (mouse.y - startY > vpx(100)) {
                    cancel();
                    return;
                }
                if (mouse.x - startX > vpx(50)) nextCollection();
                else if (startX - mouse.x > vpx(50)) prevCollection();
            }
        }

        // titlebar
        Image {
            id: titlebar
            anchors {
                top: parent.top
                left: parent.left
            }
            source: "assets/titlebar.png"
            sourceSize.width: parent.width
            sourceSize.height: vpx(20)
            width: sourceSize.width
            height: sourceSize.height
            asynchronous: true
        }

        // Game count in titlebar
        Text {
            id: gamecount
            anchors.centerIn: titlebar
            text: "%1: %2 GAMES".arg(currentCollection.shortName).arg(currentCollection.games.count)
            color: colorAmigaBlue
            font.pixelSize: vpx(16)
            font.family: amigaFont.name
        }


        Item {
            // containter for console+controller image and window
            id: consoleController
            anchors {
                top: titlebar.bottom
                topMargin: root.padding * 2
                left: parent.left
                leftMargin: root.padding
            }
            height: vpx(100)
            width: vpx(600)
            Item {
                // console+controller inner images
                height: parent.height
                width: consoleGame.width + controller.width + root.padding
                anchors.horizontalCenter: parent.horizontalCenter
                Image {
                    id: consoleGame
                    anchors {
                        top: parent.top
                        topMargin: vpx(5)
                        left: parent.left
                    }
                    fillMode: Image.PreserveAspectFit
                    source: currentCollection.shortName ?
                        "consolegame/%1.svg".arg(currentCollection.shortName) : ""
                    sourceSize.height: vpx(90)
                    height: sourceSize.height
                    asynchronous: true
                }
                Image {
                    id: controller
                    anchors {
                        top: parent.top
                        topMargin: vpx(5)
                        left: consoleGame.right
                        leftMargin: root.padding
                    }
                    fillMode: Image.PreserveAspectFit
                    source: currentCollection.shortName ?
                        "controller/%1.svg".arg(currentCollection.shortName) : ""
                    sourceSize.height: vpx(90)
                    height: sourceSize.height
                    asynchronous: true
                }
            } // console+controller inner images

            Image {
                id: consoleControllerWindow
                anchors {
                    top: parent.top
                    topMargin: vpx(-20)
                    left: parent.left
                    leftMargin: vpx(-2)
                }
                source: "assets/details-window-console.png"
                sourceSize.width: parent.width + vpx(4)
                sourceSize.height: parent.height + vpx(22)
                width: sourceSize.width
                height: sourceSize.height
            }
        } // end containter for console+controller image and window

        Item {
            // system logo and window containter
            anchors {
                top: titlebar.bottom
                topMargin: root.padding * 2
                right: parent.right
                rightMargin: root.padding
            }
            height: vpx(100)
            width: vpx(600)

            Image {
                id: logo
                anchors {
                    top: parent.top
                    topMargin: vpx(5)
                    right: parent.right
                    centerIn: parent
                }
                fillMode: Image.PreserveAspectFit
                source: currentCollection.shortName ?
                    "logo/%1.svg".arg(currentCollection.shortName) : undefined
                sourceSize.width: vpx(590)
                sourceSize.height: vpx(90)
                width: sourceSize.width
                height: sourceSize.height
                asynchronous: true
            }

            Image {
                id: logoWindow
                anchors {
                    top: parent.top
                    topMargin: vpx(-20)
                    left: parent.left
                    leftMargin: vpx(-2)
                }
                source: "assets/details-window-system.png"
                sourceSize.width: parent.width + vpx(4)
                sourceSize.height: parent.height + vpx(22)
                width: sourceSize.width
                height: sourceSize.height
            }
        } // end logo and window containter
    } // end top header for titlebar, console and logo windows

    //
    // Main content
    //
    Item {
        // gamelist and window containter
        id: gameListContainer
        anchors {
            top: header.bottom
            topMargin: root.padding
            left: parent.left
            leftMargin: root.padding
            bottom: footer.top
            // space for filter box
            bottomMargin: vpx(40)
        }
        width: parent.width * 0.35
        height: parent.height
        opacity: 0.95


        ListView {
            id: gameList
            width: parent.width
            anchors.fill: parent
            anchors {
                topMargin: root.padding / 2
                rightMargin: root.padding / 2
                bottomMargin: root.padding / 2
            }
            focus: true

            model: filteredGames

            delegate: Rectangle {
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

            clip: true
            highlightMoveDuration: 0
            // highlightRangeMode: ListView.ApplyRange
            // preferredHighlightBegin: height * 0.5 - vpx(15)
            // preferredHighlightEnd: height * 0.5 + vpx(15)

            // toggle focus on tab and details key (i)
            KeyNavigation.tab: filterInput
            Keys.onPressed: {
                if (event.isAutoRepeat) {
                    return;
                } else if (api.keys.isDetails(event)) {
                    event.accepted = true;
                    filterInput.forceActiveFocus();
                    return;
                }
            }
        } // end gameList ListView

        Image {
            // gameListWindow
            id: gameListWindow
            anchors {
                top: parent.top
                topMargin: vpx(-20)
                left: parent.left
                leftMargin: vpx(-2)
            }
            source: gameList.activeFocus ?
                "assets/details-window-games-focused.png" :
                "assets/details-window-games-unfocused.png"
            sourceSize.width: parent.width + vpx(4)
            sourceSize.height: parent.height + vpx(22)
            width: sourceSize.width
            height: sourceSize.height
        }
    } // end gameListContainer

    Item {
        // filterLabel and filterInput container
        anchors {
            top: gameListContainer.bottom
            topMargin: vpx(5)
            bottom: footer.top
            bottomMargin: root.padding / 2
            left: parent.left
            leftMargin: root.padding
        }
        width: gameListContainer.width

        Text {
            id: filterLabel
            anchors {
                top: parent.top
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            verticalAlignment: Text.AlignVCenter
            font.family: amigaFont.name
            font.pixelSize: vpx(16)
            font.weight: Font.DemiBold
            color: "white"
            text: "Filter:"
        }

        Rectangle {
            id: filterInputBg
            color: filterInput.activeFocus ? "white" : colorAmigaBlue
            anchors {
                top: parent.top
                left: filterLabel.right
                leftMargin: vpx(5)
                bottom: parent.bottom
                right: parent.right
            }

            TextInput {
                id: filterInput
                anchors {
                    fill: parent
                    leftMargin: vpx(5)
                    rightMargin: vpx(5)
                    verticalCenter: parent.verticalCenter
                }
                focus: true
                color: filterInput.activeFocus ? colorAmigaBlue : "black"
                font.family: amigaFont.name
                font.pixelSize: vpx(16)
                font.capitalization: Font.AllUppercase
                verticalAlignment: Text.AlignVCenter
                KeyNavigation.tab: descriptionScroll
                Keys.onUpPressed: {
                    if (currentGameIndex > 0) currentGameIndex--;
                    gameList.forceActiveFocus();
                }
                Keys.onDownPressed: {
                    if (currentGameIndex < gameList.count - 1) currentGameIndex++;
                    gameList.forceActiveFocus();
                }
                Keys.onPressed: {
                    if (event.isAutoRepeat) return;
                    if (event.key != Qt.Key_Tab && !api.keys.isDetails(event))
                        // keep game index on last item when typing or details don't refresh?
                        // but not when switching focus
                        currentGameIndex = gameList.count - 1;
                    if (event.key == Qt.Key_I) {
                        // catch i key so it doesn't shift focus as Details Key
                        event.accepted=true;
                        filterInput.insert(cursorPosition,"i");
                        return;
                    } else if (event.key == Qt.Key_Left && cursorPosition == 0) {
                        // catch left key to stop acidental collection switching
                        event.accepted=true;
                        return;
                    } else if (event.key == Qt.Key_Right && cursorPosition == text.length) {
                        // catch right key to stop acidental collection switching
                        event.accepted=true;
                        return;
                    } else if (api.keys.isDetails(event)) {
                        event.accepted = true;
                        descriptionScroll.forceActiveFocus();
                    }
                } // end Keys.OnPressed
            } // end FilterInput
        } // end filterInputBg
    } // end box for filterInput

    Item {
        // art, details, description and window container
        anchors {
            top: header.bottom
            topMargin: root.padding
            left: gameListContainer.right
            leftMargin: root.padding * 2
            right: parent.right
            rightMargin: root.padding
            bottom: footer.top
            bottomMargin: root.padding / 2
        }

        opacity: 0.95

        Rectangle {
            // need container to control boxart size
            id: boxart
            anchors {
                top: parent.top;
                topMargin: root.padding / 2
                left: parent.left;
                leftMargin: root.padding / 2
            }
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
                    event.accepted = true;
                    (order < 2) ? order++ : order=0;
                    return;
                } else if (api.keys.isDetails(event)) {
                    event.accepted = true;
                    gameList.forceActiveFocus();
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

        RatingBar {
            id: ratingBar
            anchors {
                top: parent.top
                topMargin: root.padding
                left: boxart.right
                leftMargin: root.padding
            }
            percentage: currentGame.rating
        }

        // While the game details could be a grid, I've separated them to two
        // separate columns to manually control the width of the second one below.
        Column {
            id: gameLabels
            anchors {
                top: ratingBar.bottom
                topMargin: root.padding / 2
                left: boxart.right
                leftMargin: root.padding
            }
            GameInfoLabel { text: "Released:" }
            GameInfoLabel { text: "Developer:" }
            GameInfoLabel { text: "Publisher:" }
            GameInfoLabel { text: "Genre:" }
            GameInfoLabel { text: "Players:" }
            GameInfoLabel { text: "Last played:" }
            GameInfoLabel { text: "Play time:" }
        }

        Column {
            id: gameDetails
            anchors {
                top: gameLabels.top
                left: gameLabels.right
                leftMargin: root.padding / 2
                right: parent.right
                rightMargin: root.padding
            }

            // 'width' is set so if the text is too long it will be cut. I also use some
            // JavaScript code to make some text pretty.

            GameInfoText { text: Utils.formatDate(currentGame.release) || "unknown" }
            GameInfoText { text: currentGame.developer || "unknown" }
            GameInfoText { text: currentGame.publisher || "unknown" }
            GameInfoText { text: currentGame.genre || "unknown" }
            GameInfoText { text: Utils.formatPlayers(currentGame.players) }
            GameInfoText { text: Utils.formatLastPlayed(currentGame.lastPlayed) }
            GameInfoText { text: Utils.formatPlayTime(currentGame.playTime) }
        }

        Rectangle {
            id: launchButton
            anchors {
                top: gameLabels.bottom
                topMargin: root.padding / 2
                left: boxart.right
                leftMargin: root.padding
                right: parent.right
                rightMargin: root.padding + vpx(18)
            }
            focus: true
            color: activeFocus ? colorAmigaOrange :
                (launchButtonArea.containsMouse ? colorAmigaOrange : "white")
            height: vpx(26)

            Text {
                anchors.centerIn: parent
                text: "LAUNCH"
                color: parent.activeFocus ? "black" :
                    (launchButtonArea.containsMouse ? "black" : colorAmigaBlue)
                font.family: amigaFont.name
                font.pixelSize: vpx(20)
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                id: launchButtonArea
                anchors.fill: parent
                onClicked: launchGame()
                hoverEnabled: true
            }

            // Toggle focus on tab and details key (i)
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
                } else if (api.keys.isDetails(event)) {
                    event.accepted = true;
                    boxart.forceActiveFocus();
                    return;
                }
            }
        }

        Rectangle {
            // wrap description in rectangle for border on focus
            anchors {
                top: boxart.bottom
                left: parent.left
                right: parent.right
                rightMargin: vpx(14)
                bottom: parent.bottom
            }
            width: parent.contentWidth
            height: parent.contentHeight
            color: "transparent"
            border.width: vpx(1)
            border.color: descriptionScroll.activeFocus ? "white" : "transparent"

            Flickable {
                id: descriptionScroll
                anchors {
                    fill: parent
                    topMargin: root.padding / 2
                    bottomMargin: root.padding / 2
                    leftMargin: root.padding
                    rightMargin: root.padding
                }
                clip: true
                focus: true
                onFocusChanged: { contentY = 0; }
                contentWidth: parent.width
                contentHeight: gameDescription.height
                flickableDirection: Flickable.VerticalFlick

                Text {
                    id: gameDescription
                    text: currentGame.description
                    wrapMode: Text.WordWrap
                    width: descriptionScroll.width
                    horizontalAlignment: Text.AlignJustify
                    font.pixelSize: vpx(18)
                    // set fixed line height or amiga topaz font behaves badly
                    lineHeightMode: Text.FixedHeight
                    lineHeight: vpx(22)
                    font.family: amigaFont.name
                    font.weight: Font.DemiBold
                    color: "white"
                }

                // Keybindings for descriptionScroll
                // scroll description on up and down
                Keys.onUpPressed: {
                    if ((contentY - 10) < 0) {
                        contentY = 0;
                    } else {
                        contentY -= 10;
                    }
                }
                Keys.onDownPressed: {
                    if ((contentY + 10) > (gameDescription.height - height)) {
                        contentY = gameDescription.height - height;
                    } else {
                        contentY += 10;
                    }
                }
                // Toggle focus on tab and details key (i)
                KeyNavigation.tab: launchButton
                Keys.onPressed: {
                    if (event.isAutoRepeat) {
                        return;
                    } else if (api.keys.isDetails(event)) {
                        event.accepted = true;
                        launchButton.forceActiveFocus();
                        return;
                    }
                }

                MouseArea {
                    // just focus description on click
                    anchors.fill: parent
                    onClicked: descriptionScroll.forceActiveFocus()
                }
            } // end descriptionScroll
        } // end description container

        Image {
            // details window
            anchors {
                top: parent.top
                topMargin: vpx(-20)
                left: parent.left
                leftMargin: vpx(-2)
            }
            source: (descriptionScroll.activeFocus || boxart.activeFocus) ?
                "assets/details-window-details-focused.png" :
                "assets/details-window-details-unfocused.png"
            sourceSize.width: parent.width + vpx(4)
            sourceSize.height: parent.height + vpx(22)
            width: sourceSize.width
            height: sourceSize.height
        }
    } // end art, details, description and window container

    Item {
        id: footer
        anchors {
            bottom: parent.bottom
            left: parent.left
            leftMargin: root.padding
            right: parent.right
            rightMargin: root.padding
        }
        height: vpx(30)

        FooterImage {
            id: leftRightButton
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            imageSource: "assets/dpad_leftright.svg"
            imageLabel: "Collection Switch"
            MouseArea {
                // can also swipe header area
                anchors.fill: parent
                onClicked: nextCollection()
            }
        }

        FooterImage {
            id: upDownButton
            anchors.left: leftRightButton.right
            anchors.bottom: parent.bottom
            imageSource: "assets/dpad_updown.svg"
            imageLabel: "Scroll"
        }

        FooterImage {
            id: bButton
            anchors.left: upDownButton.right
            anchors.bottom: parent.bottom
            imageSource: "assets/button_b.svg"
            MouseArea {
                // can also double click game in list
                anchors.fill: parent
                onClicked: launchGame()
            }
            imageLabel: "Select"
        }

        FooterImage {
            id: aButton
            anchors.left: bButton.right
            anchors.bottom: parent.bottom
            imageSource: "assets/button_a.svg"
            imageLabel: "Back"
            MouseArea {
                // can also swipe down on header area
                anchors.fill: parent
                onClicked: cancel()
            }
        }

        FooterImage {
            id: xButton
            anchors.left: aButton.right
            anchors.bottom: parent.bottom
            imageSource: "assets/button_x.svg"
            imageLabel: "Toggle Favorite"
            MouseArea {
                anchors.fill: parent
                onClicked: toggleFavorite()
            }
        }

        FooterImage {
            id: yButton
            anchors.left: xButton.right
            anchors.bottom: parent.bottom
            imageSource: "assets/button_y.svg"
            imageLabel: "Toggle Focus"
        }

        FooterImage {
            // can swipe in from right to get pegasus settions
            // not sure how to trigger that with alternate mouse action?
            id: startButton
            anchors.left: yButton.right
            anchors.bottom: parent.bottom
            imageSource: "assets/button_start.svg"
            imageLabel: "Settings"
        }
    }
}
