import Quickshell
import QtQuick
import Quickshell.Wayland


PanelWindow {
    visible: true
    implicitWidth: 200
    implicitHeight: 100
    color: '#000000'

    Text {
        anchors.centerIn: parent
        text: "Hello Quicksell"
        color: "#ffffff"
        font.pixelSize: 18
      }
}
