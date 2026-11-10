import importlib.util
import sys
import unittest
from pathlib import Path

MODULE = Path(__file__).resolve().parents[1] / "tools" / "run_tests.py"
spec = importlib.util.spec_from_file_location("run_tests", MODULE)
runner = importlib.util.module_from_spec(spec)
spec.loader.exec_module(runner)


class RunnerTests(unittest.TestCase):
    def test_pass_requires_marker_and_zero_exit(self):
        self.assertTrue(runner.run_command([sys.executable, "-c", "print('PASS')"], 5, "PASS")[0])
        self.assertFalse(runner.run_command([sys.executable, "-c", "print('other')"], 5, "PASS")[0])
        self.assertFalse(runner.run_command([sys.executable, "-c", "print('PASS'); exit(2)"], 5, "PASS")[0])

    def test_timeout_is_failure(self):
        ok, message = runner.run_command([sys.executable, "-c", "import time; time.sleep(2)"], 0.1, "PASS")
        self.assertFalse(ok)
        self.assertIn("Timed out", message)


if __name__ == "__main__":
    unittest.main()
