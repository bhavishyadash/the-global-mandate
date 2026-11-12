# Session 100: keyboard map search

## Delivered

- Map search accepts country and city names and exact country codes. Players can filter the results to all places, countries, or cities.
- Results prioritize exact matches, then prefixes, then other name matches, with countries before cities at the same rank and alphabetical ordering within each group. The list remains limited to 30 displayed results and reports the full match count.
- Pressing Enter in the search field opens the first result. An empty result list leaves the map selection unchanged. The map tooltip explains existing keyboard panning, zoom, and reset keys.
- Search still uses offline reference geography. Search results do not imply that a country has a playable simulation.

## Validation and limits

- Automated UI checks cover name search, exact country code, country/city filtering, Enter activation, no-result behavior, and existing map selection interactions.
- Full keyboard-only and assistive-technology navigation, localization, multi-DPI visual testing, and low-end hardware validation remain future work; issue #142 remains open.
