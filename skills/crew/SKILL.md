---
name: crew
description: Use when substantive implementation can be split into independently owned frontend, backend, or mechanical work, or when the user explicitly requests Crew. Avoid automatic use for review-only work, small fixes, or tasks without separable file ownership.
license: MIT
metadata:
  version: 0.2.0
  author: dk
---

# Crew — Multi-Model Build Orchestrator

The session model controls decomposition, dispatch, review, and integration.
Workers implement.

## Capability gate

Check actual capabilities for each required domain. Do not infer them from the
host name.

| Domain | Required definition |
|---|---|
| Frontend | [workers/frontend.md](workers/frontend.md) |
| Backend | [workers/backend.md](workers/backend.md) |
| Mechanical | [workers/mechanical.md](workers/mechanical.md) |

Read each required definition before composing its brief. These files are the
single source for models, effort, transports, and domain failures. Do not copy
their routes into other guidance.

If an exact worker is unavailable, fail closed for that domain. Report the
blocker and continue only with unaffected domains. Never substitute another
model unless the user explicitly approves the substitution.

## Controller boundary

The controller can make a trivial edit under about 10 lines when it affects one
file and has no ambiguity. Worker ownership rules override this exception.

## Decomposition and dispatch

- Classify work by dominant domain.
- For full-stack work, write the interface contract before dispatch.
- Give every file to one worker only.
- Run independent writers in parallel only when each has an isolated
  worktree. Otherwise, serialize them.
- Every external bridge writer uses an isolated worktree.
- Keep workers flat. Workers do not delegate.
- Give each worker a complete brief.

Use this brief contract:

```text
You are a Crew worker for one scoped implementation task. Routing already
happened. Do not invoke conductor, brainstorming, Crew, or another routing
skill. Do not delegate.

GOAL: <one sentence>
FILES YOU OWN: <complete paths>
OUT OF SCOPE: <explicit exclusions>
CONTEXT: <contracts, types, examples, neighboring code>
CONSTRAINTS: <project conventions and test discipline>
ACCEPTANCE: <observable behavior and required validation>
ITERATION CAP: after three failed attempts on the same error, stop and report.
RETURN: summary, files changed, validation performed, and unfinished work.
```

## Review gate

Nothing reaches the user without controller review.

1. Read every worker diff and check file ownership.
2. Check the interface contract and project conventions.
3. Run the relevant tests and build. Worker claims are not evidence.
4. Give one targeted retry with specific feedback.
5. If the retry fails, stop that domain and report the blocker. Do not change
   its assigned model without user approval.

## Reporting

Report each worker, controller validation, and any blocked, serialized,
retried, or approved substitute work.

## Common mistakes

- Assuming host capabilities instead of checking tools.
- Treating a text-only helper as a writer.
- Setting a model without its effort.
- Running concurrent writers in one worktree.
- Reassigning work without approval.
- Letting workers edit Crew or agent context files.

## Conductor interplay

Crew owns substantial build-phase execution. A blocked domain keeps that phase
incomplete.
