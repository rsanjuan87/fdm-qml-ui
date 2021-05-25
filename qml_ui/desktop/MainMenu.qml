import QtQuick 2.11
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.freedownloadmanager.fdm 1.0
import org.freedownloadmanager.vmsqt 1.0
import org.freedownloadmanager.fdm.appfeatures 1.0
import "../common"
import "./BaseElements"

BaseContextMenu {
    id: root
    implicitWidth: 240
    y: 50
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    property bool shutdownGroupOpened
    property var mosaicStat: {'greenMenuMarker': false, 'mosaicClick': false}

    BaseContextMenuItem {
        text: qsTr("Paste Urls from Clipboard") + App.loc.emptyString
        onTriggered: App.pasteUrlsFromClipboard()
    }

    BaseContextMenuItem {
        text: qsTr("Paste Urls from File") + App.loc.emptyString
        onTriggered: importDlg.openDialog('importListOfUrlsFromFile')
    }

    BaseContextMenuSeparator {}

    BaseContextMenu {
        title: qsTr("Export/Import") + App.loc.emptyString

        BaseContextMenuItem {
            text: qsTr("Export all downloads") + App.loc.emptyString
            onTriggered: exportDownloadsDlg.exportAll()
        }

        BaseContextMenuItem {
            text: qsTr("Import downloads") + App.loc.emptyString
            onTriggered: importDlg.openDialog('importDownloads')
        }

        BaseContextMenuSeparator {}

        BaseContextMenuItem {
            text: qsTr("Export settings") + App.loc.emptyString
            onTriggered: exportSettingsDlg.open()
        }

        BaseContextMenuItem {
            text: qsTr("Import settings") + App.loc.emptyString
            onTriggered: importDlg.openDialog('importSettings')
        }
    }

    BaseContextMenuSeparator {}

    BaseContextMenuItem {
        text: qsTr("Preferences...") + App.loc.emptyString
        enabled: !forSettingsPage
        onTriggered: appWindow.openSettings()
    }

    BaseContextMenuSeparator {}

    BaseContextMenuItem {
        text: qsTr("Contact Support") + App.loc.emptyString
        onTriggered: Qt.openUrlExternally('https://www.freedownloadmanager.org/support.htm?' + App.serverCommonGetParameters)
    }

    BaseContextMenuSeparator {
        visible: appWindow.supportComputerShutdown
    }

    BaseContextMenuItem {
        visible: appWindow.supportComputerShutdown
        text: qsTr("Auto Shutdown") + App.loc.emptyString
        enabled: App.downloads.tracker.nonFinishedDownloadsRunning || shutdownTools.powerManagement.shutdownComputerWhenDownloadsFinished
        arrow_down: enabled && !root.shutdownGroupOpened
        arrow_up: enabled && root.shutdownGroupOpened && !shutdownTools.powerManagement.shutdownComputerWhenDownloadsFinished
        MouseArea {
            anchors.fill: parent
            cursorShape: parent.enabled ? Qt.PointingHandCursor: Qt.ArrowCursor
            onClicked: root.shutdownGroupToggle()
        }
    }

    ActionGroup {
        id: shutdownGroup
    }

    BaseContextMenuSeparator {
        visible: root.shutdownGroupOpened
    }

    BaseContextMenuItem {
        visible: root.shutdownGroupOpened
        text: qsTr("Sleep") + App.loc.emptyString
        checkable: true
        insideMainMenu: true
        checked: shutdownTools.powerManagement.shutdownComputerWhenDownloadsFinished && shutdownTools.powerManagement.shutdownType == VmsQt.SuspendComputer
        onTriggered: shutdownTools.setShutdownType(VmsQt.SuspendComputer, checked)
        ActionGroup.group: shutdownGroup
    }

    BaseContextMenuItem {
        visible: Qt.platform.os === "windows" && root.shutdownGroupOpened
        text: qsTr("Hibernate") + App.loc.emptyString
        checkable: true
        insideMainMenu: true
        checked: shutdownTools.powerManagement.shutdownComputerWhenDownloadsFinished && shutdownTools.powerManagement.shutdownType == VmsQt.HibernateComputer
        onTriggered: shutdownTools.setShutdownType(VmsQt.HibernateComputer, checked)
        ActionGroup.group: shutdownGroup
    }

    BaseContextMenuItem {
        visible: root.shutdownGroupOpened
        text: qsTr("Shutdown") + App.loc.emptyString
        checkable: true
        insideMainMenu: true
        checked: shutdownTools.powerManagement.shutdownComputerWhenDownloadsFinished && shutdownTools.powerManagement.shutdownType == VmsQt.ShutdownComputer
        onTriggered: shutdownTools.setShutdownType(VmsQt.ShutdownComputer, checked)
        ActionGroup.group: shutdownGroup
    }

    BaseContextMenuSeparator {}

    BaseContextMenuItem {
        visible: appWindow.portableSupported
        text: qsTr("Create portable version") + App.loc.emptyString
        onTriggered: createPortableDlg.open()
    }

    BaseContextMenuItem {
        visible: appWindow.updateSupported
        text: qsTr("Check for Updates...") + App.loc.emptyString
        onTriggered: {
            if (forSettingsPage) {
                stackView.pop();
            }
            appWindow.checkUpdates()
        }
    }

    BaseContextMenuItem {
        text: qsTr("Join the Mosaic...") + App.loc.emptyString
        offerIndicator: true
        onTriggered: {
            Qt.openUrlExternally("https://up.freedownloadmanager.org/fdm6/js_stat.php?navigate_to_mosaic=1");
            mosaicClick();
        }
    }

    BaseContextMenuItem {
        text: qsTr("About") + App.loc.emptyString
        onTriggered: appWindow.showAbout()
    }

    BaseContextMenuSeparator {}

    BaseContextMenuItem {
        text: qsTr("Quit") + App.loc.emptyString
        onTriggered: App.quit();
    }

    BaseContextMenuSeparator {
        visible: App.isSelfTestAvail
    }

    BaseContextMenuItem {
        visible: App.isSelfTestAvail
        text: "Self Test"
        onTriggered: App.launchSelfTest();
    }

    Component.onCompleted: {
        if (appWindow.btSupported) {
            if (App.downloads.tracker.hasPostFinishedTasksDownloadsCount) {
                var i = 3;
                root.insertItem(i++, Qt.createQmlObject('import "../bt/desktop"; StartSeedingDownloadsMenuItem {}', root));
                root.insertItem(i++, Qt.createQmlObject('import "../bt/desktop"; StopSeedingDownloadsMenuItem {}', root));
                root.insertItem(i++, Qt.createQmlObject('import "./BaseElements"; BaseContextMenuSeparator {}', root));
            }
        }
    }

    function shutdownGroupToggle() {
        if (!shutdownTools.powerManagement.shutdownComputerWhenDownloadsFinished) {
            root.shutdownGroupOpened = !root.shutdownGroupOpened;
        }
    }

    function openMenu() {
        root.shutdownGroupOpened = shutdownTools.powerManagement.shutdownComputerWhenDownloadsFinished;
        root.open();
    }

    Connections {
        target: appWindow
        onActiveChanged: {
            if (!appWindow.active) {
                close()
            }
        }
        onNativeMenuItemTriggered: close()
    }

    onOpened: defineMosaicStat()

    onClosed: saveMosaicStat()

    function defineMosaicStat() {
        if (!uiSettingsTools.settings.menuMarkerShown) {
            mosaicStat.greenMenuMarker = true;
        } else {
            mosaicStat.greenMenuMarker = false;
        }
        mosaicStat.mosaicClick = false;
        uiSettingsTools.settings.menuMarkerShown = true;
    }

    function saveMosaicStat() {
        var request = new XMLHttpRequest();
        var url = 'https://up.freedownloadmanager.org/fdm6/js_stat.php?stat_type=mosaic_menu&uuid='
                + encodeURIComponent(App.uuid) + '&green_menu_marker=' + (mosaicStat.greenMenuMarker ? '1' : '0')
                + '&mosaic_click=' + (mosaicStat.mosaicClick ? '1' : '0');
        request.open('GET', url);
        request.send();
    }

    function mosaicClick() {
        mosaicStat.mosaicClick = true;
    }
}
