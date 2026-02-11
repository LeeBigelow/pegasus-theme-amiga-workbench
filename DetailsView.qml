import QtQuick 2.7 // Text padding is used below and that was added in 2.7
import SortFilterProxyModel 0.2
import "view_details/utils.js" as Utils // some helper functions
import "view_details"
import "view_shared"

// The details "view". Consists of some images, a bunch of textual info and a game list.
FocusScope {
    id: root
    // Nothing particularly interesting, see CollectionsView for more comments
    width: parent.width
    height: parent.height
    enabled: focus
    visible: y < parent.height

    readonly property int detailsTextHeight: vpx(28)
    property var currentCollection: collectionsView.currentCollection
    // for theme.qml access
    property alias boxartOrder: boxart.order
    property alias filterBox: filterBox
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
                pattern: filterBox.filterInput.text
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
    Keys.onPressed: switch (true) {
        case (event.isAutoRepeat): return;
        case (api.keys.isAccept(event)):   { event.accepted = true; launchGame(); return;}
        case (api.keys.isCancel(event)):   { event.accepted = true; cancel(); return; }
        case (api.keys.isNextPage(event)): { event.accepted = true; nextCollection(); return; }
        case (api.keys.isPrevPage(event)): { event.accepted = true; prevCollection(); return; }
        case (api.keys.isFilters(event)):  { event.accepted = true; toggleFavorite(); return; }
        case (api.keys.isPageUp(event)): {
            event.accepted = true;
            (currentGameIndex - 15) < 0 ?  currentGameIndex = 0 : currentGameIndex -= 15;
            return;
        }
        case (api.keys.isPageDown(event)): {
            event.accepted = true;
            (currentGameIndex + 15) > (currentCollection.games.count - 1) ?
                currentGameIndex = (currentCollection.games.count - 1) :
                currentGameIndex += 15;
            return;
        }
    } // end Keys.onPressed

    // Background
    Rectangle {
        // dark background
        width: root.width
        height: root.height
        anchors.fill: parent
        color: colorAmigaBlue
    }

    //
    // Header
    //
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
            onPressed: { startX = mouse.x; startY = mouse.y; }
            onReleased: {
                if (mouse.y - startY > vpx(100)) { cancel(); return; }
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
            source: "images/assets/titlebar.png"
            sourceSize.width: parent.width
            sourceSize.height: vpx(20)
            width: sourceSize.width
            height: sourceSize.height
            asynchronous: true
        }

        // game count in titlebar
        Text {
            id: gamecount
            anchors.centerIn: titlebar
            text: "%1: %2 GAMES".arg(currentCollection.shortName).arg(currentCollection.games.count)
            color: colorAmigaBlue
            font.pixelSize: vpx(16)
            font.family: amigaFont.name
        }

        // containter for console+controller image and it's window frame
        Item {
            id: consoleController
            anchors {
                top: titlebar.bottom
                topMargin: defaultPadding * 2
                left: parent.left
                leftMargin: defaultPadding
            }
            height: vpx(100)
            width: vpx(600)
            Item {
                // console+controller inner images
                height: parent.height
                width: consoleGame.width + controller.width + defaultPadding
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
                        "images/consolegame/%1.svg".arg(currentCollection.shortName) : ""
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
                        leftMargin: defaultPadding
                    }
                    fillMode: Image.PreserveAspectFit
                    source: currentCollection.shortName ?
                        "images/controller/%1.svg".arg(currentCollection.shortName) : ""
                    sourceSize.height: vpx(90)
                    height: sourceSize.height
                    asynchronous: true
                }
            } // console+controller inner images

            Image {
                // attach window to top-left of image and shift
                // up and left for titlebar/border widths
                id: consoleControllerWindow
                anchors {
                    top: parent.top
                    left: parent.left
                    topMargin: vpx(-20)
                    leftMargin: vpx(-2)
                }
                source: "images/assets/details-window-console.png"
                sourceSize.width: parent.width + vpx(4)
                sourceSize.height: parent.height + vpx(22)
                width: sourceSize.width
                height: sourceSize.height
            }
        } // end containter for console+controller image and its window

        // system logo and it's window frame
        Item {
            anchors {
                top: titlebar.bottom
                topMargin: defaultPadding * 2
                right: parent.right
                rightMargin: defaultPadding
            }
            height: vpx(100)
            width: vpx(600)

            Item {
                id: logoOrLabel
                anchors {
                    top: parent.top
                    topMargin: vpx(5)
                    right: parent.right
                    centerIn: parent
                }
                width: vpx(590)
                height: vpx(90)

                Image {
                    id: logo
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    source: currentCollection.shortName ?
                        "images/logo/%1.svg".arg(currentCollection.shortName) : undefined
                    sourceSize.width: parent.width
                    sourceSize.height: parent.height
                    width: sourceSize.width
                    height: sourceSize.height
                    // async causing the text label to flash
                    //asynchronous: true
                }

                Text {
                    id: logoLabel
                    anchors.centerIn: parent
                    color: "white"
                    font.family: amigaFont.name
                    font.pixelSize: vpx(24)
                    text: currentCollection.name // shortName should be in titlebar
                    horizontalAlignment: Text.AlignHCenter
                    visible: logo.status != Image.Ready
                }
            }

            Image {
                id: logoWindow
                anchors {
                    top: parent.top
                    topMargin: vpx(-20)
                    left: parent.left
                    leftMargin: vpx(-2)
                }
                source: "images/assets/details-window-system.png"
                sourceSize.width: parent.width + vpx(4)
                sourceSize.height: parent.height + vpx(22)
                width: sourceSize.width
                height: sourceSize.height
            }
        } // end logo and window containter
    } // end top header for titlebar, console and logo windows

    //
    // Game List and Filter
    //
    // gamelist and it's window frame
    Item {
        id: gameListContainer
        anchors {
            top: header.bottom
            topMargin: defaultPadding
            left: parent.left
            leftMargin: defaultPadding
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
                topMargin: defaultPadding / 2
                rightMargin: defaultPadding / 2
                bottomMargin: defaultPadding / 2
            }
            focus: true
            clip: true
            highlightMoveDuration: 0

            model: filteredGames
            delegate: GameListDelegate {}

            // gameList move focus
            KeyNavigation.tab: filterBox.filterInput
            Keys.onPressed: {
                if (event.isAutoRepeat) {
                    return;
                } else if (api.keys.isDetails(event)) {
                    event.accepted = true;
                    boxart.forceActiveFocus();
                    return;
                }
            }
        } // end gameList ListView

        Image {
            // gameList window frame
            id: gameListWindow
            anchors {
                top: parent.top
                topMargin: vpx(-20)
                left: parent.left
                leftMargin: vpx(-2)
            }
            source: gameList.activeFocus ?
                "images/assets/details-window-games-focused.png" :
                "images/assets/details-window-games-unfocused.png"
            sourceSize.width: parent.width + vpx(4)
            sourceSize.height: parent.height + vpx(22)
            width: sourceSize.width
            height: sourceSize.height
        }
    } // end gameList and it's window container

    Text {
        id: filterLabel
        anchors {
            top: gameListContainer.bottom
            topMargin: vpx(5)
            bottom: footer.top
            bottomMargin: defaultPadding / 2
            left: parent.left
            leftMargin: defaultPadding
        }
        verticalAlignment: Text.AlignVCenter
        font.family: amigaFont.name
        font.pixelSize: vpx(16)
        font.weight: Font.DemiBold
        color: "white"
        text: "Filter:"
    }

    FilterBox {
        // has filterInput property alias for accepting focus and getting text
        id: filterBox
        anchors {
            top: gameListContainer.bottom
            topMargin: vpx(5)
            bottom: footer.top
            bottomMargin: defaultPadding / 2
            left: filterLabel.right
            leftMargin: vpx(5)
            right: gameListContainer.right
        }
    }

    //
    // Details and Game Art
    //
    Item {
        // art, details, description and it's window frame
        anchors {
            top: header.bottom
            topMargin: defaultPadding
            left: gameListContainer.right
            leftMargin: defaultPadding * 2
            right: parent.right
            rightMargin: defaultPadding
            bottom: footer.top
            bottomMargin: defaultPadding / 2
        }

        opacity: 0.95

        Boxart {
            id: boxart
            anchors {
                top: parent.top;
                topMargin: defaultPadding / 2
                left: parent.left;
                leftMargin: defaultPadding / 2
            }
        }

        RatingBar {
            id: ratingBar
            anchors {
                top: parent.top
                topMargin: defaultPadding
                left: boxart.right
                leftMargin: defaultPadding
            }
            percentage: currentGame.rating
        }

        // While the game details could be a grid, I've separated them to two
        // separate columns to manually control the width of the second one below.
        Column {
            id: gameLabels
            anchors {
                top: ratingBar.bottom
                topMargin: defaultPadding / 2
                left: boxart.right
                leftMargin: defaultPadding
            }
            GameInfoLabel { text: "Released:" }
            GameInfoLabel { text: "Developer:" }
            GameInfoLabel { text: "Publisher:" }
            GameInfoLabel { text: "Genre:" }
            GameInfoLabel { text: "Players:" }
            GameInfoLabel { text: "Last played:" }
            GameInfoLabel { text: "Play time:" }
            GameInfoLabel { text: "Favorite:" }
        }

        Column {
            id: gameDetails
            anchors {
                top: gameLabels.top
                left: gameLabels.right
                leftMargin: defaultPadding / 2
                right: parent.right
                rightMargin: defaultPadding
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
            FavoriteButton { id: favoriteButton }
        }

        LaunchButton {
            id: launchButton
            anchors {
                top: gameLabels.bottom
                topMargin: defaultPadding / 2
                left: boxart.right
                leftMargin: defaultPadding
                right: parent.right
                rightMargin: defaultPadding + vpx(18)
            }
        }

        //
        // Game Description
        //
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

            DescriptionScroll {
                id: descriptionScroll
                anchors {
                    fill: parent
                    topMargin: defaultPadding / 2
                    bottomMargin: defaultPadding / 2
                    leftMargin: defaultPadding
                    rightMargin: defaultPadding
                }
            } // end descriptionScroll
        } // end description rectangle

        Image {
            // details window
            // show active frame if any children have focus
            anchors {
                top: parent.top
                topMargin: vpx(-20)
                left: parent.left
                leftMargin: vpx(-2)
            }
            source: (descriptionScroll.activeFocus ||
                     boxart.activeFocus ||
                     launchButton.activeFocus ||
                     favoriteButton.activeFocus) ?
                "images/assets/details-window-details-focused.png" :
                "images/assets/details-window-details-unfocused.png"
            sourceSize.width: parent.width + vpx(4)
            sourceSize.height: parent.height + vpx(22)
            width: sourceSize.width
            height: sourceSize.height
        }
    } // end art, details, description and window container

    //
    // Help Footer
    //
    DetailsFooter {
        id: footer
        anchors {
            bottom: parent.bottom
            left: parent.left
            leftMargin: defaultPadding
            right: parent.right
            rightMargin: defaultPadding
        }
    }
}
