import QtQuick 2.15 // note the version: Text padding is used below and that was added in 2.7 as per docs
import "utils.js" as Utils // some helper functions
import "collections.js" as Collections // collection definitions

// The details "view". Consists of some images, a bunch of textual info and a game list.
FocusScope {
    id: root

    // This will be set in the main theme file
    property var currentCollection
    property var favoritesCollection
    property var lastPlayedCollection

    property var colorAmigaBlue
    property var colorAmigaOrange
    property var collectionInfo: Collections.COLLECTIONS[currentCollection.shortName]

    // Shortcuts for the game list's currently selected game
    readonly property var gameList: gameList
    property alias currentGameIndex: gameList.currentIndex
    readonly property var currentGame: switch(currentCollection.shortName) {
        case "auto-lastplayed":
            return lastPlayedCollection.sourceGame(currentGameIndex);
        case "auto-favorites":
            return favoritesCollection.sourceGame(currentGameIndex);
        default:
            return currentCollection.games.get(currentGameIndex);
    }

    readonly property int padding: vpx(20)
    readonly property int detailsTextHeight: vpx(30)

    // Nothing particularly interesting, see CollectionsView for more comments
    width: parent.width
    height: parent.height
    enabled: focus
    visible: y < parent.height

    signal cancel
    signal nextCollection
    signal prevCollection
    signal launchGame
    signal toggleFavorite

    // Key handling. In addition, pressing left/right also moves to the prev/next collection.
    Keys.onLeftPressed: prevCollection()
    Keys.onRightPressed: nextCollection()
    Keys.onPressed:
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
        id: gameListBg
        anchors {
            top: header.bottom
            topMargin: root.padding
            left: parent.left
            leftMargin: root.padding
            bottom: footer.top
            bottomMargin: root.padding / 2
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

            model: currentCollection.games

            delegate:
                Rectangle {
                    // rectangle for each gameList item
                    readonly property bool selected: ListView.isCurrentItem

                    width: ListView.view.width
                    height: gameTitle.height
                    color:
                        if (selected) {
                            gameList.activeFocus ? "white" : colorAmigaBlue;
                        } else {
                            return "transparent";
                        }

                    Text {
                        id: gameTitle
                        text: (modelData.favorite ? "♥" : " ") + " " + modelData.title
                        color:
                            if (selected) {
                                gameList.activeFocus ? colorAmigaBlue : "black";
                            } else {
                                return "white";
                            }

                        font.pixelSize: vpx(20)
                        font.capitalization: Font.AllUppercase
                        font.family: amigaFont.name
                        font.weight: Font.DemiBold

                        lineHeight: 1.2
                        verticalAlignment: Text.AlignVCenter

                        width: parent.width
                        elide: Text.ElideRight
                        leftPadding: vpx(5)
                        rightPadding: vpx(10)
                    }
                }

            clip: true
            highlightMoveDuration: 0
            highlightRangeMode: ListView.ApplyRange
            preferredHighlightBegin: height * 0.5 - vpx(15)
            preferredHighlightEnd: height * 0.5 + vpx(15)

            // toggle focus on tab and details key (i)
            KeyNavigation.tab: descriptionScroll
            Keys.onPressed:
                if (event.isAutoRepeat) {
                    return;
                } else if (api.keys.isDetails(event)) {
                    event.accepted = true;
                    descriptionScroll.forceActiveFocus();
                    return;
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
    } // end gamelist and window container

    Item {
        // art, details, description and window container
        anchors {
            top: header.bottom
            topMargin: root.padding
            left: gameListBg.right
            leftMargin: root.padding * 2
            right: parent.right
            rightMargin: root.padding
            bottom: footer.top
            bottomMargin: root.padding / 2
        }

        opacity: 0.95

        Item {
            // need container to control boxart size
            id: boxart
            anchors {
                top: parent.top;
                topMargin: root.padding / 2
                left: parent.left;
                leftMargin: root.padding / 2
            }
            width: boxartImage.status === Image.Ready ? vpx(384) : 0
            height: vpx(288)

            Image {
                id: boxartImage

                anchors.fill: parent
                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                // skyscraper screenshoot is nice mixed image 3:4 ratio
                source: currentGame.assets.screenshot ||
                        currentGame.assets.boxFront ||
                        currentGame.assets.logo ||
                        currentGame.assets.marquee
                sourceSize.width: vpx(384)
                sourceSize.height: vpx(288)
                width: sourceSize.width
                height: sourceSize.height
            }
        }

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
            // wrap description in rectangle for border on focus
            anchors {
                top: boxart.bottom
                topMargin: root.padding / 2
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                bottomMargin: root.padding / 2
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
                }
                clip: true
                focus: true
                onFocusChanged: { contentY = 0; }
                contentWidth: parent.width
                contentHeight: gameDescription.height
                flickableDirection: Flickable.VerticalFlick

                Text {
                    id: gameDescription
                    topPadding: root.padding / 2
                    bottomPadding: root.padding / 2
                    leftPadding: root.padding
                    rightPadding: root.padding
                    text: currentGame.description
                    wrapMode: Text.WordWrap
                    width: descriptionScroll.width
                    //elide: Text.ElideRight
                    font.pixelSize: vpx(16)
                    font.family: amigaFont.name
                    font.weight: Font.DemiBold
                    color: "white"
                }

                // Keybindings for descriptionScroll
                // scroll description on up and down
                Keys.onUpPressed:
                    if ((contentY - 10) < 0) {
                        contentY = 0;
                    } else {
                        contentY -= 10;
                    }
                Keys.onDownPressed:
                    if ((contentY + 10) > (gameDescription.height - height)) {
                        contentY = gameDescription.height - height;
                    } else {
                        contentY += 10;
                    }
                // Toggle focus on tab and details key (i)
                KeyNavigation.tab: gameList
                Keys.onPressed:
                    if (event.isAutoRepeat) {
                        return;
                    } else if (api.keys.isDetails(event)) {
                        event.accepted = true;
                        gameList.forceActiveFocus();
                        return;
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
            source: descriptionScroll.activeFocus ?
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
            imageLabel: "Select"
        }

        FooterImage {
            id: aButton
            anchors.left: bButton.right
            anchors.bottom: parent.bottom
            imageSource: "assets/button_a.svg"
            imageLabel: "Back"
        }

        FooterImage {
            id: xButton
            anchors.left: aButton.right
            anchors.bottom: parent.bottom
            imageSource: "assets/button_x.svg"
            imageLabel: "Toggle Favorite"
        }

        FooterImage {
            id: yButton
            anchors.left: xButton.right
            anchors.bottom: parent.bottom
            imageSource: "assets/button_y.svg"
            imageLabel: "Toggle Focus"
        }

        FooterImage {
            id: startButton
            anchors.left: yButton.right
            anchors.bottom: parent.bottom
            imageSource: "assets/button_start.svg"
            imageLabel: "Settings"
        }
    }
}
