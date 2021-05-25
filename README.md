# fdm-qml-ui
Create your own custom user interfaces for Free Download Manager 6, or make improvements for existing ones and share your work with all FDM6 users.

FDM6 supports loading of custom interfaces by the use of the special command line argument.

1. Clone this repository.

2. Make your changes.

3. Test your changes by launching FDM6 with the following parameters:

    fdm --qurl file:///PATH_TO_MAIN_QML_INSIDE_OF_LOCAL_REPOSITORY

    E.g. under Windows OS this can be something like:
    fdm.exe --qurl file:///C:/fdm-qml-ui/qml_ui/desktop/main.qml

4. Share your changes with all FDM6 users using our forum or by creating pull requests to our main repository. 


We'll publish some documentation regarding FDM API the UI code is using in case there will be enough interest from our users.

We use [QML](https://doc.qt.io/qt-5/qtqml-index.html). Not familiar with QML? Please read this [nice book](https://qmlbook.github.io/).

If there are any issues, please [visit our forum's topic](https://www.freedownloadmanager.org/board/viewtopic.php?f=1&t=18517).