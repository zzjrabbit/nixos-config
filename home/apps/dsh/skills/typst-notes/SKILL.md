---
name: typst-notes
description: Create, edit, refactor, or validate mathematical notes written in Typst, including equations, theorem environments, references, figures, and project structure.
---

# Typst mathematical notes

Inspect the existing project style, imports, templates, labels, and naming conventions before editing. Reuse project abstractions instead of introducing parallel formatting helpers.

After changing Typst:

1. Compile the relevant entry point with `typst compile`.
2. Fix syntax, missing labels, package/import, font, and layout errors reported by the compiler.
3. Keep generated PDF or image artifacts out of the source tree unless the project already tracks or expects them; use a temporary output for validation when appropriate.
4. For mathematical content, preserve the user's notation and avoid silently strengthening hypotheses or changing theorem meaning.

Prefer small, reviewable edits. Do not convert entire documents between LaTeX and Typst when only a local expression needs work.
