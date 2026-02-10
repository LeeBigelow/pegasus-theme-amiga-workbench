import QtQuick 2.0

// The collection logo on the collection carousel. Just an image that gets scaled
// and more visible when selected. Also has a fallback text if there's no image.
Rectangle {
    property string imageSource
    property string imageLabel
    height: vpx(40)
    width: vpx(15) + label.contentWidth + image.paintedWidth
    color: "transparent"

    Image {
        id: image
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        source: imageSource
        sourceSize.height: vpx(20)
        height: sourceSize.height
        fillMode: Image.PreserveAspectFit
        asynchronous: true
    }

    Text {
        id: label
        anchors.left: image.right
        anchors.leftMargin: vpx(5)
        anchors.verticalCenter: parent.verticalCenter
        color: "white"
        font.family: amigaFont.name
        font.pixelSize: vpx(16)
        text: imageLabel
    }
}
