import QtQuick 2.0
import org.freedownloadmanager.fdm 1.0

Item {

    id: root
    property Component firstPageComponent
    property Component waitingPageComponent

    property var onAppReadyCallbacks: []

    function checkUiState() {
        if (App.ready) {
            stackView.clear();
            stackView.waPush(firstPageComponent);
            if (root.onAppReadyCallbacks.length) {
                root.onAppReadyCallbacks.map(function(callback){
                    callback();
                })
            }
            root.onAppReadyCallbacks = [];
        } else {
            stackView.waClear();
            stackView.waPush(waitingPageComponent);
        }
        appWindow.uiReadyStateChanged();
    }

    Component.onCompleted: {
        checkUiState();
    }

    Connections {
        target: App
        onReadyChanged: {
            checkUiState();
        }
    }

    function onReady(callback)
    {
        if (App.ready) {
            callback();
        } else {
            root.onAppReadyCallbacks.push(callback);
        }
    }

}
