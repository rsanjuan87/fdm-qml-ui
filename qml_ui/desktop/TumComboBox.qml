import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.freedownloadmanager.fdm 1.0
import org.freedownloadmanager.fdm.dmcoresettings 1.0
import org.freedownloadmanager.fdm.tum 1.0
import org.freedownloadmanager.fdm.appconstants 1.0
import "../common/Tools"

import "./BaseElements"


ComboBox {
    id: root

    property double totalDownloadSpeed: App.downloads.stats.totalDownloadSpeed
    property double totalUploadSpeed: App.downloads.stats.totalUploadSpeed

    property var currentTumMode: App.ready ? App.settings.tum.currentMode : TrafficUsageMode.High

    property string sUnlimited: qsTr("Unlimited") + App.loc.emptyString
    property string kbps: qsTr("KB/s") + App.loc.emptyString

    visible: App.ready && root.currentTumMode != TrafficUsageMode.Snail

    width: parent.width
    height: parent.height

    model: ListModel {}

    delegate: Rectangle {
        width: root.width
        height: modelData.mode === TrafficUsageMode.Low ? 30 : 35
        color: "transparent"

        Rectangle {
            width: parent.width
            height: 30
            color: "transparent"

            property bool hover: false

            Rectangle {
                visible: parent.hover
                anchors.fill: parent
                color: modelData.mode == TrafficUsageMode.High ? appWindow.theme.highMode :
                        modelData.mode == TrafficUsageMode.Medium ? appWindow.theme.mediumMode :
                        modelData.mode == TrafficUsageMode.Low ? appWindow.theme.lowMode : "transparent"
                opacity: 0.2
            }

            Rectangle {
                width: 4
                height: parent.height
                color: modelData.mode === TrafficUsageMode.High ? appWindow.theme.highMode :
                       modelData.mode === TrafficUsageMode.Medium ? appWindow.theme.mediumMode :
                       modelData.mode === TrafficUsageMode.Low ? appWindow.theme.lowMode : "transparent"
            }

            Rectangle {
                color: "transparent"
                visible: root.currentTumMode == modelData.mode
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 12
                clip: true
                width: 12
                height: 10
                Image {
                    source: appWindow.theme.elementsIcons
                    sourceSize.width: 93
                    sourceSize.height: 456
                    x: 0
                    y: -123
                }
            }

            RowLayout {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 5
                BaseLabel {
                    leftPadding: 30
                    text: modelData.text
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onEntered: parent.hover = true
                onExited: parent.hover = false
                onClicked: {
                    App.settings.tum.currentMode = modelData.mode;
                    root.popup.close()
                }
                BaseToolTip {
                    property string downSpeed: modelData.downloadSpeed != sUnlimited ? modelData.downloadSpeed + " " + kbps : qsTr("unlimited") + App.loc.emptyString
                    property string upSpeed: modelData.uploadSpeed != sUnlimited ? modelData.uploadSpeed + " " + kbps : qsTr("unlimited") + App.loc.emptyString
                    text: qsTr("Download: %1, Upload: %2").arg(downSpeed).arg(upSpeed) + App.loc.emptyString
                    visible: parent.containsMouse
                    fontSize: 11
                }
            }
        }
    }

    indicator: Rectangle {
        color: "transparent"
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 8
        width: 15
        height: 15
        clip: true
        Image {
            source: appWindow.theme.elementsIcons
            sourceSize.width: 93
            sourceSize.height: 456
            x: (root.popup.opened ? 2 : -38)
            y: -22
        }
    }

    background: Rectangle {
        implicitWidth: root.width
        implicitHeight: root.height
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: root.currentTumMode == TrafficUsageMode.High ? appWindow.theme.highMode :
                    root.currentTumMode == TrafficUsageMode.Medium ? appWindow.theme.mediumMode :
                    root.currentTumMode == TrafficUsageMode.Low ? appWindow.theme.lowMode : "transparent"
            opacity: 0.2
        }

        Rectangle {
            height: 3
            width: parent.width
            anchors.bottom: parent.bottom
            color: root.currentTumMode == TrafficUsageMode.High ? appWindow.theme.highMode :
                    root.currentTumMode == TrafficUsageMode.Medium ? appWindow.theme.mediumMode :
                    root.currentTumMode == TrafficUsageMode.Low ? appWindow.theme.lowMode : "transparent"
        }

        Rectangle {
            width: parent.width
            height: 1
            color: appWindow.theme.border
        }

        Rectangle {
            width: 1
            height: parent.height
            color: appWindow.theme.border
        }

        Rectangle {
            width: 1
            height: parent.height
            color: appWindow.theme.border
            anchors.right: parent.right
        }
    }

    contentItem: Rectangle {
        color: "transparent"
        height: root.height
        width: root.width

        Row {
            anchors.fill: parent
            Rectangle {
                color: "transparent"
                width: 87
                height: parent.height

                Image {
                    source: appWindow.theme.arrowDownSbarImg
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    width: 8
                    height: 8
                    sourceSize: Qt.size(width, height)
                }

                BaseLabel {
                    leftPadding: 20
                    anchors.verticalCenter: parent.verticalCenter
                    text: App.speedAsText(root.totalDownloadSpeed) + App.loc.emptyString
                }
            }
            Rectangle {
                color: "transparent"
                width: 87
                height: parent.height

                Image {
                    source: appWindow.theme.arrowUpSbarImg
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    width: 8
                    height: 8
                    sourceSize: Qt.size(width, height)
                }

                BaseLabel {
                    leftPadding: 20
                    anchors.verticalCenter: parent.verticalCenter
                    text: App.speedAsText(root.totalUploadSpeed) + App.loc.emptyString
                }
            }
        }
    }

    popup: Popup {
        id: someUnusedId // https://bugreports.qt.io/browse/QTBUG-96351

        y: 1 - height
        width: root.width
        height: 102
        padding: 1

        background: Rectangle {
            color: appWindow.theme.background
            border.color: appWindow.theme.border
            border.width: 1
        }

        contentItem: Item {
            ListView {
                clip: true
                anchors.fill: parent
                model: root.model
                currentIndex: root.highlightedIndex
                delegate: root.delegate
            }
        }
    }

    Component.onCompleted: {
        updateModel()
        applyCurrentModeToCombo()
    }
    Connections {
        target: App.settings.tum
        onCurrentModeChanged: root.applyCurrentModeToCombo()
    }

    Connections {
        target: appWindow
        onTumSettingsChanged: root.updateModel()//root.reloadModel()
    }

    Connections {
        target: App.loc
        onCurrentTranslationChanged: root.updateModel();
    }

    function updateModel() {
        root.model = [
            {text: qsTr("High") + App.loc.emptyString, mode: TrafficUsageMode.High, downloadSpeed: getDownloadSpeed(TrafficUsageMode.High), uploadSpeed: getUploadSpeed(TrafficUsageMode.High)},
            {text: qsTr("Medium") + App.loc.emptyString, mode: TrafficUsageMode.Medium, downloadSpeed: getDownloadSpeed(TrafficUsageMode.Medium), uploadSpeed: getUploadSpeed(TrafficUsageMode.Medium)},
            {text: qsTr("Low") + App.loc.emptyString, mode: TrafficUsageMode.Low, downloadSpeed: getDownloadSpeed(TrafficUsageMode.Low), uploadSpeed: getUploadSpeed(TrafficUsageMode.Low)}];
    }

//    function reloadModel() {
//        var m = root.model;
//        for (var i = 0; i < m.length; i++) {
//            m[i].downloadSpeed = getDownloadSpeed(m[i].mode);
//            m[i].uploadSpeed = getUploadSpeed(m[i].mode);
//        }
//        root.model = m;
//    }

    function getDownloadSpeed(mode) {
        return getSpeed(mode, DmCoreSettings.MaxDownloadSpeed);
    }

    function getUploadSpeed(mode) {
        return getSpeed(mode, DmCoreSettings.MaxUploadSpeed);
    }

    function getSpeed(mode, setting) {
        var val = App.settings.tum.value(mode, setting);
        var text = val && val !== '0' ?
                    (parseInt(val / AppConstants.BytesInKB)).toString() :
                    sUnlimited;
        return text;
    }

    function applyCurrentModeToCombo()
    {
        var cm = root.currentTumMode;
        for (var i = 0; i < model.length; i++) {
            if (model[i].mode == cm) {
                currentIndex = i;
                return;
            }
        }
        console.assert(cm == TrafficUsageMode.Snail, "Invalid current tum");
    }
}
