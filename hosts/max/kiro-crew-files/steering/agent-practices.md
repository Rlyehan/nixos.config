---
inclusion: always
name: agent-practices
description: agentic-engineering working practices from Tech Radar Vol 35 (no-install techniques)
---

# Agent working practices

No-install techniques trialed from Thoughtworks Tech Radar Vol 35. These shape
HOW agents work, not what tools they use. Keep this file lean — if a rule stops
earning its place, delete it (see "Prune" below); that is itself the discipline.

## Grilling — interview before you implement (#13)
Before writing code for a non-trivial task, briefly interview the user to
resolve ambiguity instead of guessing. Ask only the questions whose answers
would change the implementation (unclear intent, an unstated constraint, a
decision with no obvious default). Surface the assumptions you would otherwise
make silently, then capture the resolved plan. Do NOT grill on trivial or
fully-specified work — one good question beats five reflexive ones.

## Progressive context disclosure — load on demand (#5, Adopt)
Keep instructions and skills lean; pull detail in only when the task needs it.
When authoring an AGENTS.md, skill or steering file, state the essentials and
LINK to the rest rather than inlining it. Prefer looking a thing up (a doc, a
file, an MCP tool) at the point of use over front-loading it into context. This
cuts tokens and context rot.

## Writing for agents — the pointer, not the target, decides loading
When you author a skill, steering file, or any doc an agent reaches by a
reference, the *wording of the pointer* (a skill `description`/`triggers`, a line
naming a doc) — not its target — decides whether and how reliably the agent
loads it. A must-have behind a weak pointer is a variance bug: sharpen the
wording before you consider inlining the material. Complements #5 (which says
*where* to put detail); this says *how to word the reference that reaches it*.
- **Front-load the trigger word** and give one trigger per genuinely distinct
  case; synonyms that rename one case are bloat, not coverage.
- **Prompt the positive, not the prohibition.** "Write one-line comments" beats
  "don't write long comments" — a ban drags the banned behaviour into context and
  half-reads as an instruction to do it. Reserve a negation for a hard guardrail
  you can't phrase positively, and pair it with the positive target.
- **Lean on leading words** — a compact concept the model already holds (*tight*,
  *red*, *lesson*) anchors a region of behaviour in one token; repeat the token,
  never restate its meaning.
- **Kill no-ops.** An instruction a current model already obeys by default pays
  tokens to say nothing — delete the whole sentence (ties into #36). The test is
  model-relative: settle it by running the doc, not by debate.
(idea from mattpocock/skills, MIT)

## Risk-tiered human oversight — match review to blast radius (#17)
Scale caution to what a change could break; don't review everything with the
same intensity (that is just theater). Low-risk, reversible changes (a local
edit, a read-only query, a test) — proceed and report. Medium-risk (deps, config,
migrations) — proceed but say what you did. High-risk or hard-to-reverse (prod,
data deletion, auth, infra, destructive SQL) — explain the risk and get explicit
confirmation first. This is already the safety contract; apply it as a triage
default, not a per-change deliberation.

## Semantic review of AI-edited prose (#34)
When you rewrite a spec, ADR, ticket or plan, review the change by MEANING, not
text diff: call out altered facts, redefined acceptance criteria, changed scope
or new contradictions — not rewording or formatting. Say what substantively
changed so the human reviews intent, not noise. Pairs with `vale` for the
surface-level prose pass.

## Prune — fight instruction bloat (#36, Caution)
Instructions accumulate and go stale. Periodically (and whenever you touch this
file or a skill): delete rules a current model no longer needs, convert what you
can into deterministic checks/hooks, and remove anything that merely repeats a
lesson or another steering file. A shorter, current instruction set beats a long
contradictory one — frontier models follow fewer, sharper rules better.
