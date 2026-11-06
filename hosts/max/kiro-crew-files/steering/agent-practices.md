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
