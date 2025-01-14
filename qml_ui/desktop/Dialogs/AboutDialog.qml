import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import org.freedownloadmanager.fdm 1.0
import "../BaseElements"

BaseDialog {
    id: root

    contentItem: BaseDialogItem {
        titleText: qsTr("About") + App.loc.emptyString

        width: col.width + 20

        focus: true
        Keys.onEscapePressed: root.close()
        Keys.onReturnPressed: root.close()
        onCloseClick: root.close()

        Column {
            id: col
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            Layout.bottomMargin: 10
            spacing: 5

            BaseLabel {
                text: App.displayName + App.loc.emptyString
                font.bold: true
                MouseArea {
                    anchors.fill: parent
                    onClicked: timer.targetClicked()
                }
            }

            Label
            {
                visible: App.testVersion
                text: "Test mode is active <a href='#'>turn off</a>"
                onLinkActivated: {App.testVersion = false;}
            }

            BaseSelectableLabel {
                text: qsTr("Version: %1 (%2)").arg(App.version).arg(App.versionHash) + App.loc.emptyString
            }

            BaseLabel {
                text: qsTr("Build date: %1").arg(App.loc.dateToString(App.buildDateTime, true)) + App.loc.emptyString
            }

            Rectangle {
                color: "transparent"
                height: 3
                width: height
            }

            Repeater
            {
                model: App.thirdPartyLibsInfos.size()
                BaseHyperLabel {
                    text: "<a href='%1'>%2</a> ".arg(App.thirdPartyLibsInfos.url(index)).arg(App.thirdPartyLibsInfos.displayName(index)) + App.thirdPartyLibsInfos.displayVersion(index) + App.loc.emptyString
                }
            }

            Rectangle {
                color: "transparent"
                height: 3
                width: height
            }

            BaseHyperLabel {
                text: "© <a href='https://www.freedownloadmanager.org'>FreeDownloadManager.org</a>, " + App.copyrightYears()
            }

            Rectangle {
                color: "transparent"
                height: 5
                width: height
            }

            CustomButton {
                anchors.right: parent.right
                text: qsTr("OK") + App.loc.emptyString
                blueBtn: true
                onClicked: root.close()
            }
        }

        Timer{
            id:timer
            onTriggered: resetClickCounter()
            property int clickCounter: 0
            property int maxClickCount: 10
            function resetClickCounter() {
                clickCounter = 0;
            }
            function targetClicked() {
                if (!App.testVersion) {
                    timer.clickCounter++;

                    if (timer.running && timer.clickCounter == timer.maxClickCount)
                    {
                        App.testVersion = true;
                        timer.resetClickCounter();
                        timer.stop();
                    } else {
                        timer.restart();
                    }
                }
            }
        }
    }

    onOpened: {
        forceActiveFocus();
    }
}
