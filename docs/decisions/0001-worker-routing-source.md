# Decision 0001: Keep Worker Routing in Worker Definitions

Date: 2026-08-20
Status: accepted

## Decision

The files under `skills/crew/workers/` are the only operational source for
worker models, reasoning effort, transports, and failure behavior.

`SKILL.md` links to those definitions and owns the shared orchestration
contract. READMEs, manifests, pipeline comments, and architecture documents
describe Crew without copying its routing table.

## Reason

The previous routing appeared in metadata, the main skill, worker files, and
pipeline comments. Those copies drifted when model availability changed.

## Consequence

A routing change updates one worker definition. Supporting documents can
record the decision or release note, but they do not become executable
guidance.
