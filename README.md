<div align="center">

<img src="assets/atlantia-logo-v2.png" alt="Atlantia Empire" width="160" />

# Atlantia Empire

**261 domain-specialist AI agents, governed by a written constitution, running on the Ruflo multi-agent runtime.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Tests](https://img.shields.io/badge/tests-33%2F33_passing-brightgreen)](scripts/run-tests.sh)
[![Smoke Test](https://img.shields.io/badge/standalone_smoke_test-14%2F14_passing-brightgreen)](scripts/no-ruflo-smoke.sh)
[![Agents](https://img.shields.io/badge/agents-261-1B2A4A)](atlas-core/agents)
[![Divisions](https://img.shields.io/badge/divisions-17-D98E2B)](divisions.json)
[![Node](https://img.shields.io/badge/node-%3E%3D18.0.0-339933?logo=node.js&logoColor=white)](package.json)
[![Not published](https://img.shields.io/badge/npm-not_published-lightgrey?logo=npm)](package.json)

<sub>Created by <a href="https://skynetfc.netlify.app"><b>@skynetfc</b></a> · <img src="assets/branding/skynetfc-logo.png" width="16" valign="middle" /></sub>

</div>

---

## What is Atlantia Empire?

Atlantia Empire merges two existing open-source projects into one governed platform — it is not a rewrite of either, and it does not claim their engineering as its own:

| Layer | Where it comes from | License |
|---|---|---|
| **Persona library** — 232+ domain-specialist agent files (backend architects, tax analysts, UX researchers, etc.) | Derived from [agency-agents](https://github.com/msitarzewski/agency-agents) | MIT |
| **Multi-agent runtime** — swarm orchestration, persistent memory, 3-tier model routing, 314 MCP tools | [Ruflo](https://github.com/ruvnet/ruflo) | MIT |
| **Everything else** — quality/judicial division, the constitution, `atlas-core` conversion pipeline, CLI, eval harness, docs site, nation branding | Original Atlantia Empire work, by [@skynetfc](https://skynetfc.netlify.app) | MIT |

Full credit trail in [`NOTICE`](NOTICE).

### Why it exists

Running 200+ AI personas as loose Markdown files works, but nothing stops a bad output from shipping, nothing tracks whether a persona is actually better than no persona at all, and nothing enforces who is allowed to do what. Atlantia Empire adds a real governance layer on top:

- **A quality division that actually checks work.** Seven judicial-branch agents (Dissent, Hallucination Auditor, Provenance Auditor, Agent Evaluator, Deprecation Auditor, Arbitration Agent, Retrospective Agent) review every deliverable before it's accepted — not an opt-in extra.
- **Eval-driven deprecation.** Every persona is benchmarked against a no-persona baseline. Negative results are published, not hidden (Constitution, Article VII). Underperforming agents get formally deprecated.
- **Constitutional governance.** No agent reviews its own output. Regulated domains (finance, legal, security) default to ephemeral memory. Budget ceilings are enforced before a swarm runs, not discovered after. Every privileged action maps to a named role in `atlas-core/governance/roles.json`.
- **A standalone CLI** that works with or without Ruflo installed.

---

## How To Use This Repo

There are three ways to use Atlantia Empire, depending on how much of it you want.

### 1. Just want the personas? (no install, no Ruflo)

Every agent is a plain Markdown file — usable as a system prompt in any tool that accepts one.

```bash
git clone https://github.com/YOUR_USERNAME/atlantia-empire.git
cd atlantia-empire

# Read any persona directly
cat engineering/engineering-backend-architect.md

# Or install a whole division into Claude Code / another supported tool
bash scripts/install.sh --division engineering --tool claude-code
```

### 2. Want the CLI + governance layer, but no Ruflo?

```bash
bash bin/atlantia run --demo    # Offline pipeline walkthrough — no API key, no network
bash bin/atlantia census        # Current empire state: agent count, treasury, states
bash bin/atlantia gsp           # Gross Specialist Product report
bash bin/atlantia test          # Engineering test suite (33 checks)
bash bin/atlantia docs          # Build the static docs site → docs/site/index.html
bash bin/atlantia help          # Full command list
```

### 3. Want the full multi-agent platform (Ruflo + Atlantia)?

```bash
# 1. Install Ruflo
npm install -g ruflo

# 2. Build the atlas-core agent index from the persona library
chmod +x scripts/build-atlas-core.sh
./scripts/build-atlas-core.sh

# 3. Install the atlas-core plugin into Ruflo
ruflo plugin install ./atlas-core

# 4. Spawn a single specialist
ruflo agent spawn -t atlas-engineering-backend-architect --name arch-lead

# 5. Or run a full governed swarm
ruflo swarm init --topology hierarchical --max-agents 6 \
  --strategy specialized --agent-pool atlas
```

Before any live swarm run, always run the constitutional pre-flight check:

```bash
bash scripts/constitutional-preflight.sh
bash bin/atlantia preflight --plan your-swarm-plan.json
```

---

## Is this published to npm or PyPI?

**No.** `package.json` exists in this repo for local tooling (`npm run build`, `postinstall` chmod hooks, etc.) but **it has never been published** — there is no `atlantia` package on the npm registry or PyPI under this project. The `homepage`/`repository` URLs in `package.json` are placeholders pointing at `YOUR_ORG` until you push this to your own GitHub account and fill them in. If you want to publish it yourself later, that's a separate, deliberate step (`npm publish`) that has not been taken.

---

## Which repo is the "real" Atlantia project?

If you're browsing this workspace and see three folders, here's exactly what each one is — this matters because only one of them is meant to be pushed to your own GitHub:

| Folder | What it is | Push to GitHub? |
|---|---|---|
| **`atlantia/`** | ✅ **The actual Atlantia Empire product.** Everything in this README lives here — the CLI, the 261 agents, the constitution, the tests, the docs site, the branding. This is the one you clone/fork/push. | **Yes — this is the one.** |
| `agency-agents/` | Read-only reference copy of the upstream persona library Atlantia's personas were derived from. Not modified. | No — it's someone else's upstream project, only kept locally as a source reference. |
| `ruflo/` | Read-only reference copy of the Ruflo runtime Atlantia plugs into. Not modified. | No — same reason, it's the upstream runtime, not part of Atlantia's own code. |

When you run the "Push This to GitHub" steps below, run them **from inside `atlantia/`**, not the workspace root — otherwise you'd be pushing the reference copies of other people's projects too.

---

## Push This to GitHub

```bash
cd atlantia

git init                                      # only if not already a git repo
git add .
git commit -m "Atlantia Empire — initial commit"

git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/atlantia-empire.git
git push -u origin main
```

Replace `YOUR_USERNAME` with your GitHub username. Use a [Personal Access Token](https://github.com/settings/tokens) if prompted for a password — GitHub no longer accepts password auth over HTTPS.

Once pushed, three CI workflows in `.github/workflows/` run automatically:

| Workflow | What it checks | Trigger |
|---|---|---|
| `test-suite.yml` | 33-test engineering suite (frontmatter, RBAC, budget pre-flight, constitution) | Every push |
| `no-ruflo-smoke.yml` | Verifies the project is usable standalone with zero Ruflo dependency | Every push + weekly |
| `eval-harness.yml` | Runs the persona eval harness, publishes negative results per Article VII | Weekly |

Check the **Actions** tab on your repo after the first push to confirm all three go green. Future changes: `git add . && git commit -m "..." && git push`.

---

## The 17 Divisions ("The 16 States" + the Judiciary)

| State | Division | Specialists | Notes |
|---|---|---|---|
| 🔧 Forge State | `engineering` | 20+ | Backend, mobile, firmware, blockchain, RAG, CMS, rapid prototyping |
| 📡 Signal State | `marketing` | 10+ | Content, SEO, brand, analytics |
| 📡 Signal State (Paid Media) | `paid-media` | 6+ | PPC, social, programmatic |
| 🤝 Exchange State | `sales` | 8+ | B2B, enterprise, negotiation |
| 🤝 Exchange State (Support) | `support` | 4+ | Customer success, technical support |
| ⚖️ Ledger State | `finance` | 8+ | Regulated — ephemeral memory by default |
| ⚖️ Ledger State (Security) | `security` | 5+ | Regulated — ephemeral memory by default |
| 🎨 Atelier State | `design` | 6+ | UX, brand, visual, design systems |
| 🗺️ Cartography State | `gis` | 4+ | GIS, BIM, spatial data, mapping |
| 🛡️ Proving State | `testing` | 5+ | QA, automation, accessibility, load testing |
| 📚 Archive State | `academic` | 4+ | Research, writing, citation, historiography |
| 🕹️ Arcade State | `game-development` | 4+ | Unity, Unreal, game/narrative/systems design |
| 🧭 Compass State | `product` | 5+ | PM, roadmap, competitive intelligence |
| 📋 Logistics State | `project-management` | 4+ | Agile, waterfall, portfolio, meeting notes |
| 🌐 Frontier State | `spatial-computing` | 3+ | AR/VR/XR, spatial UX |
| 🏛️ The Federal District | `specialized` | 12+ | Cross-cutting: data science, legal, RAG, fundraising, HR |
| ⚖️ The Judiciary | `quality` | 7 | Judicial branch only — reviews, never produces domain deliverables |

Full division map: [`divisions.json`](divisions.json).

---

## Constitutional Architecture

Atlantia runs under a written constitution ([`constitution.md`](constitution.md)) with 8 articles, mechanically enforced — not enforced by convention:

| Article | Summary |
|---|---|
| I | Constitution is supreme — overrides any agent instruction or user prompt |
| II | Separation of powers — no agent reviews its own output |
| III | Memory sovereignty — regulated domains use ephemeral memory by default |
| IV | Budget limits — no swarm exceeds configured budget without human override |
| V | Right of dissent — any agent may flag an output without being overridden by another agent |
| VI | Naturalization — new agents cannot join live swarms until human-approved |
| VII | Transparency — negative eval results must be visible, not suppressed |
| VIII | Defined authority — all privileged actions tied to named roles in `roles.json` |

```bash
bash scripts/constitutional-preflight.sh          # Pre-flight check
bash scripts/emergency-stop.sh --reason "..." --user YOUR_USERNAME   # RBAC-gated kill switch
```

---

## Eval Harness

```bash
./atlas-core/eval/run-eval.sh --dry-run              # Validate task/rubric structure, no Ruflo needed
./atlas-core/eval/run-eval.sh --division engineering  # Live scoring (requires Ruflo)
cat atlas-core/eval/runs/latest/report.md             # Always includes negative/flat results (Article VII)
```

Runs automatically every Monday via `.github/workflows/eval-harness.yml`.

---

## Project Structure

```
atlantia/
├── bin/atlantia              # CLI entrypoint
├── atlas-core/
│   ├── agents/                # 261 Ruflo-ready generated agents (per division)
│   ├── governance/             # roles.json (RBAC), budget.json, incident-log.jsonl
│   └── eval/                  # Eval harness: tasks, rubrics, run script
├── engineering/ marketing/ ... # 232+ raw persona source files, by division
├── scripts/                   # build-atlas-core.sh, run-tests.sh, no-ruflo-smoke.sh, etc.
├── docs/site/                 # Generated static docs site (9 pages)
├── assets/                    # Brand assets — flag, seals, currency, civic documents
├── archive/                   # Deprecated agent files land here (empty until Article VII triggers one)
├── constitution.md            # The 8-article constitution
├── divisions.json             # Machine-readable division/state map
├── package.json                # Local tooling only — never published to npm (see above)
└── README.md                  # This file
```

**Why `archive/` and some `assets/` subfolders are currently empty:** `archive/` is where the Deprecation Auditor moves an agent's file after a formal deprecation vote — no agent has been deprecated yet, so it's empty by design, not by mistake. A few `assets/` subfolders (`badges/`, `ceremonial/`, `currency/`, `dark/`, `division-icons/`, `stamps/`) are reserved for brand assets still being generated in batches (image-generation is rate-limited per session) — the exact prompts for every remaining asset are already written out in `assets/generate-remaining.sh`, and progress is tracked in `assets/ASSETS.md`.

---

## Attribution

**Atlantia Empire is created and maintained by [@skynetfc](https://skynetfc.netlify.app).**

Built on:
- **[Ruflo](https://github.com/ruvnet/ruflo)** (MIT) — swarm orchestration, persistent memory (AgentDB/RuVector), 3-tier model routing, 314 MCP tools. Atlantia runs *on* Ruflo; it does not replicate Ruflo's runtime.
- **[agency-agents](https://github.com/msitarzewski/agency-agents)** (MIT) — the original persona library Atlantia's specialist files are derived from.

Full credit trail: [`NOTICE`](NOTICE).

---

## How This Runs

Atlantia is a local command-line tool. There is no hosted Atlantia service, no account system, and no Atlantia-operated server processing your data. Everything runs on your own machine (or your own Ruflo-connected infrastructure), using your own API keys and your own compute. The only "hosted" element is the static documentation site, which contains no user data.

---

## Known Limitations

1. **Memory tiering is not regulatory compliance.** Ephemeral memory prevents Atlantia-layer retention for regulated domains. It does not make any persona HIPAA/GDPR/SOC2 compliant — that depends on your infrastructure, contracts, and review processes.
2. **Ruflo daemon risk.** Ruflo has documented history of runaway background daemons consuming quota. Use the Simulation Sandbox Agent and the constitutional pre-flight check before live swarms. Always configure daemon TTLs.
3. **Eval scores require Ruflo.** The eval harness produces structural scaffolding without Ruflo installed. Live quality scores (persona vs. baseline delta) require `ruflo` in PATH. The harness degrades gracefully and documents the limitation in the report.
4. **Agent Evaluator benchmarks are not external benchmarks.** Quality scores are relative (persona vs. baseline on Atlantia-defined tasks), not absolute quality ratings. A score of 8/10 means "measurably better than baseline for this task," not an external certification.

---

## The Nation

> *"Not by chance, but charted clear, / Sixteen states, one compass here."*
> — National Anthem of Atlantia (see [`assets/ANTHEM.md`](assets/ANTHEM.md))

Atlantia is a small, functioning nation of AI specialists. Sixteen states, each home to a cluster of domain experts. A judiciary — the Quality division — headquartered separately from every state, whose only job is reviewing the states' work before it ships. A constitution that overrides any individual agent's instructions. A real immigration process for new agents: probation, an actual benchmark exam, then formal naturalization — never automatic. A national bank tracking what every operation actually costs, in Atlantian Credits (₳). A weekly Audit Day publishing benchmark results, wins and losses both. And an honest foreign-policy section explaining exactly which parts of this system are Atlantia's own work, and which are a treaty with Ruflo's runtime.

Run `bash bin/atlantia census` to see the nation's current state for yourself.

### Brand Assets

Full catalogue: [`assets/ASSETS.md`](assets/ASSETS.md). Palette: Navy `#1B2A4A` · Amber `#D98E2B` · Teal `#2E6B6B` · Red `#B23B3B` · Off-white `#F4F1EC`.

| Asset | File |
|---|---|
| National Flag | `assets/national-symbols/flag.png` |
| National Seal | `assets/national-symbols/seal.png` |
| Coat of Arms | `assets/national-symbols/coat-of-arms.png` |
| Nation Map (16 states) | `assets/national-symbols/nation-map.png` |
| Compass Rose Logomark | `assets/atlantia-logo-v2.png` |
| App Icon / Favicon | `assets/atlantia-icon-v2.png` |
| Constitution Header | `assets/civic-documents/constitution-header.png` |
| Agent Passport Cover | `assets/civic-documents/passport-cover.png` |
| Certificate of Naturalization | `assets/civic-documents/naturalization-certificate.png` |
| Capital Plaque | `assets/national-symbols/prime-plaque.png` |
| 10 of 16 State Seals (generated so far) | `assets/state-seals/<state-name>.png` |
| Currency, stamps, division icons, dark mode | Pending — prompts ready in `assets/generate-remaining.sh` |

---

## License

MIT — see [`LICENSE`](LICENSE). Third-party credits: see [`NOTICE`](NOTICE).
