# Prototype performance targets and benchmarks

These are provisional engineering targets for the **current prototype**, not a promise for the eventual fully populated game. They will be revised when country data, AI, map rendering and other major features exist. No minimum-hardware pass is claimed until it is measured on the target device.

| Profile | Provisional design baseline |
|---|---|
| Minimum | Windows laptop, 4 CPU cores, 8 GiB RAM, integrated graphics, 1280×720 display. This is the director's selected baseline; the exact processor and graphics model remain unspecified. |
| Recommended | Working assumption: Windows PC with 6 CPU cores, 16 GiB RAM, graphics supporting the chosen Godot renderer, and a 1920×1080 display. This is a planning baseline, not a measured recommendation or finalized system requirement. |

| Metric | Provisional target on minimum hardware | Workload / qualification |
|---|---|---|
| Interactive frame pacing | At least 30 mean FPS and p95 frame interval no more than 33.3 ms | Graphical `benchmark_display.gd`, 1280×720, 60-frame warm-up and 10-second sample, cycling tabs once per second while the current single-country dashboard runs at 5 simulated days/second. Frame intervals are engine-loop intervals, not display presentation latency. |
| Simulation rate | Complete at least 50 simulated days during that 10-second sample, without a backlog above five days | Same graphical workload; dates advance with fractional frame time and warm-up can contribute a partial day. |
| Coupled simulation | p95 day tick no more than 50 ms | `benchmark_registry.gd`, 200 synthetic countries, 365 days, neighboring dialogues; headless and not yet integrated into the UI. This is not a fully populated world model. |
| Save and load | Each no more than 1 second | Single-country workload in `benchmark_foundation.gd`, after 50 simulated days; excludes user file selection. Storage and filesystem affect results. |
| Memory | Engine static allocation no more than 256 MiB in the headless benchmark; whole-process peak working set goal no more than 1.5 GiB | Engine static allocation excludes some process/GPU memory. Whole-process peak must be measured separately using platform tools; neither is a guarantee for later game content. |
| Startup | Reach an interactive dashboard within 10 seconds | Cold standalone launch timed externally; no minimum-hardware measurement yet. A headless launch-and-exit baseline is useful but is not equivalent. |

## Reproduce

Run from the project root with Godot 4.7.2 console. Close unrelated heavy workloads and report hardware, OS, power mode, renderer, build/commit, number of runs and whether profiling or capture is active. Do not compare these results with target-device requirements without noting hardware differences.

```text
godot --headless --path . --script res://tools/benchmark_foundation.gd
godot --headless --path . --script res://tools/benchmark_registry.gd
godot --path . --script res://tools/benchmark_display.gd
```

The foundation benchmark creates a temporary test save only if its designated path is free and refuses to overwrite it. It verifies the round trip and removes that test save on success. The display benchmark opens a 1280×720 game window and exits after the sample; it does not use the player's save slot. If a run fails, inspect any named test artifact before moving or removing it. The benchmarks report samples, not pass/fail for untested hardware.

## Local baseline — session 74

One run on Windows, Godot 4.7.2, AMD EPYC 9354 environment exposing 4 cores / 8 threads, 16 GiB RAM, NVIDIA RTX 2000 Ada Generation, D3D12 Forward+. The machine has a dedicated GPU and is **not** the selected low-end integrated-graphics laptop.

- Graphical 720p run: 8,744 sampled frame intervals over 10.00 seconds with 10 tab changes; mean 1.144 ms, p95 3.268 ms, maximum 13.115 ms, estimated mean 874.4 engine frames/s. The simulation reached 51 days including warm-up and had 0.59 day queued at exit. Display refresh and human-perceived responsiveness were not measured.
- Headless playable UI workload: initialization 134.385 ms; 600 scheduler calls / 50 simulated days; p95 call 0.413 ms, maximum 0.696 ms; save 7.802 ms, load 2.907 ms; engine static allocation 61.99 MiB. This excludes graphical rendering and is not whole-process memory.
- Headless 200-country registry: 365 days, 995 neighboring dialogues; p95 tick 6.057 ms, maximum 9.030 ms. Synthetic countries share simplified rules and do not include trade, map rendering or real-world AI.
- Headless process launch and one-frame exit took 533 ms in a separate single run. That includes shutdown and is not an interactive startup measurement.

These isolated single runs are baselines for regression investigation, not statistical hardware certification. The director deferred testing on the provisional low-end laptop; graphics, memory and startup results on that machine remain unknown.
