# SQ LiPo Butler v1.0

[Website](https://rcfamily772-commits.github.io/squadding-quads-overlays/lipo-butler/) · [Actual Lua test page](https://rcfamily772-commits.github.io/squadding-quads-overlays/lipo-butler/test/) · [Browser manager](https://rcfamily772-commits.github.io/squadding-quads-overlays/lipo-butler/app/)

Install WIDGETS/SQLiPo/main.lua. Colour screens 320x240+. Configure Packs (up to 24), Cells, Capacity (initial defaults) and VoltSrc (optional, default VFAS). Prev/Next select a pack, State/Apply confirms a manual status, Setup changes cell count/capacity or captures the currently connected pack voltage, Summary shows inventory totals. Charge/flight counters increment only on transitions into Charged/Flown. Data is in packs-a.txt and packs-b.txt, checksummed and alternated. Back up both. The browser can import a radio save and export CSV; inventories do not automatically sync.

Live telemetry is optional, unassigned and shown only when current and fresh. No state-of-charge or battery-health estimation, no charging, arming or model changes. Inspect actual batteries and follow manufacturer guidance. Use one widget instance for edits. Hardware testing pending. The test bench simulates storage and telemetry, not real radio firmware.

API reference: https://luadoc.edgetx.org/latest/api-reference/sources/get-source-value/ and https://luadoc.edgetx.org/latest/api-overview/constants/widget-options/.
