# Agent Instructions

This file defines the project-specific working rules for any coding agent operating in this repository. It is meant to make sessions resumable and keep the project documentation trustworthy.

## Working Style

- Work in small, reversible steps.
- Prefer finishing one narrow change completely before starting the next.
- Verify behavior after making changes whenever verification is practical.
- Do not describe future work as if it already exists.
- If a blocker appears, record the blocker clearly instead of hand-waving past it.

## Documentation Discipline

Keep the following files up to date as the project evolves:

- `CURRENT_STATUS.md`
- `DETAILS.md`
- `COMMANDS.md`
- `NEXT_STEPS.md`
- `AGENTS.md` if the working process changes

When implementation changes the true state of the system, update the relevant docs in the same session whenever practical.

Examples:

- If runtime commands change, update `COMMANDS.md`.
- If architecture or system behavior changes, update `DETAILS.md`.
- If the project checkpoint changes, update `CURRENT_STATUS.md`.
- At the end of a meaningful session, update `NEXT_STEPS.md`.

## Handoff Expectations

Each session should leave behind a clear handoff for the next session or next agent.

`NEXT_STEPS.md` should contain:

- what was most recently completed
- the current verified state
- the next 1 to 3 concrete tasks
- blockers or risks
- the exact commands needed to resume work

## Accuracy Rules

- Keep docs grounded in the actual repository state, not the aspirational architecture alone.
- Distinguish clearly between what exists now and what is planned for later.
- If a command or runtime flow has not been verified, say that explicitly.
- Prefer plain English over jargon when documenting the system.

## Implementation Preferences

- Preserve the current production-shaped direction of the system.
- Prefer Flyway-owned schema management over ORM-driven schema creation.
- Prefer environment-driven configuration over hardcoded environment-specific values.
- Prefer realistic integration tests over mock-heavy early testing.
- Prefer updating an existing document over creating overlapping duplicate docs.

## Session Closeout

Before ending a meaningful work session:

1. update `NEXT_STEPS.md`
2. update any stale status or command docs affected by the work
3. note what was verified and what was not verified

The goal is that another agent should be able to open the repo, read the docs, and continue without reconstructing context from scratch.
