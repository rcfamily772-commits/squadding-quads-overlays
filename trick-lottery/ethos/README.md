# SQ Trick Lottery - ETHOS 1.0 preview

Fixed Wing edition for FrSky ETHOS colour radios. The deck is copied from EdgeTX v2.5 without changing card wording or order (20 field cards, five simulator-only cards). This is a native ETHOS Lua widget, not an EdgeTX script.

## Install
1. Download and extract SQ_Trick_Lottery_ETHOS_v1.0.zip.
2. Copy the SQTrick folder inside the archive's scripts folder into the radio's scripts folder (SD/eMMC; SCRIPTS:/SQTrick/main.lua). Do not copy it into an EdgeTX WIDGETS directory.
3. Restart ETHOS. Add a full-screen widget layout and choose SQ Trick Lottery.
4. On the ground, touch Draw, or focus the widget and use the encoder / Enter. The widget context menu also provides actions. Field is the default; tap Field to switch to Simulator and Sim to return to Field.

Draw/Deal shuffles eligible cards without repeats until the bag is exhausted. Retry keeps the current card; Landed records a self-reported completion once per draw. Focus remains on the selected button. Switching modes clears the current card and bag. Counters are session-only in this preview, not imported from EdgeTX. No telemetry or flight-control outputs are modified. No automatic flight detection. Use only before take-off and after landing; do not attempt simulator-only cards on a real aircraft.

Target: full-screen FrSky colour ETHOS radios, e.g. X18/X18RS and X20 families. Hardware and actual ETHOS simulator validation are pending. Small layouts show a prompt rather than clipped controls. API references: https://ethos-lua-doc.frsky-rc.com/api/system/registerWidget/ and https://ethos-lua-doc.frsky-rc.com/guides/events/.

## Version 1.0
Native widget; 25 fixed-wing cards; field/simulator filtering; touch, encoder and context-menu controls; session counters; responsive Black Label layout. No quad decks, persistent collection, browser sync or achievements in this initial ETHOS release.
