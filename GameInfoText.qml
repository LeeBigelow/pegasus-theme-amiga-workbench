import QtQuick 2.0

// All the game details text have the same basic properties
// so I've moved them into a new QML type.
Text {
    font.pixelSize: vpx(18)
    font.capitalization: Font.Capitalize
    font.family: amigaFont.name
    height: root.detailsTextHeight
    width: parent.width
    elide: Text.ElideRight
    color: "white"
}
