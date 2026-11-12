# Session 87: lab time controls

## Delivered

- World Lab has an independent run/pause clock with 1, 3 and 10 simulated days per real second, a single-day step, and a cancellable 30-day advance. Both lab countries advance together.
- Work is limited to ten lab days or approximately eight milliseconds per frame, whichever threshold is reached after at least one day. Remaining days are shown; no frame-rate guarantee or low-end device measurement is implied.
- While a 30-day advance is processing, country decisions and save/load are disabled so they cannot accidentally take effect halfway through. Cancelling retains days already simulated and stops the remainder. Pausing the continuous clock retains any queued time; the lab continues running on other tabs until paused.
- Opening either load confirmation pauses the lab and clears its queued and pending days, even if the load is cancelled. A successful load also starts paused. Scheduling state is not stored in the world save. The main game's clock, state and saves remain separate.
- Added checks for per-frame batch limits, cancellation, exact 30-day advancement, both-country synchronization, continuous running and pausing.

## Limits and next work

The lab still has two fictional countries, a basic dialogue model and an independent map and clock. It is not yet the main playable multi-country game. Time limits are cooperative and do not interrupt a single expensive tick. Target-device performance remains unverified.

Next: build an integrated country-control and world-clock workflow with explicit migration and save validation, then broaden political and diplomatic decision depth using data-backed rules.
