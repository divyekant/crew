# Crew Cross-Host Routing Design

Date: 2026-08-20
Status: approved

## Problem

Crew used one capability gate that recognized only the original Claude Code
fleet. A Codex controller therefore bypassed Crew even when native Codex
subagents and an authenticated Claude Code CLI were available. The same skill
also copied model choices across several files, which allowed stale routing.

## Design

Crew checks capabilities only for the domains required by the task. Each
domain has one worker definition under `skills/crew/workers/`. That definition
owns its model, reasoning effort, host transports, and failure behavior.

Frontend implementation remains Opus-only. Every controller invokes the
installed Claude Code CLI through a tested generic wrapper. The frontend
worker definition passes the model and effort. The wrapper clears higher
priority environment overrides and verifies the effective model from the
Claude event stream. It gives the worker file-reading and editing tools and
disables nested customizations.

The bridge writes only in an isolated Git worktree. The controller integrates
the diff only after model verification succeeds. It runs shell validation
after the worker returns.

Backend and mechanical workers use their approved host-specific routes as
defined in their worker files. Claude Code mechanical work uses the verified
bridge for model, effort, and worktree enforcement. No other document copies
the operational model map.

Crew fails closed when an exact worker is unavailable. It does not silently
substitute another model. External bridge writers and concurrent writers use
isolated worktrees. The controller serializes other writers.

## Validation

- Baseline behavior tests must show the old Codex pass-through and stale model
  routes.
- A deterministic wrapper test must verify the selected model, effort, tools, and
  work directory without calling the live service.
- Revised-skill scenario tests must cover Claude Code, Codex, and unavailable
  worker paths.
- The Agent Skills validator and repository diff review must pass.
