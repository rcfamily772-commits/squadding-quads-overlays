# SQ Black Label OS Studio v0.1 — development only

**Not ready for public use. Do not flash any radio.** This is an independent SQ project, not an EdgeTX or Oxbot product.

[Web studio](https://rcfamily772-commits.github.io/squadding-quads-overlays/black-label-os/) — live mock dashboard, model list, quick menu and warning preview, three palette presets, editable theme colours, PNG, EdgeTX palette YAML and build-profile JSON export. The YAML is not a full SD theme (no logo or three required screenshots). The mock interface is not compiled firmware.

## Scope
EdgeTX v2.12.5 is the selected research baseline. TX16S is the only initial build candidate; TX15, TX16S MK3 and Jumper T15 are mock preview targets only. No device support is validated. No theme lock, new navigation, embedded branding, replacement dashboard, automatic flashing or GitHub Actions compilation is implemented in v0.1. The native UI remains unchanged until a reviewed mapping is applied. The warning design colour is fixed; the compiler cannot edit the upstream warning definition.

## Local build driver
Requires Python 3.9+ (3.10+ recommended), git, CMake and the official EdgeTX build dependencies. Obtain the source from the official repository at v2.12.5, including its required submodules, and verify its commit against upstream. Use an expendable clean checkout, not a production working tree. See [upstream developer build docs](https://docs.edgetx.org/) and [release notes](https://github.com/EdgeTX/edgetx/releases/tag/v2.12.5). The pinned release may lack the current documented CMake presets; the tool blocks rather than guessing.

1. Export sq-os-profile.json from the web studio. Download build.py and review-template.json.
2. Run: python3 build.py --source /path/to/edgetx --profile sq-os-profile.json
3. The resulting sq-os-audit.json identifies the exact local commit and reports that source mapping is blocked. No source modifications occur.
4. An independent reviewer must examine the exact upstream palette definition and confirm its semantics. Fill the review manifest with the exact commit, reviewer, reviewed=true and files entries containing path, sha256 and edits (each: key, exact_line, old_literal). Only uniquely labelled single-line 24-bit hex palette assignments in narrow candidate colour/theme filenames can pass. No index, warning, UI logic, or other code edits. Actual source may use a different representation: if so, this version intentionally refuses to patch; do not manufacture a match.
5. Run the same command with --review reviewed.json for a dry-run audit; inspect every intended replacement. Then, in a disposable checkout, --apply --build simulator. Firmware target is available explicitly as --apply --build firmware for engineering compilation only, not flashing. The tool verifies the modified file set and byte hashes before launching CMake. It does not prove runtime equivalence, verify a remote tag signature, test the toolchain, or automatically revert changes after a build attempt. Restore or discard the temporary checkout afterward.
6. Do not distribute or flash binaries. Before progressing, verify source and build reproducibility, full simulator workflows, alert visibility, native navigation, calibration, failsafe behavior, timing, RF and recovery on isolated spare hardware. No aircraft powered, RF disabled during initial hardware checks. Retain a route to stock EdgeTX.

## Licensing
Respect upstream GPL-2.0 licensing and copyright notices; if distributing modified EdgeTX binaries, supply corresponding source and build materials under applicable GPL terms. SQ branding does not make modified EdgeTX closed-source. See upstream LICENSE. This repository currently contains original studio and driver code, not an upstream firmware fork.

## Next milestones
Verify upstream palette mapping and source version; build the stock and cosmetic simulator with the same toolchain; compare source, build configuration and behavior. Only then consider native dashboard changes and an optional branded UI mode that never prevents access to native warnings, settings, or recovery. Theme locking is not implemented.
