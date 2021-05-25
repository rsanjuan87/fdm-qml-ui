import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.2
import "./BaseElements"
import org.freedownloadmanager.fdm 1.0
import org.freedownloadmanager.fdm.abstractdownloadsui 1.0

Rectangle {
    id: root
    width: parent.width - 10
    height: 34
    clip: true
    color: "transparent"
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter

    //filters
    Rectangle {
        anchors.left: parent.left
        anchors.right: batchDownloadMarker.left
        anchors.top: parent.top
        anchors.topMargin: 8
        height: 18
        color: "transparent"

        Row {
            height: parent.height
            spacing: 8

            Row {
                id: statesFilters
                height: parent.height
                spacing: 8

                onWidthChanged: calculateTagsWidth()

                MainFilterButton {
                    cnt: App.downloads.tracker.totalDownloadsCount
                    text: qsTr("All") + App.loc.emptyString + (cnt > 0 ? " (%1)".arg(cnt) : "")
                    value: 0
                }

                MainFilterButton {
                    cnt: App.downloads.tracker.runningDownloadsCount
                    text: qsTr("Active") + App.loc.emptyString + (cnt > 0 ? " (%1)".arg(cnt) : "")
                    value: AbstractDownloadsUi.FilterRunning
                }

                MainFilterButton {
                    cnt: App.downloads.tracker.finishedDownloadsCount
                    text: qsTr("Completed") + App.loc.emptyString + (cnt > 0 ? " (%1)".arg(cnt) : "")
                    value: AbstractDownloadsUi.FilterFinished
                }
            }

            Repeater {
                model: tagsTools.visibleTags
                delegate: TagButton {
                    tag: modelData
                }
            }

            TagsPanelActionButton {
                id: tagPanelBtn
            }

            MessageDialog {
                id: removeTagDlg
                property int tagId
                text: qsTr("OK to remove tag?") + App.loc.emptyString
                standardButtons: StandardButton.Ok | StandardButton.Cancel
                onAccepted: {
                    if (App.downloads.model.tagIdFilter == tagId)
                        downloadsViewTools.resetDownloadsTagFilter();
                    tagsTools.removeTag(tagId);
                }
            }
        }
    }

    //batch download marker
    BatchDownloadTitle {
        id: batchDownloadMarker
        onVisibilityChanged: calculateTagsWidth()
    }

    Component.onCompleted: calculateTagsWidth()

    Connections {
        target: appWindow
        onWidthChanged: calculateTagsWidth()
    }

    onWidthChanged: calculateTagsWidth()

    function calculateTagsWidth() {
        tagsTools.setTagsPanelWidth(root.width - statesFilters.width - tagPanelBtn.width - statesFilters.spacing*2 - (batchDownloadMarker.visible ? batchDownloadMarker.width : 30));
    }
}