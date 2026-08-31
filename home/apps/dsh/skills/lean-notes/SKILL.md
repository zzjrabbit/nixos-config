---
name: lean-notes
description: Write, repair, explore, or validate Lean 4 and Mathlib definitions, examples, theorems, and proofs in a Lake project using LeanProbe for rapid feedback.
---

# Lean mathematical notes

Inspect `lakefile.toml` or `lakefile.lean`, `lean-toolchain`, imports, namespaces, local notation, and nearby theorem style before editing.

Use LeanProbe for iterative feedback:

- `mcp__lean-probe__lean_check` for standalone snippets;
- `mcp__lean-probe__lean_check_target` for a declaration in an existing file;
- proof-state and tactic tools for focused tactic exploration;
- `mcp__lean-probe__lean_status` with warming when repeated checks are expected.

LeanProbe does not replace the final project check. After editing files, run the narrowest relevant `lake env lean <file>` or `lake build` command. Do not leave `sorry`, `admit`, new axioms, or weakened statements unless the user explicitly requests them. Keep proofs compatible with the project's pinned Lean and Mathlib versions.
