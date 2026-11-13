# Session 122: Map redraw and budget display fixes

- Corrected UI scaling so the map and budget fit in a 1600 x 900 window.
- Redraw the map after resize and skip rendering for near-zero sizes, removing the observed map errors.
- Initialize budget and category proposals to the scenario's actual values after applying the correct limits; widened inputs to show those values.
- The complete Godot suite passed; a running 1600 x 900 screenshot was checked. Other resolutions and target hardware still need validation.
