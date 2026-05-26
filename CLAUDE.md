# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

A personal collection of **parametric OpenSCAD models** for 3D printing, plus a vendored Python tool that exports any model to a self-contained web customizer (OpenSCAD WASM in the browser). Each model is meant to be regenerated with different parameters, not edited as a fixed geometry.

The repo lives inside Google Drive — the working directory contains spaces and special characters. Quote every path. Be aware that `(conflict)`-suffixed files are Drive sync artifacts and should generally be ignored, not edited.

## Layout

- `Personal/` — primary working tree. All `.scad` generators live here (or in topical subfolders like `Threadboards/`, `Telescoping Light Sabers/`, `Telescoping Wands/`, `Gridfinity/`, `Misc - Custom/`).
- `Personal/lib/` — shared SCAD modules: `Mounts.scad`, `mounting_interfaces.scad`, `gc_elements.scad` (geocache parts), `qr.scad`, and `ThreadBoards/` (a Thread Boards system with its own `parts/` and `tb_*.scad` modules).
- `Personal/src/` — Jinja2 templates (`index.html.jinja2`, `multi_index.html.jinja2`, `worker.js.jinja2`) consumed by `generate.py`.
- `Personal/generate.py`, `Personal/normalize_scad_input.py`, `Personal/action.yml`, `Personal/pyproject.toml`, `Personal/uv.lock` — the vendored [`yawkat/web-openscad-editor`](https://github.com/yawkat/web-openscad-editor) GitHub Action and CLI. Treat this as third-party code: do not refactor casually.
- `MakerWorldVersions/` — copies of selected generators bundled with `Images/` and `Print Profiles/` for MakerWorld listings. The `.scad` here may diverge from `Personal/` (it's the "published" version).
- `Personal/Threadboards/` (top-level) — user-facing threadboard generators that `include <lib/tb_*.scad>` from `Personal/lib/ThreadBoards/`.

## Generator file conventions

Each generator follows the same pattern, and edits should preserve it:

1. **Customizer parameters at the top of the `.scad` file**, grouped under `/* [Group Name] */` headers, with inline range/enum hints:
   ```scad
   /* [Box Parameters] */
   Inner_Box_Width = 65;            // [10:1:300]
   Rod_Type        = "round";       // [round:Round Rod, rectangular:Rectangular Rod]
   Mirror_Labels   = false;         // [true, false]
   ```
   These comments drive OpenSCAD's Customizer panel — `min:step:max`, comma-separated literals, or `value:Label` enums. The same comment syntax is parsed by `generate.py` (via `openscad --export-format=param`) to build the web UI. Keep the format intact when adding new params.

2. **Sidecar `Foo.json`** next to `Foo.scad` holds named preset bundles under `parameterSets`. OpenSCAD's Customizer reads and writes this file; prefer letting OpenSCAD manage it rather than hand-editing.

3. **External library imports** are paths into the user's OpenSCAD library search path, not into this repo:
   - `include <BOSL2/std.scad>` → installed under `~/Documents/OpenSCAD/libraries/BOSL2`
   - `include <Gridfinity/Gridfinity Rebuilt/...>` → installed under `~/Documents/OpenSCAD/libraries/Gridfinity/...` (the local machine has multiple Gridfinity variants installed)
   - `include <lib/...>` (relative) → resolves inside this repo
   When you see an unfamiliar `include <X>`, check the OpenSCAD library path before assuming it's missing.

## Common workflows

### Local OpenSCAD CLI (macOS)

The local OpenSCAD binary is `/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD`. Typical invocations the user runs (and which are pre-allowed in `.claude/settings.local.json`):

```bash
# Render an STL with overridden parameters
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
  -D 'Rod_Type="rectangular"' \
  -o /tmp/out.stl "Personal/Some Generator.scad"

# Render a preview PNG
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
  --imgsize=1200,800 --camera=20,5,5,60,0,30,200 --colorscheme=Tomorrow \
  -D 'Label_Top_Text_Line_1="TOPS"' \
  -o preview.png "Personal/.../Foo.scad"
```

Use `-D 'Param="value"'` (with quotes for strings) to override customizer params from the CLI.

### Web export generator (`Personal/generate.py`)

The user normally invokes this via the GitHub Action (`action.yml`), but for local testing:

```bash
cd Personal
uv sync
uv run python generate.py \
  --scad "Some Generator.scad" \
  --openscad-wasm /path/to/openscad-wasm \
  --output out
```

Modes: `--mode=single` (one generator, `index.html`) or `--mode=multi` (one HTML per input plus an index). For multi-input pass `--scad-json` (a JSON array, or `@path.json` to read from a file). `generate.py` recursively follows `include`/`use` directives so all referenced libs end up in the WASM filesystem.

Requires Python ≥3.13 and `uv`. There is no separate test/lint command — `pytest` is listed in deps but no tests exist yet.

## Things to know before editing

- **Don't "fix" generator code by hardcoding values.** Almost everything is a customizer parameter on purpose. Add a new parameter (with a range hint comment) rather than burning in a constant.
- **Module names use library-specific prefixes** to avoid collisions: `mnt_*` / `mnts_*` for mounting interfaces, `tb_*` / `tb_tb_*` for Thread Boards, `gc_*` for geocaching. Match the surrounding convention when adding modules to those libs.
- **MakerWorldVersions/ and Personal/ can drift.** A change in `Personal/Foo.scad` is not automatically reflected in `MakerWorldVersions/Foo/Foo.scad`. Ask before syncing across — the published version may intentionally lag.
- **The Python generator is upstream code** from `yawkat/web-openscad-editor`. Prefer keeping `generate.py`, `normalize_scad_input.py`, `action.yml`, and `src/*.jinja2` close to upstream so they remain easy to update.
- `Personal/README.md` is the upstream README for the vendored web generator, not for this repo as a whole.
