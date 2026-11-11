# Session 84: scenario-linked map layers

## Delivered

- Moved the US map association into a versioned [map binding catalogue](../data/map/scenario_bindings.json). Each entry explicitly identifies the geography, built-in scenario, scenario country ID and display name. The catalogue validates map IDs, unique bindings and referenced scenario contents before any associations are used; invalid data disables links with a visible explanation.
- Added a **sandbox availability** map layer: gold means a sandbox can be started, teal means the current single-country simulation is that sandbox, and slate means geographic reference only. Selection and hover still work; the original geography layer remains available.
- Availability and active status update on scenario start, load and other screen refreshes. The US sandbox remains the only linked entry, and its values remain fictional. The existing save format is unchanged.
- Added checks for missing or duplicate IDs, mismatched country identity, layer colors, starting and leaving the US sandbox, and packaged binding data.

## Limits and next work

The binding catalogue is a map-to-single-scenario lookup, not the separate experimental multi-country world registry. No other country is simulated and the layer is not a political, economic or diplomatic assessment. City-level simulation remains unimplemented; country geometry is simplified and low-end hardware validation is still open.

Next, connect the experimental synchronized multi-country registry to a safe player workflow with isolated world saves and tested time advancement, then add appropriately sourced country data and useful, clearly labeled layers.
