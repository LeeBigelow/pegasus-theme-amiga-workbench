import QtQuick 2.0
import "../view_shared" // for FooterImage
// DetailsFooter: Clickable help footer for DetailsView
Item {
    id: root
    height: vpx(30)

    FooterImage {
        id: leftRightButton
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        imageSource: "images/assets/dpad_leftright.svg"
        imageLabel: "Collection Switch"
        function imageAction() { nextCollection(); }
    }

    FooterImage {
        id: upDownButton
        anchors.left: leftRightButton.right
        anchors.bottom: parent.bottom
        imageSource: "images/assets/dpad_updown.svg"
        imageLabel: "Scroll"
        color: "transparent" // no need for a scroll function
    }

    FooterImage {
        id: bButton
        anchors.left: upDownButton.right
        anchors.bottom: parent.bottom
        imageSource: "images/assets/button_b.svg"
        imageLabel: "Select"
        function imageAction() { launchGame(); }
    }

    FooterImage {
        id: aButton
        anchors.left: bButton.right
        anchors.bottom: parent.bottom
        imageSource: "images/assets/button_a.svg"
        imageLabel: "Back"
        function imageAction() { cancel(); }
    }

    FooterImage {
        id: xButton
        anchors.left: aButton.right
        anchors.bottom: parent.bottom
        imageSource: "images/assets/button_x.svg"
        imageLabel: "Toggle Favorite"
        function imageAction() { toggleFavorite(); }
    }

    FooterImage {
        id: yButton
        anchors.left: xButton.right
        anchors.bottom: parent.bottom
        imageSource: "images/assets/button_y.svg"
        imageLabel: "Move Focus"
        color: "transparent" // need to figure out how to trigger "details" button
    }

    FooterImage {
        // can swipe in from right to get pegasus settions
        // not sure how to trigger that with alternate mouse action?
        id: startButton
        anchors.left: yButton.right
        anchors.bottom: parent.bottom
        imageSource: "images/assets/button_start.svg"
        imageLabel: "Settings"
        color: "transparent" // need to figure out how to trigger esc key
    }
}
