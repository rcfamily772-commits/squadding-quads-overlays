# SQ Wallpaper Shuffle v1.1

[Download the complete v1.1 ZIP](https://github.com/rcfamily772-commits/squadding-quads-overlays/releases/download/SQwall/SQWall-v1.1.zip) · [GitHub release](https://github.com/rcfamily772-commits/squadding-quads-overlays/releases/tag/SQwall)

Expanded Squadding Quads wallpaper pack for colour EdgeTX radios.

## What's new
- 32 gallery images (31 wallpapers and the tinywhoop splash), provided in five colour resolutions.
- Radio size lookup and monochrome BMP artwork in 128×64 and 212×64; the Lua widget itself is colour-only.
- Custom native boot splash (`IMAGES/splash.png`) and optional widget intro.
- Startup wallpaper selection, saved last choice and manual “I'm Feeling Lucky” shuffle.
- Custom PNGs can be added to `/IMAGES/SQWALL/`.

## Install / upgrade
1. Extract the release ZIP. Check `Radio sizes.txt` and choose ONE matching folder under `Colour/`.
2. Back up your card and any existing `IMAGES/splash.png`. Copy the chosen `WIDGETS` folder to the storage root; copy `IMAGES` too if you want the custom boot splash.
3. Replace the old `main.lua`; delete an old compiled `main.luac` if present. Keep `last.txt`. Eject safely and restart.
4. On a colour main view, open Setup widgets and assign SQWall to a zone. Use a large zone for the best appearance. Set the radio clock and ensure storage is writable.
5. Open the widget full screen and tap I'm Feeling Lucky or press Enter to reshuffle. Disable Intro in widget settings if desired.

Monochrome radios receive artwork only. Splash installation depends on firmware and target. Check the supplied lookup against your exact radio and firmware; hardware compatibility has not been tested across all listed radios.

The release ZIP is an exact copy of the supplied archive. Five numbered V12 concept previews are also included separately for reference.

[Version 1.1 website](https://rcfamily772-commits.github.io/squadding-quads-overlays/wallpaper-shuffle/v1.1/)
