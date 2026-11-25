# The Trick Lottery v2.0

[Current release](../trick-lottery/) · [Radio v1.8 archive](v1.8/)

# Squadding Quads · The Pack Lottery

## Radio v1.8 — Black Label

[Download EdgeTX v1.8](SQ_Pack_Lottery_v1.8.zip) · [Radio release page](https://rcfamily772-commits.github.io/squadding-quads-overlays/pack-lottery/v1.8/). Browser stays on v1.7. Stats opens Passport, Vault and Achievements (Next cycles pages). Optional Motion, SFX and Haptic settings; sound and haptic off by default. Progress begins on radio with v1.8 and is separate from the browser. Two validated local files album-a.txt / album-b.txt in WIDGETS/SQLotto retain best rarity and counts; back up both to transfer. No model/flight-control access. Physical radio validation pending.

## Browser v1.7 and previous radio versions

**What are you flying this pack?** Draw a freestyle challenge on your EdgeTX radio before take-off. After landing, log the win, give it another go or deal yourself a fresh card.

**[Download The Pack Lottery v1.7 (ZIP)](https://github.com/rcfamily772-commits/squadding-quads-overlays/raw/refs/heads/main/pack-lottery/SQ_Pack_Lottery_v1.7.zip)**

[Official v1.7 website](https://rcfamily772-commits.github.io/squadding-quads-overlays/pack-lottery/v1.7/)

[Original v1.0 ZIP](SQ_Pack_Lottery_v1.zip) · [Previous v1.1 ZIP](SQ_Pack_Lottery_v1.1.zip) · [Previous v1.2 ZIP](SQ_Pack_Lottery_v1.2.zip) · [v1.2 page](v1.2/)

## New in v1.7 — Black Label Edition

- Black-and-gold card room, deck-box opening sequence, serial-numbered cards, reduced-motion support.
- Nine achievements and personalised Pilot Passport based on the existing collection. Export cards or passport as PNG images.
- Installable browser app with scoped service worker and offline app shell after the first successful online load. Use Install / offline or the browser menu; support varies by browser.
- Export a local JSON collection backup and restore on another device. Restore replaces the current collection and call sign after confirmation; does not include session tally or sound settings. No cloud storage or account.
- EdgeTX: black-and-gold palette, all 60 cards and existing lightweight rarity and sound functionality; browser-only passport, achievements, image export and album.

[Previous v1.6 ZIP](SQ_Pack_Lottery_v1.6.zip) · [v1.6 website](v1.6/)

## Retained from v1.6 — Collector’s Edition

- Six bespoke SVG deck crests, distinct card backs and four cosmetic foil finishes: Standard 70%, Rare 20%, Legendary 9%, Mythical 1%. Random rarity is independent of the challenge; there are no paid draws.
- Shimmer, sparks, subtle pointer tilt and deck recoil, with reduced-motion support; original rarity chimes and optional supported-device vibration.
- Browser-only album: 60 discoverable cards, best rarity, rarity counts, drawn/completed counts and favourites. Stored locally, starts with v1.6 and remains across session reset. No account or cloud sync. Adult text hidden until explicitly revealed.
- Lightweight EdgeTX rarity labels and colours with optional tones; no album or haptics on the radio. Physical compatibility remains untested.

[Previous v1.5 ZIP](SQ_Pack_Lottery_v1.5.zip) · [v1.5 website](v1.5/)

## Retained from v1.5

- Original procedural audio: papery shuffle, card slide and tap, retry cue, deck switch and victory chime. No third-party recordings or audio downloads.
- Sounds start only after interaction; the browser mute setting persists locally. Unsupported audio falls back to silent play.
- Optional normal-priority EdgeTX tones using radio beep volume. Enable SFX in widget settings; defaults off. No additional files or global audio settings to change.
- Radio sound is a simpler tone version, not the browser foley. The test bench remains visual-only for radio audio.

[Previous v1.4 ZIP](SQ_Pack_Lottery_v1.4.zip) · [v1.4 website](v1.4/)

## Retained from v1.4

- Premium playing-card layout, stacked card backs and six deck accents.
- Animated deal, redraw, retry and completion in the browser; reduced-motion preference respected.
- Lightweight 240 ms non-blocking card-back slide on EdgeTX; the exact frame rate depends on the radio.
- Existing session scoring, adult warning and all 60 cards retained.

[Previous v1.3 ZIP](SQ_Pack_Lottery_v1.3.zip) · [v1.3 website](v1.3/)

## Inside the deck

| Level | Cards | Example challenge |
| --- | --- | --- |
| Beginner | 8 | **Park it** · Pick a landing patch before take-off. Touch down inside it three times this pack. |
| Intermediate | 8 | **Mirror rolls** · Roll left, then right at recovery height. Finish each roll on your original heading. |
| Advanced | 8 | **BoyWonder mirror** · Build a three-trick line and reverse every roll direction on the second run. |
| OnlyDrones | 1 challenge / 12 messages | **Just Fly** · No tricks, no pressure. Go fly when conditions are safe. |
| Bench Pilot | 1 challenge / 12 messages | **Touch Grass & Fly** · Finish your checks, unplug the USB cable and leave the shed. |
| Adults Only (18+) | 1 challenge / 12 messages | **After Dark** · Explicit language, opt-in comedy deck. |

Each skill deck deals all eight cards before it shuffles again. OnlyDrones cycles through twelve humorous messages without repeats within a shuffle; every message is the same Just Fly challenge. Bench Pilot independently shuffles twelve sarcastic reminders around the single Touch Grass & Fly challenge. Adults Only independently shuffles twelve uncensored messages, all for one flying challenge. On the radio, selecting this level shows a warning; Draw reveals the message. The browser asks for confirmation before entry. Never skip required safety checks or fly in unsafe conditions. Switching levels remembers which cards you’ve drawn in each deck for the current session.

## Get it on your radio

1. Unzip the download. Copy the **SQLotto** folder from inside **WIDGETS** to the existing **WIDGETS** folder on your radio’s SD card. The file should end up at `/WIDGETS/SQLotto/main.lua`.
2. Restart the radio. Open **Screen Settings → Setup widgets**, select a zone and choose **SQLotto**.
3. Double-tap the widget to open it full screen, or select it, press **Enter** and choose **Full screen**.
4. Before putting on your goggles, choose **Level**, then **Draw**. Tap a button or highlight it with the wheel/navigation keys and press **Enter**.

## After the pack

- **Landed it** adds one to your completion tally.
- **Try again** keeps the card and increments your attempt count.
- **Redraw** skips to the next challenge.
- **Level** leaves the current card and cycles to the next difficulty.

Hold **Return** to leave full screen. The home-screen tile shows your current card. Restarting the radio or reloading the widget starts a fresh session.

## Compatibility and feedback

**Field preview 1.7** targets colour-screen EdgeTX radios with a display of 320 × 240 or larger. The original shuffle, scoring, retries and touch/key paths have been exercised with simulated inputs. The redesigned radio interface, animation and optional sound still need physical-radio testing.

Trying it on your radio? Tell Squadding Quads the radio model, EdgeTX version, whether you used touch or buttons, and which card you drew. A photo helps us fix any text that gets cut off.
