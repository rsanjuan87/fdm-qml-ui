import QtQuick 2.0
import QtQuick.Controls 2.3
import org.freedownloadmanager.fdm 1.0
import "../BaseElements"

Rectangle {
    id: root

    property string text
    signal selectAll

    border.width: 1
    border.color: appWindow.theme.border

    onSelectAll: textArea.selectAll()

    Flickable {
        anchors.fill: parent
        anchors.margins: 1
        clip: true
        flickableDirection: Flickable.VerticalFlick

        ScrollBar.vertical: ScrollBar {}
        ScrollBar.horizontal: null

        TextArea.flickable: TextArea {
            id: textArea

            text: root.text
            focus: true
            wrapMode: TextArea.WordWrap
            font.pixelSize: 14
            color: appWindow.theme.foreground
            selectByMouse: true
            onTextChanged: { root.text = text }
            Keys.onEscapePressed: root.close()

            background: Rectangle {
                color: appWindow.theme.background
            }
        }
    }

    onFocusChanged: {
        if (!focus) {
            appWindow.globalFocusLost()
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        hoverEnabled: true
        property int selectStart
        property int selectEnd
        property int curPos
        onClicked: {
            selectStart = textArea.selectionStart;
            selectEnd = textArea.selectionEnd;
            curPos = textArea.cursorPosition;
            contextMenu.x = mouse.x;
            contextMenu.y = mouse.y;
            contextMenu.open();
            textArea.cursorPosition = curPos;
            textArea.select(selectStart,selectEnd);
        }
        onPressAndHold: {
            if (mouse.source === Qt.MouseEventNotSynthesized) {
                selectStart = textArea.selectionStart;
                selectEnd = textArea.selectionEnd;
                curPos = textArea.cursorPosition;
                contextMenu.x = mouse.x;
                contextMenu.y = mouse.y;
                contextMenu.open();
                textArea.cursorPosition = curPos;
                textArea.select(selectStart,selectEnd);
            }
        }

        BaseContextMenu {
            id: contextMenu
            Action {
                text: qsTr("Cut") + App.loc.emptyString
                onTriggered: {
                    textArea.cut()
                }
            }
            Action {
                text: qsTr("Copy") + App.loc.emptyString
                onTriggered: {
                    textArea.copy()
                }
            }
            Action {
                text: qsTr("Paste") + App.loc.emptyString
                onTriggered: {
                    textArea.paste()
                }
            }
        }
    }
}
