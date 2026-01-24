import QtQuick 2.0

// All the game details text have the same basic properties
// so I've moved them into a new QML type.
Text {
    font.pixelSize: vpx(20)
    font.capitalization: Font.Capitalize
    font.family: "Open Sans"
    height: root.detailsTextHeight
    width: parent.width
    elide: Text.ElideRight
    color: "white"
}
