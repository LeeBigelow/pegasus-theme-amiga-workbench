import QtQuick 2.0
// FilterBox: input box changes background on focus and catches some UI keys
// Has filterInput property alias for accepting focus and accessing text
Rectangle {
    id: root
    property alias filterInput: filterInput
    color: filterInput.activeFocus ? "white" : colorAmigaBlue

    TextInput {
        id: filterInput
        anchors {
            fill: parent
            leftMargin: vpx(5)
            rightMargin: vpx(5)
            verticalCenter: parent.verticalCenter
        }
        focus: true
        clip: true
        color: filterInput.activeFocus ? colorAmigaBlue : "black"
        font.family: amigaFont.name
        font.pixelSize: vpx(16)
        font.capitalization: Font.AllUppercase
        verticalAlignment: Text.AlignVCenter
        KeyNavigation.tab: descriptionScroll
        Keys.onUpPressed: {
            if (currentGameIndex > 0) currentGameIndex--;
            gameList.forceActiveFocus();
        }
        Keys.onDownPressed: {
            if (currentGameIndex < gameList.count - 1) currentGameIndex++;
            gameList.forceActiveFocus();
        }
        Keys.onPressed: {
            // move game index to last item on key press so details refresh
            // but not for focus switching keys
            if (event.key != Qt.Key_Tab && !api.keys.isDetails(event))
                currentGameIndex = gameList.count - 1;
            if (event.isAutoRepeat) return;
            else if (event.key == Qt.Key_I) {
                // catch i key so it doesn't shift focus as Details Key
                event.accepted=true;
                filterInput.insert(cursorPosition,"i");
                return;
            } else if (event.key == Qt.Key_Left && cursorPosition == 0) {
                // catch left key to stop acidental collection switching
                event.accepted=true;
                return;
            } else if (event.key == Qt.Key_Right && cursorPosition == text.length) {
                // catch right key to stop acidental collection switching
                event.accepted=true;
                return;
            } else if (api.keys.isDetails(event)) {
                event.accepted = true;
                gameList.forceActiveFocus();
            } else if (api.keys.isAccept(event)) {
                event.accepted = true;
                currentGameIndex = gameList.count - 1;
                gameList.forceActiveFocus();
            }
        } // end filterInput Keys.OnPressed
    } // end filterInput TextInput
} // end filterInputBg
