# Session 18 — protect save recovery

Related issue: https://github.com/bhavishyadash/the-global-mandate/issues/4

Review and harden the single-slot save and backup rotation. In particular, loading a backup after a corrupted primary must not cause the next save to replace the good backup with the corrupted primary. Test the recovery path and document any remaining gaps. This is a partial step toward issue #4, which remains open until all acceptance criteria are met.

## Result

The current primary is validated using a separate world instance before rotating it into the backup. Invalid or unsupported primary data is preserved as `.invalid` while an existing backup is retained. If an `.invalid` file already exists, saving fails with a message rather than overwriting it. A regression test verifies that saving after a corrupt primary preserves the prior valid backup; the existing round-trip and UI tests also pass. Remaining work includes interrupted-write/failure-injection coverage and stronger backup rotation guarantees; in particular, a failed rename after removal of an older backup is not yet fully transactional.
