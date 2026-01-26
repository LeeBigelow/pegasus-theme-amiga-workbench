import QtQuick 2.15
import "collections.js" as Collections // collection definitions

// The collections view consists of two carousels, one for the collection logo bar
// and one for the background images. They should have the same number of elements
// to be kept in sync.
FocusScope {
    id: root

    // This element has the same size as the whole screen (ie. its parent).
    // Because this screen itself will be moved around when a collection is
    // selected, I've used width/height instead of anchors.
    width: parent.width
    height: parent.height
    enabled: focus // do not receive key/mouse events when unfocused
    visible: y + height >= 0 // optimization: do not render the item when it's not on screen

    signal collectionSelected

    // Shortcut for the currently selected collection. They will be used
    // by the Details view too, for example to show the collection's logo.
    property alias currentCollectionIndex: logoAxis.currentIndex
    readonly property var currentCollection: logoAxis.model.get(logoAxis.currentIndex)
    property var collectionInfo: Collections.COLLECTIONS[currentCollection.shortName]

    // set from theme.qml
    property var extendedCollections
    property var lastPlayedCollection
    property var favoritesCollection
    property color colorAmigaBlue

    readonly property int padding: vpx(20)

    Component.onCompleted: {
        // clone collections so we can add to it
        for (var i = 0; i < api.collections.count; i++) {
            extendedCollections.append(api.collections.get(i));
        }
        extendedCollections.append(lastPlayedCollection);
        extendedCollections.append(favoritesCollection);
        // only attach model after it's filled
        bgAxis.model = extendedCollections;
        logoAxis.model = extendedCollections;
        // When the theme loads, try to restore the last selected game
        currentCollectionIndex = api.memory.get('collectionIndex') || 0;
        if (extendedCollections.get(currentCollectionIndex).shortName == "auto-lastplayed") {
            // if lauched from lastplayed game will be at top of list on return
            detailsView.currentGameIndex = 0
        } else {
            detailsView.currentGameIndex = api.memory.get('gameIndex') || 0;
        }
        //detailsView.focus = true;
    }



    // These functions can be called by other elements of the theme if the collection
    // has to be changed manually. See the connection between the Collection and
    // Details views in the main theme file.
    function selectNext() {
        logoAxis.incrementCurrentIndex();
    }

    function selectPrev() {
        logoAxis.decrementCurrentIndex();
    }

    // The carousel of background images. This isn't the item we control with the keys,
    // however it reacts to mouse and so should still update the Index.
    Carousel {
        id: bgAxis

        anchors.fill: parent
        itemWidth: width

        model: undefined
        delegate: bgAxisItem
        currentIndex: logoAxis.currentIndex

        highlightMoveDuration: 0 // instant switching
    }

    Component {
        // background color, titlebar, windows and images
        id: bgAxisItem

        Item {
            anchors.fill: parent
            width: root.width
            height: root.height
            visible: PathView.onPath // optimization: do not draw if not visible

            // background
            Rectangle {
                anchors.fill: parent
                color: colorAmigaBlue
            }

            // titlebar
            Image {
                id: titlebar
                anchors {
                    top: parent.top
                    left: parent.left
                }
                width: parent.width
                height: vpx(20)
                source: "assets/collections-titlebar.png"
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
                horizontalAlignment: Text.alignHCenter
            }

            // console + game
            Image {
                id: consoleGameWindow
                anchors {
                    top: titlebar.bottom
                    topMargin: vpx(10)
                    left: parent.left
                    leftMargin: vpx(30)
                }
                width: vpx(562)
                height: vpx(215)
                source: "assets/collections-window-console.png"
                asynchronous: true
                visible: consoleGameImage.status === Image.Ready
                Image {
                    id: consoleGameImage
                    anchors {
                        top: parent.top
                        topMargin: vpx(30)
                        left: parent.left
                        leftMargin: vpx(16)
                    }
                    width: vpx(530)
                    height: vpx(166)
                    fillMode: Image.PreserveAspectFit
                    source: currentCollection.shortName ? "consolegame/%1.svg".arg(currentCollection.shortName) : ""
                    asynchronous: true
                }
            }


            // controller
            Image {
                id: controllerWindow
                anchors {
                    top: titlebar.bottom
                    topMargin: vpx(10)
                    left: consoleGameWindow.right
                    leftMargin: vpx(100)
                }
                width: vpx(319)
                height: vpx(215)
                source: "assets/collections-window-controller.png"
                asynchronous: true
                visible: controllerImage.status === Image.Ready
                Image {
                    id: controllerImage
                    anchors {
                        top: parent.top
                        topMargin: vpx(30)
                        left: parent.left
                        leftMargin: vpx(7)
                    }
                    width: vpx(305)
                    height: vpx(175)
                    fillMode: Image.PreserveAspectFit
                    source: currentCollection.shortName ? "controller/%1.svg".arg(currentCollection.shortName) : ""
                    asynchronous: true
                }
            }
        }
    }

    // I've put the main bar's parts inside this wrapper item to change the opacity
    // of the background separately from the carousel. You could also use a Rectangle
    // with a color that has alpha value.
    Item {
        id: logoBar
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        height: vpx(170)

        // Background
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            opacity: 0.85
        }

        // The main carousel that we actually control
        Carousel {
            id: logoAxis

            anchors.fill: parent
            itemWidth: vpx(480)

            model: undefined
            delegate: CollectionLogo {
                longName: model.name
                shortName: model.shortName
            }

            focus: true

            Keys.onPressed:
                if (event.isAutoRepeat) {
                    return;
                } else if (api.keys.isNextPage(event)) {
                    event.accepted = true;
                    incrementCurrentIndex();
                } else if (api.keys.isPrevPage(event)) {
                    event.accepted = true;
                    decrementCurrentIndex();
                }

            onItemSelected: root.collectionSelected()
        }

        Image {
            anchors {
                left: parent.left
                top: parent.top
                topMargin: vpx(-20)
            }
            height: vpx(208)
            width: parent.width
            source: "assets/collections-window-system.png"
            asynchronous: true
        }
    }

    // Collection Info section
    Item {
        anchors {
            left: parent.left
            leftMargin: vpx(600)
            top: logoBar.bottom
            topMargin: vpx(30)
            bottom: footer.top
        }

        Image {
            id: collectionInfoWindow
            anchors {
                top: parent.top
                left: parent.left 
            }
            width: vpx(526)
            height: vpx(205)
            source: "assets/collections-window-info.png"
            asynchronous: true
            z: 1
            Text {
                id: collectionInfoLabel
                anchors.fill: parent
                width: parent.width
                height: parent.height
                topPadding: vpx(30)
                leftPadding: vpx(10)
                rightPadding: vpx(30)
                bottomPadding: vpx(30)
                wrapMode: Text.Wrap
                text: collectionInfo.info.join("\n")
                color: "white"
                font.pixelSize: vpx(14)
                font.family: amigaFont.name
                elide: Text.ElideRight
            }
        }

    }

    Rectangle {
        id: footer
        anchors {
            bottom: parent.bottom
            left: parent.left
            leftMargin: root.padding
            right: parent.right
            rightMargin: root.padding
        }
        height: vpx(40)
        color: "transparent"

        FooterImage {
            id: leftRightButton
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            imageSource: "assets/dpad_leftright.svg"
            imageLabel: "Collection Switch"
        }

        FooterImage {
            id: bButton
            anchors.left: leftRightButton.right
            anchors.bottom: parent.bottom
            imageSource: "assets/button_b.svg"
            imageLabel: "Select"
        }

        FooterImage {
            id: startButton
            anchors.left: bButton.right
            anchors.bottom: parent.bottom
            imageSource: "assets/button_start.svg"
            imageLabel: "Settings"
        }
    }
}
