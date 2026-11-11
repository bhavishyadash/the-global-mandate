"""Export a temporary resource pack and run its scenario from an empty folder."""
from __future__ import annotations

import argparse
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parent.parent


def checked(command: list[str], cwd: Path, env: dict[str, str], marker: str | None = None) -> None:
    result = subprocess.run(command, cwd=cwd, env=env, capture_output=True, text=True,
                            errors="replace", timeout=120, check=False)
    output = result.stdout + result.stderr
    if result.returncode or "ERROR:" in output or (marker and marker not in output):
        raise RuntimeError(f"Command failed ({result.returncode}):\n{output}")
    print(marker or "Resource pack exported", flush=True)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--godot", required=True, help="Path to the Godot 4.7 console executable")
    args = parser.parse_args()
    godot = str(Path(args.godot).resolve())
    try:
        with tempfile.TemporaryDirectory(prefix="export-check-", dir=ROOT) as temporary:
            temp = Path(temporary)
            pack = temp / "game.pck"
            env = os.environ.copy()
            env["TMP"] = env["TEMP"] = str(temp)
            checked([godot, "--headless", "--log-file", str(temp / "export.log"),
                     "--path", str(ROOT), "--export-pack", "Windows Development", str(pack)], ROOT, env)
            # An empty working directory ensures source files cannot mask a missing asset.
            checked([godot, "--headless", "--log-file", str(temp / "smoke.log"),
                     "--main-pack", str(pack), "--script", "res://tools/export_smoke.gd"], temp, env,
                    "Packaged scenario checks passed")
    except (OSError, subprocess.TimeoutExpired, RuntimeError) as exc:
        print(f"Export verification failed: {exc}")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
