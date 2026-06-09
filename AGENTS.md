# AGENTS.md

Notes for agents (Claude Code, GitHub Copilot, …) working in this repository.
Please read before editing 3D models or exports.

## Project overview

`scad` contains parametric 3D models (OpenSCAD) that are exported to
printable `.3mf` files.

```
.
├── export.sh           # generic STL → 3MF export script
├── resources/          # shared assets (SVG logos etc.)
└── <model>/            # one folder per model
    ├── <model>.scad    # parametric source
    └── *.3mf           # exported results (checked in)
```

## Requirements

- `openscad` (tested with 2021.01) — must be on the `PATH`
- `python3` (tested with 3.12) — assembles the `.3mf` from the STL

The export script checks both and aborts with a clear message if anything is
missing.

## Exporting a model

Run from the repository root:

```bash
./export.sh <model>/<model>.scad                  # output next to the .scad
./export.sh <model>/<model>.scad output.3mf       # explicit output path
```

The script renders one STL with OpenSCAD and packages it as a single-part
`.3mf` (no color/material assignment).

## Important pitfalls

- **Check the SVG paths.** If the `.scad` imports an SVG, the path is
  **relative to the `.scad` file**. If the SVG is missing, OpenSCAD
  **does not fail hard** — it prints `ERROR: Can't open file …` but keeps
  rendering without the import. Symptom: suspiciously small output and
  near-instant render time.
- **Don't blindly trust the script output.** OpenSCAD import errors do not
  always produce a non-zero exit code. After every export, check for
  `ERROR`/`WARNING` in the output and verify the file size looks plausible.

## Conventions

- Exported `.3mf` files are deliberately checked in (directly printable
  without OpenSCAD). After changes to the model, regenerate the export and
  commit it too.
- Parameters live at the top of the `.scad` and should be maintained there,
  not duplicated in calling scripts.
