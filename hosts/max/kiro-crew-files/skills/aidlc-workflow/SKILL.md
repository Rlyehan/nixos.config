---
name: aidlc-workflow
description: Detect and drive the AWS AI-DLC gated software-development workflow (INCEPTION → CONSTRUCTION → OPERATIONS) in a project that ships its scaffolding. Proactively suggest it for real build/feature work; never auto-start.
triggers: aidlc, ai-dlc, gated workflow, strict workflow, full workflow, construction phase, inception phase, functional design, code generation plan, aidlc-docs
source: crystallize
---

# aidlc-workflow

Drive the **AWS AI-DLC** methodology (AI-Driven Development Life Cycle) when a
project ships its scaffolding. AI-DLC is a *gated* lifecycle: every stage has an
owner, produces markdown artifacts under `aidlc-docs/`, and stops at an approval
gate before the next stage begins. This skill does **not** re-implement the
stages — the project's own steering (`core-workflow.md` + a rule-details tree)
is the source of truth. This skill's job is to (1) recognise when AI-DLC applies,
(2) resolve and load that steering, and (3) enforce the discipline agents
otherwise skip: audit trail, approval gates, state-file resume, per-unit loop.

## When to use

Two families of projects, detected differently:

- **v1 rule-detail model (what our Databricks repos use today):** the project
  has `.kiro/steering/aws-aidlc-rules/core-workflow.md`, an `aidlc-docs/`
  directory, and a rule-details tree (see resolution order below). This is
  plain markdown — nothing is installed.
- **v2 engine model:** the project has an `.aidlc/` engine directory and the
  native `aidlc` CLI is on PATH. Invocation is `/aidlc <description>`; the
  deterministic engine (state machine, audit log, hooks) runs the stages. Prefer
  `/aidlc --doctor` to verify, then `/aidlc <description>` to start.

**Activate when:**
- The user types `/aidlc`, or says "use the full/strict/gated workflow", "run
  AI-DLC", "do this properly with the workflow", "as a template going forward".
- OR the request is a **real build/feature/change** — a new pipeline, job,
  schema, feature, or a structural change — **AND** the current project has
  AI-DLC scaffolding. In that case **propose** the workflow (see Proactive
  invocation); do not silently enter it.

**Do NOT activate for:** one-off queries, data investigations, ad-hoc SQL, a
quick bug fix, doc lookups, or any project with no AI-DLC scaffolding. A crew
agent's normal mode is unchanged for that work.

## Proactive invocation (never auto-start)

When a request looks like AI-DLC work in an enabled project, **ask first** —
one line, then wait:

> "This looks like a build/feature change and this repo has AI-DLC scaffolding
> (`aidlc-docs/` + `core-workflow.md`). Want me to run it through the gated
> AI-DLC workflow, or handle it directly?"

Only enter the workflow on a yes. Never begin INCEPTION, write to `aidlc-docs/`,
or emit the welcome message before the user opts in. If they decline, do the
work in the agent's normal mode.

## Steps

1. **Resolve the rule-details directory** (v1 model). Check these paths in order,
   use the first that exists — do not assume one:
   - `.aidlc/aidlc-rules/aws-aidlc-rule-details/`
   - `.aidlc-rule-details/`
   - `.kiro/aws-aidlc-rule-details/`  ← our Databricks repos
   - `.amazonq/aws-aidlc-rule-details/`
   All later rule references (`common/…`, `inception/…`, `construction/…`) are
   relative to whichever resolved.

2. **Load the workflow spine.** Read `.kiro/steering/aws-aidlc-rules/core-workflow.md`
   (or the project's equivalent) in full — it is authoritative and overrides
   built-in workflows. At workflow start also load the common rules it names:
   `common/process-overview.md`, `common/session-continuity.md`,
   `common/content-validation.md`, `common/question-format-guide.md`.

3. **Resume or start.** If `aidlc-docs/aidlc-state.md` exists, this is a resume —
   read it and continue from the recorded stage; do NOT restart. Otherwise begin
   INCEPTION → Workspace Detection, and log the raw user request to
   `aidlc-docs/audit.md` first.

4. **Scan extensions lightly.** Under the rule-details `extensions/` tree, load
   ONLY `*.opt-in.md` files at start. Present each opt-in during Requirements
   Analysis; load the full `<name>.md` rule body ONLY after the user opts in.
   Extensions with no `*.opt-in.md` are always-on — load them immediately.
   Record enabled/disabled state in `aidlc-state.md` under
   `## Extension Configuration`.

5. **Walk the phases as the spine dictates**, honouring CONDITIONAL/ALWAYS:
   - **INCEPTION** — Workspace Detection (always) → Reverse Engineering
     (brownfield, if no artifacts) → Requirements Analysis (always, adaptive
     depth) → User Stories (conditional) → Workflow Planning (always) →
     Application Design (conditional) → Units Generation (conditional).
   - **CONSTRUCTION** — per-unit loop, each unit finished fully before the next:
     Functional Design → NFR Requirements → NFR Design → Infrastructure Design
     → Code Generation (always; Plan then Generate). Then Build and Test once all
     units are done.
   - **OPERATIONS** — placeholder today.

6. **At every stage gate, stop.** Present the stage's standardized **2-option**
   completion message ("Request Changes" / "Continue to Next Stage") exactly as
   the stage's rule file defines it. Do NOT invent a 3-option menu or other
   emergent navigation. Do not proceed until the user confirms.

7. **Log every interaction to `audit.md`** with an ISO-8601 timestamp and the
   user's COMPLETE RAW INPUT (never summarised). APPEND/edit only — never
   overwrite the file. Log approval prompts before asking and responses after
   receiving.

8. **Track two checkbox levels.** Mark plan-file steps `[x]` in the SAME
   interaction the work completes; update stage-level progress in
   `aidlc-state.md`.

## Gotchas

- **Code to the repo root, docs to `aidlc-docs/`.** Application code (pipelines,
  jobs, notebooks) goes in the workspace tree per the project's layout; only
  markdown artifacts go under `aidlc-docs/`. Never put code in `aidlc-docs/`.
- **`audit.md` is append-only.** Read-then-overwrite duplicates the whole file.
  Edit/append only.
- **Two-tier knowledge.** Methodology knowledge ships with the framework; team
  knowledge is user-managed under the project's steering. Respect the project's
  existing steering (`.kiro/steering/`) — it carries project-specific rules that
  override generic AI-DLC defaults.
- **Databricks repos — ClickHouse rule.** In `databricks_games_de` and siblings,
  ClickHouse access goes through `clickhouse_connect` in Python running on
  Databricks (see `jobs/utils.py`), NOT the ClickHouse MCP server (not configured
  there). The project `_classifier.md` states this explicitly.
- **Don't re-implement stages.** If a stage's behaviour seems missing, the fix is
  to load its rule-details file, not to improvise. Missing rule files → tell the
  user the scaffolding is incomplete rather than inventing stage behaviour.
- **v2 vs v1.** If `.aidlc/` + the `aidlc` CLI exist, drive via `/aidlc` and let
  the engine own state/audit/hooks — do not hand-manage `aidlc-docs/` in that
  case. The v1 hand-driven discipline above applies only to the markdown model.
- **Model note.** AI-DLC's gate discipline is heavy; on weaker models the
  reviewer pass and learnings ritual get skipped and gates get rushed. Keep the
  gates strict regardless.
