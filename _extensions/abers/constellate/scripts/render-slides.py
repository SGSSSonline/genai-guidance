"""Render both colour variants of Quarto RevealJS decks."""

import argparse
import json
import os
from pathlib import Path
import subprocess
import sys

SLIDE_FORMAT = "constellate-revealjs"
LIGHT_PROFILE = "slides-light"
SLIDES_PROFILE = "slides"


def inspect(path, profiles):
    result = subprocess.run(
        ["quarto", "inspect", str(path), "--profile", profiles],
        capture_output=True,
        check=True,
        encoding="utf-8",
    )
    return json.loads(result.stdout)


def active_profiles():
    return [
        p
        for p in os.environ.get("QUARTO_PROFILE", "").split(",")
        if p and p != LIGHT_PROFILE
    ]


def records_for(root, sources, profiles):
    records = []
    for source in sources:
        source = Path(source).resolve()
        info = inspect(source, ",".join(profiles))
        fmt = info.get("formats", {}).get(SLIDE_FORMAT)
        if not fmt:
            continue
        output = Path(fmt["pandoc"]["output-file"])
        dark = source.parent.relative_to(root) / output
        light = dark.with_name(dark.stem + "-light" + dark.suffix)
        records.append(
            {
                "source": source.relative_to(root).as_posix(),
                "dark": dark.as_posix(),
                "light": light.as_posix(),
            }
        )
    return records


def render(root, record, variant, profiles, output_dir, embed_resources=False):
    source = root / record["source"]
    args = [
        "render",
        source.name,
        "--no-clean",
        "--to",
        SLIDE_FORMAT,
        "--output-dir",
        str(output_dir),
    ]
    if embed_resources:
        args.append("--embed-resources")
    selected = ([LIGHT_PROFILE] if variant == "light" else []) + profiles
    args.extend(["--profile", ",".join(selected)])
    print(f"Slides: {variant} {record['source']} -> {record[variant]}", flush=True)
    env = os.environ.copy()
    env.pop("QUARTO_PROJECT_RENDER_ALL", None)
    output_file = os.path.relpath(record[variant], Path(record["source"]).parent)
    args.extend(["--output", output_file])
    subprocess.run(["quarto", *args], env=env, check=True, cwd=source.parent)


def write_manifest(output_dir, records):
    value = (
        "window.quartoSlideVariants = " + json.dumps(records, ensure_ascii=True) + ";\n"
    )
    (output_dir / "slide-variants.js").write_text(value, encoding="utf-8")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "sources",
        nargs="*",
        help="QMD files, or omit for all inputs in the slides profile",
    )
    parser.add_argument("--post-render", action="store_true")
    parser.add_argument(
        "--output-dir", help="Directory for both dark and light slide files"
    )
    parser.add_argument(
        "--embed-resources",
        action="store_true",
        help="Embed resources in each exported slide HTML file",
    )
    options = parser.parse_args()
    if options.post_render and os.environ.get("QUARTO_PROJECT_RENDER_ALL") != "1":
        return
    if options.post_render and LIGHT_PROFILE in os.environ.get(
        "QUARTO_PROFILE", ""
    ).split(","):
        return
    profiles = active_profiles()
    profiles = [SLIDES_PROFILE] + [p for p in profiles if p != SLIDES_PROFILE]
    project = inspect(".", ",".join(profiles))
    root = Path(project["dir"]).resolve()
    configured_output = root / project["config"]["project"].get("output-dir", ".")
    output_setting = options.output_dir or os.environ.get(
        "QUARTO_PROJECT_OUTPUT_DIR", str(configured_output)
    )
    output_dir = (root / output_setting).resolve()
    inputs = options.sources or project["files"]["input"]
    sources = dict.fromkeys(Path(source).resolve() for source in inputs)
    records = records_for(root, sources, profiles)
    for record in records:
        if not options.post_render:
            render(root, record, "dark", profiles, output_dir, options.embed_resources)
        render(root, record, "light", profiles, output_dir, options.embed_resources)
    if options.post_render:
        write_manifest(output_dir, records)
        print(
            f"Slides: {len(records)} complete slide pairs in {output_dir}", flush=True
        )


if __name__ == "__main__":
    try:
        main()
    except subprocess.CalledProcessError as error:
        print(f"Slide rendering failed: {error}", file=sys.stderr)
        if error.stderr:
            print(error.stderr, file=sys.stderr)
        sys.exit(1)
