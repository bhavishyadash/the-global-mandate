# Session 25 — spending decision preview

Related to issues #12 and #45. Show a non-mutating preview of the fiscal balance and daily treasury change for the selected annual spending amount. Validate the preview against the applied decision, including invalid inputs and leap years. The broader public services and dashboard issues remain open.

## Result

The spending selector shows the projected annual balance and daily treasury change before applying the value. The preview uses the same input limits as the decision, does not mutate country state and uses the current year's day count. Tests compare preview to application and cover invalid inputs and a leap year. Both Godot headless suites passed locally. Services, employment and public opinion are explicitly not modeled by this spending control; visual playtesting remains outstanding.
