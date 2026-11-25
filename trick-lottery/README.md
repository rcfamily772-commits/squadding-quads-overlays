# The Trick Lottery v2.3 — Black Label

[Play / download / test](https://rcfamily772-commits.github.io/squadding-quads-overlays/trick-lottery/)

100 cards (original 60 plus 40), five modes, Golden Ticket cosmetic finish (0.2%), XP ranks, daily/weekly challenges, local battles, Academy, themes and browser creator exports. No paid draws. Back up existing data before upgrading. Browser storage keys stay unchanged. Radio retains SQLotto and original card IDs; new progress is in trick-a.txt and trick-b.txt, old album files are retained and read if no v2 file is valid. Radio and browser collections remain separate. Radio is a field preview and needs hardware verification. Web video requires MediaRecorder and canvas capture support. Tutorial links are searches, not verified individual tutorials. Academy illustrations are conceptual, not stick guides. Radio daily/weekly uses local date; browser UTC. Radio theme accents are selectable; web Carbon and Signature unlock at 10 and 30 completions. Radio battles are session-only. Use on the ground before take-off and after landing. Simulator first for advanced tricks.

## Install
Merge BOTH WIDGETS and SCRIPTS folders from the ZIP into the SD card root; do not replace/delete existing folders or collection files. Restart. Recommended: SYS > TOOLS > SQTrick (or SQ Trick Lottery). Colour screen 320×240+. Mode: 1 Real World, 2 Simulator, 3 TinyWhoop, 4 Freestyle, 5 Cinematic. Theme: 1 Black Label, 2 Bando, 3 Neon, 4 Retro, 5 Carbon, 6 Signature. Stats opens Passport, Vault and Achievements; Play opens daily, weekly and battle; Info opens Academy. Previous v1.8 ZIP remains available.

## v2.1 — radio compatibility hotfix
- Fix the refresh crash at main.lua:208 by calling the string library directly rather than indexing string values; also fix collection drawing, checksums, album decoding and achievement labels.
- Reset all six deck bags when flying mode changes, and clear stale animation/message state.
- Keep the existing SQLotto folder, original card IDs and SQ20 save format. Keep all album-*.txt and trick-*.txt files. Only replace main.lua; delete main.luac if present and restart.
- Browser game remains v2.0; this is a radio-widget maintenance release. Physical-radio confirmation pending.

## v2.2 — dashboard launcher and interaction hotfix
- The standard EdgeTX dashboard does not send key/touch events to classic widgets. Select SQLotto, press ENTER, choose Full screen. Double-tap only where supported by firmware. In full screen, tap Draw or press ENTER; Deck cycles the six packs, Deal draws another card. Long-press RTN to leave.
- Replace the empty dashboard with a responsive card preview, deck, collection status and launch instructions; small zones show a compact prompt. Preview is read-only, not a draw button. No cards are drawn or saved until you explicitly act in full screen.
- Guard full-screen input coordinates and selection focus; clarify empty deck/status text. All v2.1 Lua compatibility fixes and saved collection data remain. Browser game remains v2.0.
- Physical V15 confirmation still required; see tests/smoke.lua for a desktop Lua mock test. Test on the ground, with aircraft disarmed.

## v2.3 — independent Tools launch
- App Mode can cover the whole screen while the firmware still sends nil to widget refresh; no Lua widget input can be synthesized safely in that view. The widget now labels that state VIEW and advertises SYS > TOOLS. Long-press the widget and choose Full screen for classic interaction; LIVE identifies real input mode.
- Added self-contained SCRIPTS/TOOLS/SQTrick.lua, built from the same 100-card engine. It implements the EdgeTX one-time script init/run interface, normalizes nil idle frames, ignores the launch event, and returns 1 on exit. TOOL identifies its active screen. Tap Draw, Deck, Stats, Play, Mode or Theme, or navigate using the encoder and ENTER. All six decks and saved collection files are shared with the widget. Tool settings start at defaults each launch; Mode and Theme can be changed within the session. On-radio verification pending.
- One-time scripts suspend other Lua scripts while active. Use only on the ground with the aircraft disarmed; exit before flying. Copy both folders, preserve TXT files, and remove stale SQLotto/main.luac or SQTrick.luac if present. Browser game remains v2.0.
