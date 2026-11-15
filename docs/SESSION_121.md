# Session 121: Map-first budget workspace

## Completed
- Made the budget panel wider on larger windows while retaining a visible map; the chart and table stack on narrow panels.
- Added a fiscal summary showing annual deficit as a share of GDP where available, annual revenue, and total expenses including policy costs and interest.
- Added a direct shortcut from the budget workspace to tax controls, and clarified that category allocations are approximate.

## Validation and limitations
- Full Godot test suite passed. Actual visual review at multiple resolutions is still required; this is the first budget interface slice, not the complete redesign shown in the reference screenshots.
- The budget uses the existing simulation and approximate category crosswalk; the shortcut opens existing tax controls. Low-end hardware validation remains open.
