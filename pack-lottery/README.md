# Squadding Quads · The Pack Lottery

**What are you flying this pack?** Draw a freestyle challenge on your EdgeTX radio before take-off. After landing, log the win, give it another go or deal yourself a fresh card.

**[Download The Pack Lottery v1.4 (ZIP)](https://github.com/rcfamily772-commits/squadding-quads-overlays/raw/refs/heads/main/pack-lottery/SQ_Pack_Lottery_v1.4.zip)**

[Official v1.4 website](https://rcfamily772-commits.github.io/squadding-quads-overlays/pack-lottery/v1.4/)

[Original v1.0 ZIP](SQ_Pack_Lottery_v1.zip) · [Previous v1.1 ZIP](SQ_Pack_Lottery_v1.1.zip) · [Previous v1.2 ZIP](SQ_Pack_Lottery_v1.2.zip) · [v1.2 page](v1.2/)

## New in v1.4

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

**Field preview 1.4** targets colour-screen EdgeTX radios with a display of 320 × 240 or larger. The original shuffle, scoring, retries and touch/key paths have been exercised with simulated inputs. The redesigned radio interface and deal animation still need physical-radio testing.

Trying it on your radio? Tell Squadding Quads the radio model, EdgeTX version, whether you used touch or buttons, and which card you drew. A photo helps us fix any text that gets cut off.
