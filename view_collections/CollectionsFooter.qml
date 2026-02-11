import QtQuick 2.0
import "../view_shared" // for FooterImage
// CollectionsFooter: clickable help images for CollectionsView
Item {
    id: root
    height: vpx(30)

    FooterImage {
        id: leftRightButton
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        imageSource: "images/assets/dpad_leftright.svg"
        imageLabel: "Collection Switch"
        function imageAction() { selectNext(); }
    }

    FooterImage {
        id: bButton
        anchors.left: leftRightButton.right
        anchors.bottom: parent.bottom
        imageSource: "images/assets/button_b.svg"
        imageLabel: "Select"
        function imageAction() { collectionSelected(); }
    }

    FooterImage {
        id: startButton
        anchors.left: bButton.right
        anchors.bottom: parent.bottom
        imageSource: "images/assets/button_start.svg"
        imageLabel: "Settings"
        color: "transparent" // need to figure out how to trigger esc key
    }
} // end footer
