# Session 66: reproducible simulation records

## Delivered

`simulation/replay_record.gd` provides an isolated recorder for a complete validated scenario, its schema version and effective seed, ordered decisions including their outcome codes, and elapsed days. The detached record is JSON-compatible. `reproduce` validates limits and ordering, applies the embedded scenario, repeats each action and verifies its outcome. Actions on the final day and failed votes that generate history are retained. Tests serialize through JSON and compare the complete resulting world snapshot; malformed records and changed outcomes are rejected.

The recorder is a headless API: the playable UI does not yet automatically capture a session or provide export. It only records actions and days routed through it; direct state mutation and external random calls are not recorded. Simulation code and scenario behavior must match when reproducing a record; the format is not a promise of cross-version compatibility. Recordings are local data and are never transmitted automatically. These limits remain relevant to issue #7's player-facing diagnostic facility.
