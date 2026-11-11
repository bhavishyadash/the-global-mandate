# Session 83: US map sandbox

## Delivered

- Added an explicitly fictional US sandbox linked to the Natural Earth USA map feature. Its population, finances, parties and behavior are copied from the fictional Federal Republic test scenario. These are placeholders, **not US statistics or a calibrated US model**.
- Selecting the US or one of its mapped cities exposes **Start US sandbox**. Confirmation names the scenario and warns that it replaces the current session. Cancel leaves the world unchanged. The Overview scenario picker can also start the sandbox.
- When the US sandbox is active, the map panel shows live fictional population, approval, cash and annual balance, and offers **Open government**. Values update after decisions and day advances. Other countries are reference-only.
- The binding checks both scenario and country identity. Save/load preserves the scenario; older saves remain supported. The packaged export check loads the sandbox.
- Added tests for selection, confirmation/cancellation, live values after a tax decision, Government navigation, JSON save/load, switching away and unsupported countries.

## Limits and next work

This is one playable, single-country sandbox over reference geography, not a multi-country world. The experimental world registry is not wired into the playable UI. City markers have no city-level simulation. Existing single-chamber and US-inspired bicameral governing paths remain separate prototypes. No real-world population, fiscal, demographic, party or law dataset is implied. Low-end hardware testing remains open.

Next: design a country-to-scenario registry and multi-country save and time integration, then introduce researched, dated and sourced US data and realistic institutions incrementally. Distinguish missing information from known values throughout.
