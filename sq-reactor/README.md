# SQ Pilot Dash v1.3 — Black Label

**Formerly SQ Reactor.** The existing project has evolved from a decorative animated core into a read-only FPV telemetry dashboard. Reactor v1.0 remains available unchanged.

[Project page, interactive demo and v1.3 ZIP](https://rcfamily772-commits.github.io/squadding-quads-overlays/sq-reactor/)

## v1.3 Performance Edition (field preview)
- Layered instrument panels, 32-segment speed dial, estimated electrical power (sampled volts × amps), peak power on the debrief.
- Up to 36 approximately one-second speed samples, frozen on disarm; trace uses an automatic scale and is displayed on large zones (400×230 or larger). Missing samples break the trace.
- Sample mean GPS speed and completed-flight session speed records; records survive re-arm but not settings changes or widget reload. No SD writes. Session records are not certified personal records.
- Original v1.1 available at [the archived page](https://rcfamily772-commits.github.io/squadding-quads-overlays/sq-reactor/v1.1/).

- Live GPS ground speed (km/h or mph), voltage, current, LQ, RSSI dBm, altitude, flight timer and observed mAh consumption.
- Automatic last-flight view: sampled peak speed/current/altitude, minimum voltage/LQ and weakest RSSI; observed mAh delta and arm-input elapsed time.
- Five palettes, segmented speed dial, compact zone layout, gold last-flight report.
- Background sampling while widget is hidden (subject to EdgeTX scheduling); fresh/current sensor values only; physical units checked and converted.
- Browser demo includes arm/disarm, throttle simulation, GPS loss, themes and downloadable ZIP assembled from the published Lua source.

## Installation
Extract the ZIP into your SD card root: WIDGETS/SQDash/main.lua. Restart EdgeTX and add SQDash to a large colour widget zone. Existing SQReact installations are unaffected.

In widget settings:
- ArmSrc: select a dedicated two-position arm source (prefer the arm AUX output channel or matching logical switch). Default unconfigured. Verify with propellers removed.
- ArmHigh: on for positive armed input, off for negative armed input. Middle or unavailable input is unknown. The widget waits for an observed disarmed state before recording.
- Cells: verified pack cell count, 0 disables calculated average voltage per cell.
- Theme: 1–5; MPH: switch speed unit.

Discover sensors and verify battery sensor corresponds to the aircraft pack (RxBt can represent receiver supply). GPS speed and altitude require appropriate compatible sensors. No values are invented when sensors are absent. Sampled extrema are not flight-controller blackbox maxima. Arm input is not verified FC arm status. Capacity is a delta from the first observed value; a reset invalidates it. Missing samples can hide peaks; report stays in RAM until re-arm, settings change or reload. Colour EdgeTX 2.8+ target, physical radio validation pending. Never rely on this widget for flight safety. No control, model or SD writes.

## Validation
v1.3 browser JavaScript passed a mocked DOM test of live power, rolling trace, frozen debrief, first record, second-flight record retention, GPS loss, session reset and ZIP entry/payload. Physical radio testing remains pending. Actual browser rendering, EdgeTX Lua runtime, physical hardware and Pages deployment not verified by this check.

Original Reactor v1.0: SQ_Reactor_v1.0.zip and WIDGETS/SQReact/main.lua retained. Existing smoke.lua pertains to v1.0.

API: https://luadoc.edgetx.org/latest/api-reference/sources/get-source-value/ and https://luadoc.edgetx.org/latest/api-overview/script-types/widget-scripts/
