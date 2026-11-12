# Session 98: small-window UI size preference

## Delivered

- Added a Small-window UI selector with Compact, Standard and Large choices. It adjusts the minimum interface scale in smaller windows; larger windows keep the existing base layout when it already provides enough scale.
- The preference is stored independently in `user://ui_preferences.cfg`. A missing or invalid value falls back to Standard. A selection is applied immediately and saved; write failures are shown in the status message. An unreadable existing settings file is not deliberately overwritten.
- The existing narrow-window stacked map layout responds to the selected canvas size. Simulation and game save data are unaffected.

## Validation and limits

- Automated UI checks cover default, valid and invalid preference values, saving and rejected indexes, and the resulting canvas dimensions.
- This setting has not been visually validated across different monitors, DPI configurations, or languages. Very small windows may still require nested scrolling. Issue #142 remains open for broader DPI and accessibility validation and low-end hardware testing.
