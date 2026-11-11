# Session 75: flat world map

## Delivered

- Added a flat, equirectangular offline world map as the initial dashboard tab. Drag or use arrow keys to pan; use the wheel, plus/minus or buttons to zoom, and Home or the reset button to return to the world view. Click a geographic country or visible city marker for a selection panel. City labels are shown with zoom and use basic overlap avoidance.
- Added reproducible, checked-in Natural Earth 1:110m country and city source data, a compact conversion and a data provenance record in [map data README](../data/map/README.md). The current map has 177 geographic features and 243 places. Geography is explicitly identified as reference-only: selecting the real-world United States does not switch or configure the fictional playable country.
- Added country and city hit-testing, zoom/reset tests, reproducible data test and packaged-map loading smoke test. A Windows build was visually checked for map rendering, selection and zoom on the current machine.

## Remaining

Low-resolution polygons omit some small places, do not yet display interior holes accurately, and may render untriangulatable tiny polygons as outlines. There are no state boundaries, city detail illustrations, city search, gameplay overlays or linked country simulation yet. Disputed-boundary presentation, target-hardware profiling and broader 720p/accessibility checks remain open in issues #114–#118 and #40. This is the first map slice, not the final UI or world simulation.
