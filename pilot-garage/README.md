# SQ Pilot Garage v1.0
Local-first aircraft workspace and shared contract for future SQ tools.

## Integration
Load `../pilot-garage/shared.js?v=1` in a same-origin Pages app. `SQPilotGarage.read()` returns a validated version-1 object: `{version:1,active:string|null,aircraft:[]}`. `fromUrl()` resolves the `?aircraft=ID` parameter against local storage, or returns null. Catch storage and validation errors; never silently replace unknown values with measured values. Link back to `../pilot-garage/`. Profiles are not cloud synced. Labs should read only; writes belong to the garage editor unless a future explicitly authorised workflow is designed.

Profile fields: id, name, type, status, frame, dry (g, no battery or added payload), payload (g), cells, motors, motorModel, kv, thrust (static grams per motor), escAmps, propSize (inches), propModel, fc, esc, video (stable system ID), goggles, videoFirmware, rc (stable protocol ID), receiver, radio, rcFirmware, rates (text), refCapacity (mAh), refWeight (g), refTime (measured minutes), refPayload (g), cruise (km/h), notes, updated. Unknown numeric data is null; unknown strings are empty. See shared.js for bounds and enumerations. Never interpret a Ready status as flight clearance. Thrust may be estimated, and the example is explicitly provisional.

LiPo Lab only imports 6S four-motor profiles with dry, payload and thrust; complete measured references are imported as measured, otherwise the reference is labelled illustrative. Range Lab imports known system/RC IDs and available measured duration and cruise, not a control-distance claim. Goggles/firmware are shown for manual matching. No automatic writeback.

## Backup
Export/import versioned JSON. Import validates shape, bounds and unique IDs before explicit replacement confirmation. Data stays in the browser; clearing storage can remove it. Same-origin storage is shared across the toolbox; no encryption or account sync.

## Next tools
Build Doctor, Black Box, Prop Lab, Rate Lab and Flight Window should use the same read contract. Add new schema versions with explicit migration; don't change units in place.

## Validation
Shared contract validation tests and JavaScript syntax checks passed. Full browser and mobile end-to-end tests are not yet confirmed.
