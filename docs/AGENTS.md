# AGENTS.md — HE_AIRWORTHINESS_EVIDENCE

## Mission
This repository produces defense-industry-grade human engineering artifacts focused on:
- Fighter Pilot-Vehicle Interaction (PVI)
- Human Systems Integration (HSI)
- Airworthiness certification (MIL-HDBK-516, MIL-STD-1472)

Artifacts must be technically rigorous, traceable, and suitable for internal defense review.

## Primary Standards
- MIL-HDBK-516 (Human Factors sections)
- MIL-STD-1472 (Human Engineering)
- Applicable FAA / DoD certification guidance when relevant

## Artifact Classes
1. Journal Article Summaries (empirical, structured, N + stats required)
2. Review Articles (theory + limitations + quantitative grounding)
3. Systematic Reviews / Meta-Analyses (explicit inclusion criteria)
4. Airworthiness / Standards Analysis Documents (MoC mapping, traceability)

## Evidence Rules
- No hallucinated citations.
- Distinguish clearly between:
  a) Source claim
  b) Inference
  c) Recommendation
- When empirical: include N, design, variables, and statistical outcomes when available.
- If uncertainty exists, explicitly state it.

## Formatting Rules
- Primary format: AsciiDoc (.adoc)
- Use structured headings.
- Prefer tables for:
  - Requirements traceability
  - Methods of Compliance
  - Standard-to-test mapping
- Keep documents modular.

## Airworthiness Logic
All major artifacts should connect:
Human capability → Interface behavior → Operational risk → Regulatory requirement → Verification method.

## Safety & Compliance
Do not include:
- ITAR data
- Proprietary Boeing program details
- Sensitive system descriptions

Keep all content generalizable and unclassified.

## Quality Standard
Outputs should resemble:
- Internal human engineering white papers
- Certification preparation documents
- Publishable aviation human factors reviews

# AGENTS.md — HE Airworthiness Evidence

## Mission
Produce human engineering certification artifacts with:
- Verbatim standard text
- Traceable MoC logic
- Defensible verification plans
- Complete risk and traceability links
- Audit-readiness

## Templates (enforced)
- airworthiness criterion template
- MoC playbook template
- verification blueprint template
- risk narrative template

## Refactor discipline
- Print move plan first
- Update compiler.adoc
- Update airworthiness-index.adoc
- Create compatibility stubs on moves

## Naming conventions
- airworthiness artifacts use exact standard reference naming
- risk IDs must be unique
- narrative files named `R-###.adoc`

## Rigor rules
- No invented numeric thresholds
- No paraphrasing of standard text
- No generic MoC claims
- Environmental constraints explicitly addressed