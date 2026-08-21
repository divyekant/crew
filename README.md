# crew

**Host-adaptive multi-model build orchestrator.** Your session model acts as
the controller. It decomposes implementation work, dispatches each domain to
its required worker, reviews every diff, and integrates the results. Crew
supports Claude Code and Codex controllers from one shared skill.

| Worker definition | Domain |
|---|---|
| [`frontend.md`](skills/crew/workers/frontend.md) | Components, styling, layout, UX states, accessibility |
| [`backend.md`](skills/crew/workers/backend.md) | APIs, services, DB/schema, auth, business logic |
| [`mechanical.md`](skills/crew/workers/mechanical.md) | Tests, fixtures, renames, codemods, boilerplate |

The worker definitions are the operational source of truth for models,
reasoning effort, transports, and failure behavior. Full cited research:
[`docs/research/findings.md`](docs/research/findings.md).

## How it works

1. **Decompose** — the orchestrator classifies each work item by dominant
   domain. Full-stack features go contract-first: it authors the interface
   contract, then frontend and backend dispatch in parallel against it.
2. **Brief** — every worker gets a self-contained brief: goal, files it
   exclusively owns, out-of-scope list, constraints, acceptance criteria,
   iteration cap, return format. Per-worker specifics live in
   [`skills/crew/workers/`](skills/crew/workers/).
3. **Dispatch** — independent workers run in parallel; concurrent
   same-repo work gets git worktree isolation; one file, one owner.
4. **Review** — the controller applies the review gate in `SKILL.md` before it
   accepts worker output.
5. **Report** — per-worker attribution plus what was verified.

The controller does not implement substantive worker-owned work. Small fixes
usually do not need Crew. When Crew is active, each worker definition still
controls its domain.

## Install

### Claude Code

Via marketplace:

```sh
claude plugin marketplace add divyekant/dk-marketplace
claude plugin install crew
```

Or manual:

```sh
git clone https://github.com/divyekant/crew.git
ln -s "$(pwd)/crew/skills/crew" ~/.claude/skills/crew
```

**Requirements:** Claude Code with subagent support and the
[openai-codex plugin](https://github.com/openai/codex-plugin-cc) with
`codex login` completed.

### Codex

See [`.codex/INSTALL.md`](.codex/INSTALL.md).

## Usage

Just work normally — crew triggers when a task reaches substantive
multi-file implementation — or invoke it explicitly:

```text
/crew build the share-link feature: API endpoint + settings UI + tests
```

## Customize

- **Shared orchestration**: edit
  [`skills/crew/SKILL.md`](skills/crew/SKILL.md).
- **Worker behavior**: each worker's model, transport, domain, brief additions,
  failure behavior, and review focus live in one file under
  [`skills/crew/workers/`](skills/crew/workers/).
- **Pipelines**: using [skill-conductor](https://github.com/divyekant/skill-conductor)?
  Add `crew` to the build phase of your substantial pipelines; keep it out
  of small-fix pipelines.

## Docs

- Current design: [`docs/superpowers/specs/2026-08-20-cross-host-routing-design.md`](docs/superpowers/specs/2026-08-20-cross-host-routing-design.md)
- Original design: [`docs/superpowers/specs/2026-06-10-crew-design.md`](docs/superpowers/specs/2026-06-10-crew-design.md)
- Research (routing split, brief protocol, anti-patterns): [`docs/research/`](docs/research/)
- Changelog: [`CHANGELOG.md`](CHANGELOG.md)

## License

[MIT](LICENSE)
