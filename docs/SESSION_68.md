# Session 68: structured diagnostics

## Delivered

Bounded event records now include a stable cause identifier and info, warning or error severity. Existing built-in actions assign cause IDs; historical saves migrate old records with `legacy_unknown` causes and informational severity. Save format 17 validates the new fields and preserves the original event text and dates. Category filters and old save versions remain supported.

The History tab provides an optional reproduction-steps field and an explicit local JSON report export. Reports contain prototype and engine versions, save format, scenario ID, seed and RNG state, date, entered steps, and bounded event dates/categories/causes/severities. They omit event text, system identifiers and local file paths; entered steps may contain anything the player types and should be reviewed before sharing. Reports are not sent anywhere automatically and existing filenames are not overwritten. They do not automatically capture player decisions or contain an initial scenario; the separate headless replay recorder can capture those when all operations use its API.

Nine Godot suites pass locally, including structured-event validation, old-save migration, local report round trip, privacy fields and existing-file protection. The report is an aid for reproduction, not a complete automatic replay or a substitute for a player describing steps.
