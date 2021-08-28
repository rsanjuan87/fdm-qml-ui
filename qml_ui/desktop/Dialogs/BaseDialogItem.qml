import QtQuick 2.0
import QtQuick.Layouts 1.3

ColumnLayout {
    property alias titleText: title.text
    property alias showTitleIcon: title.showTitleIcon
    property alias titleIconUrl: title.titleIconUrl
    property alias titleIconSize: title.titleIconSize
    signal closeClick

    width: parent.width
    spacing: 10

    DialogTitle {
        id: title
        Layout.fillWidth: true
        onCloseClick: {
            parent.closeClick();
        }
    }
}
