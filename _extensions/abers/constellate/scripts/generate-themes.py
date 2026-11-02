"""Generate plot themes from Sass colours and brand fonts."""

from pathlib import Path
import json
import re
import subprocess

import yaml

EXT = Path(__file__).resolve().parents[1]
PLOT_ROLES = ("background", "text", "muted", "grid", "axis")


def hex_colour(channels):
    return "#" + "".join(f"{int(channel):02x}" for channel in channels.split())


def plot_colours(css):
    modes = {}
    for mode, block in re.findall(r"\.(light|dark)\s*\{([^}]+)\}", css):
        values = dict(re.findall(r"--([\w-]+):\s*([^;]+);", block))
        modes[mode] = {role: hex_colour(values[role]) for role in PLOT_ROLES}
        modes[mode]["series"] = [
            hex_colour(values["series-" + hue])
            for hue in values["series-hues"].split()
        ]
        modes[mode]["sequential"] = [
            hex_colour(values["sequential-" + end]) for end in ("low", "high")
        ]
    return modes


def generate():
    destination = EXT / "visualisation"
    compiled = subprocess.run(
        ["sass", str(EXT / "scss/visualisation-export.scss")],
        check=True,
        stdout=subprocess.PIPE, text=True, encoding="utf-8",
    )
    modes = plot_colours(compiled.stdout)
    brand = yaml.safe_load((EXT / "brand.yml").read_text(encoding="utf-8"))
    fonts = {
        role: (value["family"] if isinstance(value, dict) else value)
        for role, value in brand["typography"].items()
        if role in ("base", "headings", "monospace")
    }
    template = (destination / "matplotlib.mplstyle.template").read_text(encoding="utf-8")
    for mode, palette in modes.items():
        values = {
            **palette,
            "font_base": fonts["base"],
            "font_monospace": fonts["monospace"],
            "series": json.dumps(palette["series"]),
        }
        (destination / f"constellate-{mode}.mplstyle").write_text(
            template.format_map(values), encoding="utf-8"
        )
    (destination / "tokens.yml").write_text(
        yaml.safe_dump({"fonts": {role: fonts[role] for role in ("base", "headings")},
                        "modes": modes}, sort_keys=False), encoding="utf-8"
    )
    print("Constellate: regenerated plot themes from Sass and brand fonts")


if __name__ == "__main__":
    generate()
