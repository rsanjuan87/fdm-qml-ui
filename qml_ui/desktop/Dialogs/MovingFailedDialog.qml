import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.11
import org.freedownloadmanager.fdm 1.0
import "../BaseElements"
import "../../common/Tools"

BaseDialog {
    id: root

    property int downloadId
    property string errorMessage

    width: 542

    contentItem: BaseDialogItem {
        titleText: qsTr("Moving download failed") + App.loc.emptyString
        focus: true
        Keys.onEscapePressed: root.abortMoving()
        Keys.onReturnPressed: root.retryMoving()
        onCloseClick: root.abortMoving()

        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            spacing: 3

            BaseLabel {
                Layout.fillWidth: true
                text: qsTr("Error: %1").arg(errorMessage) + App.loc.emptyString
                Layout.bottomMargin: 7
            }

            BaseLabel {
                id: lbl
                visible: downloadsItemTools.tplPathAndTitle.length > 0
                Layout.fillWidth: true
                elide: Text.ElideMiddle
                color: "#737373"
                DownloadsItemTools {
                    id: downloadsItemTools
                    itemId: root.downloadId
                }
                text: qsTr("Unable to move: %1").arg(downloadsItemTools.hasChildDownloads ? downloadsItemTools.destinationPath : downloadsItemTools.tplPathAndTitle) + App.loc.emptyString
            }

            RowLayout {
                Layout.topMargin: 10
                Layout.bottomMargin: 10
                Layout.alignment: Qt.AlignRight

                spacing: 5

                CustomButton {
                    text: qsTr("Try again") + App.loc.emptyString
                    blueBtn: true
                    alternateBtnPressed: cnclBtn.isPressed
                    onClicked: root.retryMoving()
                }

                CustomButton {
                    id: cnclBtn
                    text: qsTr("Cancel") + App.loc.emptyString
                    onClicked: root.abortMoving()
                }
            }
        }
    }

    onOpened: {
        forceActiveFocus();
    }

    onClosed: {
        downloadId = -1;
        errorMessage = "";
        appWindow.appWindowStateChanged();
    }

    function abortMoving()
    {
        App.downloads.moveFilesMgr.abortMove(downloadId);
        root.close();
    }

    function retryMoving()
    {
        App.downloads.moveFilesMgr.retryFailedMove(downloadId);
        root.close();
    }

    function movingFailedAction(id, error)
    {
        root.downloadId = id;
        root.errorMessage = error;
        root.open();
    }
}
