<!-- APOLLO:START - Do not edit this section manually -->
## Project Conventions (managed by Apollo)
- Language: markdown, package manager: none
- Commits: conventional style (feat:, fix:, chore:, etc.)
- Never auto-commit — always ask before committing
- Branch strategy: feature branches
- Code style: concise, comments: minimal
- Design before code: always run brainstorming/design phase first
- Design entry: invoke conductor skill for all design/brainstorm work
- Maintain README.md
- Maintain CHANGELOG.md
- Maintain a Quick Start guide
- Maintain architecture documentation
- Track decisions in docs/decisions/
- Update docs on: feature
- Code review required before merging
- Versioning: semver
- Check for secrets before committing
<!-- APOLLO:END -->

# crew

Multi-model build orchestrator skill. The `skills/crew/` directory is the
operational source. `SKILL.md` owns shared orchestration. Worker definitions
own routing. Keep manifests, pipelines, and project instructions free of
copied model maps.
