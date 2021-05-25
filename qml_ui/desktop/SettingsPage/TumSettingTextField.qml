import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.4
import org.freedownloadmanager.fdm 1.0
import org.freedownloadmanager.fdm.dmcoresettings 1.0
import org.freedownloadmanager.fdm.appsettings 1.0
import org.freedownloadmanager.fdm.tum 1.0

SettingsTextField {
    property int mode: TrafficUsageMode.Low
    property int setting: DmCoreSettings.MaxDownloadSpeed

    implicitWidth: 123

    Material.accent: Material.Blue

    text: App.settings.tum.value(mode, setting)

    inputMethodHints: Qt.ImhDigitsOnly
    validator: RegExpValidator { regExp: /\d+/ }

    onTextChanged: {
        if (isValid())
            App.settings.tum.setValue(mode, setting, text);
    }

    function isValid()
    {
        return text !== "" &&
                /^\d+$/.test(text) &&
                parseInt(text) > 0;
    }
}