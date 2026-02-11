import QtQuick 2.0
// FooterImage: image and label side by side
Rectangle {
    id: root
    property string imageSource
    property string imageLabel
    height: vpx(40)
    width: vpx(15) + label.contentWidth + image.paintedWidth
    color: mouseArea.containsMouse ? colorAmigaOrange : "transparent"

    Image {
        id: image
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        // path given relative to parent not here so step up a dir
        source: "../" + imageSource
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

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: imageAction()
        hoverEnabled: true
    }
}
