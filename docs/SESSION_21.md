# Session 21 — reliable test invocation

Related to issue #8. Provide one repeatable headless test command with a timeout and clear failure status so a failed assertion cannot leave the test process running indefinitely. Preserve the existing Godot test scripts. The CI issue remains open until an actual CI workflow is implemented and verified.
