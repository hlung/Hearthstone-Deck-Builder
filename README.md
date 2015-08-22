# Hearthstone-Deck-Builder

HSDeckBuilder is a [Hearthstone](http://www.playhearthstone.com/) deck list importer for Mac OS X 10.9+.
It can import deck from websites straight into the game.

If you have any suggestions or issues, please leave in issues section. :)

[_Download here_](https://github.com/hlung/Hearthstone-Deck-Builder/releases)

### Demo Video
[![Demo Video](/README/youtube-thumb.png)](http://www.youtube.com/watch?v=i_oS_82nofM)

<!-- ![Image](/README/ss1.png) -->

## Installation
- Go to the [releases page](https://github.com/hlung/Hearthstone-Deck-Builder/releases)
- Download _HSDeckBuilder.app.zip_, extract the archive
- Move _HSDeckBuilder.app_ to your _Applications_ directory
- Launch the app!

## How to use

### Import deck from web
- Copy the web page url
- Click "Import from Web"
- Paste the url, click import
- Currently supported websites:
    - http://www.hearthpwn.com/
    - http://www.icy-veins.com/

### Export deck to Hearthstone
- Make sure you have imported a deck first
- Open the game
- Go to "My Collection"
- Click "New Deck"
- Choose same Hero as the deck you want to export
- Come back to HSDeckBuilder
- Click "Export to Hearthstone" button
- Wait until done, don't move the mouse!
- TIP: While exporting, you can press ESC to cancel

## Possible Improvements
- If normal and golden cards existst, golden cards should be able to be selected
- List out cards that you don't have after export

## Special thanks
- [Epix37/Hearthstone-Deck-Tracker](https://github.com/Epix37/Hearthstone-Deck-Tracker) - for the inspiration. One of its functionality is the same as this app, but unfortunately, I use _Mac_, not _Windows_.
- [Jeswang/Hearthstone-Deck-Tracker-Mac](https://github.com/Jeswang/Hearthstone-Deck-Tracker-Mac) - for hearthpwn.com deck parsing code (and app icon :P).
- [Apple's Son of Grab sample project](https://developer.apple.com/library/mac/samplecode/SonOfGrab/Introduction/Intro.html) - for getting window frames of other running applications. And also how to use NSArrayController binding with NSTableView (can't believe how hard to find information for this trivial problem!).
