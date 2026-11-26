# SQ Pilot Dash v1.8 — Apex

[Interactive preview and download](https://rcfamily772-commits.github.io/squadding-quads-overlays/sq-reactor/) · [Design overview](design/apex-overview.png) · [Previous v1.7](v1.7/)

A motorsport-inspired visual redesign of the actual EdgeTX widget. SQ identity throughout; no Red Bull or Formula 1 affiliation.

## What changed

- New Theme 6: near-black surfaces, warm white numerals, ice-blue live instruments and an amber frozen flight report.
- Bespoke geometric speed digits, 24-segment speed strip, measured text fitting, six telemetry fields, central arm timer and speed trace, and a restrained peak/consumption rail.
- Performance, Essentials, Battery and Logbook share one visual system. Themes 1–5 retain their classic rendering.
- Explicit missing GPS and partial GPS report messages. Missing readings are not filled with invented zeroes. Values that cannot fit at the smallest font show `--` rather than truncated digits.
- The web preview now executes the downloadable Lua **drawing code** in a bounded worker using the existing Fengari dependency. Its state is simulated, font metrics approximate, and it is not a firmware emulator or radio connection. History remains on the existing browser storage key.
- No extra radio image/font files, decorative animation, sensors, widget settings or SD format changes. Telemetry sampling and flight/log bookkeeping are unchanged.
- v1.7 remains archived with its own stylesheet, JavaScript and Lua source.

## Display and install

Main design target: 480×272 landscape, including V15 Ultra. Apex Performance reflows in landscape zones at least 360×210; the other three Apex pages can use 360×180. Aspect ratio must be at least 1.4. Smaller/portrait zones retain the compact/classic fallback, including 400×190 and 320×240.

Select **Theme = 6** after installation; saved widget settings can retain an older theme. Download `SQ_Pilot_Dash_v1.8.zip`, extract to the SD card root and add SQDash to a large colour widget zone. Full details below. The website download button packages the same main.lua; the static ZIP also includes this README.

## Retained Flight Command features
- Four selectable instrument layouts: Performance (32-segment dial, telemetry, rolling speed trace), Essentials (large readings), Battery Performance (pack voltage, minimum voltage, voltage drop from first armed sample, last armed voltage, current, observed capacity, electrical power), Logbook (per-model saved flights, accumulated arm time, best observed speed, duration and power; latest entries).
- Independent MPH and Feet toggles. Stored speed remains km/h; altitude remains metres.
- Gold-accented frozen last-flight report; six themes. Read-only flight telemetry, no model or control writes.
- Optional SD journal, one append after a confirmed radio arm-source disarm. No file I/O during observed armed state; loading is incremental when disarmed. One SQDash instance per model.
- Browser demo has its own local-storage aircraft history, up to 500 rows per aircraft, CSV export, independent units and page tabs. Simulated data only; does not read the radio or sync with its SD journal.

## Install
Extract ZIP into SD card root (WIDGETS/SQDash/main.lua); restart and add SQDash to a large colour widget zone. **EdgeTX 2.11+ required** because eight widget options are used. Older firmware can use [v1.3](https://rcfamily772-commits.github.io/squadding-quads-overlays/sq-reactor/v1.3/). [v1.1](https://rcfamily772-commits.github.io/squadding-quads-overlays/sq-reactor/v1.1/) and Reactor v1.0 are preserved.

Settings: ArmSrc = dedicated two-position arm AUX channel or matching logical switch; ArmHigh = positive means armed; Cells = verified pack cell count (0 disables average cell voltage); Theme = 1–6 (6 Apex); MPH and Feet = independent unit choices; Layout = 1 Performance, 2 Essentials, 3 Battery, 4 Logbook; LogSD = off by default. Full-screen page or rotary/field navigation switches layouts when the arm source is disarmed. Logbook is hidden when arm state is unsafe/unknown. Use one instance per model to avoid duplicate entries. Test with propellers removed.

## SD logbook
Enable LogSD and select Logbook while disarmed. Wait for history to load before arming. A log is keyed by the EdgeTX model filename (not the display name), so reusing a model file shares history. If filename is unavailable/unsupported, storage is disabled. Files are in /LOGS/SQD_<model filename>.csv; /LOGS must exist. New or unreadable history is reported as such; read/write/open failures and capacity limits are reported in the logbook. At 256 KiB, archive the file manually with the radio off; the widget never truncates existing data. It retains eight recent rows in RAM and aggregates records from loaded rows. Re-arming before a pending write is ready can lose that entry. No guarantee against power loss or SD corruption. Back up the SD card. Logs are not flight-controller blackbox logs.

CSV format (no header, blank lines permitted):
SQ14,date_local,duration_s,peak_speed_kmh,avg_speed_kmh,max_alt_m,min_pack_v,peak_current_a,peak_power_w,observed_mah,min_lq_pct,min_rssi_dbm,last_armed_v,partial_flag,END
A dash denotes unavailable data. Partial rows are marked and excluded from aircraft bests; GPS-less aircraft can still log arm time and other available values. Date uses radio RTC. The recent list shows as many rows as the display fits (up to eight loaded).

## Telemetry and limitations
Discover sensors and verify values, especially RxBt (can represent receiver supply, not aircraft pack). GPS speed and altitude require compatible telemetry. Power = sampled voltage × current; pack voltage drop is relative to the first armed voltage, not measured internal resistance or true transient sag. Observed arm time follows the configured radio source, not confirmed FC arm state. Speed average is a sample mean; missing/stale values omitted. Missing samples can hide extrema. Session-only bests survive re-arm, not reload; SD aircraft records survive restart if successfully saved. Never use as a safety instrument. Remove if radio performance suffers.

## Validation — v1.8

Executed the actual Lua with a desktop LCD mock: arm gating, zero LQ, missing GPS, frozen peak report, independent speed/altitude conversion, disarmed-only layout switching, four Apex layouts at 480×272, 460×232, 460×210 and 800×480; fallback geometry at 400×190, 320×240, 320×480, 240×160, 160×100 and 80×64. Drawing budget stays below 500 primitives/frame in these checks. Text measurements are approximations, not firmware font validation.

Browser inspection: worker-loaded Lua renderer, start/finish report, Battery and Logbook pages, retained local demo history after reload, unit controls, missing-speed toggle, 320×240 fallback and a 390px mobile iframe. Native and JavaScript syntax checks passed. Static ZIP payload and browser ZIP encoder checked against the current Lua bytes.

Physical radio execution, radio CPU/memory use, actual firmware font metrics and hardware SD I/O remain unverified. This is an experimental field preview. Test with propellers removed before using the widget in flight.

Reproduce the Lua checks from the repository root:

```sh
python sq-reactor/tests/run-lua.py
python sq-reactor/tests/render-proof.py
```

Requires the Lua 5.4 shared library for the Python launcher (or run `lua sq-reactor/tests/apex.lua` directly with Lua 5.3+) and Pillow/DejaVu fonts for design proofs. The PNG proofs use actual recorded Lua drawing commands with approximate typography; they are not photographs of radio hardware.

API references: [Widget options](https://luadoc.edgetx.org/2.11/api-reference/constants/widget-options/), [LCD text](https://luadoc.edgetx.org/2.11/api-reference/display-lcd/drawtext/), [text measurement](https://luadoc.edgetx.org/2.11/api-reference/display-lcd/sizetext/), [SD I/O](https://luadoc.edgetx.org/2.11/overview/version-libraries/io-library/).
