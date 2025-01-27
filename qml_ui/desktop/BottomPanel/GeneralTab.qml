import QtQuick 2.10
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3
import org.freedownloadmanager.fdm 1.0
import org.freedownloadmanager.fdm.appfeatures 1.0
import "../../common/Tools"
import "../BaseElements"
import "../../common"
import "../"

Flickable {
    id: flickable

    anchors.fill: parent

    property int bottomPanelHeight
    property bool hasVerticalScrollbar: contentHeight > height

    clip: true

    flickableDirection: Flickable.VerticalFlick
    ScrollBar.vertical: ScrollBar {
        policy: flickable.hasVerticalScrollbar ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
    }
    boundsBehavior: Flickable.StopAtBounds

    contentHeight: myContent.height

    MouseArea {
        anchors.fill: parent
        onClicked: forceActiveFocus()
    }

    Column
    {
        id: myContent

        width: parent.width

        spacing: 0

        Rectangle {id: topSpacingRect; height: 20; width: height; color: "transparent"}

        Row {
            id: myContent2

            x: 10
            width: parent.width - x*2

            spacing: 20

            Image {
                id: img
                readonly property var preview: App.downloads.previews.preview(selectedDownloadsTools.currentDownloadId)
                readonly property var previewUrl: preview ? preview.large : null
                source: previewUrl.toString() ? previewUrl : (downloadsItemTools.hasChildDownloads ? appWindow.theme.batchDownloadIcon : appWindow.theme.defaultFileIcon)
                fillMode: Image.PreserveAspectFit
                height: Math.min(sourceSize.height, bottomPanelHeight, Math.floor(sourceSize.height * Math.min(sourceSize.width, parent.width * 0.3) / sourceSize.width))
            }

            Column {
                id: topColumn
                width: parent.width - img.width - parent.spacing - (flickable.hasVerticalScrollbar ? 13 : 0)

                clip: true

                spacing: 8

                Flow {
                    id: flow
                    spacing: 5
                    width: parent.width

                    BaseSelectableLabel {
                        text: downloadsItemTools.tplTitle
                        font.pixelSize: appWindow.smallWindow ? 15 : 18
                        width: parent.width
                    }

                    Repeater {
                        model: downloadsItemTools.allTags

                        delegate: TagLabel{
                            tag: modelData
                            downloadId: downloadsItemTools.itemId
                        }
                    }
                }

                StatusItem
                {
                    id: statusItem
                    width: parent.width
                    visible: !showingCompletedState
                }

                GridLayout
                {
                    columns: parent.width > 500 ? 4 : 2
                    rowSpacing: topColumn.spacing

                    readonly property int horizSpacing: 30

                    BaseLabel {
                        visible: downloadsItemTools.finished
                        font.pixelSize: appWindow.fonts.defaultSize
                        color: appWindow.theme.generalTabKey
                        text: qsTr("Status") + ":" + App.loc.emptyString
                        leftPadding: Math.abs(x - parent.x) < 5 ? 0 : parent.horizSpacing
                    }
                    BaseLabel {
                        visible: downloadsItemTools.finished
                        font.pixelSize: appWindow.fonts.defaultSize
                        color: appWindow.theme.generalTabValue
                        text: qsTr("completed") + App.loc.emptyString
                    }

                    BaseLabel {
                        visible: downloadsItemTools.state.length > 0
                        font.pixelSize: appWindow.fonts.defaultSize
                        color: appWindow.theme.generalTabKey
                        text: qsTr("State") + ":" + App.loc.emptyString
                        leftPadding: Math.abs(x - parent.x) < 5 ? 0 : parent.horizSpacing
                    }
                    BaseLabel {
                        visible: downloadsItemTools.state.length > 0
                        font.pixelSize: appWindow.fonts.defaultSize
                        color: appWindow.theme.generalTabValue
                        text: downloadsItemTools.state
                    }

                    BaseLabel {
                        id: speed
                        visible: downloadsItemTools.showDownloadSpeed || downloadsItemTools.showUploadSpeed
                        font.pixelSize: appWindow.fonts.defaultSize
                        color: appWindow.theme.generalTabKey
                        text: qsTr("Speed") + ":" + App.loc.emptyString
                        leftPadding: Math.abs(x - parent.x) < 5 ? 0 : parent.horizSpacing
                    }
                    DownloadSpeed {
                        visible: speed.visible
                        myDownloadsItemTools: downloadsItemTools
                    }

                    BaseLabel {
                        font.pixelSize: appWindow.fonts.defaultSize
                        color: appWindow.theme.generalTabKey
                        text: (downloadsItemTools.finished ? qsTr("Total size:") : qsTr("Downloaded:")) + App.loc.emptyString
                        leftPadding: Math.abs(x - parent.x) < 5 ? 0 : parent.horizSpacing
                    }
                    BaseLabel {
                        font.pixelSize: appWindow.fonts.defaultSize
                        color: appWindow.theme.generalTabValue
                        text: downloadsItemTools.finished || downloadsItemTools.unknownFileSize ? JsTools.sizeUtils.bytesAsText(downloadsItemTools.selectedBytesDownloaded) :
                                                                                                  qsTr("%1 of %2").arg(JsTools.sizeUtils.bytesAsText(downloadsItemTools.selectedBytesDownloaded)).arg(JsTools.sizeUtils.bytesAsText(downloadsItemTools.selectedSize)) + App.loc.emptyString
                    }

                    BaseLabel {
                        visible: downloadsItemTools.canUpload
                        font.pixelSize: appWindow.fonts.defaultSize
                        color: appWindow.theme.generalTabKey
                        text: qsTr("Uploaded") + ":" + App.loc.emptyString
                        leftPadding: Math.abs(x - parent.x) < 5 ? 0 : parent.horizSpacing
                    }
                    BaseLabel {
                        visible: downloadsItemTools.canUpload
                        font.pixelSize: appWindow.fonts.defaultSize
                        color: appWindow.theme.generalTabValue
                        text: App.bytesAsText(downloadsItemTools.bytesUploaded) +
                              " (" + qsTr("ratio") + ": " + downloadsItemTools.ratioText + ")" +
                              App.loc.emptyString
                    }

                    BaseLabel {
                        visible: downloadsItemTools.added
                        font.pixelSize: appWindow.fonts.defaultSize
                        color: appWindow.theme.generalTabKey
                        text: qsTr("Added at:") + App.loc.emptyString
                        leftPadding: Math.abs(x - parent.x) < 5 ? 0 : parent.horizSpacing
                    }
                    BaseLabel {
                        visible: downloadsItemTools.added
                        font.pixelSize: appWindow.fonts.defaultSize
                        color: appWindow.theme.generalTabValue
                        text: App.loc.dateOrTimeToString(downloadsItemTools.added, false) + App.loc.emptyString
                        MouseArea {
                            propagateComposedEvents: true
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked : function (mouse) {mouse.accepted = false;}
                            onPressed: function (mouse) {mouse.accepted = false;}
                            BaseToolTip {
                                text: App.loc.dateTimeToString(downloadsItemTools.added, true) + App.loc.emptyString
                                visible: parent.containsMouse
                            }
                        }
                    }
                }

                Row {
                    visible: downloadsItemTools.destinationPath
                    width: parent.width

                    Rectangle {
                        width: 18
                        height: 18
                        clip: true
                        color: "transparent"
                        Image {
                            source: appWindow.theme.elementsIcons
                            sourceSize.width: 93
                            sourceSize.height: 456
                            x: -1
                            y: -329
                        }
                        MouseArea {
                            anchors.fill: parent
                            enabled: App.features.hasFeature(AppFeatures.OpenFolder)
                            cursorShape: Qt.PointingHandCursor
                            onClicked: App.downloads.mgr.openDownloadFolder(downloadsItemTools.itemId, -1)
                        }
                    }

                    BaseSelectableLabel {
                        font.pixelSize: appWindow.fonts.defaultSize
                        color: appWindow.theme.generalTabValue
                        Layout.fillWidth: true
                        width: parent.width - 18
                        wrapMode: Text.WrapAnywhere
                        text: App.toNativeSeparators(downloadsItemTools.destinationPath)
                    }
                }

                LinkWithIcon {
                    id: webPageLinkWithIcon
                    visible: downloadsItemTools.needToShowWebPageUrl
                    width: parent.width
                    title: qsTr("Web page") + App.loc.emptyString
                    url: downloadsItemTools.webPageUrl
                    downloadModuleUid: downloadsItemTools.moduleUid
                }

                LinkWithIcon {
                    visible: downloadsItemTools.needToShowResourceUrl
                    width: parent.width
                    title: qsTr("File") + App.loc.emptyString
                    url: downloadsItemTools.resourceUrl
                    downloadModuleUid: downloadsItemTools.moduleUid
                }
            }
        }

        Rectangle {
            visible: flickable.height < topSpacingRect.height + myContent2.height
            height: topSpacingRect.height
            width: height
            color: "transparent"
        }
    }
}
