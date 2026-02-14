import QtQuick 2.0
Item {
    id: root
    property bool verticalScroll: false
    property bool horizontalScroll: false
    property bool isFocused: false
    property string title: ""

    Image {
        // top
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        source: root.isFocused ?
            "../images/assets/window-parts/top-focused.png" :
            "../images/assets/window-parts/top-unfocused.png"
        height: vpx(20)
        fillMode: Image.TileHorizontally
        asynchronous: true

        // window title
        Rectangle {
            anchors {
                top: parent.top
                left: parent.left
                leftMargin: vpx(30)
            }
            height: parent.height
            width: windowTitle.width + vpx(6)
            color: "white"
            Text {
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: vpx(-2)
                id: windowTitle
                text: title
                font.family: amigaFont.name
                font.pixelSize: vpx(16)
                color: colorAmigaBlue
            }
        }
    }

    Image {
        // bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        source: horizontalScroll ?
            "../images/assets/window-parts/bottom-hscroll.png" :
            "../images/assets/window-parts/bottom.png"
        height: horizontalScroll ? vpx(18) : vpx(2)
        fillMode: Image.TileHorizontally
        asynchronous: true
    }

    Image {
        // left border
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        source: "../images/assets/window-parts/side.png"
        width: vpx(2)
        fillMode: Image.TileVertically
        asynchronous: true
    }

    Image {
        // right border
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        source: verticalScroll ?
            "../images/assets/window-parts/side-vscroll.png" :
            "../images/assets/window-parts/side.png"
        width: verticalScroll ? vpx(16) : vpx(2)
        fillMode: Image.TileVertically
        asynchronous: true
    }

    Image {
        // top left
        anchors.top: parent.top
        anchors.left: parent.left
        source: "../images/assets/window-parts/top-left.png"
        width: vpx(30)
        height: vpx(20)
        asynchronous: true
    }

    Image {
        // top right
        anchors.top: parent.top
        anchors.right: parent.right
        source: verticalScroll ?
            "../images/assets/window-parts/top-right-vscroll.png" :
            "../images/assets/window-parts/top-right.png"
        width: vpx(56)
        height: verticalScroll ? vpx(36) : vpx(20)
        asynchronous: true
    }

    Image {
        // bottom right vertical
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        source: verticalScroll ?
            "../images/assets/window-parts/bottom-right-vscroll.png" :
            "../images/assets/window-parts/bottom-right.png"
        width: vpx(16)
        height: verticalScroll ? vpx(34) : vpx(18)
        asynchronous: true
    }

    Image {
        // bottom right horizontal
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        source: horizontalScroll ?
            "../images/assets/window-parts/bottom-right-hscroll.png" :
            "../images/assets/window-parts/bottom-right.png"
        width: horizontalScroll ? vpx(31) : vpx(16)
        height: vpx(18)
        asynchronous: true
    }

    Image {
        // bottom left
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        source: horizontalScroll ?
            "../images/assets/window-parts/bottom-left-hscroll.png" :
            "../images/assets/window-parts/bottom.png"
        width: horizontalScroll ? vpx(17) : vpx(1)
        height: horizontalScroll ? vpx(18) : vpx(2)
        asynchronous: true
    }

}
