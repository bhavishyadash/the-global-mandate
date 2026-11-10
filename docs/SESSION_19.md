# Session 19 — protect backup rotation

Related to issue #4. Preserve the previous backup until the old primary has been successfully moved aside and the new primary installed. Test rollback scenarios and document remaining crash-consistency limitations. Open the PR before implementation and leave the broad issue open until its full criteria are met.

## Result

Rotation moves the existing backup to `.bak.previous` before moving the primary; it attempts to restore files if a later rename fails. A pre-existing `.bak.previous` blocks the next rotation instead of being silently overwritten. Automated tests verify normal rotation and refusal to overwrite a simulated leftover backup, along with existing corrupt-primary recovery checks. They do not inject filesystem errors at every rename or simulate a process crash, and restoration can still fail; manual recovery may be required. Issue #4 remains open.
