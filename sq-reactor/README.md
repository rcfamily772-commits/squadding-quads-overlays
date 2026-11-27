# Squadding Quads FPV Dashboard v1.8.9

[Dashboard](./) · [Download v1.8.9](Squadding-Quads-FPV-Dashboard-v1.8.9.zip) · [Grand Prix ’92](grand-prix-92/) · [Boy Wonder](boy-wonder/)

**Grand Prix ’92 is Theme 10** in the shared dashboard. Its royal-blue, yellow and white cockpit takes inspiration from the 1992 Williams FW14B. The instrument cluster pairs amber speed digits with a calibrated 0–200 km/h arc and a red peak marker. The timer and GPS trace sit beside the dial. Essentials, Battery, Logbook and the four-stat disarm summary share the pit-wall layout. Theme 10 uses the radio’s drawing primitives and requires no artwork on the SD card.

Boy Wonder is Theme 9. Tailor, Nocturne, APEX and the five classic themes are included in the same download.

Version 1.8.9 fixes the startup error reported on the HelloRadioSky V15 at `main.lua:55`. The widget now uses the EdgeTX string functions directly when opening a model, drawing the instruments and reading saved flights. If you already installed v1.8.8, overwrite `WIDGETS/SQDash/main.lua` with the copy in the new ZIP and restart the radio. If the same error persists, rename `WIDGETS/SQDash/main.luac` to `main.luac.bak` if present and restart. EdgeTX can then compile the updated source. Your widget settings and existing flight journals use the same names.

## Install or upgrade

1. Extract the ZIP. Copy its **WIDGETS** folder to the root of your radio SD card, merging the folder and replacing `WIDGETS/SQDash/main.lua` and adding `WIDGETS/SQDash/pilot.png`. The two files belong in the same folder.
2. Restart EdgeTX. Open SQDash settings on your existing widget, or add SQDash to a large colour widget zone.
3. Select **Theme 10** for Grand Prix ’92 or **Theme 9** for Boy Wonder. Theme 8 selects Tailor. Theme 7 selects Nocturne. Theme 6 selects the ice-blue APEX v1.8 design, and themes 1–5 select the classic instrument layouts. New instances default to Tailor.
4. Choose a layout and your preferred speed and altitude units. For a first setup, select the arm AUX channel or switch under **ArmSrc** and match its polarity under **ArmHigh**. Verify both positions with the props removed.

The main design target is a 480 × 272 landscape zone on colour EdgeTX 2.11 or later. Larger layouts reflow. Shallow Performance zones switch from the dial to a grid of readings. Very small zones show a compact readout.

## Flight displays

- **Performance** places GPS ground speed, a recent speed trace where space permits, and arm time alongside voltage, current, power, link quality, RSSI and altitude.
- **Essentials** uses six larger fields for speed, altitude, voltage, link quality, arm time and power.
- **Battery** shows live or minimum pack voltage, observed voltage drop from the first armed sample, consumption, current and power.
- **Logbook** shows per-model flights, total time, best ground speed, peak power and recent entries. The logbook is available with the arm source disarmed.

The radio follows your configured arm source. Disarming freezes the report until the next observed arm cycle. Missing readings appear as dashes. Compatible telemetry sensors are required for each reading. Select MPH and Feet independently. Set Cells only when the pack count is known.

## Records

In full-screen widget view, press Enter or tap the disarm summary to open Logbook. Press Enter or tap again to review the newest flight. Next and Previous step through up to eight entries. Enter or tap returns to the overview. On the summary, a page key returns to the usual layout navigation. Re-arming always returns to live readings.

**LogSD** defaults to on for a new widget. When upgrading an existing widget, turn it on in widget settings to keep flights after a restart. With LogSD off, flights remain available for the session. The summary shows the result of the SD save. Pending SD writes wait through a quick re-arm and resume while disarmed (up to eight queued flights).

The widget uses the existing `/LOGS/SQD_<model filename>.csv` journal. Keep one widget instance per model and allow history to load while disarmed. The existing SQ14 record format and model filenames apply, including to logs saved by v1.8. The logbook retains eight recent rows in memory. Archive a journal manually when it reaches the existing 256 KiB limit.

## Offline preview

Open **Squadding-Quads-FPV-Dashboard-Offline.html** from the extracted ZIP in a modern browser. Choose a layout, start a demo flight, adjust the throttle and finish the flight to see the report. Preview settings include screen size, themes, independent units and simulated GPS loss. Demo history stays in the browser. The HTML runs the packaged Lua drawing code against simulated state. Its fonts approximate the radio display. A static design proof is included for viewers that cannot run the interactive preview.

## Verification

The desktop Lua harness covers disarm from all four layouts, telemetry extrema and units, missing readings, consecutive flights, SD journal round trips and browsing existing records. The browser preview uses simulated telemetry. Physical-radio fit and SD behaviour still need a hardware check.

Run the desktop Lua harness from the repository root with `SQ_DASH_THEME=8 python3 sq-reactor/tests/run-lua.py`. Set the theme to 7 or 6 to check Nocturne or APEX. Run `python3 sq-reactor/tests/run-lua.py sq-reactor/tests/theme-layouts.lua` for the Grand Prix ’92 and Boy Wonder layouts.
