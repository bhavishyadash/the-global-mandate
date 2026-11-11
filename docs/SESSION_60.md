# Session 60: multi-country persistence and performance

The headless registry can now save/load its version-1 JSON snapshot, validate the new file before replacement, retain a previous backup, preserve an invalid primary for recovery, refuse an existing temporary file, and attempt rollback on rename failures. Tests save during bilateral talks, reload from primary and backup, and verify invalid candidate state and an existing temporary file do not overwrite prior data. This is separate from the playable single-country save; filesystem fault injection and crash safety remain unproven.

Added `tools/benchmark_registry.gd`: fictional copies with unique IDs run for 365 simulated days, with neighbor dialogues started every 90 days. One local headless run on Windows/Godot 4.7.2, AMD64 Family 25 Model 17, gave:

| Countries | Dialogues started | Initialization | 365 ticks | Average tick |
|---:|---:|---:|---:|---:|
| 2 | 5 | 3.264 ms | 11.267 ms | 0.031 ms |
| 50 | 245 | 73.389 ms | 283.922 ms | 0.778 ms |
| 200 | 995 | 276.099 ms | 1302.541 ms | 3.569 ms |

This measures a single run on the current machine, not the provisional low-end laptop. Countries are copies with no geography, trade, AI or complex interactions; dialogues use simplified rules, and some started on day 360 are still in progress. It does not measure rendering, frame pacing, p95 latency, memory, loading real-world data or future feature costs. It is a starting measurement, not a performance guarantee.
