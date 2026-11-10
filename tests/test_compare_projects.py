import importlib.util
import tempfile
import unittest
from pathlib import Path

MODULE = Path(__file__).resolve().parents[1] / "tools" / "compare_projects.py"
spec = importlib.util.spec_from_file_location("compare_projects", MODULE)
compare_projects = importlib.util.module_from_spec(spec)
spec.loader.exec_module(compare_projects)


class CompareTests(unittest.TestCase):
    def test_equal_changed_extra_missing_and_ignored(self):
        with tempfile.TemporaryDirectory() as temp:
            left, right = Path(temp) / "left", Path(temp) / "right"
            left.mkdir()
            right.mkdir()
            (left / "project.godot").write_text("same")
            (right / "project.godot").write_text("same")
            self.assertEqual(compare_projects.compare(left, right), [])
            (left / "changed.gd").write_text("one")
            (right / "changed.gd").write_text("two")
            (left / "left.gd").write_text("left")
            (right / "right.gd").write_text("right")
            (right / ".godot").mkdir()
            (right / ".godot" / "cache").write_text("ignored")
            self.assertEqual(compare_projects.compare(left, right), [
                ("Different", "changed.gd"),
                ("Only in repository", "left.gd"),
                ("Only in other", "right.gd"),
            ])


if __name__ == "__main__":
    unittest.main()
