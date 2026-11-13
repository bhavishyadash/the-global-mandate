# Session 118: Map-first interface and US startup

## Target
Keep the world map visible while other controls are open, replace the scroll-heavy outer dashboard with compact navigation, start in the US sandbox, and retain map interaction and save compatibility. Related: #171.

## Completed
- The main view starts with the interactive world map; dashboards open in a collapsible right-side panel over the map. Laws and Budget have direct buttons, and the other panels remain available through the selector. Clicking a country with the panel closed opens its map inspector.
- Removed the outer page scrollbar. The law list grows with its rows so the enclosing panel provides the vertical scroll, and applicable editors appear above the list. The catalogue keeps two wider columns for names and status.
- A fresh UI session now starts the US sandbox, showing the 6.04% of GDP annual deficit. World simulation defaults used by standalone tests are unchanged. Old saves still retain their own scenarios and financial values when loaded.
- Tested startup, panel toggling, map visibility for every panel, shortcuts, law interactions, packaged data and the Godot regression suite. Visually inspected the map and side panel in a Windows build.

## Limitations
- This is a functional map-first prototype, not a finished HOI4-quality interface. Several panels still contain prototype controls and long content; the side panel scrolls where necessary, and 3D military assets are not implemented.
- US GDP is still fixed, and most laws, policy consequences, UI assets and real-world systems remain unfinished. Target low-end hardware testing is open.
