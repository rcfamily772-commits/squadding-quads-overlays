# SQ OSD Studio v1.0 — experimental
[Launch app](https://rcfamily772-commits.github.io/squadding-quads-overlays/osd-studio/)

Local browser tool for Intel HEX validation, a deliberately narrow experimental post-flight heading replacement, and a 288x72 three-colour analogue boot logo drawing studio.

The patch accepts only a unique, NUL-terminated, isolated "--- STATS ---" candidate in STM32 internal-flash images with Betaflight and statistics markers. It supports Intel HEX record types 00–05, rejects overlap, invalid checksums, missing EOF and ambiguous matches, pads replacements to 13 bytes, preserves addresses/start records, and reparses/verifies all data bytes. It does not prove string references, board identity, signatures, image-level CRCs or flight safety. No arbitrary search/replace or safety-message editing. Synthetic demo cannot export HEX. Experimental output is for bench validation only, with props removed; retain original firmware and backup. No real hardware verification yet.

The logo editor exports a separate 288x72 PNG using black, white and green transparency for compatible MAX7456 Font Manager workflows. It is not injected into the FC HEX. Digital systems differ. Native custom-text/OSD layout settings or a target-specific source build are appropriate for more extensive customisation.

Sources: https://betaflight.com/docs/wiki/app/osd-tab ; https://github.com/betaflight/betaflight/blob/master/src/main/osd/osd.c ; https://betaflight.com/docs/development/Defines .
