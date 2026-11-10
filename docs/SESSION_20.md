# Session 20 — responsive simulation pacing

Related to issue #6. Bound the number of simulation days processed in a single rendered frame, preserve remaining elapsed time, and test pause, speed changes and long frame delays. The issue remains open for representative full-world benchmarking and additional performance work.

## Result

The UI processes at most 30 simulated days per frame and retains any additional elapsed simulated time for later frames. Pausing stops both processing and accumulation; changing speed does not alter an existing backlog. Loading a save continues to clear the pending UI time. Headless simulation and UI checks passed, including a two-second frame at 30 days per second followed by pause, speed change and catch-up. This prevents unbounded work in one frame, but does not guarantee a target frame rate or provide full-world performance measurements.
