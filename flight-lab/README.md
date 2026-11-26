# SQ FlightLab v0.1 — experimental performance prototype

**NOT READY FOR PUBLIC USE.** Do not use on a primary flying radio. Use a spare radio with internal and external RF disabled, all aircraft unpowered and an SD-card backup. The code does not flash firmware, write settings, change channels or send commands. The Lua prototype has not been validated on hardware.

## Web companion
Open [FlightLab](https://rcfamily772-commits.github.io/squadding-quads-overlays/flight-lab/). Acknowledge the development warning. Keyboard, touch or USB joystick input; check axis assignment and polarity with the on-screen readout. Start/pause/reset, 3 graphics profiles, camera tilt, linear rates, optional adaptive detail and frame cap. A 30-second scripted benchmark exports per-second CSV samples. Canvas 2D draws projected 3D line geometry; this is deliberately not WebGL yet.

## Radio files (developer inspection only)
Copy the following files to the same paths at the SD root of the spare radio:
- SCRIPTS/SQFL/core.lua
- SCRIPTS/TOOLS/SQFlight.lua
- WIDGETS/SQFlight/main.lua (optional colour radio only)

Use stock EdgeTX. Launch the tool from the radio's Tools menu, or add the SQFlight widget and enter full-screen mode. Read the warning and confirm only on an isolated spare. ENTER starts/stops/reset the simulation; NEXT cycles detail Q0/Q1/Q2; PREV cycles rate 200–1000 deg/s; EXIT leaves. Actual key mappings vary by radio. A normal widget tile is intentionally idle. The same core is used in both contexts.

## Measurement plan
Record exact radio, firmware version, display resolution, tool/widget mode, detail level, rate, FPS, worst callback gap (ms), drawn lines and physics steps/s. For repeatability first measure the identical stationary spawn camera (paused) for 30 seconds at each detail level, then measure a manual flight. The radio timer is 10 ms resolution; FPS measures draw callbacks, not the panel's physical refresh or input latency. The browser's 95th interval is different from the radio's maximum gap. Do not claim the two numbers are directly comparable. Fixed-step physics runs inside available callbacks, not an independent thread. No claim of exceeding EdgeTX scheduling constraints. Measure true motion-to-display latency separately with high-speed video.

## Known limitations
Original proof-of-concept, no StickTime code used. Simple quaternion body rotation, gravity, thrust, drag and ground plane; no obstacle collisions, aerodynamics validation, Betaflight Actual Rates, track timing, or validated radio compatibility. Web and radio scenes differ slightly. Browser FPS is dependent on device, display and browser scheduling. No hardware or end-to-end browser validation has been completed. No firmware modification is required or recommended.

Reference: [EdgeTX Lua widget API](https://luadoc.edgetx.org/latest/api-overview/script-types/widget-scripts/).
