import QtQuick 2.0
// GameInfoText: Detail properties
Text {
    id: root
    font.pixelSize: vpx(18)
    font.capitalization: Font.Capitalize
    font.family: amigaFont.name
    height: detailsTextHeight
    width: parent.width
    elide: Text.ElideRight
    color: "white"
}
