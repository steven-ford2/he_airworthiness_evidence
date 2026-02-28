# Lint Checklist (Manual + Codex-Assisted)

## Purpose
Prevent broken links, naming drift, missing hard-gate sections, and low-rigor artifacts before commit.

## How to Use
Run this checklist before every commit that touches `.adoc` files.

---

## A. Naming Discipline (Hard Gate)

- [ ] All filenames are `snake_case` (lowercase, underscores, no hyphens, no spaces).
- [ ] No version numbers in filenames (use `:revnumber:` and `:revdate:`).
- [ ] Risk narrative files use `R_###.adoc` (3 digits).
- [ ] No duplicate filenames serving different purposes.

**Quick checks**
- [ ] VS Code search: `-` in filenames under repo (should be none except in content).
- [ ] Confirm risk files follow `R_` prefix and 3 digits.

---

## B. AsciiDoc Title and Heading Quality (Hard Gate)

- [ ] Document title line (`= `) is readable Title Case (not snake_case).
- [ ] Section headings (`==`, `===`) are readable Title Case.
- [ ] No paragraph exceeds ~10 lines in airworthiness artifacts.
- [ ] No “motivational” or filler language.

---

## C. Link Integrity (Hard Gate)

- [ ] No broken `xref:` targets.
- [ ] No broken `include::` targets.
- [ ] If files were moved/renamed, all references were updated atomically.

**Quick checks**
- [ ] VS Code search: `xref:` and click-through a sample of the most used links.
- [ ] VS Code search: `include::` and confirm each included path exists.

---

## D. Airworthiness Artifact Hard Gates (Hard Gate)

For each `/airworthiness/criteria-deconstruction/*.adoc` artifact:

- [ ] Verbatim criterion text present and exact (no paraphrasing).
- [ ] Criterion reference number correct.
- [ ] Intent section present and does not add requirements.
- [ ] Certification philosophy section present.
- [ ] HE technical basis section present (constructs + metrics + evidence strength).
- [ ] Hazard pathway section present (failure mode + severity + mechanism).
- [ ] MoC table fully populated OR “Not appropriate” justified (no blank cells).
- [ ] Verification strategy present and aligned to HE metrics.
- [ ] Cross-functional integration section present (Avionics, Software, Flight Test, Supplier).
- [ ] Traceability section present (flowdown + verification mapping).
- [ ] Certification risk section present and concrete.
- [ ] Environmental considerations addressed or explicitly justified as not applicable.
- [ ] Related artifacts cross-linked.

---

## E. Risk Register Discipline (Hard Gate)

- [ ] Every open risk in `risk_register.adoc` has a corresponding narrative file in `risk-register/narratives/`.
- [ ] The narratives compiler includes every narrative file.
- [ ] Risk IDs match across:
  - [ ] master table row
  - [ ] narrative filename
  - [ ] narrative title

---

## F. MoC Playbook Discipline

For each `/airworthiness/moc-playbooks/*.adoc`:

- [ ] Defines when each MoC type is appropriate/inappropriate.
- [ ] Identifies concrete evidence artifacts (not generic “report”).
- [ ] Environmental stressors mapped to MoC implications.
- [ ] Cross-domain dependencies described.
- [ ] Common pitfalls listed.

---

## G. Verification Blueprint Discipline

For each `/airworthiness/verification-blueprints/*.adoc`:

- [ ] Platform + fidelity justification.
- [ ] Population definition + variability considerations.
- [ ] IV/DV separation.
- [ ] Environmental stress inclusion (or justified exclusion).
- [ ] Statistical sufficiency logic without invented numeric thresholds.
- [ ] Evidence package deliverables listed.
- [ ] Traceability + risk alignment present.

---

## H. Compiler / Index Discipline

- [ ] New artifacts are referenced from `compiler.adoc`.
- [ ] Airworthiness artifacts are referenced from `airworthiness_index.adoc` (if you use one).
- [ ] No orphan `.adoc` files.

**Quick checks**
- [ ] Confirm new file is reachable from `compiler.adoc` via `xref`.

---

## I. Language Discipline

- [ ] No “clearly”, “obviously”, “it is evident” unless tied to explicit evidence.
- [ ] Avoid hedging without stating why (use “unknown because …”).
- [ ] Distinguish:
  - [ ] source claim
  - [ ] inference
  - [ ] recommendation

---

## Pass Standard
- Sections A, C, D, and E must be 100%.
- Overall must be ≥ 90%.