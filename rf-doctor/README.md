# SQ RF Doctor v1.0

Read-only colour EdgeTX RF analyser. [Project site](https://rcfamily772-commits.github.io/squadding-quads-overlays/rf-doctor/) · [CSV analyser](https://rcfamily772-commits.github.io/squadding-quads-overlays/rf-doctor/app/)

Install WIDGETS/SQRF/main.lua on the SD card. EdgeTX 2.8+ colour screens (320x240+). Discover telemetry first. Expected sensor aliases: RQly/Rqly, 1RSS, 2RSS, RSNR, TPWR, RFMD, TQly. Manual Record/Stop; graph and report views. Samples about 1 Hz; stale/missing values are blank. RFMD raw code, no latency or actual failsafe detection. CSV stored in widget folder. Flush every 5 rows; stop before switching models or powering off. Maximum 3600 seconds. The browser compares two CSVs locally. No settings or outputs modified. Hardware testing pending.

API references: https://luadoc.edgetx.org/2.9/api-reference/general/getsourcevalue-source/ and https://luadoc.edgetx.org/2.9/programming/included-lua-libraries/io-library/io-open/.
