"""Export all or specified slides as dark/light standalone HTML files with embedded resources."""

from pathlib import Path
import subprocess
import sys

root = Path(__file__).resolve().parent
command = [
    sys.executable,
    str(root / "_extensions/abers/constellate/scripts/render-slides.py"),
    "--embed-resources",
    "--output-dir",
    str(root / "slides-export"),
    *sys.argv[1:],
]
subprocess.run(command, cwd=root, check=True)
