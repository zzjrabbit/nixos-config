---
name: math-study
description: Maintain durable mathematical learning context and progress with Engram while studying, explaining mathematics, or editing personal notes. Use at the start of a mathematical study session and after context compaction.
---

# Mathematical study memory

Use Engram as the user's automatic local learning memory. The fixed memory project is `math-notes`; the filesystem workspace is resolved separately for each session. Do not require a Git repository or ask the user to maintain separate progress files.

Files in the resolved workspace are the source of truth for full mathematical notes, proofs, exercises, Typst sources, and Lean code. Engram stores concise learning state and conventions; it is not a transcript or document store.

## Start and workspace checks

1. Call `mcp__engram__mem_current_project` once before substantive mathematical work.
2. Require the resolved memory project to be `math-notes`. If it differs, report the mismatch and do not save project memory under another name.
3. Call `mcp__engram__mem_context` to recover recent learning state.
4. Resolve a filesystem workspace only when the task needs files. Use these signals in order:
   - a path or file explicitly supplied by the user;
   - referenced or already-inspected files that identify the project;
   - the Harness working directory when it contains relevant project signals such as `typst.toml`, `*.typ`, `lakefile.toml`, `lakefile.lean`, `lean-toolchain`, or nearby mathematical sources;
   - a concise clarification from the user when file work remains ambiguous.
5. Do not redirect work to a preferred directory, reject a valid project merely because it is elsewhere, or search broad parts of the home directory speculatively. For explanation-only study, no filesystem workspace needs to be selected.
6. Use `mcp__engram__mem_search` only for a specific earlier definition, misconception, decision, exercise, convention, or proof. Fetch a full hit with `mcp__engram__mem_get_observation` only when its preview is insufficient.

Before editing, inspect the resolved project's local structure and conventions. Stay within the Harness sandbox and report a real access limitation rather than describing an arbitrary path difference as a workspace mismatch.

## Compaction recovery

When the conversation contains a `<compacted-summary>` checkpoint:

1. Use it as the established in-session handoff for continuing the conversation, but not as independent evidence that the user mastered something or that a claimed memory was never saved.
2. Call `mcp__engram__mem_context` before writing checkpoint-derived state. Search for a specific item when the checkpoint and recent context disagree or are insufficient.
3. Save a recovered milestone only after it is corroborated by retained messages, project files, existing Engram state, or fresh evidence from the user. Prefer updating the stable `topic_key` over creating a duplicate.
4. Do not restate the checkpoint or interrupt the user merely to announce memory maintenance.

## What to remember

Save concise, durable learning state with `mcp__engram__mem_save` after a meaningful milestone, not after every exchange:

- concepts the user has demonstrably mastered;
- recurring misconceptions and their correction;
- notation and presentation preferences;
- unresolved questions, exercises, or proof gaps;
- the current topic and the next useful study step;
- important Typst or Lean project conventions;
- decisive examples or counterexamples that should guide later explanations.

Use stable `topic_key` values for evolving state so a subject is updated instead of duplicated. Prefer these families:

- `study/<subject>-progress` for current course or topic progress;
- `notation/<subject>` for notation choices;
- `preference/<description>` for teaching and presentation preferences;
- `misconception/<description>` for a recurring error and its correction;
- `proof-gap/<description>` for a live unresolved proof;
- `project/<workspace-slug>/typst-conventions` and `project/<workspace-slug>/lean-conventions` for workspace-specific rules.

Choose a short, stable workspace slug from the project directory or manifest name. Do not store absolute paths in topic keys unless disambiguation genuinely requires them.

Never save raw transcripts, full papers, complete note prose, long derivations, large compiler output, routine tool calls, secrets, or speculative claims about the user's understanding. Put full mathematical content in the resolved project files instead.

## Session close

At a natural stopping point, call `mcp__engram__mem_session_summary` with a short summary of the goal, progress, remaining difficulty, resolved workspace when file work occurred, relevant files, and next step. Do not interrupt the conversation merely to announce memory maintenance.

If Engram tools are missing or repeatedly fail, explicitly state that durable learning memory is degraded. Continue note-file work when safe, but never claim that something was remembered or saved when the memory call did not succeed.

## Teaching behavior

Distinguish established facts from intuition and conjecture. Preserve exact hypotheses, domains, and quantifiers. Prefer definitions, small examples, counterexamples, and dependency-aware explanations. Infer mastery only from evidence in the conversation and record uncertainty explicitly.
