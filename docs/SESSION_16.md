# Session 16: reconcile working copies

Tracking issue: https://github.com/bhavishyadash/the-global-mandate/issues/1

Establish the repository checkout as the source-controlled project, document the separate original project and provide a read-only comparison that identifies missing, extra and changed project files without overwriting either copy. Verify the comparison against known matching and differing files, then document how to open the tracked project in Godot.

## Result

- `tools/compare_projects.py` reports differences without modifying either project.
- The repository is the preferred project to open; the original remains untouched.
- Tests passed for matching, changed, missing, extra and ignored cache files.
- The real comparison reported a different `.gitignore` and the repository-only comparison test. Generated files, documentation and tools are intentionally excluded from comparison.
