# Session 97: readable window scaling

## Delivered

- The content canvas adapts to window dimensions, retaining a minimum scale instead of shrinking all text with a very small restored window. The normal large-window canvas remains capped at its existing design size.
- When the available canvas is narrower than 800 units, the world map and its country panel stack vertically. Wider windows retain the side-by-side layout. Map instructions wrap and the existing scroll areas keep additional content accessible.
- The layout does not change save files or simulation behavior.

## Validation and limits

- Visually inspected a maximized Windows window and a very small restored window. Text remained legible in the restored window; the map and reference country controls were reached by scrolling. The very small window requires nested scrolling and does not show the map and panel simultaneously.
- Automated UI checks cover canvas-size calculations and existing interaction suites. Tests do not certify every DPI setting, display, or language; low-end hardware validation remains open. No player-adjustable UI scale is included yet.
- Resolves the observed small-window shrinking reported in issue #142; broader DPI and accessibility work remains future scope.
