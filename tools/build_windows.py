"""Export and headlessly smoke-test a Windows development build."""
from __future__ import annotations

import argparse
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parent.parent


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--godot", required=True, help="Path to the Godot 4.7.2 console executable")
    parser.add_argument("--output", required=True, help="Empty output directory for the build")
    args = parser.parse_args()
    if os.name != "nt":
        print("Windows build smoke test requires Windows.")
        return 1
    out = Path(args.output).resolve()
    out.mkdir(parents=True, exist_ok=True)
    exe = out / "TheGlobalMandate.exe"
    pck = out / "TheGlobalMandate.pck"
    if exe.exists() or pck.exists():
        print("Build files already exist; choose an empty output directory.")
        return 1
    godot = str(Path(args.godot).resolve())
    try:
        with tempfile.TemporaryDirectory(prefix="windows-build-check-", dir=ROOT) as tmp:
            temporary = Path(tmp)
            env = os.environ.copy()
            env["TMP"] = env["TEMP"] = str(temporary)
            build = subprocess.run([godot, "--headless", "--log-file", str(temporary / "export.log"),
                                    "--path", str(ROOT), "--export-release", "Windows Development", str(exe)],
                                   cwd=ROOT, env=env, capture_output=True, text=True, errors="replace", timeout=180)
            output = build.stdout + build.stderr
            if build.returncode or "ERROR:" in output or not exe.is_file() or not pck.is_file():
                raise RuntimeError(f"Export failed ({build.returncode}):\n{output}")
            log = temporary / "startup.log"
            startup = subprocess.run([str(exe), "--headless", "--quit-after", "5", "--log-file", str(log)],
                                     cwd=out, env=env, capture_output=True, text=True, errors="replace",
                                     timeout=60, creationflags=subprocess.CREATE_NO_WINDOW)
            logs = log.read_text(encoding="utf-8", errors="replace") if log.exists() else ""
            if startup.returncode or not logs or "ERROR:" in logs or "SCRIPT ERROR" in logs:
                raise RuntimeError(f"Standalone startup failed ({startup.returncode}):\n{logs}\n{startup.stderr}")
    except (OSError, subprocess.TimeoutExpired, RuntimeError) as exc:
        print(f"Build verification failed: {exc}")
        return 1
    print(f"Windows build exported and started headlessly: {exe}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
