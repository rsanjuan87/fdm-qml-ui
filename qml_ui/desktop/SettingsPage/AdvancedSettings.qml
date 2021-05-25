import QtQuick 2.10
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import Qt.labs.settings 1.0
import org.freedownloadmanager.fdm 1.0
import org.freedownloadmanager.fdm.dmcoresettings 1.0
import org.freedownloadmanager.fdm.appsettings 1.0
import org.freedownloadmanager.fdm.appfeatures 1.0
import org.freedownloadmanager.fdm.abstractdownloadsui 1.0
import "../BaseElements"
import "../Dialogs"

Column
{
    spacing: 10
    width: parent.width

    SettingsGroupHeader {
        text: qsTr("Advanced") + App.loc.emptyString
    }

    SettingsGroupColumn {
        visible: App.features.hasFeature(AppFeatures.SystemNotifications)
        width: parent.width

        SettingsSubgroupHeader {
            text: qsTr("Notifications") + App.loc.emptyString
            visible: App.features.hasFeature(AppFeatures.SystemNotifications)
        }

        SettingsCheckBox {
            text: qsTr("Notify me of completed downloads via Notification Center") + App.loc.emptyString
            checked: App.settings.toBool(App.settings.app.value(AppSettings.NotifyOfFinishedDownloads))
            width: parent.width
            onClicked: {
                App.settings.app.setValue(
                            AppSettings.NotifyOfFinishedDownloads,
                            App.settings.fromBool(checked));
            }
        }

        SettingsCheckBox {
            text: qsTr("Notify me of failed downloads via Notification Center") + App.loc.emptyString
            checked: App.settings.toBool(App.settings.app.value(AppSettings.NotifyOfFailedDownloads))
            width: parent.width
            onClicked: {
                App.settings.app.setValue(
                            AppSettings.NotifyOfFailedDownloads,
                            App.settings.fromBool(checked));
            }
        }

        SettingsCheckBox {
            text: qsTr("Notify me of downloads only when %1 window is inactive").arg(App.shortDisplayName) + App.loc.emptyString
            checked: App.settings.toBool(App.settings.app.value(AppSettings.NotifyOfDownloadsWhenAppInactiveOnly))
            onClicked: {
                App.settings.app.setValue(
                            AppSettings.NotifyOfDownloadsWhenAppInactiveOnly,
                            App.settings.fromBool(checked));
            }
        }

        Rectangle {
            width: parent.width
            height: useSounds.height
            color: "transparent"

            SettingsCheckBox {
                id: useSounds
                text: qsTr("Use sounds") + App.loc.emptyString
                checked: App.settings.toBool(App.settings.app.value(AppSettings.EnableSoundNotifications))
                onClicked: {
                    App.settings.app.setValue(
                                AppSettings.EnableSoundNotifications,
                                App.settings.fromBool(checked));
                }
            }

            Rectangle {
                anchors.left: useSounds.right
                anchors.leftMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                width: 16
                height: width
                color: "transparent"

                Image {
                    source: Qt.resolvedUrl("../../images/desktop/edit_list.png")
                    sourceSize.width: 16
                    sourceSize.height: 16
                    opacity: useSounds.checked ? 1 : 0.5
                    layer {
                        effect: ColorOverlay {
                            color: appWindow.theme.foreground
                        }
                        enabled: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: { if (useSounds.checked) customizeSoundsDlg.open() }
                        onEntered: toolTipHosts.visible = true
                        onExited: toolTipHosts.visible = false

                        BaseToolTip {
                            id: toolTipHosts
                            text: qsTr("Customize sounds") + App.loc.emptyString
                        }
                    }
                }
            }
        }
    }

    SettingsGroupColumn {
        visible: App.features.hasFeature(AppFeatures.PreventOsAutoSleep)

        SettingsSubgroupHeader {
            text: qsTr("Power management") + App.loc.emptyString
            visible: App.features.hasFeature(AppFeatures.PreventOsAutoSleep)
        }

        SettingsCheckBox {
            text: qsTr("Don't put your computer to sleep if there is an active download") + App.loc.emptyString
            checked: App.settings.toBool(App.settings.dmcore.value(DmCoreSettings.PreventOsAutoSleepIfDownloadsRunning))
            onClicked: {
                App.settings.dmcore.setValue(
                            DmCoreSettings.PreventOsAutoSleepIfDownloadsRunning,
                            App.settings.fromBool(checked));
            }
        }

        SettingsCheckBox {
            text: qsTr("Enable sleep mode while running finished downloads") + App.loc.emptyString
            checked: App.settings.toBool(App.settings.dmcore.value(DmCoreSettings.PreventOsAutoSleepIfDownloadsRunning_IgnoreFinished))
            onClicked: {
                App.settings.dmcore.setValue(
                            DmCoreSettings.PreventOsAutoSleepIfDownloadsRunning_IgnoreFinished,
                            App.settings.fromBool(checked));
            }
        }
    }

    SettingsGroupColumn {

        SettingsSubgroupHeader{
            text: qsTr("Options") + App.loc.emptyString
        }

        SettingsCheckBox {
            text: qsTr("Launch at startup (minimized)") + App.loc.emptyString
            checked: App.autorunEnabled()
            onClicked: App.enableAutorun(checked)
            visible: App.features.hasFeature(AppFeatures.Autorun)
        }

        Loader {
            width: parent.width
            active: appWindow.btSupported
            source: "../../bt/desktop/IntegrationSettings.qml"
        }

        SettingsCheckBox {
            text: qsTr("Open/hide the bottom panel by clicking on the download") + App.loc.emptyString
            checked: uiSettingsTools.settings.toggleBottomPanelByClickingOnDownload
            onClicked: { uiSettingsTools.settings.toggleBottomPanelByClickingOnDownload = !uiSettingsTools.settings.toggleBottomPanelByClickingOnDownload }
        }

        Loader {
            width: parent.width
            active: appWindow.macVersion
            source: "DockUploadSpeedSetting.qml"
        }

        Rectangle {
            width: parent.width
            height: backupCheckbox.height
            color: "transparent"

            SettingsCheckBox {
                id: backupCheckbox
                text: qsTr("Backup the list of downloads every") + App.loc.emptyString
                checked: App.settings.dbBackupMinInterval() != -1
                onClicked: {
                    if (checked) {
                        App.settings.setDbBackupMinInterval(backupCombo.model[backupCombo.currentIndex].value);
                    } else {
                        App.settings.setDbBackupMinInterval(-1);
                    }
                }
            }

            BackupComboBox {
                id: backupCombo
                enabled: backupCheckbox.checked
                anchors.left: backupCheckbox.right
                anchors.leftMargin: 5
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        SettingsCheckBox {
            text: qsTr("Do not allow downloads to perform post finished tasks when running on battery") + App.loc.emptyString
            visible: App.features.hasFeature(AppFeatures.Battery)
            checked: App.settings.dmcore.value(DmCoreSettings.DisablePostFinishedTasksOnBattery)
            onClicked: { App.settings.dmcore.setValue(
                             DmCoreSettings.DisablePostFinishedTasksOnBattery,
                             App.settings.fromBool(checked));
            }
        }

        Rectangle {
            visible: App.features.hasFeature(AppFeatures.Battery)
            width: parent.width
            height: batteryCheckbox.height
            color: "transparent"

            SettingsCheckBox {
                id: batteryCheckbox
                text: qsTr("Do not allow downloads if battery level drops below") + App.loc.emptyString
                checked: App.settings.dmcore.value(DmCoreSettings.BatteryMinimumPowerLevelToRunDownloads) > 0
                onClicked: {
                    if (checked) {
                        batteryCombo.saveBatteryMinimumPowerLevelToRunDownloads(batteryCombo.currentText);
                    } else {
                        batteryCombo.saveBatteryMinimumPowerLevelToRunDownloads(0);
                    }
                }
            }

            BatteryComboBox {
                id: batteryCombo
                enabled: batteryCheckbox.checked
                anchors.left: batteryCheckbox.right
                anchors.leftMargin: 5
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    SettingsGroupColumn {

        SettingsSubgroupHeader{
            text: qsTr("Delete button action") + App.loc.emptyString
        }

        SettingsRadioButton {
            text: qsTr("Remove only from download list") + App.loc.emptyString
            checked: uiSettingsTools.settings.deleteButtonAction === 2
            onClicked: uiSettingsTools.settings.deleteButtonAction = 2
        }
        SettingsRadioButton {
            text: qsTr("Delete files") + App.loc.emptyString
            checked: uiSettingsTools.settings.deleteButtonAction === 1
            onClicked: uiSettingsTools.settings.deleteButtonAction = 1
        }
        SettingsRadioButton {
            text: qsTr("Always ask") + App.loc.emptyString
            checked: uiSettingsTools.settings.deleteButtonAction === 0
            onClicked: uiSettingsTools.settings.deleteButtonAction = 0
        }
    }

    SettingsGroupColumn {
        id: existingFileReactionGroup

        property int existingFileReaction: App.settings.dmcore.value(DmCoreSettings.ExistingFileReaction)

        SettingsSubgroupHeader{
            text: qsTr("File exists reaction") + App.loc.emptyString
        }

        SettingsRadioButton {
            text: qsTr("Rename") + App.loc.emptyString
            checked: existingFileReactionGroup.existingFileReaction == AbstractDownloadsUi.DefrRename
            onClicked: existingFileReactionGroup.setFileExistsReaction(AbstractDownloadsUi.DefrRename)
        }
        SettingsRadioButton {
            text: qsTr("Overwrite") + App.loc.emptyString
            checked: existingFileReactionGroup.existingFileReaction == AbstractDownloadsUi.DefrOverwrite
            onClicked: existingFileReactionGroup.setFileExistsReaction(AbstractDownloadsUi.DefrOverwrite)
        }
        SettingsRadioButton {
            text: qsTr("Always ask") + App.loc.emptyString
            checked: existingFileReactionGroup.existingFileReaction == AbstractDownloadsUi.DefrAsk
            onClicked: existingFileReactionGroup.setFileExistsReaction(AbstractDownloadsUi.DefrAsk)
        }

        function setFileExistsReaction(value) {
            App.settings.dmcore.setValue(DmCoreSettings.ExistingFileReaction, value);
        }
    }
}