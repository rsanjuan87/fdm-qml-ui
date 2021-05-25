import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.11
import org.freedownloadmanager.fdm 1.0
import Qt.labs.settings 1.0
import "../BaseElements"
import "../../common/Tools"

BaseDialog {
    id: root

    property var downloadIds: []

    width: 542

    contentItem: BaseDialogItem {
        titleText: qsTr("Pause download") + App.loc.emptyString
        focus: true
        Keys.onEscapePressed: root.close()
        Keys.onReturnPressed: root.deleteFilesClick()
        onCloseClick: root.close()

        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            spacing: 3

            BaseLabel {
                Layout.fillWidth: true
                text: qsTr("The download(s) below can't be resumed after pausing.") + App.loc.emptyString
                Layout.bottomMargin: 7
            }

            ListView {
                clip: true
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(contentHeight, 150)
                ScrollBar.vertical: ScrollBar {
                    active: parent.contentHeight > 150
                }
                model: root.downloadIds
                delegate: Rectangle {
                    width: parent.width
                    height: lbl.height
                    color: 'transparent'

                    BaseLabel {
                        id: lbl
                        visible: downloadsItemTools.tplPathAndTitle.length > 0
                        width: parent.width
                        elide: Text.ElideMiddle
                        color: "#737373"
                        DownloadsItemTools {
                            id: downloadsItemTools
                            itemId: root.downloadIds[index]
                        }
                        text: downloadsItemTools.hasChildDownloads ? downloadsItemTools.destinationPath : downloadsItemTools.tplPathAndTitle
                    }
                }
            }

            RowLayout {
                Layout.topMargin: 10
                Layout.bottomMargin: 10
                Layout.alignment: Qt.AlignRight

                spacing: 5

                CustomButton {
                    text: qsTr("Pause") + App.loc.emptyString
                    blueBtn: true
                    alternateBtnPressed: cnclBtn.isPressed
                    onClicked: root.okClick()
                }

                CustomButton {
                    id: cnclBtn
                    text: qsTr("Cancel") + App.loc.emptyString
                    onClicked: root.close()
                }
            }
        }
    }

    onOpened: {
        forceActiveFocus();
    }

    onClosed: {
        downloadIds = [];
    }

    function okClick()
    {
        selectedDownloadsTools.stopByIds(downloadIds);
        root.close();
    }

    function show(ids)
    {
        console.log("show(ids)", ids);
        root.downloadIds = ids;
        root.open();
    }
}
