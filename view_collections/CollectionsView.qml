import QtQuick 2.7
import "../view_shared"
import "../view_shared/collections.js" as CollectionsData // platform info

// CollectionsView: The collections view consists of two carousels, one for the collection logo bar
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
    // if system isn't in collections.js show the "DUMMY" empty system
    readonly property var collectionInfo:
        (CollectionsData.COLLECTIONS[currentCollection.shortName] === undefined) ?
            CollectionsData.COLLECTIONS["DUMMY"] :
            CollectionsData.COLLECTIONS[currentCollection.shortName]

    // called from theme.qml after custom ListModel filled
    function attachModelsRestore() {
        bgAxis.model = extendedCollections;
        logoAxis.model = extendedCollections;
        // restore saved settings
        currentCollectionIndex = api.memory.get('collectionIndex') || 0;
        detailsView.focus = true;
        // force redraw
        detailsView.gameList.forceLayout();
        if (extendedCollections.get(currentCollectionIndex).shortName == "auto-lastplayed") {
            // if lauched from lastplayed game will be at top of list on return
            detailsView.currentGameIndex = 0
        } else {
            detailsView.currentGameIndex = api.memory.get('gameIndex') || 0;
        }
        // scroll gameList to selection
        detailsView.gameList.positionViewAtIndex(detailsView.currentGameIndex, ListView.Center);
        detailsView.boxartOrder = api.memory.get('boxartOrder') || 0;
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

        //highlightMoveDuration: 0 // instant switching
    }

    Component {
        // delegate for bgAxis
        id: bgAxisItem

        // background color, titlebar, icons, game count,
        // console, controller, and window frame images
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
                source: "../images/assets/titlebar.png"
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
                    topMargin: defaultPadding
                    right: parent.right
                    rightMargin: defaultPadding
                }
                source: "../images/assets/ramdiskicon.png"
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
                    topMargin: defaultPadding
                    right: parent.right
                    rightMargin: defaultPadding
                }
                source: "../images/assets/workbenchicon.png"
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
                    rightMargin: defaultPadding
                }
                source: "../images/assets/cursor.png"
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
                // top container for console and controller window
                // needed for positioning windows by center offsets
                // which handles portrait screen sizes better
                anchors {
                    top: titlebar.bottom
                    left: parent.left
                    right: parent.right
                }
                height: ( parent.height - systemWindow.height - titlebar.height ) / 2

                // window frame defines position and size of console image
                Image {
                    id: consoleWindow
                    anchors {
                        top: parent.top
                        left: parent.left
                        centerIn: parent
                        verticalCenterOffset: vpx(-7)
                        horizontalCenterOffset: vpx( -320 )
                    }
                    source: "../images/assets/window-console.png"
                    sourceSize.width: vpx(565)
                    sourceSize.height: vpx(215)
                    width: sourceSize.width
                    height: sourceSize.height
                    visible: consoleImage.status === Image.Ready
                    z: 9 // stack on top of contents
                }

                // console image, draw image then window frame on top
                Image {
                    id: consoleImage
                    anchors {
                        fill: consoleWindow
                        // margins account for window titlebar and borders
                        topMargin: vpx(30)
                        bottomMargin: vpx(10)
                        leftMargin: vpx(10)
                        rightMargin: vpx(10)
                    }
                    source: currentCollection.shortName ? "../images/consolegame/%1.svg".arg(currentCollection.shortName) : ""
                    sourceSize.width: consoleWindow.width
                    sourceSize.height: consoleWindow.height
                    fillMode: Image.PreserveAspectFit
                }

                // window frame defines position and size of controller image
                Image {
                    id: controllerWindow
                    anchors {
                        top: parent.top
                        left: parent.left
                        centerIn: parent
                        verticalCenterOffset: vpx(-7)
                        horizontalCenterOffset: vpx(200)
                    }
                    source: "../images/assets/window-controller.png"
                    sourceSize.width: vpx(320)
                    sourceSize.height: vpx(215)
                    width: sourceSize.width
                    height: sourceSize.height
                    visible: controllerImage.status === Image.Ready
                    z: 9 // stack on top of contents
                }

                // controller image inside window but stacked underneath
                Image {
                    id: controllerImage
                    anchors {
                        fill: controllerWindow
                        // margins account for window titlebar and borders
                        topMargin: vpx(30)
                        bottomMargin: vpx(10)
                        leftMargin: vpx(10)
                        rightMargin: vpx(10)
                    }
                    source: currentCollection.shortName ? "../images/controller/%1.svg".arg(currentCollection.shortName) : ""
                    sourceSize.width: controllerWindow.width
                    sourceSize.height: controllerWindow.height
                    fillMode: Image.PreserveAspectFit
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
                MouseArea {
                    anchors.fill: parent
                    onClicked: collectionSelected()
                }
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

            onItemSelected: collectionSelected()
        }

        Image {
            id: systemWindow
            anchors {
                left: parent.left
                top: parent.top
                centerIn: parent
                // move up to accommodate window titlebar
                verticalCenterOffset: vpx(-5)
            }
            source: "../images/assets/window-systems.png"
            // slightly taller for window scrollbar
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
                source: "../images/assets/window-info.png"
                width: vpx(525)
                height: vpx(205)
                asynchronous: true
                visible: (collectionInfoLabel.text.length > 0)
                Text {
                    id: collectionInfoLabel
                    anchors {
                        fill: parent
                        // margins for window titlebar, scrollbar, and borders
                        topMargin: vpx(28)
                        leftMargin: vpx(15)
                        rightMargin: vpx(23)
                        bottomMargin: vpx(2)
                    }
                    width: parent.width
                    height: parent.height
                    wrapMode: Text.Wrap
                    text: collectionInfo.info.join("\n")
                    color: "white"
                    font.pixelSize: vpx(14)
                    lineHeightMode: Text.FixedHeight
                    lineHeight: vpx(17)
                    font.family: amigaFont.name
                    elide: Text.ElideRight
                }
            } // end collectionInfoWindow

            MouseArea {
                // swipe up on colleciton info area to switch to detailsView
                anchors.fill: parent
                property int startY
                onPressed: startY = mouse.y;
                onReleased: if (startY - mouse.y > vpx(100)) collectionSelected();
            }
        } // end bottom third container

        CollectionsFooter {
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
}
