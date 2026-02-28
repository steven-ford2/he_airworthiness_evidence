# Artifact Lifecycle Standard

## Purpose
Define the lifecycle for every artifact in this repository so production is repeatable, auditable, and scalable.

## Artifact Types
1) Journal article summary
2) Review article
3) Systematic review / meta-analysis
4) Airworthiness criterion artifact (deconstruction + MoC + verification blueprint)
5) MoC playbook (domain-level reusable compliance logic)
6) Verification blueprint (standalone verification architecture)
7) Risk register entry (table row + narrative file)
8) Compliance simulation (mock execution case)

---

# 1. Lifecycle Stages (All Artifacts)

## Stage 0 — Initiate
**Inputs**
- Topic / criterion selection
- Target standard paragraph (if airworthiness)
- Related review/systematic review targets

**Outputs**
- Created file stub from template
- Added placeholder entry in compiler/index

**Gate**
- File exists at correct path
- Filename conforms to naming specification
- Header attributes populated (`:revdate:`, `:revnumber:`)

---

## Stage 1 — Draft
**Goal**
Populate core sections with initial content using source materials.

**Rules**
- No invented thresholds
- Keep paragraphs short
- Use tables for traceability content

**Outputs**
- Draft content complete enough for SME review
- Open questions listed explicitly

**Gate**
- Template sections retained
- Any missing info is marked explicitly as TBD with reason

---

## Stage 2 — Evidence Hardening
**Goal**
Replace general statements with measurable claims and explicit limitations.

**Outputs**
- Quantified methods and results where possible
- Evidence strength classification justified
- Environmental sensitivity discussed

**Gate**
- No “hand-wavy” sections remain
- Each recommendation traces to evidence or standard text

---

## Stage 3 — Cross-Linking and Traceability
**Goal**
Make the artifact navigable and auditable.

**Outputs**
- xrefs to related artifacts
- traceability chain completed (where applicable)
- risk linkages established (where applicable)

**Gate**
- No orphaned files
- Links resolve locally
- Compiler updated

---

## Stage 4 — Audit Readiness
**Goal**
Meet the hard gates for the artifact type.

**Outputs**
- Artifact passes LINT_CHECKLIST.md
- Risks are tracked properly
- MoC and verification logic are defensible

**Gate**
- PASS on pre-commit validation prompt (or all failures fixed)

---

## Stage 5 — Release
**Goal**
Publish-ready and manager-review-ready.

**Outputs**
- Rev bumped (e.g., 0.1 → 0.2 / 1.0)
- Short change summary added (optional section)
- Clean commit message

**Gate**
- No unresolved TBD items without explicit justification
- Structured as something you could present in a design review

---

# 2. Type-Specific Lifecycle Rules

## 2.1 Journal Article Summaries
**Minimum fields**
- Research question
- Context
- Methods (N, design, apparatus)
- Measures
- Results (effect sizes where available)
- Limitations
- Design implications

**Gate**
- Must be fact-accurate to the source

---

## 2.2 Review Articles
**Minimum fields**
- Model comparisons
- Boundary conditions
- Measurement discussion
- Design implications
- Research gaps

**Gate**
- Claims tied to multiple sources, not a single paper unless explicitly stated

---

## 2.3 Systematic Reviews
**Minimum fields**
- Search strategy
- Inclusion/exclusion
- Data extraction table
- Bias considerations
- Evidence strength grading
- Summary of findings

**Gate**
- Reproducible method described

---

## 2.4 Airworthiness Criterion Artifacts
**Minimum sections**
- Verbatim criterion text
- Intent and certification philosophy
- HE constructs + metrics + evidence strength
- Hazard pathway and severity justification
- MoC table populated and justified
- Verification strategy with IV/DV and statistical sufficiency logic
- Cross-functional integration impacts
- Traceability mapping
- Certification risk and mitigation
- Environmental considerations
- Related artifacts xrefs

**Gate**
- Must pass Airworthiness hard gates (Lint checklist section D)

---

## 2.5 MoC Playbooks
**Minimum**
- Appropriate/inappropriate conditions by MoC type
- Evidence artifact architecture
- Environmental stress mapping
- Cross-functional dependencies
- Pitfalls

**Gate**
- Must be reusable across multiple criteria

---

## 2.6 Verification Blueprints
**Minimum**
- Platform and fidelity justification
- Population definition
- Environmental stress plan
- IV/DV and metrics alignment
- Statistical plan
- Evidence package deliverables

**Gate**
- Must read like an execution plan, not a generic experiment

---

## 2.7 Risk Entries
**Minimum**
- Row in risk_register.adoc
- Narrative file `R_###.adoc`
- Included in risk_narratives_compiler.adoc
- Links to related criterion/playbook/blueprint as applicable

**Gate**
- No orphan risks (table-only risks are not allowed)

---

# 3. Change Control

## 3.1 Renames and Refactors
- Plan first
- Move files without deletion
- Update xrefs atomically
- Update compiler
- Create compatibility stubs if appropriate

## 3.2 Revisioning
Use:
- `:revnumber:`
- `:revdate:`

Do not version filenames.

---

# 4. Definition of Done
An artifact is “done” when:
- It meets its type-specific gates
- It is linked from compiler.adoc
- It has no broken xrefs
- It has explicit limitations and assumptions
- It would not embarrass you in a design review