import QtQuick 2.8
import QtMultimedia 5.9

FocusScope {
  id: root

  // Options
  property int numColumns: 4

  property alias gridWidth: grid.width
  property int gridItemSpacing: (numColumns == 4) ? vpx(7) : vpx(5) // it will double this
  property var collectionData
  property var gameData
  property int currentGameIdx

  signal launchRequested
  signal menuRequested
  signal detailsRequested
  //signal filtersRequested
  signal collectionNext
  signal collectionPrev
  signal gameChanged(int currentIdx)

  Keys.onPressed: {
      if (event.isAutoRepeat)
          return;

      if (api.keys.isDetails(event)) {
          event.accepted = true;
          toggleFav();
          return;
      }
      if (api.keys.isCancel(event)) {
          event.accepted = true;
          menuRequested();
          return;
        }
      if (api.keys.isFilters(event)) {
          event.accepted = true;
          toggleFilters()

          //filtersRequested();
          return;
      }
  }



  //property bool isFavorite: (gameData && gameData.favorite) || false
  function toggleFav() {
      if (gameData)
          gameData.favorite = !gameData.favorite;

      toggleSound.play()

  }

  function toggleFilters() {
    if (api.filters.favorite) {
      api.filters.playerCount = 1
      api.filters.favorite = false
      api.filters.current.enabled = false
    } else {
      api.filters.playerCount = 1
      api.filters.favorite = true
      api.filters.current.enabled = true
    }

    //api.filters.index = 0

  }



  GridView {
    id: grid

    focus: true

    anchors {
      top: parent.top; topMargin: - gridItemSpacing
      bottom: parent.bottom
    }

    anchors.horizontalCenter: parent.horizontalCenter

    cellWidth: grid.width/numColumns
    cellHeight: (numColumns == 4) ? vpx(157) : vpx(210)

    //highlightFollowsCurrentItem: false
    preferredHighlightBegin: vpx(0); preferredHighlightEnd: vpx(314)
    highlightRangeMode: GridView.StrictlyEnforceRange
    displayMarginBeginning: 300
    //snapMode: GridView.SnapOneItem

    model: collectionData ? collectionData.games : []
    currentIndex: currentGameIdx
    onCurrentIndexChanged: {
      //if (api.currentCollection) api.currentCollection.games.index = currentIndex;
      navSound.play()
      gameChanged(currentIndex)

    }

    Keys.onPressed: {
        if (api.keys.isAccept(event) && !event.isAutoRepeat) {
            event.accepted = true;
            root.detailsRequested()
        }
        if (api.keys.isPageUp(event) || api.keys.isPageDown(event)) {
            event.accepted = true;
            var rows_to_skip = Math.max(1, Math.round(grid.height / cellHeight));
            var games_to_skip = rows_to_skip * numColumns;
            if (api.keys.isPageUp(event.key))
                currentIndex = Math.max(currentIndex - games_to_skip, 0);
            else
                currentIndex = Math.min(currentIndex + games_to_skip, model.length - 1);
        }
        if (api.keys.isPrevPage(event))
        {
          collectionPrev()
        }
        if (api.keys.isNextPage(event))
        {
          collectionNext()
        }
        if (event.modifiers === Qt.AltModifier && event.text) {
            event.accepted = true;
            api.currentCollection.games.jumpToLetter(event.text);
        }
    }



    delegate: GameGridItem {
      width: GridView.view.cellWidth
      height: GridView.view.cellHeight
      selected: GridView.isCurrentItem
      //collection: api.currentCollection

      game: modelData
      collection: collectionData
      z: (selected) ? 100 : 1

      onDetails: detailsRequested();
      onClicked: GridView.view.currentIndex = index

    }

    // Removal animation
    remove: Transition {
      NumberAnimation { property: "opacity"; to: 0; duration: 100 }
    }
  }
}
