# Codex Pre-Commit Validation Prompt

## How to Run
In VS Code Codex chat, attach:
- `#AGENTS.md`
- `#docs/NAMING_SPECIFICATION.md`
- `#docs/LINT_CHECKLIST.md`
- `#compiler.adoc`

Then paste the prompt below.

---

## Prompt (Paste into Codex)

Task: Pre-commit validation and repo hygiene pass.

Scope:
- All changed .adoc files (git diff).
- Any files referenced by xref/include from changed files.

Do the following in order:

1) Naming compliance
- Confirm filenames are snake_case and conform to docs/NAMING_SPECIFICATION.md.
- Do NOT rename files unless explicitly instructed in the task; if naming is wrong, report it and propose a rename plan.

2) Title and heading sanity
- Check each changed .adoc file:
  - Document title line (`= `) is readable Title Case.
  - Section headings are readable Title Case.
- Do not convert anchors/attributes.

3) Link integrity
- Validate that all xref and include targets referenced by changed files exist.
- Report any broken links with exact source file + line snippet + missing target.

4) Airworthiness hard gates (if applicable)
For any changed file under /airworthiness/criteria-deconstruction/:
- Verify all required sections exist per docs/LINT_CHECKLIST.md section D.
- Verify MoC table has no blank rows/cells (or "Not appropriate" justified).
- Verify no invented numeric thresholds.

5) Risk register integrity (if applicable)
- Ensure each open risk in risk_register.adoc has:
  - a narrative file in risk-register/narratives/
  - an include entry in risk_narratives_compiler.adoc
- Report missing narratives or missing includes.

6) Compiler hygiene
- Confirm any new artifacts are linked in compiler.adoc.
- If not linked, propose exact xref line(s) to add (do not invent titles).

Output requirements:
- Provide a concise report with:
  - PASS/FAIL overall
  - failed checks grouped by checklist section (A–I)
  - specific file paths and exact fixes needed
- Do NOT claim that links or checks are valid unless verified from the workspace files.