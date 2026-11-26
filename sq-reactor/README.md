# SQ Pilot Dash v1.6 — Velocity / V15 Landscape Edition

Formerly SQ Reactor. [Project page, four-layout browser demo and v1.6 ZIP](https://rcfamily772-commits.github.io/squadding-quads-overlays/sq-reactor/).

## v1.6 V15 landscape correction (experimental field preview)
- Primary target: HelloRadioSky V15 Ultra, native 480×272 landscape, confirmed by LCD_W/LCD_H in the EdgeTX 2.12 V15 HAL: https://github.com/EdgeTX/edgetx/blob/2.12/radio/src/targets/hrs/v15/hal.h .
- Reflow rather than stretch: three header modules, six telemetry pods, circular speed dial with equal pixel radii, full-width trace, gold peaks rail and footer. Timer moves to centre header.
- Full layout reflows to actual widget zones at least 400×190 and aspect ratio ≥1.45, subject to minimum tile height; smaller/portrait zones use the previous adaptive fallback.
- Browser preview uses a fixed 480×272 SVG viewBox with preserved aspect ratio; artwork is illustrative and firmware fonts may differ. Theme 6 selects Velocity.
- Existing SD journal and telemetry features unchanged. [Archived v1.5](https://rcfamily772-commits.github.io/squadding-quads-overlays/sq-reactor/v1.5/).

## Velocity features
- Theme 6 (default for new instances): blue glass-inspired bevelled instrument pods, large flight timer, central segmented speed dial, full-width rolling trace and a gold current/last-flight peaks rail.
- Six total themes; themes 1–5 retain their earlier layout. Existing saved widget settings may retain the previous theme: set Theme=6 explicitly to activate Velocity. See v1.6 landscape requirements above.
- The browser uses CSS gradients/glow; the actual radio uses lightweight LCD primitives and does not replicate the concept photograph pixel-for-pixel. No Oxbot firmware support is implied.
- Existing log schema, demo storage key, four layouts and telemetry collection remain unchanged. Archived [v1.4](https://rcfamily772-commits.github.io/squadding-quads-overlays/sq-reactor/v1.4/) remains available.

## Retained Flight Command features
- Four selectable instrument layouts: Performance (32-segment dial, telemetry, rolling speed trace), Essentials (large readings), Battery Performance (pack voltage, minimum voltage, voltage drop from first armed sample, last armed voltage, current, observed capacity, electrical power), Logbook (per-model saved flights, accumulated arm time, best observed speed, duration and power; latest entries).
- Independent MPH and Feet toggles. Stored speed remains km/h; altitude remains metres.
- Gold-accented frozen last-flight report; six themes. Read-only flight telemetry, no model or control writes.
- Optional SD journal, one append after a confirmed radio arm-source disarm. No file I/O during observed armed state; loading is incremental when disarmed. One SQDash instance per model.
- Browser demo has its own local-storage aircraft history, up to 500 rows per aircraft, CSV export, independent units and page tabs. Simulated data only; does not read the radio or sync with its SD journal.

## Install
Extract ZIP into SD card root (WIDGETS/SQDash/main.lua); restart and add SQDash to a large colour widget zone. **EdgeTX 2.11+ required** because eight widget options are used. Older firmware can use [v1.3](https://rcfamily772-commits.github.io/squadding-quads-overlays/sq-reactor/v1.3/). [v1.1](https://rcfamily772-commits.github.io/squadding-quads-overlays/sq-reactor/v1.1/) and Reactor v1.0 are preserved.

Settings: ArmSrc = dedicated two-position arm AUX channel or matching logical switch; ArmHigh = positive means armed; Cells = verified pack cell count (0 disables average cell voltage); Theme = 1–6 (6 Velocity); MPH and Feet = independent unit choices; Layout = 1 Performance, 2 Essentials, 3 Battery, 4 Logbook; LogSD = off by default. Full-screen page or rotary/field navigation switches layouts when the arm source is disarmed. Logbook is hidden when arm state is unsafe/unknown. Use one instance per model to avoid duplicate entries. Test with propellers removed.

## SD logbook
Enable LogSD and select Logbook while disarmed. Wait for history to load before arming. A log is keyed by the EdgeTX model filename (not the display name), so reusing a model file shares history. If filename is unavailable/unsupported, storage is disabled. Files are in /LOGS/SQD_<model filename>.csv; /LOGS must exist. New or unreadable history is reported as such; read/write/open failures and capacity limits are reported in the logbook. At 256 KiB, archive the file manually with the radio off; the widget never truncates existing data. It retains eight recent rows in RAM and aggregates records from loaded rows. Re-arming before a pending write is ready can lose that entry. No guarantee against power loss or SD corruption. Back up the SD card. Logs are not flight-controller blackbox logs.

CSV format (no header, blank lines permitted):
SQ14,date_local,duration_s,peak_speed_kmh,avg_speed_kmh,max_alt_m,min_pack_v,peak_current_a,peak_power_w,observed_mah,min_lq_pct,min_rssi_dbm,last_armed_v,partial_flag,END
A dash denotes unavailable data. Partial rows are marked and excluded from aircraft bests; GPS-less aircraft can still log arm time and other available values. Date uses radio RTC. The recent list shows as many rows as the display fits (up to eight loaded).

## Telemetry and limitations
Discover sensors and verify values, especially RxBt (can represent receiver supply, not aircraft pack). GPS speed and altitude require compatible telemetry. Power = sampled voltage × current; pack voltage drop is relative to the first armed voltage, not measured internal resistance or true transient sag. Observed arm time follows the configured radio source, not confirmed FC arm state. Speed average is a sample mean; missing/stale values omitted. Missing samples can hide extrema. Session-only bests survive re-arm, not reload; SD aircraft records survive restart if successfully saved. Never use as a safety instrument. Remove if radio performance suffers.

## Validation
v1.6 mocked browser tests passed: native view, 32 ticks, timer, power, trace, feet/metres, frozen peaks, logbook retention, legacy theme switch, unique IDs, 480×272 viewBox and ZIP payload. A geometry calculation mirroring the Lua layout passed at 480×272, 460×232, 460×210 and 400×190; 320×240 takes the fallback. This is not a Lua runtime, font-rendering or on-radio test. Live Pages deployment remains unverified.
v1.5 mocked browser checks passed: default Velocity selection, live timer and wattage, feet/metres conversion, frozen peaks on disarm, legacy theme selection, logbook retention, unique HTML IDs and ZIP source payload. Lua rendering and radio performance remain untested on physical hardware.
Prior v1.4 browser logic passed mocked DOM checks of feet/metres conversion, battery layout, logbook count, separate aircraft, persistence after reload and ZIP entry/payload. The Lua runtime, physical radio, SD I/O on hardware, actual browser rendering and live GitHub Pages deployment have not been verified. This remains a field preview.

References: https://luadoc.edgetx.org/2.11/api-reference/constants/widget-options/ ; https://luadoc.edgetx.org/2.11/overview/version-libraries/io-library/ ; https://luadoc.edgetx.org/2.11/api-reference/model/getinfo/ .
