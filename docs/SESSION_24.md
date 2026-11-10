# Session 24 — tax decision preview

Related to issues #11 and #45. Add a non-mutating preview of the current prototype's tax decision, showing the projected annual revenue and group approval outcomes before applying it. Verify that preview and application agree and that previews do not change game state. The broader economic and UI issues remain open.

## Result

The tax selector now displays projected annual revenue, national approval and group approvals under the existing fictional immediate model. The simulation computes the preview using a separate political-state copy; tests verify the original country and political state remain unchanged and the predicted results match the applied policy. Invalid rates return no preview. Godot headless simulation and UI checks passed locally. This is not an economic forecast, and the current simplified model and visual layout still need further work.
