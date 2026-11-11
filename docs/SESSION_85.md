# Session 85: multi-country laboratory

## Delivered

- Added a **World Lab** tab for the existing synchronized registry. It starts an independent world containing the fictional US sandbox and fictional Coastal Republic. Both advance together using the lab's manual day control.
- Select either country, inspect its fictional fiscal and approval data, and apply an income tax change to that country only. Open a bilateral dialogue, track its 30-day progression and see its relationship change.
- The lab uses `experimental_world_save.json`, a different slot from the main game's `prototype_save.json`. Loading asks before replacing the current lab state, validates the candidate and checks country/scenario identity before accepting it. The main game and map remain independent of the lab.
- Added a dedicated test covering independent tax changes, shared time, diplomacy, save/load, invalid world rejection, and a UI check that lab time does not change the main simulation. The export smoke test verifies that both packaged countries advance.

## Limits and next work

This is an experimental manually advanced test world, not a complete playable global simulation. It has two fictional countries and one simple relationship, not real diplomacy, trade or military systems. The lab is not connected to map selection, main-game policy tabs, the main clock or the main save. Its data is fictional; the US sandbox is not calibrated US data. There is no in-game lab-backup loader; recovery is manual. Low-end hardware remains untested.

Next, design explicit country switching and an integrated world clock and map, with a migration-safe save architecture and clear separation between view selection and the player's controlled country. Expand diplomacy and real-world data only when their models and provenance are ready.
