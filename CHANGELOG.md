# Changelog

All notable changes to Crew will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Replaced the Codex-wide pass-through with per-domain capability checks.
- Made the worker definitions the operational source of truth for routing.
- Routed backend work through GPT-5.6 Sol with `high` reasoning on both hosts.
- Routed Codex mechanical work through GPT-5.6 Luna with `max` reasoning while preserving Sonnet on Claude Code.
- Preserved Opus as the only frontend implementation model and added a verified, write-capable Claude Code CLI bridge for every controller.
- Changed worker failures to fail closed instead of silently substituting models.

### Added
- Added `scripts/run-claude-worker.sh` for Claude workers, with environment
  normalization, effective-model verification, and isolated-worktree
  enforcement.
- Added deterministic bridge and routing-contract tests.

## [0.1.0] - 2026-06-10

### Added
- Initial release: `crew` skill — multi-model build orchestrator (Opus→frontend, GPT‑5.5 via Codex→backend, Sonnet→mechanical/low-level)
- Worker definitions under `skills/crew/workers/` (opus-frontend, gpt-backend, sonnet-mechanical) with per-worker brief additions and review focus
- Cross-host capability gate: full orchestration on Claude Code, one-line graceful pass-through on Codex CLI
- Worker brief protocol: self-contained briefs with routing-skill bypass preamble, one-file-one-owner, explicit out-of-scope, iteration caps, required return format
- Mandatory review gate: orchestrator reads every diff and runs tests itself; one targeted retry, then reroute or takeover; Opus fallback when Codex is unavailable
- Contract-first decomposition for full-stack work (orchestrator authors the interface contract; FE/BE dispatch in parallel)
- Optional skill-conductor integration (build phase of feature/complex pipelines)
- Research report backing the routing split and brief protocol (`docs/research/`)
- Codex install guide (`.codex/INSTALL.md`)
