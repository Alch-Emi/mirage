import QtQuick 2.12
import "../utils.js" as Utils

FocusScope {
    onFocusChanged: if (! focus) clearSelection()


    signal deselectAll()


    property bool reversed: false

    readonly property bool dragging: pointHandler.active || dragHandler.active
    // onDraggingChanged: print(dragging)
    property bool selecting: false
    property int selectionStart: -1
    property int selectionEnd: -1
    property point selectionStartPosition: Qt.point(-1, -1)
    property point selectionEndPosition: Qt.point(-1, -1)
    property var selectedTexts: ({})

    readonly property var selectionInfo: [
        selectionStart, selectionStartPosition,
        selectionEnd, selectionEndPosition,
    ]

    readonly property string joinedSelection: {
        let toCopy = []

        for (let key of Object.keys(selectedTexts).sort()) {
            if (selectedTexts[key]) toCopy.push(selectedTexts[key])
        }

        if (reversed) toCopy.reverse()

        return toCopy.join("\n\n")
    }

    readonly property alias dragPoint: dragHandler.centroid
    readonly property alias dragPosition: dragHandler.centroid.position
    readonly property alias contextMenu: contextMenu


    function clearSelection() {
        selecting              = false
        selectionStart         = -1
        selectionEnd           = -1
        selectionStartPosition = Qt.point(-1, -1)
        selectionEndPosition   = Qt.point(-1, -1)
        deselectAll()
    }


    Item { id: dragPoint }

    DragHandler {
        id: dragHandler
        target: dragPoint
        onActiveChanged: {
            if (active) {
                target.Drag.active = true
            } else {
                target.Drag.drop()
                target.Drag.active = false
                selecting          = false
            }
        }
    }

    PointHandler {
        id: pointHandler
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: clearSelection()
        onLongPressed: contextMenu.popup()
    }

    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: contextMenu.popup()
        onLongPressed: contextMenu.popup()
    }

    HMenu {
        id: contextMenu

        HMenuItem {
            icon.name: "copy"
            text: qsTr("Copy")
            enabled: Boolean(joinedSelection)
            onTriggered: Utils.copyToClipboard(joinedSelection)
        }
    }
}
