import QtQuick 2.7 // Text padding is used below and that was added in 2.7
import QtQuick.Layouts 1.15
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

    // Header: titlebar, console+controller and logo windows
    DetailsHeader {
        id: header
        anchors {
            top: parent.top
            right: parent.right
            left: parent.left
        }
    }

    // Game List size defined by this gameListWindow
    Image {
        // gameList window frame
        id: gameListWindow
        anchors {
            top: header.bottom
            left: parent.left
            leftMargin: defaultPadding
        }
        source: gameList.activeFocus ?
            "images/assets/details-window-games-focused.png" :
            "images/assets/details-window-games-unfocused.png"
        width: vpx(448)
        height: vpx(480)
    }

    ListView {
        id: gameList
        anchors {
            fill: gameListWindow
            // adjust for window decorations and padding
            topMargin: vpx(24)
            leftMargin: vpx(6)
            rightMargin: vpx(20)
            bottomMargin: vpx(6)
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

    Text {
        id: filterLabel
        anchors {
            top: gameListWindow.bottom
            topMargin: vpx(5)
            left: parent.left
            leftMargin: defaultPadding
        }
        verticalAlignment: Text.AlignVCenter
        font.family: amigaFont.name
        font.pixelSize: vpx(16)
        font.weight: Font.DemiBold
        color: "white"
        text: "Filter:"
        height: vpx(24)
    }

    FilterBox {
        // has filterInput property alias for accepting focus and getting text
        id: filterBox
        anchors {
            top: gameListWindow.bottom
            topMargin: vpx(5)
            left: filterLabel.right
            leftMargin: vpx(5)
            right: gameListWindow.right
        }
        height: vpx(24)
    }

    // Game Art, Details and Description
    // Eveything contained in this detailsWindow
    Image {
        id: detailsWindow
        // details window
        // show active frame if any children have focus
        anchors {
            top: header.bottom
            left: gameListWindow.right
            leftMargin: defaultPadding
            right: parent.right
            rightMargin: defaultPadding
        }
        height: vpx(510)
        source: (descriptionScroll.activeFocus ||
                 boxart.activeFocus ||
                 launchButton.activeFocus ||
                 favoriteButton.activeFocus) ?
            "images/assets/details-window-details-focused.png" :
            "images/assets/details-window-details-unfocused.png"
    }

    Boxart {
        id: boxart
        anchors {
            top: detailsWindow.top;
            // ajust for titlebar
            topMargin: vpx(23)
            left: detailsWindow.left;
            leftMargin: vpx(8)
        }
    }

    RatingBar {
        id: ratingBar
        anchors {
            top: detailsWindow.top
            // ajust for titlebar
            topMargin: vpx(23)
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
            right: detailsWindow.right
            // adjust for scrollbar and padding
            rightMargin: vpx(35)
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
            right: detailsWindow.right
            // adjust for scrollbar and padding
            rightMargin: vpx(35)
        }
    }

    // Game Description
    Rectangle {
        // wrap description in rectangle for border on focus
        anchors {
            top: boxart.bottom
            left: detailsWindow.left
            right: detailsWindow.right
            bottom: detailsWindow.bottom
            // adjust for window frame and padding
            rightMargin: vpx(18)
            leftMargin: vpx(3)
            bottomMargin: vpx(3)
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
        }
    } // end description rectangle

    // Help Footer
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
