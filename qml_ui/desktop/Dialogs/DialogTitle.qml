import QtQuick 2.0
import QtQuick.Layouts 1.12
import '../BaseElements'
import "../../common"

Rectangle {

    id: root

    property string text
    property bool showTitleIcon: false
    property url titleIconUrl: Qt.resolvedUrl("../../images/mobile/fdmlogo.svg")
    property int titleIconSize: 32

    signal closeClick

    height: 36
    color: appWindow.theme.dialogTitleBackground

    Rectangle {
        anchors.fill: parent
        visible: appWindow.macVersion && appWindow.theme === lightTheme
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#ececec" }
            GradientStop { position: 1.0; color: "#dddcdc" }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10

        WaSvgImage {
            source: root.titleIconUrl
            Layout.preferredHeight: Math.min(root.titleIconSize, parent.height - 6)
            Layout.preferredWidth: Layout.preferredHeight
            Layout.alignment: Qt.AlignVCenter
            visible: root.showTitleIcon
        }

        BaseLabel {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            text: root.text
            color: appWindow.macVersion ? appWindow.theme.dialogTitleMac : appWindow.theme.dialogTitle
        }

        Rectangle {
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.preferredHeight: 24
            Layout.preferredWidth: 24
            clip: true
            color: "transparent"

            Image {
                source: appWindow.theme.elementsIcons
                sourceSize.width: 93
                sourceSize.height: 456
                x: 6
                y: -366
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.closeClick()
            }
        }
    }
}
