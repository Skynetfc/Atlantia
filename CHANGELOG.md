# Atlantia Changelog

## [1.0.0] — 2026-06-21

### What is Atlantia 1.0.0?

This is the founding release — the merger of the agency-agents persona library with the Ruflo multi-agent runtime into a single governed platform.

### Added

**Core governance:**
- `constitution.md` — 8-article constitutional framework (Articles I–VIII)
- `atlas-core/governance/roles.json` — RBAC config: contributor, judiciary_reviewer, commissioning_officer, treasury_officer, security_officer, constitutional_council
- `atlas-core/governance/budget.json` — project budget ceiling with hard-stop enforcement
- `atlas-core/governance/alerts.json` — webhook alerting config for emergency-stop and budget overrun events
- `atlas-core/governance/ownership.json` — state/division domain reviewer map (prevents generalist reviewers approving domain content they can't evaluate)
- `atlas-core/governance/lessons-ledger.jsonl` — append-only post-project learning record

**Quality / Judicial Division (7 new agents):**
- `quality/dissent-agent.md` — flags objectionable claims, blocks rubber-stamp reviews
- `quality/hallucination-auditor.md` — claim-by-claim factual audit for externally-facing content
- `quality/provenance-auditor.md` — chain-of-custody tracking for regulated-domain artifacts
- `quality/agent-evaluator.md` — benchmark harness (persona vs. baseline, blind scoring)
- `quality/deprecation-auditor.md` — argues for removing underperforming agents
- `quality/arbitration-agent.md` — resolves Executive-branch agent conflicts
- `quality/retrospective-agent.md` — post-project learning, feeds Lessons Ledger

**New agents (prompt2.md §8.1 and §9):**
- `sales/sales-negotiation-simulator.md` — war-games actual negotiation dialogue
- `specialized/org-digital-twin-strategist.md` — simulates process changes before rollout
- `specialized/compute-footprint-auditor.md` — estimates swarm cost before running
- `specialized/data-scientist.md` — statistical modeling, experiment design
- `engineering/engineering-rag-architect.md` — retrieval pipeline design for user-facing features
- `specialized/contract-negotiator.md` — active redlining strategy (ephemeral memory, regulated)
- `specialized/fundraising-strategist.md` — pitch narrative, investor targeting
- `product/product-competitive-intelligence-analyst.md` — systematic competitor tracking
- `specialized/dynamic-agent-synthesizer.md` — immigration officer for new agents
- `specialized/capital-allocation-agent.md` — weekly GSP-driven model tier proposals
- `specialized/treaty-compliance-agent.md` — Ruflo attribution and lock-in compliance monitoring
- `testing/testing-simulation-sandbox.md` — dry-run engine for swarm plans

**atlas-core plugin layer:**
- `atlas-core/plugin.json` — Ruflo plugin manifest
- `atlas-core/install.sh` — plugin installation script
- `scripts/build-atlas-core.sh` — converts source personas to Ruflo agent format with automated memory_tier enforcement and division state_name mapping

**Eval harness:**
- `atlas-core/eval/rubrics/` — 4 rubrics: diagnostic-recommendation, audit-review, strategy-planning, content-creation
- `atlas-core/eval/tasks/` — task files for paid-media-ppc-strategist, engineering-backend-architect, engineering-code-reviewer, marketing-content-strategist, quality agents
- `atlas-core/eval/run-eval.sh` — harness runner (degrades gracefully without Ruflo)

**Templates:**
- `templates/agent-template.md` — canonical template with frontmatter field reference

**CLI:**
- `bin/atlantia` — commands: census, gsp, emergency-stop, improvement-report, build, preflight, help

**Scripts:**
- `scripts/constitutional-preflight.sh` — pre-swarm constitutional check
- `scripts/emergency-stop.sh` — immediate termination of all swarms (RBAC-gated)
- `scripts/no-ruflo-smoke.sh` — verify library works without Ruflo installed

**GitHub Actions workflows:**
- `.github/workflows/no-ruflo-smoke.yml` — standalone library verification
- `.github/workflows/treaty-compliance.yml` — Ruflo attribution and dependency hygiene
- `.github/workflows/eval-harness.yml` — weekly Audit Day eval run + PR scoring

**Documentation:**
- `README.md` — full project overview with quick start, division table, constitutional summary, known limitations
- `NOTICE` — third-party credits (Ruflo, agency-agents)
- `SECURITY.md` — disclosure process, scope, known limitations
- `CONTRIBUTING.md` — two-tier change process, persona writing guide, naturalization pipeline
- `CHANGELOG.md` — this file
- `docs/academy/getting-started.md` — new contributor guide

**Inherited (from agency-agents, MIT):**
- 232 persona files across 16 divisions, now tagged with Atlantia nation metadata (state_name, branch, ruflo_type, memory_tier, status fields)

### Breaking changes vs. agency-agents

- Persona frontmatter format is extended. The original 5 fields (`name`, `description`, `color`, `emoji`, `vibe`) are preserved. Six new fields are required for Ruflo compatibility (`ruflo_type`, `division`, `state_name`, `branch`, `memory_tier`, `status`).
- Files in `atlas-core/agents/` are generated from source personas by `build-atlas-core.sh`. Do not hand-edit generated files.
- `quality/` is a new division not present in agency-agents. It is the Judicial branch and cannot be used as an Executive-branch agent pool.

### Attribution

Ruflo is required for multi-agent features (swarm, memory, model routing). See `NOTICE` and `README Known Limitations`. Ruflo is in `optionalDependencies` — the library is fully usable without it.

---

## [0.x] — Pre-merger

Atlantia v0.x was the agency-agents persona library ("The Agency"). See the agency-agents repository changelog for that history.
