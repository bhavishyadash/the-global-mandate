# Session 74: foundation performance benchmarks

## Delivered

Established provisional minimum and recommended planning profiles and measurable targets for frame pacing, simulation speed, save/load, memory and startup. Added a headless playable-dashboard scheduler/save benchmark and a graphical 1280×720 frame-interval benchmark; both use explicit fictional workloads and avoid the player's save slot. The existing headless registry benchmark measures the synthetic multi-country workload.

Local results, commands, metrics and limitations are in [performance targets](PERFORMANCE_TARGETS.md). One local graphical run achieved p95 3.268 ms at 720p on a dedicated RTX 2000 Ada GPU while cycling tabs; the 200-country synthetic headless p95 was 6.057 ms. These values do not validate the provisional low-end integrated-graphics hardware. Process-wide peak memory, interactive startup timing, broader UI playtesting and future fully populated-world benchmarks remain open.
