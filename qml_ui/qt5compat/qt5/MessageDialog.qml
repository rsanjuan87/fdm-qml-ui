import QtQuick 2.0
/*import QtQuick.Dialogs 1.3

MessageDialog
{
    readonly property int buttonOk: StandardButton.Ok
    readonly property int buttonCancel: StandardButton.Cancel
    property int buttons: buttonOk
    standardButtons: buttons
}*/

import Qt.labs.platform 1.1

MessageDialog
{
    readonly property int buttonOk: MessageDialog.Ok
    readonly property int buttonCancel: MessageDialog.Cancel
    buttons: buttonOk
}
