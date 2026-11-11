# Session 48: deterministic replay and benchmark

`simulation/replay.gd` runs ordered, day-indexed decisions against an isolated validated scenario, bounded to 3,660 days and 1,000 actions. It returns the resulting world on success or the failing decision on error; it does not mutate the supplied scenario or an existing game. Repeating the same test scenario and commands produced identical country, politics, service, institution, diplomacy, ledger and event state. The current simulation is deterministic and has no random seed; future stochastic systems will need an explicitly persisted generator and replay contract.

`tools/benchmark.gd` measures initialization and 30 daily ticks for independent copies of the fictional test country. One local run on Windows, Godot 4.7.2, AMD64 Family 25 Model 17 (CPU model and RAM not established) produced:

| Independent copies | Initialization | 30 ticks | Simulated world-days/s |
|---:|---:|---:|---:|
| 1 | 1.287 ms | 0.561 ms | 53,476 |
| 50 | 48.164 ms | 22.592 ms | 66,395 |
| 200 | 174.375 ms | 94.908 ms | 63,219 |

This is a single unoptimized headless measurement, not a coupled 200-country simulation, frame-rate test, low-end hardware guarantee or stable performance target. Run with `godot --headless --path . --script res://tools/benchmark.gd`. Replay tests are included in the bounded test runner and CI.
