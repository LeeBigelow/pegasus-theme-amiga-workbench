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
        detailsView.focus = true;
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
        // delegate for bgAxis
        id: bgAxisItem

        // background color, titlebar, cosole and controller images and windows
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
                source: "assets/titlebar.png"
                sourceSize.width: parent.width
                sourceSize.height: vpx(20)
                width: sourceSize.width
                height: sourceSize.height
                asynchronous: true
            }

            // ramdisk icon
            Image {
                id: ramdiskIcon
                anchors {
                    top: titlebar.bottom
                    topMargin: root.padding
                    right: parent.right
                    rightMargin: root.padding
                }
                source: "assets/ramdiskicon.png"
                sourceSize.width: vpx(96)
                sourceSize.height: vpx(46)
                width: sourceSize.width
                height: sourceSize.height
                asynchronous: true
            }

            // workbench icon
            Image {
                id: workbenchIcon
                anchors {
                    top: ramdiskIcon.bottom
                    topMargin: root.padding
                    right: parent.right
                    rightMargin: root.padding
                }
                source: "assets/workbenchicon.png"
                sourceSize.width: vpx(96)
                sourceSize.height: vpx(46)
                width: sourceSize.width
                height: sourceSize.height
                asynchronous: true
            }

            // cursor image
            Image {
                id: cursorImage
                anchors {
                    top: workbenchIcon.bottom
                    right: parent.right
                    rightMargin: root.padding
                }
                source: "assets/cursor.png"
                sourceSize.width: vpx(24)
                sourceSize.height: vpx(23)
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
                // top third windows container
                anchors {
                    top: titlebar.bottom
                    left: parent.left
                    right: parent.right
                }
                height: ( parent.height - systemWindow.height - titlebar.height ) / 2

                // console
                Image {
                    id: consoleImage
                    anchors {
                        top: parent.top
                        left: parent.left
                        centerIn: consoleWindow
                        verticalCenterOffset: vpx(5)
                    }
                    source: currentCollection.shortName ? "consolegame/%1.svg".arg(currentCollection.shortName) : ""
                    sourceSize.width: vpx(530)
                    sourceSize.height: vpx(165)
                    width: sourceSize.width
                    height: sourceSize.height
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                }

                Image {
                    id: consoleWindow
                    anchors {
                        top: parent.top
                        left: parent.left
                        centerIn: parent
                        verticalCenterOffset: vpx(-7)
                        horizontalCenterOffset: vpx( -320 )
                    }
                    source: "assets/collections-window-console.png"
                    sourceSize.width: vpx(565)
                    sourceSize.height: vpx(215)
                    width: sourceSize.width
                    height: sourceSize.height
                    asynchronous: true
                    visible: consoleImage.status === Image.Ready
                }


                // controller
                Image {
                    id: controllerImage
                    anchors {
                        top: parent.top
                        left: parent.left
                        centerIn: controllerWindow
                        verticalCenterOffset: vpx(5)
                    }
                    source: currentCollection.shortName ? "controller/%1.svg".arg(currentCollection.shortName) : ""
                    sourceSize.width: vpx(305)
                    sourceSize.height: vpx(175)
                    width: sourceSize.width
                    height: sourceSize.height
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                }

                Image {
                    id: controllerWindow
                    anchors {
                        top: parent.top
                        left: parent.left
                        centerIn: parent
                        verticalCenterOffset: vpx(-7)
                        horizontalCenterOffset: vpx(200)
                    }
                    source: "assets/collections-window-controller.png"
                    sourceSize.width: vpx(320)
                    sourceSize.height: vpx(215)
                    width: sourceSize.width
                    height: sourceSize.height
                    asynchronous: true
                    visible: controllerImage.status === Image.Ready
                }
            } // end container top third windows
        } // end container for titlebar, gamecount, top windows
    } // end Component bgAxisItem

    // system logo bar
    Item {
        id: logoBar
        anchors.fill: parent
        height: vpx(170)

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
            id: systemWindow
            anchors {
                left: parent.left
                top: parent.top
                centerIn: parent
                verticalCenterOffset: vpx(-5)
            }
            source: "assets/collections-window-system.png"
            sourceSize.height: vpx(208)
            sourceSize.width: parent.width
            height: sourceSize.height
            width: sourceSize.width
            asynchronous: true
        }

        // Collection Info section
        Item {
            // bottom third
            anchors {
                top: systemWindow.bottom
                left: parent.left
                right: parent.right
                bottom: footer.top
            }

            Image {
                id: collectionInfoWindow
                anchors {
                    top: parent.top
                    left: parent.left
                    centerIn: parent
                    horizontalCenterOffset: vpx(200)
                }
                source: "assets/collections-window-info.png"
                width: vpx(525)
                height: vpx(205)
                asynchronous: true
                Text {
                    id: collectionInfoLabel
                    anchors.fill: parent
                    width: parent.width
                    height: parent.height
                    topPadding: vpx(25)
                    leftPadding: vpx(15)
                    rightPadding: vpx(23)
                    bottomPadding: vpx(23)
                    wrapMode: Text.Wrap
                    text: collectionInfo.info.join("\n")
                    color: "white"
                    font.pixelSize: vpx(12)
                    lineHeightMode: Text.FixedHeight
                    lineHeight: vpx(15)
                    font.family: amigaFont.name
                    elide: Text.ElideRight
                }
            } // end collectionInfoWindow
        } // end bottom third container

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
        } // end footer
    }

}
