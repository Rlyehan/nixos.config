---
inclusion: auto
name: quality-gates
description: documentation and quality standards for coding, code review, and technical-documentation work
---

# Quality & Documentation Standards

## When Writing Code
- Load `create-python` or `create-shell` skill patterns for new files
- Apply `definition-of-ready` before starting significant work
- Apply `definition-of-done` before declaring work complete

## When Writing Documentation
- Follow `create-doc` skill templates for architecture docs
- Follow `create-runbook` patterns for operational procedures

## When Reviewing
- Use `review-pr` patterns (correctness, security, maintainability)
- Use `review-python` for Python-specific review

## Feedback sensors for coding agents (run these, act on the output)
When the tool is on PATH, treat its output as a high-priority prompt, not a
suggestion. These are deterministic (no extra LLM) and complement ruff/mypy.

- **habit-hooks** — run `habit-hooks --branch main` (or `--last N`) before
  declaring Python work complete. It wraps ruff/deptry and returns a short
  coaching guide per smell (high-complexity, oversized-function,
  swallowed-exception, ...). Fix the cause the guide names; do NOT mechanically
  extract helpers or narrow an `except` only to silence the check — that games
  the metric. Exit 1 = a real finding to fix; exit 2 = a broken tool (fix it,
  do not treat the change as checked). Never `habit-snooze` without Max's
  explicit approval.
- **ast-grep** — structural (AST) rules for bug classes ruff/mypy miss. This
  repo ships a ready ruleset in `ast-grep/` (`sgconfig.yml` + `rules/*.yml`):
  swallowed-exception, print-in-source, boolean-flag-param — all drawn from
  `python-conventions.md`. Run `ast-grep scan -c ast-grep/sgconfig.yml <changed
  files>` and fix matches at the cause (log/handle the exception, switch print
  to logging, split the boolean-flag function); don't game the pattern. The
  dev-loop gate runs this advisory step automatically on changed files. Always
  invoke `ast-grep`, never the `sg` alias (on NixOS `sg` is the setgid wrapper).
  See `ast-grep/README.md` to add rules.
- **vale** — run `vale <file>` on specs/ADRs/PR descriptions before handing
  them over; fix flagged prose. (Needs `vale sync` once per repo to fetch styles.)

## Git (Gitea on git.noenv.eu)
- Branch naming: f/<slug> (from /start-usecase convention)
- Commit messages: conventional commits (feat:, fix:, chore:, docs:)
- Never push to main/master directly
- PR title < 70 chars, description has: summary, what was tested, blocked features
