# Session 18 — protect save recovery

Related issue: https://github.com/bhavishyadash/the-global-mandate/issues/4

Review and harden the single-slot save and backup rotation. In particular, loading a backup after a corrupted primary must not cause the next save to replace the good backup with the corrupted primary. Test the recovery path and document any remaining gaps. This is a partial step toward issue #4, which remains open until all acceptance criteria are met.
