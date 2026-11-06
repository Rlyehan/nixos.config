---
inclusion: auto
name: python-conventions
description: Python coding conventions — always apply when writing or reviewing Python code
---

# Python Conventions

## Code Composition
- Guard clauses / early returns — keep flat, no nesting beyond 2 levels
- Small, single-purpose, composable functions
- Pure functions where feasible — push side effects to boundaries
- List comprehensions over imperative loops for data transforms
- Functions over classes for stateless logic; classes only for state/lifecycle
- match/case for complex multi-branch logic (Python 3.10+)
- Function signatures tell the story — clear names, return type hints, no boolean flags

## Comments & Documentation
- Comments explain WHY, not WHAT — no redundant narration, no commented-out code

## Type Safety
- TypedDict for structured dicts, Pydantic at external boundaries
- Type hints on all function signatures (mypy strict)

## Error Handling
- try/except only at system boundaries (I/O, external calls)
- Internally validate with guard clauses
- No swallowed exceptions, no leaked internals in error messages
- Use logging (not print), with appropriate log levels

## Tooling
- Ruff: E, W, F, I (isort), UP (pyupgrade), B (bugbear), SIM (simplify)
- Line length: 120
- mypy: disallow_untyped_defs, warn_return_any
- Python 3.13

## Never Flag (Pedantry Exclusions)
- Style/formatting (linters handle it)
- Import ordering
- Naming unless genuinely misleading
- Comment style
