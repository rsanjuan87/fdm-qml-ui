import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.11
import "../common"
import "../common/Tools"
import "./Dialogs"
import "./Banners"
import "./BottomPanel"
import "./BaseElements"
import org.freedownloadmanager.fdm 1.0
import org.freedownloadmanager.fdm.appfeatures 1.0

Page {
    id: root

    property var keyboardFocusItem: keyboardFocusItem

    Component.onCompleted: {
        keyboardFocusItem.focus = true;
        root.forceActiveFocus();

        colsWidthCalc.downloadsViewSpeedColumnHovered = Qt.binding(function() {
            return downloadsView.speedColumnHoveredDownloadId != -1;
        });
        colsWidthCalc.downloadsViewSpeedColumnHoveredWidth = Qt.binding(function() {
            return downloadsView.speedColumnHoveredWidth;
        });
        colsWidthCalc.downloadsViewSpeedColumnNotHoveredSinceTime = Qt.binding(function() {
            return downloadsView.speedColumnNotHoveredSinceTime;
        });
        colsWidthCalc.downloadsViewShowingCompleteMsg = Qt.binding(function() {
            return downloadsView.showingCompleteMsg > 0;
        });
    }

    Item {
        id: keyboardFocusItem
        focus: true

        DownloadsItemTools {
            id: downloadsItemTools
            itemId: selectedDownloadsTools.currentDownloadId
        }

        Keys.onDownPressed: selectedDownloadsTools.navigateToNearbyItem(1, (event.modifiers & Qt.ShiftModifier))
        Keys.onUpPressed: selectedDownloadsTools.navigateToNearbyItem(-1, (event.modifiers & Qt.ShiftModifier))
        Keys.onSpacePressed: App.features.hasFeature(AppFeatures.FilesQuickLook) ? selectedDownloadsTools.quickLookFile() : downloadsItemTools.changeChecked()
        Keys.onEscapePressed: selectedDownloadsTools.checkAll(false)

        Keys.onDeletePressed: selectedDownloadsTools.removeCurrentDownloads()
        Keys.onPressed: {
            if (event.key === 16777219 || event.key === Qt.Key_Back) {
                selectedDownloadsTools.removeCurrentDownloads();
            }
            if (event.key === Qt.Key_PageUp) {
                selectedDownloadsTools.navigateToNearbyPage(-1, (event.modifiers & Qt.ShiftModifier));
            }
            if (event.key === Qt.Key_PageDown) {
                selectedDownloadsTools.navigateToNearbyPage(1, (event.modifiers & Qt.ShiftModifier));
            }
            if (event.key === Qt.Key_End) {
                selectedDownloadsTools.navigateToEnd((event.modifiers & Qt.ShiftModifier));
            }
            if (event.key === Qt.Key_Home) {
                selectedDownloadsTools.navigateToHome((event.modifiers & Qt.ShiftModifier));
            }
        }

        Keys.onReturnPressed: {
            if (selectedDownloadsTools.currentDownloadId > 0) {
                downloadsItemTools.doAction();
            }
        }

        Shortcut {
            sequence: StandardKey.New
            onActivated: buildDownloadDlg.newDownload()
        }

        Shortcut {
            sequence: StandardKey.Paste
            onActivated: buildDownloadDlg.newDownload()
        }

        Shortcut {
            sequence: StandardKey.SelectAll
            onActivated: selectedDownloadsTools.checkAll(true)
        }
    }

    header: MainToolbar {
        id: mainToolbar
        leftPadding: 0
        rightPadding: 0
        bottomPadding: 0
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredHeight: integrationBanner.item.visible || shutdownBanner.visible ? 30 : 0
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            color: "transparent"
            clip: true

            Loader {
                id: integrationBanner
                active: btSupported
                source: "../bt/desktop/IntegrationBanner.qml"
                width: parent.width
                height: parent.height
            }

            ShutdownBanner {
                id: shutdownBanner
            }
        }

        Rectangle {
            id: pageContent
            color: "transparent"
            Layout.fillWidth: true
            Layout.fillHeight: true

            DownloadPageBackground {}

            ColumnLayout {
                id: columnLayout
                anchors.fill: parent
                spacing: 0

                Rectangle {

                    color: "transparent"
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    //filters bar
                    MainFiltersBar {
                        id: filtersBar
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 5
                        border.color: App.downloads.infos.empty ? "transparent" : appWindow.theme.border
                        border.width: 1
                        color: "transparent"
                        anchors.topMargin: filtersBar.height

                        //downloads list
                        Rectangle {
                            visible: !App.downloads.infos.empty
                            anchors.fill: parent
                            color: "transparent"

                            DownloadsViewHeader {
                                id: downloadsViewHeader
                                width: parent.width
                                DownloadsViewHeaderColumnsWidthCalc {
                                    id: colsWidthCalc
                                    header: parent
                                }
                            }

                            Rectangle {
                                z: 2
                                width: parent.width
                                anchors.top: downloadsViewHeader.bottom
                                anchors.topMargin: -1
                                anchors.bottom: parent.bottom
                                color: "transparent"
                                clip: true

                                DownloadsView {
                                    id: downloadsView
                                    anchors.fill: parent
                                    downloadsViewHeader: downloadsViewHeader

                                    Component.onCompleted: {
                                        selectedDownloadsTools.registerListView(this);
                                    }

                                    Component.onDestruction: {
                                        selectedDownloadsTools.unregisterListView(this);
                                    }
                                }
                            }
                        }

                        //drop area - empty download list
                        Rectangle {
                            id: pageBody
                            anchors.fill: parent
                            visible: App.downloads.infos.empty
                            color: "transparent"
                            border.color: "transparent"
                            border.width: 2
                            clip: true

                            DottedBorder {
                                anchors.fill: parent
                                anchors.topMargin: 1
                                anchors.bottomMargin: appWindow.macVersion ? 0 : 1
                                anchors.leftMargin: 1
                                anchors.rightMargin: 1
                            }

                            ColumnLayout {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter

                                BaseLabel {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: qsTr("Download list is empty.") + App.loc.emptyString
                                    color: appWindow.theme.emptyListText
                                    font.pixelSize: 32
                                }
                                BaseLabel {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: qsTr("Add new download URL.") + App.loc.emptyString
                                    color: appWindow.theme.emptyListText
                                    font.pixelSize: 22
                                }
                            }

                            DropArea {
                                anchors.fill: parent
                                onDropped: App.onDropped(drop)
                            }
                        }

                        //empty search results
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 5
                            color: "transparent"
                            visible: !App.downloads.infos.empty
                                     && (downloadsViewTools.emptySearchResults
                                         || downloadsViewTools.emptyActiveDownloadsList
                                         || downloadsViewTools.emptyCompleteDownloadsList
                                         || downloadsViewTools.emptyTagResults)

                            ColumnLayout {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: parent.width
                                spacing: 15

                                BaseLabel {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: (downloadsViewTools.emptySearchResults ? qsTr("No results found for") + " \"" + downloadsViewTools.downloadsTitleFilter + "\"" :
                                           downloadsViewTools.emptyTagResults ? qsTr("No results tagged \"%1\" found").arg(downloadsViewTools.downloadsSelectedTag) :
                                           downloadsViewTools.emptyActiveDownloadsList ? qsTr("No active downloads") :
                                           downloadsViewTools.emptyCompleteDownloadsList ? qsTr("No completed downloads") : "") + App.loc.emptyString
                                    font.pixelSize: 24
                                    font.weight: Font.Light
                                    Layout.fillWidth: true
                                    wrapMode: Text.Wrap
                                    horizontalAlignment: Text.AlignHCenter
                                    textFormat: Text.PlainText
                                }

                                BaseLabel {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "<a href='#'>" + qsTr("Show all") + "</a>" + App.loc.emptyString
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: downloadsViewTools.resetFilters()
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: bottomPanelRct
                    Layout.fillWidth: true
                    width: parent.width
                    visible: bottomPanelTools.panelVisible && bottomPanelTools.sufficientWindowHeight
                    Layout.preferredHeight: bottomPanelTools.panelHeigth
                    color: "transparent"

                    BottomPanel {}
                }
            }

            Rectangle {
                width: parent.width
                color: "transparent"
                height: 100
                y: bottomPanelRct.y - 50
                visible: dragDropRect.movingStarted
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.SplitVCursor
                }
            }

            DragDropBottomPanel {
                id: dragDropRect
                bottomPanelRct: bottomPanelRct
            }
        }
    }

    UpdateDialogSubstrate {}
}
