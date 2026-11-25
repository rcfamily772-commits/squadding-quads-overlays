# The Trick Lottery v2.5 — Fixed Wing Edition

125 cards, seven decks, six flying modes. 25 new fixed-wing cards (20 field, five simulator-only). Original 100 IDs unchanged. Radio v2.5 migrates 60/100-card saves to 125-card SQ25 format. Back up all SQLotto TXT files; older versions cannot read new SQ25 saves. Browser storage keys unchanged. On-radio tests pending.

## Fixed Wing deck
1. **Deck of Wings** — Fly one smooth rectangular circuit at steady height and speed.
2. **Mirror circuit** — Fly left- and right-hand circuits with ample clearance.
3. **Horizon keeper** — Hold a straight level leg for ten seconds in clear air.
4. **The big eight** — Fly a wide figure eight at a consistent crossing height.
5. **Three gentle banks** — Link three broad alternating turns at comfortable airspeed.
6. **Heading hold** — Maintain a steady heading for ten seconds in clear air.
7. **Parallel lines** — Fly two parallel legs with a wide turn between them.
8. **Smooth climb** — Climb gently, level out and hold heading with ample clearance.
9. **Descent discipline** — Make a gentle descent and level out well above ground.
10. **Speed step** — Change between two comfortable cruise speeds while holding height.
11. **Windward circuit** — In suitable wind, fly a wide circuit and note ground-track changes.
12. **Wind correction** — Hold a straight ground track in light crosswind at safe height.
13. **The long glide** — At generous altitude, practise a short reduced-power glide at safe airspeed.
14. **Smooth return** — Return from a normal circuit to a stable approach heading.
15. **Go-around** — Practise an early go-around from a stable approach with safe clearance.
16. **Landing zone** — Make a normal landing in a clear designated landing area.
17. **Two tidy landings** — Complete two controlled landings, stopping for checks between flights.
18. **Steady camera pass** — Fly a smooth filming pass in open air at safe height, away from people.
19. **Symmetric arcs** — Fly two broad turns of similar size, left then right.
20. **Energy review** — Review DVR or logs after a normal circuit for smooth speed changes.
21. **Ground rush 50** — SIM ONLY: Fly a low-level pass above 50 km/h in a simulator.
22. **Axial roll** — SIM ONLY: Complete an axial roll and return to level flight.
23. **Big sky loop** — SIM ONLY: Fly one smooth loop and return to the entry heading.
24. **Cuban practice** — SIM ONLY: Practise a half Cuban eight with virtual recovery height.
25. **Slow flight lab** — SIM ONLY: Explore slow flight and recover before losing control.

## Previous release notes
# The Trick Lottery v2.4 — Black Label

[Play / download / test](https://rcfamily772-commits.github.io/squadding-quads-overlays/trick-lottery/)

100 cards (original 60 plus 40), five modes, Golden Ticket cosmetic finish (0.2%), XP ranks, daily/weekly challenges, local battles, Academy, themes and browser creator exports. No paid draws. Back up existing data before upgrading. Browser storage keys stay unchanged. Radio retains SQLotto and original card IDs; new progress is in trick-a.txt and trick-b.txt, old album files are retained and read if no v2 file is valid. Radio and browser collections remain separate. Radio is a field preview and needs hardware verification. Web video requires MediaRecorder and canvas capture support. Tutorial links are searches, not verified individual tutorials. Academy illustrations are conceptual, not stick guides. Radio daily/weekly uses local date; browser UTC. Radio theme accents are selectable; web Carbon and Signature unlock at 10 and 30 completions. Radio battles are session-only. Use on the ground before take-off and after landing. Simulator first for advanced tricks.

## Install
Replace WIDGETS/SQLotto/main.lua, retain all collection TXT files and restart. Press and hold the widget, then choose Full screen. This method was confirmed by the V15 Ultra user. Standalone SQTrick is optional, not required. Colour screen 320×240+. Mode: 1 Real World, 2 Simulator, 3 TinyWhoop, 4 Freestyle, 5 Cinematic. Theme: 1 Black Label, 2 Bando, 3 Neon, 4 Retro, 5 Carbon, 6 Signature. Stats opens Passport, Vault and Achievements; Play opens daily, weekly and battle; Info opens Academy. Previous v1.8 ZIP remains available.

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

## v2.4 — Black Label launcher and sticky action focus
- Redesigned dashboard splash with the long-press instruction, rank, collection count, achievements and progress bar. EdgeTX controls entering interactive full screen; no auto-entry is attempted.
- Confirmed V15 Ultra launch procedure: press and hold the widget, then choose Full screen. No Tools installation needed.
- Keep the selected action by name for both rotary/ENTER and touch. Draw becomes Deal on the card screen; Deal, Retry, Deck, Mode, Theme and Next stay selected if available. Landed becomes Draw after completion; entering menus selects Back, and Back restores the original menu action. Avoid accidental Landed selection when a card is drawn.
- All 100 cards, six decks, five modes, themes and SQ20 save format retained. Browser game remains v2.0. Optional standalone tool uses the same focus logic. Hardware verification of v2.4 pending.


## ETHOS v1.0 preview (fixed wing)
Separate native widget, 25 fixed-wing cards. [ETHOS release and install](ethos/index.html) | [ETHOS ZIP](SQ_Trick_Lottery_ETHOS_v1.0.zip). EdgeTX v2.5 remains unchanged. Hardware validation pending.

## ETHOS v1.1 preview
[Fixed-wing web companion](ethos/app/index.html) | [ETHOS v1.1 ZIP](SQ_Trick_Lottery_ETHOS_v1.1.zip). Same 25 cards. Separate local browser records and backup; no radio sync. EdgeTX v2.5 unchanged.

## ETHOS v1.2 preview
[Web companion](ethos/app/index.html) | [ETHOS v1.2 ZIP](SQ_Trick_Lottery_ETHOS_v1.2.zip). 25 matching flight plates for both platforms of the ETHOS edition (web and radio). EdgeTX v2.5 untouched. Hardware validation pending.
