# Squadding Quads — OBS Overlays

## Squadding Quads Tools

[Open the complete Black Label software collection](https://rcfamily772-commits.github.io/squadding-quads-overlays/tools/): Pack Lottery, Wallpaper Shuffle, RF Doctor, LiPo Butler, OSD Studio, EdgeTX Test Bench OBS Glass Overlays and [SQ Radio Toolbox v1.0](https://rcfamily772-commits.github.io/squadding-quads-overlays/radio-toolbox/).


Independent, Squadding Quads-owned copy of the V5 frosted-glass overlay prototype, reproduced with permission of the original author.

[Squadding Quads FPV Dashboard v1.8.9 for colour EdgeTX radios](https://rcfamily772-commits.github.io/squadding-quads-overlays/sq-reactor/)

## Status

**Frontend source copied, not deployed.** V5 visual styling retained. The subscriber and live-chat APIs are intentionally **disabled** until our own Cloudflare Worker is deployed. Patreon and YouTube supporter integrations are **not live**; sample names appear only with `?demo=1`. No production API credentials or secrets belong in this repository.

## Pages

- `index.html` — preview entry point (`test-controls.html`)
- `subscribers.html` — transparent OBS subscriber overlay
- `chat.html` — transparent OBS live-chat overlay
- `supporters.html` — transparent OBS supporters overlay
- `overlay.html` — shared V5 styling and logic
- `test-controls.html` — design preview/testing controls

The optional `fpv-background.png` preview-only image has **not yet been transferred**. It does not belong in production OBS browser sources.

## Next steps

1. Transfer preview-only background image (optional).
2. Verify visual appearance against the original V5.
3. Configure GitHub Pages under this account.
4. Deploy our own Cloudflare Worker and only then enable subscriber/chat data.
5. Implement privacy-safe Patreon and YouTube member acknowledgements.

Source prototype: https://github.com/alfonsogordon/squadding-quads-overlays
