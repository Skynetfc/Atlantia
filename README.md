<div align="center">

<img src="assets/atlantia-logo-v2.png" alt="Atlantia Empire" width="140" />

# Atlantia Empire

### Constitutional Multi-Agent AI Governance Platform

**261 domain-specialist AI agents · 17 divisions · a written constitution · a judiciary that reviews every deliverable**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Tests](https://img.shields.io/badge/tests-33%2F33_passing-brightgreen)](scripts/run-tests.sh)
[![Smoke Test](https://img.shields.io/badge/standalone-14%2F14_passing-brightgreen)](scripts/no-ruflo-smoke.sh)
[![Agents](https://img.shields.io/badge/agents-261-1B2A4A)](atlas-core/agents)
[![Divisions](https://img.shields.io/badge/divisions-17-D98E2B)](divisions.json)
[![Node](https://img.shields.io/badge/node-%3E%3D18.0.0-339933?logo=node.js&logoColor=white)](package.json)
[![Built by skynetfc](https://img.shields.io/badge/built_by-%40skynetfc-B23B3B)](https://skynetfc.netlify.app)

[Overview](#overview) ·
[Architecture](#architecture) ·
[Installation](#installation) ·
[Usage](#usage) ·
[CLI Reference](#cli-reference) ·
[Divisions](#divisions) ·
[Constitution](#constitution) ·
[Testing](#testing--ci) ·
[Repository Layout](#repository-layout) ·
[Contributing](#contributing) ·
[License](#license--attribution)

</div>

---

## Overview

Atlantia Empire is a governance layer for large multi-agent AI systems. It combines a library of 261 domain-specialist agents with a written constitution, a judiciary that reviews every deliverable before it ships, and an economic/operational model that tracks cost, quality, and authority for every agent action.

It is built on two upstream open-source projects rather than reinventing them:

| Layer | Provided by | License | Role |
|---|---|---|---|
| Persona library | [agency-agents](https://github.com/msitarzewski/agency-agents) | MIT | 232+ source persona files across engineering, marketing, finance, design, and more |
| Multi-agent runtime | [Ruflo](https://github.com/ruvnet/ruflo) | MIT | Swarm orchestration, persistent memory (AgentDB/RuVector), 3-tier model routing, 314 MCP tools |
| Governance layer | Atlantia Empire (this project) | MIT | Judicial/quality division, constitution, `atlas-core` conversion pipeline, CLI, eval harness, RBAC, budget enforcement |

Full third-party credit trail is documented in [`NOTICE`](NOTICE).

### Why a governance layer

Running 200+ AI personas as loose prompt files is straightforward, but it leaves three problems unsolved: nothing catches a bad output before it ships, nothing measures whether a given persona is actually better than no persona at all, and nothing enforces which agent is allowed to take which action. Atlantia Empire addresses each directly:

- **Judicial review is mandatory, not optional.** Seven judicial-branch agents — Dissent Agent, Hallucination Auditor, Provenance Auditor, Agent Evaluator, Deprecation Auditor, Arbitration Agent, Retrospective Agent — review every deliverable from an executive-branch agent before it is accepted.
- **Evaluation drives deprecation.** Every persona is benchmarked against a no-persona baseline. Negative and flat results are published, never suppressed (Constitution, Article VII), and the Deprecation Auditor formally retires personas that don't earn their keep.
- **Authority is explicit.** Every privileged action (spawning a swarm, approving naturalization, invoking emergency stop) maps to a named role in `atlas-core/governance/roles.json`. No agent can grant itself authority.
- **Cost and memory are governed up front.** Budget ceilings are enforced at pre-flight, not discovered after the fact. Regulated domains (finance, legal, security, HR) default to ephemeral memory.
- **A standalone CLI.** All governance features work without any hosted service — `atlantia census`, `gsp`, `preflight`, `emergency-stop`, and more run entirely on your own machine.

---

## Architecture

```
                     ┌─────────────────────────────┐
                     │        Constitution          │
                     │   (8 articles — supreme)     │
                     └──────────────┬───────────────┘
                                    │ governs
        ┌───────────────────────────┼───────────────────────────┐
        │                            │                            │
┌───────▼────────┐         ┌────────▼─────────┐        ┌─────────▼────────┐
│  Executive      │         │   Judicial        │        │   Governance      │
│  (16 states /   │  work → │   (Quality div.,  │  logs  │   (roles.json,    │
│  divisions)     │ product │   7 agents)        │ ──────▶│   budget.json,    │
│  261 agents     │────────▶│   reviews before   │        │   incident log)   │
│                 │         │   acceptance       │        │                    │
└───────┬────────┘         └────────┬─────────┘        └───────────────────┘
        │                            │
        │           runs on          │
        └──────────────┬─────────────┘
                        │
              ┌─────────▼──────────┐
              │       Ruflo         │
              │  swarm orchestration │
              │  memory · model      │
              │  routing · MCP tools │
              └─────────────────────┘
```

`atlas-core/` is the conversion layer that turns the 232+ raw persona Markdown files into Ruflo-compatible agent types with the correct frontmatter (`ruflo_type`, `memory_tier`, `state_name`, naturalization `status`). It is regenerated with `scripts/build-atlas-core.sh` whenever a persona is added or edited.

---

## Installation

**Requirements:** bash, git. Ruflo (optional — see [Usage](#usage) for standalone mode) requires Node.js ≥ 18.

```bash
git clone https://github.com/YOUR_USERNAME/atlantia-empire.git
cd atlantia-empire

chmod +x bin/atlantia scripts/*.sh atlas-core/eval/run-eval.sh
```

No package is installed from a registry — see [Package & Publishing Status](#package--publishing-status).

---

## Usage

Atlantia Empire operates in three modes depending on how much of the platform you need.

### Mode 1 — Persona library only (no CLI, no Ruflo)

Every agent is a plain Markdown file usable as a system prompt in any tool that accepts one.

```bash
cat engineering/engineering-backend-architect.md
bash scripts/install.sh --division engineering --tool claude-code
```

### Mode 2 — CLI and governance layer, standalone

Runs entirely offline, with no API keys and no network calls.

```bash
bash bin/atlantia run --demo    # Offline pipeline walkthrough
bash bin/atlantia census        # National state: agent count, treasury, states
bash bin/atlantia gsp           # Gross Specialist Product report
bash bin/atlantia test          # Engineering test suite (33 checks)
bash bin/atlantia docs          # Build the static documentation site
```

### Mode 3 — Full multi-agent platform (Ruflo + Atlantia)

```bash
npm install -g ruflo
./scripts/build-atlas-core.sh
ruflo plugin install ./atlas-core

ruflo agent spawn -t atlas-engineering-backend-architect --name arch-lead

ruflo swarm init \
  --topology hierarchical \
  --max-agents 6 \
  --strategy specialized \
  --agent-pool atlas
```

Always run the constitutional pre-flight check before a live swarm:

```bash
bash scripts/constitutional-preflight.sh
bash bin/atlantia preflight --plan your-swarm-plan.json
```

---

## CLI Reference

```
atlantia census                          Show current nation state
atlantia gsp [--period weekly|daily]     Gross Specialist Product report
atlantia emergency-stop                  Kill all swarms and daemons (RBAC-gated)
  --reason "..." --user <github-username>
atlantia improvement-report              Rolling quality improvement trend
  [--since YYYY-MM-DD]
atlantia build [--dry-run]               Regenerate atlas-core/agents/ from source personas
  [--division <name>] [--verbose]
atlantia preflight --plan <file>         Constitutional pre-flight check for a swarm plan
atlantia run --demo                      Offline pipeline demo, no API key required
atlantia docs [--serve]                  Build the static documentation site
atlantia test                            Run the engineering test suite
atlantia help                            Show the command list
atlantia version                         Show version
```

---

## Divisions

Atlantia organizes its 261 agents into 17 divisions, referred to internally as "states." Each maps to a directory of persona source files and a corresponding entry in [`divisions.json`](divisions.json).

| Division | State | Specialists | Focus |
|---|---|---|---|
| `engineering` | Forge State | 20+ | Backend, mobile, firmware, blockchain, RAG, CMS, rapid prototyping |
| `marketing` | Signal State | 10+ | Content, SEO, brand, analytics |
| `paid-media` | Signal State (Paid Media) | 6+ | PPC, social, programmatic |
| `sales` | Exchange State | 8+ | B2B, enterprise, negotiation |
| `support` | Exchange State (Support) | 4+ | Customer success, technical support |
| `finance` | Ledger State | 8+ | Regulated — ephemeral memory by default |
| `security` | Ledger State (Security) | 5+ | Regulated — ephemeral memory by default |
| `design` | Atelier State | 6+ | UX, brand, visual, design systems |
| `gis` | Cartography State | 4+ | GIS, BIM, spatial data, mapping |
| `testing` | Proving State | 5+ | QA, automation, accessibility, load testing |
| `academic` | Archive State | 4+ | Research, writing, citation, historiography |
| `game-development` | Arcade State | 4+ | Unity, Unreal, game/narrative/systems design |
| `product` | Compass State | 5+ | PM, roadmap, competitive intelligence |
| `project-management` | Logistics State | 4+ | Agile, waterfall, portfolio, meeting notes |
| `spatial-computing` | Frontier State | 3+ | AR/VR/XR, spatial UX |
| `specialized` | The Federal District | 12+ | Cross-cutting: data science, legal, RAG, fundraising, HR |
| `quality` | The Judiciary | 7 | Review only — never produces domain deliverables |

---

## Constitution

Atlantia operates under a written constitution ([`constitution.md`](constitution.md)) with eight articles, enforced mechanically by the governance layer rather than by convention.

| Article | Provision |
|---|---|
| I | Constitution is supreme — overrides any agent instruction or user prompt |
| II | Separation of powers — no agent reviews its own output |
| III | Memory sovereignty — regulated domains use ephemeral memory by default |
| IV | Budget limits — no swarm exceeds its configured budget without human override |
| V | Right of dissent — any agent may flag an output without being overridden by another agent |
| VI | Naturalization — new agents cannot join live swarms until human-approved |
| VII | Transparency — negative evaluation results must be visible, never suppressed |
| VIII | Defined authority — all privileged actions are tied to named roles in `roles.json` |

```bash
bash scripts/constitutional-preflight.sh
bash scripts/emergency-stop.sh --reason "runaway daemon" --user YOUR_USERNAME
```

### Evaluation Harness

```bash
./atlas-core/eval/run-eval.sh --dry-run               # Validate task/rubric structure
./atlas-core/eval/run-eval.sh --division engineering   # Live scoring (requires Ruflo)
cat atlas-core/eval/runs/latest/report.md              # Always includes negative/flat results (Article VII)
```

The eval harness runs automatically every Monday via `.github/workflows/eval-harness.yml`.

---

## Testing & CI

```bash
bash scripts/run-tests.sh        # 33-test engineering suite: frontmatter, RBAC, budget pre-flight, constitution
bash scripts/no-ruflo-smoke.sh   # 14-check standalone smoke test — verifies zero Ruflo dependency
```

| Workflow | Checks | Trigger |
|---|---|---|
| `.github/workflows/test-suite.yml` | Full 33-test engineering suite | Every push |
| `.github/workflows/no-ruflo-smoke.yml` | Standalone usability with zero Ruflo dependency | Every push, weekly |
| `.github/workflows/eval-harness.yml` | Persona eval harness, publishes negative results per Article VII | Weekly |

---

## Repository Layout

```
atlantia/
├── bin/atlantia                 CLI entrypoint
├── atlas-core/
│   ├── agents/                  261 generated Ruflo-compatible agents, by division
│   ├── governance/               roles.json (RBAC), budget.json, incident-log.jsonl
│   └── eval/                    Evaluation harness: tasks, rubrics, run script
├── engineering/ marketing/ ...  232+ raw persona source files, by division
├── scripts/                     build-atlas-core.sh, run-tests.sh, no-ruflo-smoke.sh, etc.
├── docs/site/                   Generated static documentation site
├── assets/                      Brand assets — flag, seals, currency, civic documents
├── archive/                     Deprecated agent files (populated after a formal deprecation vote)
├── constitution.md              The 8-article constitution
├── divisions.json               Machine-readable division map
├── package.json                 Local tooling manifest (see below)
└── README.md
```

### Package & Publishing Status

`package.json` defines local tooling only (`npm run build`, `postinstall` chmod hooks, npm script aliases for the CLI). This project has not been published to the npm registry or PyPI. The `homepage` and `repository` fields are placeholders to be updated once you push this repository to your own GitHub account.

---

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for persona authoring conventions, the deprecation lifecycle, and pull request guidelines. See [`SECURITY.md`](SECURITY.md) to report a vulnerability.

---

## License & Attribution

Released under the [MIT License](LICENSE).

Built by [**@skynetfc**](https://skynetfc.netlify.app). Built on [Ruflo](https://github.com/ruvnet/ruflo) (MIT) and [agency-agents](https://github.com/msitarzewski/agency-agents) (MIT) — full credit trail in [`NOTICE`](NOTICE).
