import QtQuick 2.0
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import org.freedownloadmanager.fdm 1.0
import org.freedownloadmanager.fdm.abstractdownloadsui 1.0
import "../../BaseElements"

ColumnLayout {
    visible: downloadTools.batchDownload
    Layout.topMargin: 8
    Layout.fillWidth: true
    Layout.preferredHeight: Math.min(list.count * 26 + 35, Math.max(130, (appWindow.height <= 680 ? appWindow.height - 480 : (appWindow.height > 680 && appWindow.height < 810 ? 200 : appWindow.height - 610))))
    spacing: 5

    property bool showAgeCol
    property bool showMediaDurationCol

    Rectangle {
        Layout.fillWidth: true
        height: 20
        color: "transparent"

        BaseLabel {
            text: qsTr("Download links (%1 selected)").arg(list.checkedUrlsCount) + App.loc.emptyString
            anchors.left: parent.left
        }

        BaseLabel {
            text: qsTr("Select all") + App.loc.emptyString
            color: linkColor
            anchors.right: selectNone.left
            anchors.rightMargin: 20
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    setAllFilesToDownload(true);
                    list.positionViewAtBeginning();
                }
            }
        }

        BaseLabel {
            id: selectNone
            text: qsTr("Select none") + App.loc.emptyString
            color: linkColor
            anchors.right: parent.right
            MouseArea {
                anchors.fill: parent
                onClicked: setAllFilesToDownload(false)
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        border.color: appWindow.theme.border
        border.width: 1
        color: appWindow.theme.background

        ButtonGroup {
            id: downloadsListGroup
            exclusive: false
            onCheckStateChanged: downloadTools.setEmptyDownloadsListWarning(checkState === Qt.Unchecked)
        }

        ListView {
            id: list
            anchors.fill: parent
            spacing: 10
            clip: true
            anchors.topMargin: 5
            anchors.bottomMargin: 5
            anchors.rightMargin: 5

            flickableDirection: Flickable.VerticalFlick
            ScrollBar.vertical: ScrollBar{
                minimumSize: 0.2

                onVisualPositionChanged: {
                    if (visualPosition + visualSize == 1) {
                        tryToRetrieveMoreDownloads();
                    }
                }
            }
            boundsBehavior: Flickable.StopAtBounds

            property int checkedUrlsCount

            onFlickEnded: {
                if (list.atYEnd /*&& list.count < downloadTools.batchDownloadMaxUrlsCount*/) {
                    tryToRetrieveMoreDownloads();
                }
            }

            model: ListModel {}

            delegate: RowLayout {
                width: parent.width
                spacing: 10

                BaseCheckBox {
                    id: label
                    text: (index + 1) + ". " + title
                    checkBoxStyle: "black"
                    fontSize: 13
                    Layout.fillWidth: true
                    textColor: checked ? appWindow.theme.foreground : "#737373"
                    checked: !excluded
                    onCheckedChanged: markDownloadAsExcluded(index, checked);
                    ButtonGroup.group: downloadsListGroup
                    enabled: checked || list.checkedUrlsCount < downloadTools.batchDownloadMaxUrlsCount

                    MouseArea {
                        id: mouseAreaLabel
                        propagateComposedEvents: true
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: mouse.accepted = false
                        onPressed: mouse.accepted = false

                        BaseToolTip {
                            text: title
                            visible: label.truncated && mouseAreaLabel.containsMouse
                            width: 250
                            onVisibleChanged: {
                                if (visible) {
                                    x = mouseAreaLabel.mouseX
                                    y = mouseAreaLabel.mouseY + 20
                                }
                            }
                        }

                        Popup {
                            visible: remotePreviewImgUrl && mouseAreaLabel.containsMouse && !list.flicking
                            parent: tuneDialog.overlay
                            x: label.x + 27
                            y: label.y - 115
                            contentItem: Image {
                                source: remotePreviewImgUrl
                                sourceSize.width: 200
                                sourceSize.height: 100
                            }
                        }
                    }
                }

                BaseLabel {
                    id: ageHrLabel
                    visible: showAgeCol
                    text: ageHr
                    Layout.preferredWidth: 90
                    elide: Label.ElideRight
                    font.pixelSize: 13

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true

                        BaseToolTip {
                            text: ageHrLabel.text
                            visible: ageHrLabel.truncated && parent.containsMouse
                        }
                    }
                }

                BaseLabel {
                    visible: showMediaDurationCol
                    text: "[" + mediaDurationHr + "]"
                    Layout.preferredWidth: 80
                    elide: Label.ElideRight
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: 13
                }
            }

            footer: BusyIndicator {
                visible: false
                anchors.horizontalCenter: parent.horizontalCenter
                height: visible ? undefined : 0
            }
        }
    }

    function tryToRetrieveMoreDownloads() {
        if (downloadTools.canRetrieveMoreDownloads()) {
            list.footerItem.visible = true;
            downloadTools.retrieveMoreDownloads();
        }
    }

    function setAllFilesToDownload(value) {
        if (value && list.model.count > downloadTools.batchDownloadMaxUrlsCount) {
            setAllFilesToDownload(false);
        }

        for (var i = 0; i < list.model.count; i++) {
            markDownloadAsExcluded(i, value);
        }
    }

    function markDownloadAsExcluded(index, value) {
        var item = list.model.get(index);
        if (item.excluded !== !value) {
            if (value && list.checkedUrlsCount >= downloadTools.batchDownloadMaxUrlsCount) {
                return;
            }
            list.checkedUrlsCount += value ? 1 : -1;
            downloadTools.setBatchDownloadLimitWarning(list.checkedUrlsCount);
        }
        list.model.setProperty(index, 'excluded', !value);
        var fileIndex = list.model.get(index).fileIndex;
        App.downloads.creator.markDownloadAsExcluded(downloadTools.requestId, fileIndex, !value);
    }

    function initialization() {
        list.model.clear();
        list.checkedUrlsCount = 0;
        showAgeCol = false;
        showMediaDurationCol = false;
        loadRows();
    }

    function loadRows() {
        var request;
        var preferredVideoHeight = false;
        var originFilesTypes = [];
        var addDateToFileName = false;
        var subtitlesEnabled = false;
        var allDownloadsExcluded = true;
        var excluded;

        var firstIndex = list.count ? list.count : 0;

        for (var i = firstIndex; i < App.downloads.creator.downloadCount(requestId) - 1; i++) {
            request = App.downloads.creator.downloadInfo(requestId, (i + 1));

            if (!firstIndex) {
                if (request.mediaDurationHr) {
                    showMediaDurationCol = true;
                }
                if (request.ageHr) {
                    showAgeCol = true;
                }

                preferredVideoHeight = preferredVideoHeight || request.supportedOptions & AbstractDownloadsUi.PreferredVideoHeight;
                addDateToFileName = addDateToFileName || request.supportedOptions & AbstractDownloadsUi.AddDateToFileName;
                subtitlesEnabled = subtitlesEnabled || request.supportedOptions & AbstractDownloadsUi.PreferredSubtitlesLanguagesCodes;

                if (request.supportedOptions & AbstractDownloadsUi.PreferredFileType) {
                    for (var j = 0; j < request.originFilesTypes.length; j++) {
                        if (request.originFilesTypes[j] != AbstractDownloadsUi.UnknownFile && originFilesTypes.indexOf(request.originFilesTypes[j]) === -1) {
                            originFilesTypes.push(request.originFilesTypes[j]);
                        }
                    }
                }
            }

            excluded = App.downloads.creator.isDownloadMarkedAsExcluded(requestId, i+1);
            allDownloadsExcluded = allDownloadsExcluded && excluded;
            list.checkedUrlsCount += excluded ? 0 : 1;
            downloadTools.setBatchDownloadLimitWarning(list.checkedUrlsCount);

            list.model.insert(i, {'title': request.title, 'fileIndex': (i + 1), 'excluded': excluded, 'mediaDurationHr': request.mediaDurationHr, 'ageHr': request.ageHr, 'remotePreviewImgUrl': request.remotePreviewImgUrl.toString()});
        }

        if (!firstIndex) {
            downloadTools.setPreferredVideoHeight(preferredVideoHeight > 0 ? downloadTools.defaultPreferredVideoHeight : 0);
            downloadTools.setOriginFilesTypes(originFilesTypes);
            downloadTools.setAddDateToFileName(addDateToFileName);
            downloadTools.setSubtitlesEnabled(subtitlesEnabled);
            downloadTools.setEmptyDownloadsListWarning(allDownloadsExcluded);
        }
    }

    Connections {
        target: App.downloads.creator
        onFinishedRetrievingMoreDownloads: {
            if (id == requestId) {
                list.footerItem.visible = false;
                loadRows();
            }
        }
    }
}