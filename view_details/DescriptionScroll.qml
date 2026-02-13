import QtQuick 2.0
// DescriptionScroll: scrollable text box for game description
Flickable {
    id: root
    anchors {
        fill: parent
        topMargin: defaultPadding / 2
        bottomMargin: defaultPadding / 2
        leftMargin: defaultPadding
        rightMargin: defaultPadding
    }
    clip: true
    focus: true
    onFocusChanged: { contentY = 0; }
    contentWidth: parent.width
    contentHeight: gameDescription.height
    flickableDirection: Flickable.VerticalFlick

    Text {
        id: gameDescription
        text: currentGame.description
        wrapMode: Text.WordWrap
        width: descriptionScroll.width
        horizontalAlignment: Text.AlignJustify
        font.pixelSize: vpx(18)
        // set fixed line height or amiga topaz font behaves badly
        lineHeightMode: Text.FixedHeight
        lineHeight: vpx(22)
        font.family: amigaFont.name
        color: "white"
    }

    // Keybindings for descriptionScroll
    // scroll description on up and down
    Keys.onUpPressed: (contentY - 10) < 0 ?  contentY = 0 : contentY -= 10
    Keys.onDownPressed: {
        (contentY + 10) > (gameDescription.height - height) ?
            contentY = gameDescription.height - height :
            contentY += 10
    }
    // Move focus on tab and details key (i)
    KeyNavigation.tab: launchButton
    Keys.onPressed: {
        if (event.isAutoRepeat) {
            return;
        } else if (api.keys.isDetails(event)) {
            event.accepted = true;
            filterInput.forceActiveFocus();
            return;
        } else if (api.keys.isAccept(event)) {
            // return focus to gameList on "accept"
            event.accepted = true;
            gameList.forceActiveFocus();
            return;
        }
    }

    MouseArea {
        // just focus description on click
        anchors.fill: parent
        onClicked: descriptionScroll.forceActiveFocus()
    }
} // end descriptionScroll
