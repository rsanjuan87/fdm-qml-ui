import QtQuick 2.10
import QtQuick.Window 2.10
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.2
import QtQuick.Controls.Material 2.4
import "../common"
import "../common/Tools"
import "./Tools"
//import "../common/Tests"
import "FilePicker"
import org.freedownloadmanager.fdm 1.0
import org.freedownloadmanager.fdm.appfeatures 1.0
import org.freedownloadmanager.fdm.qtsystemtheme 1.0
import org.freedownloadmanager.fdm.dmcoresettings 1.0
import "./Themes"
import "./BaseElements"
import "./Dialogs"

ApplicationWindow
{
    id: appWindow

    property bool mobileVersion: true

    property bool smallScreen: width < 500
    property bool verySmallScreen: width < 400

    property real screenWidthInches: width / ( Screen.pixelDensity * 25.4 )
    property bool showBordersInDownloadsList: false//width > 799 && appWindow.screenWidthInches > 4.5

    property bool showDownloadIcon: true
    property bool showDownloadCheckbox: false
    property bool showDownloadItemMenuBtn: true
//    property int checkedDownloadsCount: 0
    property bool selectMode: false
    property bool searchMode: false
    property bool btSupported: App.features.hasFeature(AppFeatures.BT)
    property bool ytSupported: App.features.hasFeature(AppFeatures.YT)
    property alias btS: btStrings.item

    signal newDownloadAdded
    signal uiReadyStateChanged
    signal appWindowStateChanged
    signal tumSettingsChanged
    signal stopDownload(var downloadIds)
    signal openBrowser
    signal startDownload
    signal reportError(int failedId)

    visible: true
    width: 360
    height: 640
//    visibility: Window.FullScreen
    title: App.displayName

    DarkTheme {id: darkTheme}
    LightTheme {id: lightTheme}
    property var theme: defineTheme()

    Material.theme: Material.Light
    Material.background: theme.background
    Material.primary: theme.primary
    Material.foreground: theme.foreground
    Material.accent: theme.accent

    onOpenBrowser: App.launchBuiltInWebBrowser()
    onActiveChanged: {
        theme = defineTheme()
    }

    UiReadyTools {
        id: uiReadyTools
        firstPageComponent: Component {
            DownloadsPage {}
        }
        waitingPageComponent: Component {
            WaitingPage {}
        }
    }

    WaStackView {
        id: stackView
        anchors.fill: parent
        onCurrentItemChanged: appWindowStateChanged()
    }

    UiSettingsTools {
        id: uiSettingsTools
    }

    //footer: MainStatusBar {}

    Loader {
        id: aboutDlg
        active: false
        source: "Dialogs/AboutDialog.qml"
        anchors.centerIn: parent
        property bool opened: active && item.opened
        function open() {
            active = true;
            item.open();
        }
    }

    Loader {
        id: selfTestDlg
        active: App.isSelfTestMode
        source: "../desktop/Dialogs/SelfTestDialog.qml"
        anchors.centerIn: parent
        width: parent.width - 100
        height: parent.height - 200
        Component.onCompleted: {
            if (App.isSelfTestMode)
                uiReadyTools.onReady(function(){selfTestDlg.item.open();});
        }
    }

    Loader {
        id: btTools
        active: btSupported
        source: "../bt/Tools.qml"
    }

    Loader {
        id: btStrings
        active: btSupported
        source: "../bt/BtStrings.qml"
    }

    MovingFailedDialog {
        id: movingFailedDlg
    }

    Loader {
        id: privacyDlg
        source: "Dialogs/PrivacyDialog.qml"
        active: false
        anchors.centerIn: parent
        property bool opened: active && item.opened
        function open(failedId) {
            if (uiSettingsTools.settings.reportProblemAccept) {
                App.downloads.errorsReportsMgr.reportError(failedId);
                appWindow.reportError(failedId);
            } else {
                active = true;
                if (!item.opened) {
                    item.showDialog(failedId);
                }
            }
        }
    }

    Loader {
        id: quitConfDlg
        active: false
        source: "Dialogs/QuitConfirmationDialog.qml"
        anchors.centerIn: parent
        function open(message) {
            active = true;
            item.message = message;
            item.open();
        }
    }

    MessageDialog
    {
        id: reportSentDlg
        property string errorMessage
        text: (errorMessage.length > 0 ? qsTr("Sorry, the report hasn't been sent, an error occurred: %1").arg(errorMessage) : qsTr("The report has been sent. Thank you for your cooperation!")) + App.loc.emptyString
        standardButtons: StandardButton.Ok
    }

    Connections
    {
        target: App.downloads.errorsReportsMgr
        onReportFinished: {
            reportSentDlg.errorMessage = error;
            reportSentDlg.open();
        }
    }

    FilePicker {
        id: filePicker
    }

    Connections {
        target: filePicker
        onFolderSelected: {
            if (initiator == 'fileMoving') {
                selectedDownloadsTools.moveCurrentDownloads(folderName)
            }
        }
    }

    onClosing: {
        if(stackView.depth > 1) {
            stackView.pop();
            close.accepted = false;
        } else if (selectMode || searchMode) {
            stackView.currentItem.state = "mainView"
            close.accepted = false;
        } else {
            close.accepted = true;
        }
    }

    onStopDownload: stopDownloadDlg.show(downloadIds)

    DownloadsInterceptionTools {
        id: interceptionTools
        onHasDownloadRequests: appWindow.onDownloadRequest(false)
        onNewDownloadRequests: appWindow.onDownloadRequest(true)
        onHasMergeRequests: appWindow.onMergeRequest(false)
        onNewMergeRequests: appWindow.onMergeRequest(true)
        onNewAuthenticationRequest: appWindow.onAuthenticationRequest()
        onNewSslRequest: onSslRequest()
        onHasMovingFailedDownloads: onMovingFailed(downloadId, error)
    }

    MergeDownloadsDialog {
        id: mergeDownloadsDlg
    }

    StopDownloadDialog {
        id: stopDownloadDlg
    }

    SslDialog {
        id: sslDlg
    }

    BrowserIntroDialog {
        id: browserIntroDlg
    }

    MobileDataUsageDialog {
        id: mobileDataUsageDlg
    }

    FileManagerSupportDialog {
        id: fileManagerSupportDlg
    }

    SortTools {
        id: sortTools
    }

//    AddManyDownloads {
//        countAdd: 100
//    }

    ScreenTools {
        id: screenTools
    }

    AdaptiveTools {
        id: adaptiveTools
    }

    EnvTools {
        id: envTools
    }

    SelectedDownloadsTools {
        id: selectedDownloadsTools
    }

    DownloadsViewTools {
        id: downloadsViewTools
    }

    DownloadsWithMissingFilesTools {
        id: downloadsWithMissingFilesTools
    }

    TagsTools {
        id: tagsTools
    }

    VoteBlock {
        id: voteBlock
    }

    function createDownloadDialog(uiNewDownloadRequest)
    {
        uiNewDownloadRequest = uiNewDownloadRequest || null;
        stackView.waPush(Qt.resolvedUrl("BuildDownloadPage.qml"), {downloadRequest: uiNewDownloadRequest});
    }

    function createAuthDialog(request)
    {
        stackView.waPush(Qt.resolvedUrl("AuthenticationPage.qml"), {request: request});
    }

    function createAddTDialog(ids)
    {
        if (btSupported) {
            stackView.waPush(Qt.resolvedUrl("../bt/mobile/AddTPage.qml"), {downloadIds: ids});
        }
    }

    function canShowCreateDownloadDialog(force)
    {
        if (stackView.depth === 0) {
            return false;
        }
        var page = stackView.get(0);
        var page_name = page.pageName;
        if (['WaitingPage'].indexOf(page_name) >= 0) {
            return false;
        }
        if (!(force && !mergeDownloadsDlg.opened)) {
            var current_page = stackView.currentItem;
            var current_page_name = current_page.pageName;
            if (['BuildDownloadPage', 'TuneAndAddDownloadPage', "AuthenticationPage.qml"].indexOf(current_page_name) >= 0 || mergeDownloadsDlg.opened) {
                return false;
            }
        }
        return true;
    }

    function canShowAuthDialog()
    {
        if (stackView.depth === 0) {
            return false;
        }
        var page = stackView.get(0);
        var page_name = page.pageName;
        if (['WaitingPage'].indexOf(page_name) >= 0) {
            return false;
        }

        var current_page = stackView.currentItem;
        var current_page_name = current_page.pageName;
        if (['AuthenticationPage'].indexOf(current_page_name) >= 0 || mergeDownloadsDlg.opened) {
            return false;
        }

        return true;
    }

    function canShowMergeDownloadsDialog(force)
    {
        if (stackView.depth === 0) {
            return false;
        }
        var page = stackView.get(0);
        var page_name = page.pageName;
        if (['WaitingPage'].indexOf(page_name) >= 0) {
            return false;
        }
        if (mergeDownloadsDlg.opened || sslDlg.opened) {
            return false;
        }
        return true;
    }

    function onDownloadRequest(force)
    {
        if (canShowCreateDownloadDialog(force)) {
            var uiNewDownloadRequest = interceptionTools.getDownloadRequest();
            if (uiNewDownloadRequest) {
                appWindow.createDownloadDialog(uiNewDownloadRequest);
            }
        }
    }

    function onMergeRequest(force)
    {
        if (canShowMergeDownloadsDialog(force)) {
            var mergeRequestId = interceptionTools.getMergeRequestId();
            if (mergeRequestId) {
                var existingRequestId = interceptionTools.getExistingRequestId(mergeRequestId);
                mergeDownloadsDlg.newMergeByRequest(mergeRequestId, existingRequestId);
            }
        }
    }

    function onAuthenticationRequest() {
        if (canShowAuthDialog()) {
            var request = interceptionTools.getAuthRequest();
            if (request) {
                appWindow.createAuthDialog(request);
            }
        }
    }

    function onSslRequest() {
        if (canShowMergeDownloadsDialog()) {
            var request = interceptionTools.getSslRequest();
            if (request) {
                sslDlg.newSslRequest(request);
            }
        }
    }

    function onMovingFailed(downloadId, error) {
        error = error !== '' ? error : getDownloadMovingError(downloadId);

        if (!movingFailedDlg.opened) {
            movingFailedDlg.movingFailedAction(downloadId, error);
        }
    }

    function getDownloadMovingError(downloadId) {
        return App.downloads.infos.info(downloadId).loError;
    }

    Connections {
        target: uiSettingsTools.settings
        onThemeChanged: {
            theme = defineTheme()
        }
    }

    function defineTheme() {
        return uiSettingsTools.settings.theme === 'dark' || uiSettingsTools.settings.theme === 'system' && App.systemTheme == QtSystemTheme.Dark ? darkTheme : lightTheme
    }

    Loader {
        id: remoteResourceChangedDlg
        active: false
        source: "Dialogs/RemoteResourceChangedDialog.qml"
        anchors.centerIn: parent
        property bool opened: active && item.opened
        function open(id) {
            active = true;
            item.remoteResourceChanged(id);
            if (!item.opened) {
                item.open();
            }
        }
    }

    Connections {
        target: App.downloads.tracker
        onRemoteResourceChanged: {
            if (!App.settings.toBool(App.settings.dmcore.value(DmCoreSettings.AutoRestartFinishedDownloadIfRemoteResourceChanged))) {
                remoteResourceChangedDlg.open(id);
            }
        }
    }

    Loader {
        id: filesExistsDlg
        active: false
        source: "Dialogs/FilesExistsDialog.qml"
        anchors.centerIn: parent
        property bool opened: active && item.opened
        function open(downloadId, fileIndex, files) {
            active = true;
            item.downloadId = downloadId;
            item.fileIndex = fileIndex;
            item.files = files;
            if (!item.opened) {
                item.open();
            }
        }
    }

    Connections {
        target: App.downloads.filesExistsActionsMgr
        onActionRequired: {
            filesExistsDlg.open(downloadId, fileIndex, files);
        }
    }

    Connections {
        target: App
        onShowQuitConfirmation: {quitConfDlg.open(message);}
    }

    Connections {
        target: appWindow
        onNewDownloadAdded: downloadsViewTools.resetAllFilters()
    }

    DownloadExpiredDialog {
        id: downloadExpiredDlg
        onClosed: {
            App.downloads.expiredDownloads.onExpiredDownloadNotificationFinished(downloadId);
            openDownloadExpiredDialogForNextDownload();
        }
    }
    function openDownloadExpiredDialog(downloadId)
    {
        downloadExpiredDlg.downloadId = downloadId;
        downloadExpiredDlg.open();
    }
    function openDownloadExpiredDialogForNextDownload()
    {
        if (!downloadExpiredDlg.opened &&
                App.downloads.expiredDownloads.hasNewExpiredDownloads)
        {
            openDownloadExpiredDialog(App.downloads.expiredDownloads.nextNewExpiredDownloadId());
        }
    }
    Connections {
        target: App.downloads.expiredDownloads
        onHasNewExpiredDownloadsChanged: openDownloadExpiredDialogForNextDownload()
        onNotExpiredAnymore: {
            if (downloadExpiredDlg.opened && downloadExpiredDlg.downloadId == id)
                downloadExpiredDlg.close();
        }
    }
}
