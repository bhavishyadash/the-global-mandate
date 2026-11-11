# Session 69: bounded simulation speed

## Delivered

The playable scheduler processes at most 30 simulated days or approximately 8 ms of day-tick work per frame, whichever limit is reached first. At least one pending day is processed even when an individual tick takes longer than the budget. Unprocessed days are retained, displayed as a backlog and resumed on later frames; pausing preserves the backlog. New scenario and load behavior continues to clear the old backlog.

The budget is a cooperative limit checked between whole ticks. A single slow tick and UI refresh are not preempted, so this is not a frame-rate guarantee. The headless UI test forces a zero budget to prove one-day progress, queued time, pause and later catch-up; other suites exercise dates, rollover and long runs. The current playable screen runs one country; the multi-country benchmark remains a synthetic, headless workload rather than proof of frame rate under a future coupled game.

Nine Godot suites pass locally. Target-hardware and graphical frame-time measurements remain open.
