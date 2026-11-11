"""Run the Godot headless checks with bounded execution time."""
from __future__ import annotations

import argparse
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CASES = (
    ("res://tests/simulation_test.gd", "Simulation checks passed"),
    ("res://tests/ui_test.gd", "UI interaction checks passed"),
    ("res://tests/integration_test.gd", "Integrated scenario checks passed"),
    ("res://tests/replay_test.gd", "Replay checks passed"),
    ("res://tests/stress_test.gd", "Long-run stress checks passed"),
)


def run_command(command: list[str], timeout: float, marker: str) -> tuple[bool, str]:
    try:
        result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True,
                                errors="replace", timeout=timeout, check=False)
    except subprocess.TimeoutExpired:
        return False, f"Timed out after {timeout:g} seconds."
    except OSError as exc:
        return False, f"Could not start the test: {exc}"
    output = result.stdout + result.stderr
    passed = result.returncode == 0 and marker in output and "SCRIPT ERROR" not in output
    return passed, output.strip() or f"Process exited with code {result.returncode}."


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", required=True, help="Path to a Godot 4.7 console executable")
    parser.add_argument("--timeout", type=float, default=30.0, help="Seconds per test")
    args = parser.parse_args()
    if not 0 < args.timeout <= 3600:
        parser.error("--timeout must be greater than 0 and at most 3600 seconds")
    success = True
    # Godot writes logs even in headless mode. Keep test logs in an isolated,
    # temporary project subdirectory rather than modifying user logs.
    with tempfile.TemporaryDirectory(prefix="godot-tests-", dir=ROOT) as tmp:
        for index, (script, marker) in enumerate(CASES):
            log = str(Path(tmp) / f"{index}.log")
            ok, output = run_command([args.godot, "--headless", "--path", str(ROOT),
                                      "--log-file", log, "--script", script], args.timeout, marker)
            print(f"{'PASS' if ok else 'FAIL'} {script}\n{output}", flush=True)
            success = success and ok
    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())
