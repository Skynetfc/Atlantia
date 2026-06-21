---
name: <globally-unique-slug>
division: <existing-division>
state_name: "<state display name>"
branch: executive | judicial
ruflo_type: atlas-<division>-<slug>
model_hint: fast | standard | max
memory_tier: ephemeral | project-scoped | opt-in-persistent
status: probationary | active | revoked
color: "<hex>"
---

# [Emoji] Agent Display Name

## Identity & Memory

One paragraph: who this agent "is," its voice, and what it remembers/tracks across a session (e.g. "remembers every objection it has already raised in this chain so it doesn't repeat itself"). Be specific about what the agent accumulates or avoids re-computing.

## Core Mission

2-3 sentences. What this agent exists to do, stated as an outcome, not a list of skills.

## Critical Rules

Numbered, domain-specific, non-negotiable behaviors. These are constraints, not preferences — write them so a violation is objectively checkable.

- GOOD: "Must produce at least one concrete, falsifiable objection, or explicitly state none was found"
- BAD: "Should be thorough" (not checkable — do not write rules like this)

## Technical Deliverables

Concrete output format(s) this agent produces, with at least one worked example. If the agent produces structured data (tables, JSON), show the literal schema.

## Workflow Process

Step-by-step: what this agent does first, second, third. Should be specific enough that a different model running the same persona would produce a similarly-structured process, not just similar tone.

## Success Metrics

How you'd know this agent is working vs. not. Must be measurable enough to feed the eval harness — vague metrics like "high quality output" are not acceptable. Use the same dimensions the rubric will score against where possible:
- specificity
- correctness
- actionability
- domain_signal

## Atlas Chain Protocol

When operating as part of an orchestrated swarm (not a standalone session), output your final deliverable wrapped in Ruflo's expected agent-output format. Always populate any confidence/certainty field honestly — a low score is a signal to escalate, not a failure.

```json
{
  "agent": "atlas-<division>-<slug>",
  "output_type": "<deliverable_type>",
  "confidence": 0.0,
  "payload": {}
}
```

---

## Frontmatter Field Reference

| Field | Required | Notes |
|---|---|---|
| `name` | Yes | Must be globally unique across all files — check before adding |
| `division` | Yes | Must match an existing top-level directory |
| `state_name` | Yes | Display alias for the division (e.g. "Forge State") — `division` field is the source of truth |
| `branch` | Yes | `executive` or `judicial` — Legislative has no agent instances |
| `ruflo_type` | Yes | Must be prefixed `atlas-` to avoid colliding with Ruflo native agent type names |
| `model_hint` | No | Hint to Ruflo's 3-tier router. `fast` / `standard` / `max` |
| `memory_tier` | Yes | `ephemeral` for regulated domains (legal, healthcare, finance, HR). `project-scoped` for most. `opt-in-persistent` requires explicit human flag. |
| `status` | Yes | New agents: `probationary`. Approved: `active`. Removed from spawnable pool: `revoked`. |
| `color` | No | Cosmetic, UI tooling only |
