# SQ Pilot Dash v1.8.1 · APEX Nocturne

[Launch the live preview](https://rcfamily772-commits.github.io/squadding-quads-overlays/sq-reactor/v1.8.1/) · [Download v1.8.1](../SQ-Pilot-Dash-v1.8.1-Nocturne.zip) · [Design board](../design/nocturne/overview.png) · [Previous APEX v1.8](../v1.8/)

Nocturne is Theme 7 for Squadding Quads Pilot Dash. The speed figures, Apex hallmark and flight trace are drawn directly on the radio. A dark oxblood band frames the frozen last-flight report.

## Install or upgrade

1. Extract the ZIP. Copy its **WIDGETS** folder to the root of your radio SD card, merging the folder and replacing `WIDGETS/SQDash/main.lua`. For an existing installation you can replace just the Lua file.
2. Restart EdgeTX. Open SQDash settings on your existing widget, or add SQDash to a large colour widget zone.
3. Select **Theme 7** for Nocturne. Theme 6 selects the ice-blue APEX v1.8 design, and themes 1–5 select the classic instrument layouts. New instances default to Nocturne.
4. Choose a layout and your preferred speed and altitude units. For a first setup, select the arm AUX channel or switch under **ArmSrc** and match its polarity under **ArmHigh**. Verify both positions with the props removed.

The main design target is a 480 × 272 landscape zone on colour EdgeTX 2.11 or later. Larger layouts reflow. The peak rail gives way to the live readings in shallow Performance zones. Very small zones show a compact readout.

## Flight displays

- **Performance** places GPS ground speed, a recent speed trace where space permits, and arm time alongside voltage, current, power, link quality, RSSI and altitude. A lower rail shows peaks and observed consumption.
- **Essentials** uses six larger fields for speed, altitude, voltage, link quality, arm time and power.
- **Battery** shows live or minimum pack voltage, observed voltage drop from the first armed sample, consumption, current and power.
- **Logbook** shows per-model saved flights, total time, best ground speed, peak power and recent entries. The logbook is available with the arm source disarmed.

The radio follows your configured arm source. Disarming freezes the report until the next observed arm cycle. Missing readings appear as dashes. Compatible telemetry sensors are required for each reading. Select MPH and Feet independently. Set Cells only when the pack count is known.

## Records

The optional **LogSD** setting uses the existing `/LOGS/SQD_<model filename>.csv` journal. Keep one widget instance per model and allow history to load while disarmed. The existing SQ14 record format and model filenames apply, including to logs saved by v1.8. The logbook retains eight recent rows in memory. Archive a journal manually when it reaches the existing 256 KiB limit.

## Offline preview

Open **APEX-Nocturne-Preview.html** from the extracted ZIP in a modern browser. Choose a layout, start a demo flight, adjust the throttle and finish the flight to see the report. Preview settings include screen size, themes, independent units and simulated GPS loss. Demo history stays in the browser. The HTML runs the packaged Lua drawing code against simulated state. Its fonts approximate the radio display. A static design proof is included for viewers that cannot run the interactive preview.

## Verification

The v1.8 and v1.8.1 Lua builds were compared against the v1.8 behavioural checks. The new theme passed desktop Lua checks for arm gating, missing GPS, zero link quality, unit conversion and a frozen report. The preview worker's packaged code also ran with a mock display across all seven themes. Physical radio rendering, CPU and memory use, and SD I/O remain to be checked on hardware.

Run the desktop Lua harness from the repository root with `python3 sq-reactor/tests/run-lua.py` for APEX and `SQ_DASH_THEME=7 python3 sq-reactor/tests/run-lua.py` for Nocturne.
