# Session 22 — continuous integration

Related to issue #8. Add a GitHub Actions workflow that runs the headless Godot simulation and UI checks and Python utility tests on pull requests and pushes. Pin the engine version, bound execution and verify the workflow on this PR. Keep the issue open if hosted execution cannot be verified.

## Implementation

Added a Linux GitHub Actions job using Godot 4.7.2 with a pinned SHA-256 checksum and a commit-pinned checkout action. It imports assets, runs Python utility tests and the timeout-protected Godot suites. The job has a 10-minute limit. The hosted run on PR #60 is the authoritative CI verification; this workflow does not cover Windows-specific or visual testing.
