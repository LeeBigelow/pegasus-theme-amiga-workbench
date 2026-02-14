import QtQuick 2.0
import "../view_shared" // AmgiaWindow
// DetailsHeader: titlebar, console+controller and logo windows
Item {
    // top header for titlebar, console and logo windows
    id: root
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
    // called in here to make swipeable as well
    AmigaTitlebar { id: titlebar }

    // console and controller in a window
    AmigaWindow {
        id: consoleControllerWindow
        anchors {
            top: titlebar.bottom
            topMargin: defaultPadding
            left: parent.left
            leftMargin: defaultPadding
        }
        width: vpx(604)
        height: vpx(122)
        title: "Console"
        visible: (consoleImage.status === Image.Ready) ||
            (controllerImage.status === Image.Ready)
        z: 9 // stack on top of contents
    }

    Image {
        id: consoleImage
        anchors {
            centerIn: consoleControllerWindow
            // shift left to center with combined controller
            horizontalCenterOffset: -(controllerImage.width + defaultPadding)/ 2
            // adjust for window titlebar
            verticalCenterOffset: vpx(9)
        }
        source: currentCollection.shortName ?
            "../images/consolegame/%1.svg".arg(currentCollection.shortName) : ""
        // adjust height for window titlebar, border, and padding
        sourceSize.height: consoleControllerWindow.height - vpx(30)
        height: sourceSize.height
        fillMode: Image.PreserveAspectFit
        asynchronous: true
    }

    Image {
        id: controllerImage
        anchors {
            left: consoleImage.right
            leftMargin: defaultPadding
            bottom: consoleImage.bottom
        }
        source: currentCollection.shortName ?
            "../images/controller/%1.svg".arg(currentCollection.shortName) : ""
        sourceSize.height: consoleImage.height
        height: sourceSize.height
        fillMode: Image.PreserveAspectFit
        asynchronous: true
    }

    // system logo, or fallback text, in a window
    AmigaWindow {
        id: logoWindow
        anchors {
            top: titlebar.bottom
            topMargin: defaultPadding
            right: parent.right
            rightMargin: defaultPadding
        }
        width: vpx(604)
        height: vpx(122)
        title: "System"
        z: 9 // stack ontop of contents
    }

    Image {
        id: logo
        anchors.centerIn: logoWindow
        // adjust for window titlebar
        anchors.verticalCenterOffset: vpx(9)
        fillMode: Image.PreserveAspectFit
        source: currentCollection.shortName ?
            "../images/logo/%1.svg".arg(currentCollection.shortName) : undefined
        sourceSize.width: logoWindow.width - vpx(20)
        sourceSize.height: logoWindow.height - vpx(30)
        width: sourceSize.width
        height: sourceSize.height
        // async may cause the text label to flash
        asynchronous: true
    }

    Text {
        id: logoLabel
        anchors.centerIn: logoWindow
        // adjust for window titlebar
        anchors.verticalCenterOffset: vpx(9)
        width: logoWindow.width - vpx(6)
        elide: Text.ElideRight
        color: "white"
        font.family: amigaFont.name
        font.pixelSize: vpx(24)
        text: currentCollection.name // shortName should be in titlebar
        horizontalAlignment: Text.AlignHCenter
        visible: logo.status != Image.Ready
    }
} // end top header for titlebar, console and logo windows
