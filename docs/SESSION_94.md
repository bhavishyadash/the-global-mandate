# Session 94: shared-world diplomacy on the map

## Delivered

- The World Map sidebar displays the shared registry's relationship, current talks, remaining agreement duration and fictional rules for dialogue and cooperation.
- Selecting the US map or one of its cities selects its simulated country. A separate country selector includes the fictional Coastal Republic, which has no geographic location; other map countries remain reference only.
- Players review talks before opening them, and can cancel active talks. Starting a review pauses the clock; changed world state, selected country or proposal invalidates the review. The main clock advances talks and World Lab displays the same live state.
- The Diplomacy tab links to the shared map panel while in shared mode; legacy single-country controls are hidden and guarded to avoid changing a separate diplomacy system accidentally.

## Validation and limitations

- UI tests exercise map bindings, unmapped selection, self-selection guard, review cancellation and staleness, shared talks, cancellation, clock progress, relationship completion and legacy-mode restoration.
- The model is still fictional and limited to two countries. Cooperation uses existing test rules, not realistic diplomatic AI. There is no invented map location for Coastal Republic. The single-country diplomacy model remains separate outside shared mode.
