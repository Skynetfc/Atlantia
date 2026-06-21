# Contributing to Atlantia

Atlantia is the merged product of the agency-agents persona library and the Ruflo runtime.
This document covers how to contribute persona files, run the eval harness, and understand
the governance structure that every contribution flows through.

---

## Before You Start

Read these three documents first:

1. `constitution.md` — the rules that override everything else
2. `templates/agent-template.md` — the required structure for every persona file
3. `atlas-core/governance/roles.json` — who can approve what

---

## Two-Tier Change Process

| Change type | Process |
|---|---|
| **Minor** (single persona wording, small rule addition, bug fix) | Standard PR review by a Judiciary Reviewer — no RFC needed |
| **Major** (new state/division, new cross-cutting agent, constitutional amendment) | Written RFC required — see RFC Process below |

### Minor changes

1. Fork the repo and create a branch
2. Make your change to the relevant persona file
3. Run `./scripts/build-atlas-core.sh` to regenerate `atlas-core/agents/`
4. Open a PR — the eval harness will run automatically on the changed agent's task files (if coverage exists)
5. A Judiciary Reviewer reviews and approves

### RFC Process (major changes)

For any new division, new cross-cutting agent (like those in `quality/` or `specialized/`), or constitutional amendment:

1. Open an Issue describing: problem statement, proposed change, alternatives considered, benchmark plan
2. Constitutional Council reviews the RFC *before* implementation begins
3. If approved: implement the change, open a PR, go through normal review
4. If rejected: the RFC stays as a record of the decision

---

## Writing a New Persona

Use the template at `templates/agent-template.md`. Every field in the frontmatter is required
or has a documented reason for being optional.

### Naming

- `name` field: must be globally unique. Run `grep -r "^name: " */` before adding.
- `ruflo_type`: must be prefixed `atlas-` — this prevents collisions with Ruflo's native agent type names.
- File name: `<division>-<descriptive-slug>.md`

### Memory tier (required, not optional)

| Your persona is in... | memory_tier |
|---|---|
| `legal/`, `finance/`, `security/` (regulated), `specialized/healthcare-*`, `specialized/medical-*`, `specialized/hr-*`, `specialized/loan-*`, `specialized/real-estate-*` | `ephemeral` |
| All other divisions | `project-scoped` |
| Special case: regulated persona with user-explicit persistence | `opt-in-persistent` (requires human override flag at runtime) |

### Critical Rules section

Write rules that are **objectively checkable**. A rule that can't be verified against output isn't a rule — it's a wish.

- ✅ "Must produce at least one concrete, falsifiable objection, or explicitly state 'no material objection found' with reasoning"
- ❌ "Should be thorough and helpful" (not checkable)

### Eval coverage

If your persona will be a high-traffic agent (used in most sessions), add at least 3 task files in `atlas-core/eval/tasks/<division>/<agent-name>/task-NNN.json`. Use the format from existing tasks. The rubric files in `atlas-core/eval/rubrics/` can be reused across agents with the same task type.

---

## New Agent Pipeline (Naturalization)

All new agents enter as `status: probationary`:

1. **Draft**: Dynamic Agent Synthesizer or contributor creates persona using the template
2. **Sandbox only**: `status: probationary` means the agent runs only via `--dry-run` or the Simulation Sandbox Agent
3. **Eval**: Agent Evaluator benchmark run — at least 3 tasks
4. **Human review**: Commissioning Officer reviews eval results
5. **Naturalization**: `status: probationary` → `status: active` — agent is spawnable in live swarms
6. **Ongoing**: Deprecation Auditor monitors eval data; may recommend `status: revoked` if performance is flat

---

## Deprecation and Archiving

Revoked agents:

- Are NOT deleted — files move to `archive/` after one full minor version cycle
- Remain readable for history and Lessons Ledger purposes
- Swarm plans referencing a revoked agent by name fail with a clear message pointing to its replacement

---

## Versioning

Atlantia uses Semantic Versioning for `atlas-core`:

- **Major**: breaking changes to the persona conversion schema or CLI commands
- **Minor**: new agents, new states, new eval tasks
- **Patch**: wording fixes, Critical Rules additions, rubric adjustments

Document your version impact in your PR description so reviewers know which version bump it warrants.

---

## Ruflo Upgrade Procedure

Ruflo is pinned in `package.json` (optionalDependencies). When upgrading:

1. Read Ruflo's changelog for the target version
2. Run the full validation checklist from `constitution.md` and `prompt1.md` Section 7 against the new version in a branch
3. Run `./scripts/build-atlas-core.sh` and confirm agent spawning still works
4. Run the no-ruflo smoke test: `.github/workflows/no-ruflo-smoke.yml` logic manually
5. Only then bump the pinned version, with the Ruflo delta noted in CHANGELOG.md

---

## Code of Conduct

Atlantia's "Official Language" (per the national charter) is plain, hype-free technical English.

In practice:
- Make claims that are checkable, not aspirational
- Cite sources for performance claims or don't make them
- Negative eval results are a contribution, not an embarrassment — they're how the Deprecation Auditor works
- Attribution: Ruflo built the runtime. Agency-agents built the original personas. Be explicit about where things come from.

---

## Questions?

Open an issue. The governance structure is documented in `constitution.md` and `atlas-core/governance/` — most process questions are answered there.
