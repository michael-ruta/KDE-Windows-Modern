/* SPDX-License-Identifier: GPL-3.0-or-later
 * Windows 11-style pinned grid, retaining KDE's favorites and launch model.
 * Derived from Jeysef's Windows Modern pinned page.
 */
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import "../components"
import "../code/tools.js" as Tools

ColumnLayout {
    id: pinnedPage
    spacing: 18
    property alias favoritesList: favoritesListView
    signal showAllAppsRequested
    signal keyNavUpFromList
    function tryActivate(row) { favoritesListView.currentIndex = Math.min(row, favoritesListView.count-1); favoritesListView.forceActiveFocus(); }
    function navigateUp() { favoritesListView.currentIndex = Math.max(0, favoritesListView.currentIndex - 6); }
    function navigateDown() { favoritesListView.currentIndex = Math.min(favoritesListView.count-1, favoritesListView.currentIndex < 0 ? 0 : favoritesListView.currentIndex + 6); }
    function activateCurrent() { if(favoritesListView.currentIndex >= 0) { favoritesListView.model.trigger(favoritesListView.currentIndex,"",null); root.closeMenu(); } }
    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 16
        Layout.rightMargin: 16
        PlasmaComponents3.Label { text: i18n("Pinned"); font.weight: Font.DemiBold }
        Item { Layout.fillWidth: true }
        AToolButton { text: i18n("All apps"); iconName: "go-next"; buttonHeight: 28; flat: true; onClicked: pinnedPage.showAllAppsRequested() }
    }
    GridView {
        id: favoritesListView
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        cellWidth: width / 6
        cellHeight: 92
        currentIndex: -1
        keyNavigationEnabled: true
        boundsBehavior: Flickable.StopAtBounds
        PlasmaComponents3.ScrollBar.vertical: PlasmaComponents3.ScrollBar {}
        delegate: Item {
            id: tile
            required property int index
            required property var model
            width: favoritesListView.cellWidth
            height: favoritesListView.cellHeight
            Accessible.role: Accessible.Button
            Accessible.name: model.display || ""
            Accessible.onPressAction: launch()
            function launch() { favoritesListView.model.trigger(index,"",null); root.closeMenu(); }
            Rectangle {
                anchors.fill: parent
                anchors.margins: 3
                radius: 5
                color: Kirigami.Theme.hoverColor
                opacity: mouse.containsMouse ? 0.35 : tile.GridView.isCurrentItem ? 0.2 : 0
            }
            Column {
                anchors.top: parent.top
                anchors.topMargin: 10
                width: parent.width
                spacing: 7
                Kirigami.Icon { anchors.horizontalCenter: parent.horizontalCenter; width: 32; height: 32; source: tile.model.decoration }
                PlasmaComponents3.Label {
                    width: parent.width - 8
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: tile.model.display || ""
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize
                }
            }
            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: event => {
                    favoritesListView.currentIndex = tile.index;
                    if(event.button === Qt.RightButton) {
                        var actions = Tools.buildAppActions(i18n, globalFavorites, tile.model.favoriteId, tile.model.url, tile.model.actionList);
                        var pos = tile.mapToItem(sharedContextMenu,event.x,event.y);
                        sharedContextMenu.open(actions,pos.x,pos.y,{model:favoritesListView.model,index:tile.index});
                    } else tile.launch();
                }
            }
        }
        Keys.onReturnPressed: pinnedPage.activateCurrent()
        Keys.onEnterPressed: pinnedPage.activateCurrent()
        Keys.onUpPressed: event => { if(currentIndex<6){pinnedPage.keyNavUpFromList();event.accepted=true;}else{currentIndex-=6;event.accepted=true;} }
    }
}
