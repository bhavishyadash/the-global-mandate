# Session 23 — stable tax-opinion prototype

Related to issue #20. Investigate and fix approval drift caused by repeated tax changes and clamping, while preserving existing saves and the expected initial 20%-to-60% example. Document the test model and its limitations; keep the broader population-reaction issue open.

## Result

Each fictional group now retains an unclamped internal approval value while the displayed value remains within 0–100%. Reversing a tax change therefore recovers the pre-change value even when the visible value hit a boundary. Save format 3 preserves this internal value; version 1 and 2 saves migrate by initializing it from visible approval, so any historical clipped amount cannot be recovered. Tests cover reversal across a boundary, saving while clipped, version-2 migration, and the initial 60% tax example. This is still an immediate linear test model, not a realistic theory of public opinion.
