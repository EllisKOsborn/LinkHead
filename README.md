# LinkHead

A tiny World of Warcraft addon: bind a hotkey, and pressing it looks up
whatever you're hovering on [Wowhead](https://www.wowhead.com/) and gives
you the link.

Works for:
- NPCs / creatures (mouseover, or the NPC behind an open gossip/quest/vendor frame)
- Interactable objects (mouseover)
- Items (hover the tooltip, in bags, loot, trade, etc.)
- Quests (while a quest frame is open, or one is selected in your quest log)
- Your current target, as a fallback

WoW's addon sandbox can't open your web browser directly, so pressing the
hotkey pops up a small window with the Wowhead URL, pre-selected (and copied
to your clipboard where the client supports it) so you can paste it into
your browser.

## Install

1. Download this repo and drop the `LinkHead` folder into your
   `World of Warcraft/_retail_/Interface/AddOns/` directory.
2. Launch WoW, open **Game Menu > Options > Keybindings**, find the
   **LinkHead** section, and bind a key to **Look up on Wowhead**.
3. Hover something and press your key.

## Notes

The `.toc` targets a recent retail interface version. If the client refuses
to load it after a patch, bump the `## Interface:` line in `LinkHead.toc` or
enable "Load out of date AddOns" in the AddOns list.

## License

MIT, see [LICENSE](LICENSE).
