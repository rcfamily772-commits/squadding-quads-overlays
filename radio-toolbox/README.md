# SQ Radio Toolbox v1.0 — public beta

[Launch](https://rcfamily772-commits.github.io/squadding-quads-overlays/radio-toolbox/) · [All tools](../tools/)

Mobile-first installable web app. No server, accounts or uploads. Compatible browsers may select an EdgeTX SD root with read/write permission; otherwise use ZIP export. Not a native APK. Physical USB compatibility has not been tested. Queue is session-only. Artwork PNG, audio upload/recording to 32 kHz mono PCM WAV, extracted WIDGETS import, folder scan, visible settings backup, review and write with original-file ZIP backup and CRC verification. No edits to firmware, RF, mixers, failsafe, calibration or model settings. Widget placement, theme selection, model image assignment and custom Play track assignments are manual. Extra widget assets need separate copying. Offline app shell after first successful visit.

Before testing: back up all SD and internal settings with EdgeTX Companion, disconnect aircraft batteries, use a spare SD card, confirm resolution, active theme and language, verify the backup has downloaded before overwrites, eject safely and check operation before flight. Failed writes may leave partial changes; restore original files and remove newly created ones if needed. Browser support varies; folder access is not guaranteed.

References: https://github.com/EdgeTX/edgetx-sdcard ; https://github.com/EdgeTX/themes/blob/main/structure.md ; https://github.com/EdgeTX/edgetx-sdcard-sounds ; https://manual.edgetx.org/ ; https://developer.mozilla.org/en-US/docs/Web/API/Window/showDirectoryPicker
