import QtQuick 2.0
import org.freedownloadmanager.fdm 1.0
import org.freedownloadmanager.fdm.abstractdownloadsui 1.0

Item {

    id: root

    property var downloadIds
    property bool schedulerCheckboxEnabled: false
    property int daysEnabled: 0
    property int startTime: 0
    property int endTime: 0

    property bool tuneAndDownloadDialog: false

    signal settingsSaved()
    signal buildingFinished()

    property bool statusWarning: false
    property string lastError: qsTr("Set days of the week to enable Scheduler") + App.loc.emptyString

    function buildScheduler(ids)
    {
        reset();
        downloadIds = ids;

        //existing schedules
        if (downloadIds && App.downloads.scheduler.isScheduled(downloadIds[0])) {
            schedulerCheckboxEnabled = true;
            daysEnabled = App.downloads.scheduler.days(downloadIds[0]);
            startTime = App.downloads.scheduler.fromTime(downloadIds[0]);
            endTime = App.downloads.scheduler.toTime(downloadIds[0]);
            updateState();
        }

        buildingFinished();
    }

    function reset()
    {
        downloadIds = [];
        schedulerCheckboxEnabled = tuneAndDownloadDialog ? false : true;
        daysEnabled = uiSettingsTools.settings.schedulerDaysEnabled;
        startTime = uiSettingsTools.settings.schedulerStartTime;
        endTime = uiSettingsTools.settings.schedulerEndTime;
        statusWarning = false;
        updateState();
    }

    function doOK()
    {
        if (!downloadIds)
            return false;
        if (schedulerCheckboxEnabled) {
            setSchedule();
        } else {
            removeSchedule();
        }
        settingsSaved();
    }

    function setSchedule() {
        if (daysEnabled) {
            for (var i = 0; i < downloadIds.length; i++) {
                App.downloads.scheduler.setSchedule(downloadIds[i], daysEnabled, startTime, endTime);
            }
            uiSettingsTools.settings.schedulerDaysEnabled = daysEnabled;
            uiSettingsTools.settings.schedulerStartTime = startTime;
            uiSettingsTools.settings.schedulerEndTime = endTime;
        }
        else {
            removeSchedule();
        }
    }

    function removeSchedule() {
        for (var i = 0; i < downloadIds.length; i++) {
            if (App.downloads.scheduler.isScheduled(downloadIds[i])) {
                App.downloads.scheduler.removeSchedule(downloadIds[i]);
            }
        }
        settingsSaved();
    }

    function updateState()
    {
        statusWarning = failed() && schedulerCheckboxEnabled;
    }

    function failed()
    {
        return daysEnabled == 0;
    }

    function onDaysEnabledChanged(checked, i)
    {
        if (checked) {
            daysEnabled = daysEnabled | (1<<i);
        } else {
            daysEnabled = daysEnabled & ~(1<<i)
        }
        updateState();
    }

    function onSchedulerCheckboxChanged(checked)
    {
        schedulerCheckboxEnabled = checked;
        updateState();
    }
}
