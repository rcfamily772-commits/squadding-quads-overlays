# SQ Wallpaper Shuffle

## Latest: v1.5 — Complete Gallery

# Wallpaper Shuffle v1.5 — Complete Gallery

The original 32 gallery images (31 wallpapers plus intro art) are packaged inside WIDGETS/SQWall/art, alongside the current Lua widget. Choose a single ZIP for your radio resolution, or download the all-radio archive and select one folder. No separate v1.1 artwork download is required once the v1.5 release assets are published.

The build verifies the original release SHA-256, requires all 32 matching artworks for each of five colour resolutions, checks ZIP integrity, and publishes only after all packages pass. Custom artwork in /IMAGES/SQWALL remains supported. Existing splash, theme and saved selection are not overwritten. Monochrome radios are not supported by the colour widget. Physical-radio testing pending.

[Complete downloads](https://github.com/rcfamily772-commits/squadding-quads-overlays/releases/tag/SQwall-v1.5) · [Website](v1.5/index.html)

## v1.4 — Unified Gallery

# SQ Wallpaper Shuffle v1.4 — Unified Gallery

Compact shared Toolbox styling, general multi-ZIP importer, downloadable radio-sized gallery kit, manifest fallback for the Lua catalogue. Original 32-image v1.1 release remains available separately. Recovered artwork supplements can be selected alongside it. No global theme or splash replacement. Colour widget only; physical testing pending.

[Open v1.4](https://rcfamily772-commits.github.io/squadding-quads-overlays/wallpaper-shuffle/v1.4/)

## Historical v1.3 — FPV Dads & Sons

[Upgrade page and local ZIP builder](https://rcfamily772-commits.github.io/squadding-quads-overlays/wallpaper-shuffle/v1.3/) · [v1.3 Lua](v1.3/main.lua). Use the supplied full-art ZIP or ready-made v1.3 upgrade package; artwork binaries are not hosted on GitHub. New gallery names: dads_sons.png and optional dads_sons_bw.png (320x240). Existing v1.1 assets retained. Monochrome boot art is separate. Hardware testing pending.

## v1.2 Gallery Black Label (Lua-only upgrade)

[Download upgrade ZIP](SQWall-v1.2-Upgrade.zip) · [v1.2 page](https://rcfamily772-commits.github.io/squadding-quads-overlays/wallpaper-shuffle/v1.2/). Requires the complete [v1.1 artwork kit](https://github.com/rcfamily772-commits/squadding-quads-overlays/releases/download/SQwall/SQWall-v1.1.zip). Install only WIDGETS/SQWall/main.lua; retain art, wallpaper files, splash and last.txt. Full-screen Prev, Lucky, Next, Clean; use Enter or touch to exit clean preview. Optional Motion and SFX; startup intro retained. Physical radio validation pending.

## v1.1

[Download v1.1 (38.9 MB ZIP)](https://github.com/rcfamily772-commits/squadding-quads-overlays/releases/download/SQwall/SQWall-v1.1.zip) · [Version 1.1 website](https://rcfamily772-commits.github.io/squadding-quads-overlays/wallpaper-shuffle/v1.1/) · [GitHub release](https://github.com/rcfamily772-commits/squadding-quads-overlays/releases/tag/SQwall) · [Release notes and installation](v1.1/RELEASE-NOTES.md) · [Radio sizes](v1.1/radio-sizes.txt)

The expanded pack includes 32 gallery images, 48 radio model listings, five colour artwork sizes, two monochrome artwork sizes and a custom splash screen. Monochrome artwork does not run the colour widget. The original v1.0 documentation follows.

Give a colour-screen EdgeTX home page its own rotating collection of FPV artwork. When the widget first loads after power-up, it picks a wallpaper. Open it full screen and tap **I'm Feeling Lucky**, or press **Enter**, for another. With two or more readable PNGs, the next pick differs from the current one.

[Download the original v1.0 SD-card kit](https://github.com/rcfamily772-commits/squadding-quads-overlays/raw/refs/heads/main/wallpaper-shuffle/SQ_Wallpaper_Shuffle_v1.zip) · [Launch page](https://rcfamily772-commits.github.io/squadding-quads-overlays/wallpaper-shuffle/) · [Try the actual Lua widget in the browser](https://rcfamily772-commits.github.io/squadding-quads-overlays/pack-lottery/test-bench/?wallpaper)

## Install

1. Unzip the kit. Copy **SQWall** into the existing **WIDGETS** folder on your SD card, and **SQWALL** into the existing **IMAGES** folder. Keep your other folders and files.
2. Check for `/WIDGETS/SQWall/main.lua` and `/IMAGES/SQWALL/workshop.png`. Restart the radio.
3. In **Screen Settings**, give a main view a single large widget zone, select **Setup widgets**, then choose **SQWall**. Use this view as your home page to see the art when you switch on.
4. Double-tap the artwork or select **Full screen** from the widget menu. Tap **I'm Feeling Lucky** or press **Enter**. Hold **Return** to go back to the clean artwork.

## Your collection

The four included PNGs are Midnight FPV Workshop, Manchester After Dark, Angry Karen and Drone Dealer. Add your own landscape PNGs directly to `/IMAGES/SQWALL/` and reload the widget or restart the radio to rescan. Use short, simple filenames and size images close to your display resolution to save radio memory. The starter images are 480 × 272. Art fills the widget area with a centred crop. Wallpapers appear inside the assigned widget page; menus and the radio's global theme retain their usual appearance.

## Startup and testing

The last choice is saved in `/WIDGETS/SQWall/last.txt`. Use a writable SD card and a correctly set radio clock. The widget estimates the power-on time from the real-time clock and radio uptime. On model reload it reuses the current session's selection. Changing the clock or an unusually rapid reboot can affect session detection. Two valid pictures are needed for a different pick.

Field preview 1.0. Lua behaviour tested with simulated display, SD-card and clock inputs. Physical-radio compatibility and bitmap memory limits still need a bench check. For feedback, include the radio, EdgeTX version, PNG size and what happened.
