# Atlantia Academy — Getting Started

*For new contributors and new agents.*

---

## What Is Atlantia?

Atlantia is the merger of two projects:

1. **The persona library** (formerly "The Agency") — 232+ Markdown persona files across 16 divisions (engineering, marketing, legal, finance, GIS, academic, and more). Deep domain specialist knowledge.

2. **Ruflo** (https://github.com/ruvnet/ruflo) — a mature multi-agent orchestration runtime that provides swarm coordination, persistent memory (AgentDB), 3-tier model routing, and 314 MCP tools.

**Atlantia = the personas running natively as Ruflo agent types, on Ruflo's runtime, governed by the Atlantia Constitution.**

What Atlantia built itself: the atlas-core plugin layer, the quality (judicial) division, the eval harness, the governance scripts, and this CLI. Everything else is from Ruflo or the agency-agents library. This is stated plainly because honesty about what was built vs. inherited is a constitutional requirement (Article VIII).

---

## The Three Branches

Atlantia operates under a constitutional separation of powers:

### Executive Branch — "does the work"
The domain specialists: engineering, marketing, sales, legal, finance, GIS, design, and all other division agents. They produce deliverables. They cannot mark their own output as final.

### Judicial Branch — "checks the work"
The Quality division, seated in Atlantia Prime (the repo root). Includes:
- **Dissent Agent** — reviews individual outputs, flags objectionable claims
- **Hallucination Auditor** — claim-by-claim factual audit on externally-facing content
- **Provenance Auditor** — chain-of-custody tracking for regulated-domain artifacts
- **Agent Evaluator** — benchmark comparisons (persona vs. baseline)
- **Deprecation Auditor** — argues for removing agents that don't measurably help
- **Arbitration Agent** — resolves conflicts between two Executive-branch agents
- **Retrospective Agent** — post-project learning, feeds the Lessons Ledger

The Judicial branch reviews work. It cannot produce original domain deliverables.

### Legislative Branch — "sets the rules"
The Constitution itself (`constitution.md`) plus each persona's Critical Rules section. It has no agent identity — it constrains both other branches.

---

## Writing Your First Persona

**1. Copy the template:**
```bash
cp templates/agent-template.md <division>/<division>-<your-agent-name>.md
```

**2. Fill in the frontmatter:**
```yaml
---
name: <globally-unique-slug>         # check with: grep -r "^name: " */
division: <existing-division>
state_name: "<state display name>"   # see divisions.json
branch: executive                    # or judicial (quality division only)
ruflo_type: atlas-<division>-<slug>  # must start with atlas-
memory_tier: project-scoped          # or ephemeral for regulated domains
status: probationary                 # new agents always start here
---
```

**3. Write Critical Rules that are objectively checkable:**
- ✅ "Must produce at least one falsifiable objection or state 'no material objection found' with reasoning"
- ❌ "Should be helpful and thorough" (not checkable — don't write rules like this)

**4. Add eval tasks** (for high-traffic agents):
```bash
mkdir -p atlas-core/eval/tasks/<division>/<your-agent-name>/
# Create task-001.json, task-002.json, task-003.json following existing task files
```

**5. Build and verify:**
```bash
chmod +x scripts/build-atlas-core.sh
./scripts/build-atlas-core.sh --dry-run   # check output
./scripts/build-atlas-core.sh             # generate atlas-core/agents/
```

---

## Running the Eval Harness Locally

```bash
# Make sure Ruflo is installed (optional — harness degrades gracefully without it)
npm install -g ruflo

# Make scripts executable
chmod +x atlas-core/eval/run-eval.sh

# Run for a specific agent
./atlas-core/eval/run-eval.sh --agent <your-agent-name>

# Run for a whole division
./atlas-core/eval/run-eval.sh --division engineering

# Dry run (validate task/rubric structure without making model calls)
./atlas-core/eval/run-eval.sh --dry-run

# View results
cat atlas-core/eval/runs/latest/report.md
```

The report always shows negative and flat results — this is required by the Constitution (Article VII). If every single agent shows a positive delta in your test run, treat that as a sign the scoring isn't blind enough, not as a success.

---

## The New Agent Pipeline

All new agents go through naturalization before joining a live swarm:

| Step | What happens |
|---|---|
| 1. Draft | You create the persona file with `status: probationary` |
| 2. Sandbox | Agent runs only in dry-run/simulation mode |
| 3. Eval | Agent Evaluator runs ≥3 benchmark tasks |
| 4. Human review | Commissioning Officer reviews eval results |
| 5. Active | `status: active` — agent spawnable in live swarms |

A probationary agent that is spawned in a live swarm (not dry-run) is a constitutional violation (Article VI). The pre-flight script blocks this.

---

## Using Atlantia With Ruflo

**Spawn a single persona:**
```bash
ruflo agent spawn -t atlas-engineering-backend-architect --name arch-lead
```

**Run a swarm using only Atlantia personas:**
```bash
ruflo swarm init --topology hierarchical \
  --max-agents 6 \
  --strategy specialized \
  --agent-pool atlas
```

**Always run the constitutional pre-flight check before live swarms:**
```bash
chmod +x scripts/constitutional-preflight.sh
./scripts/constitutional-preflight.sh --plan my-swarm-plan.json
```

---

## Atlantia Without Ruflo

All persona files are plain Markdown and remain usable without Ruflo. Copy any persona directly into a Claude chat session and it works as a system prompt. The Ruflo integration is additive power — it is NOT a hard dependency that breaks the project if Ruflo isn't installed.

Verify this with:
```bash
# Confirm the library still works without ruflo in PATH
PATH=$(echo $PATH | tr ':' '\n' | grep -v ruflo | tr '\n' ':') \
  bash bin/atlantia census
```

---

## The Atlantia CLI

```bash
chmod +x bin/atlantia

atlantia census            # current nation state
atlantia gsp               # Gross Specialist Product report
atlantia improvement-report --since 2026-01-01
atlantia build             # regenerate atlas-core/agents/
atlantia preflight --plan swarm-plan.json
atlantia emergency-stop --reason "runaway daemon" --user your-username
```

---

## Getting Help

- Governance questions: read `constitution.md` and `atlas-core/governance/`
- Persona structure questions: read `templates/agent-template.md`
- Runtime questions (Ruflo): https://github.com/ruvnet/ruflo
- Open an issue for everything else
