# Session 119: Responsive map-first controls

## Target
Make the map-first header and navigation usable at narrower window sizes, with readable deficit and an accessible side panel. Preserve map and gameplay behavior. Related: #173, #142 and #118.

## Completed
- Added a compact layout for narrower game canvases: the US deficit and approval remain visible, controls are shortened, and secondary panels plus save/load are accessible through a More menu. The map stays in the main view and the panel can still be opened and closed.
- Made panel width responsive to available space and condensed the Laws header, explanation and search row on small windows. Larger windows retain the full explanations and direct navigation. Shared-world restrictions also disable unavailable load menu options.
- Automated checks cover responsive geometry, menu navigation, map visibility and the GDP deficit label. The full Godot suite, packaged data smoke test and a standalone Windows build passed.
- Visually checked the current computer's small restored window, including the map, Laws panel and More menu. The initial breakpoint was corrected after a visual check.

## Limitations
- Very small windows still require vertical panel scrolling and are not a substitute for a full-size display. No validation was done on the provisional low-end target hardware, at every DPI setting, or with all long translations. #142 and #118 remain open.
- This changes the interface, not the underlying fixed GDP assumption or the set of implemented laws.
