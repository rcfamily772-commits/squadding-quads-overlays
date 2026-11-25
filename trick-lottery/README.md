# The Trick Lottery v2.1 — Black Label

[Play / download / test](https://rcfamily772-commits.github.io/squadding-quads-overlays/trick-lottery/)

100 cards (original 60 plus 40), five modes, Golden Ticket cosmetic finish (0.2%), XP ranks, daily/weekly challenges, local battles, Academy, themes and browser creator exports. No paid draws. Back up existing data before upgrading. Browser storage keys stay unchanged. Radio retains SQLotto and original card IDs; new progress is in trick-a.txt and trick-b.txt, old album files are retained and read if no v2 file is valid. Radio and browser collections remain separate. Radio is a field preview and needs hardware verification. Web video requires MediaRecorder and canvas capture support. Tutorial links are searches, not verified individual tutorials. Academy illustrations are conceptual, not stick guides. Radio daily/weekly uses local date; browser UTC. Radio theme accents are selectable; web Carbon and Signature unlock at 10 and 30 completions. Radio battles are session-only. Use on the ground before take-off and after landing. Simulator first for advanced tricks.

## Install
Copy WIDGETS/SQLotto/main.lua to the existing SD card widget folder and restart. Colour screen 320×240+. Mode: 1 Real World, 2 Simulator, 3 TinyWhoop, 4 Freestyle, 5 Cinematic. Theme: 1 Black Label, 2 Bando, 3 Neon, 4 Retro, 5 Carbon, 6 Signature. Stats opens Passport, Vault and Achievements; Play opens daily, weekly and battle; Info opens Academy. Previous v1.8 ZIP remains available.

## v2.1 — radio compatibility hotfix
- Fix the refresh crash at main.lua:208 by calling the string library directly rather than indexing string values; also fix collection drawing, checksums, album decoding and achievement labels.
- Reset all six deck bags when flying mode changes, and clear stale animation/message state.
- Keep the existing SQLotto folder, original card IDs and SQ20 save format. Keep all album-*.txt and trick-*.txt files. Only replace main.lua; delete main.luac if present and restart.
- Browser game remains v2.0; this is a radio-widget maintenance release. Physical-radio confirmation pending.
