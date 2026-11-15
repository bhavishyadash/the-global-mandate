# Session 125: Satellite terrain map

- Added a lightweight offline Blue Marble satellite-derived terrain texture under the existing interactive flat world map. Country borders, city markers, selection highlighting and scenario layers remain available.
- Verified the global view at 1600 x 900, ran the full Godot suite, and passed the resource pack export and packaged scenario checks.
- The image is a historical global composite, not live imagery. Its 3840 x 1920 resolution limits detail at close zoom and coastlines can differ slightly from Natural Earth polygons. Low-end hardware performance has not been measured.
- Asset source and provenance are recorded in data/map/README.md.
