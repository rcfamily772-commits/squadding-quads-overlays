# SQ Reactor v1.0 — Black Label

[Animated browser preview / download](https://rcfamily772-commits.github.io/squadding-quads-overlays/sq-reactor/)

A read-only decorative EdgeTX colour-screen widget: rotating mechanical rings, pulsing core, sparks, five palettes, configurable speed, optional stick response, callsign and fresh telemetry. No control writes, SD writes, sounds, backlight overrides or background polling. All geometry drawn with standard LCD primitives. Actual refresh cadence depends on firmware and processor; this is a field preview, not flight-tested.

## Install
Merge WIDGETS/SQReact/main.lua into the SD card root. Restart and add SQReact to your main screen. Use the largest available zone. No full-screen input mode needed for animation. Widget Settings: Theme 1 Ion Blue, 2 Toxic Green, 3 Molten Red, 4 Black Gold, 5 Neon Violet; Speed 0 static, 1 slow, 2 normal, 3 fast; React toggles decorative aileron/elevator response; Telemetry toggles read-only TX voltage and RQly/LQ; Callsign up to eight characters. Colour EdgeTX 2.8+ target, hardware validation pending. Smaller zones use simplified layout. Unknown or stale data shown as --; session is widget uptime. Never rely on Reactor for flight safety or low battery warnings. Test disarmed; switch to static or remove widget if radio performance suffers. Browser uses simulated data and illustrative geometry.

## Development
Run `lua sq-reactor/tests/smoke.lua` from repository root using desktop Lua. Mock checks validate dashboard geometry and state, not radio performance. API references: https://luadoc.edgetx.org/latest/api-overview/script-types/widget-scripts/ and https://luadoc.edgetx.org/latest/api-reference/sources/get-source-value/ .
