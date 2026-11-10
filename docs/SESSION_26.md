# Session 26 — scheduled test elections

Related to issue #26. Replace unrestricted manual election calls with a fictional four-year election schedule. Explain the next election in the interface, prevent duplicate calls and preserve schedule behavior for existing saves. This remains a simplified test election, not a realistic country-specific electoral system.

## Result

The prototype automatically holds elections on January 1 every four years starting in 2030. The next year is derived from the saved date, so no save schema change is needed. Existing saves continue from their saved date; missed elections before that date are not retroactively simulated. Tests cover the first election, no duplicate on the next day, the next scheduled year, UI display and saving/loading immediately before and after an election. Local Godot simulation and UI checks passed. The voting and seat allocation are still placeholders, and election dates are not country-specific.
