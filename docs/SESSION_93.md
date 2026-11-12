# Session 93: shared world restore

## Delivered

- Shared-world saves record the controlled country together with the existing two-country registry. The normal lab save slot and its backup retain their existing rotation and recovery behavior.
- The main screen provides reviewed restore actions for the shared save and its backup. A restore pauses both clocks, validates the saved world and country, and replaces both current sessions only after confirmation. It does not write a save.
- The review is rejected if either live session or the saved world changes before confirmation. Cancel leaves both sessions intact. Pending decision reviews are cleared when a restore succeeds.
- Older lab saves remain readable. If they do not contain controlled-country metadata, load them in World Lab and enter shared mode manually; then save again to enable direct shared restore.

## Validation and limitations

- Automated coverage checks save and restore, cancel, stale review, invalid controlled-country metadata, old saves and retained bilateral relationships.
- This remains an experimental two-country fictional world. Single-country and lab diplomacy are still separate systems; real-world country data and low-end hardware validation remain future work.
