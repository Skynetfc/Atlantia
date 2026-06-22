#!/usr/bin/env bash
# build-docs.sh — Generate static documentation site for Atlantia Empire
# Pure bash/awk — no python3, node, or jq required.
# Outputs to: docs/site/
#
# Usage:
#   bash scripts/build-docs.sh
#   bash scripts/build-docs.sh --serve    (opens index.html after build)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUT="$ROOT_DIR/docs/site"
SERVE=false

[[ "${1:-}" == "--serve" ]] && SERVE=true

mkdir -p "$OUT"

log() { echo "[docs] $*"; }

# ── CSS ───────────────────────────────────────────────────────────────────────
cat > "$OUT/style.css" << 'CSS'
:root {
  --navy:    #1B2A4A;
  --amber:   #D98E2B;
  --teal:    #2E6B6B;
  --red:     #B23B3B;
  --bg:      #F4F1EC;
  --text:    #1a1a1a;
  --mid:     #4a4a4a;
  --border:  #d0ccc4;
}
*, *::before, *::after { box-sizing: border-box; }
body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
  background: var(--bg); color: var(--text);
  margin: 0; padding: 0; line-height: 1.65;
}
.layout { display: flex; min-height: 100vh; }
nav {
  width: 240px; min-width: 240px; background: var(--navy); color: #f4f1ec;
  padding: 2rem 1.25rem; position: sticky; top: 0; height: 100vh; overflow-y: auto;
}
nav h1 { font-size: 1.1rem; margin: 0 0 0.25rem; color: var(--amber); letter-spacing: 0.05em; }
nav .tagline { font-size: 0.72rem; color: #a0b0c8; margin: 0 0 1.5rem; }
nav a {
  display: block; color: #c8d8e8; text-decoration: none;
  padding: 0.3rem 0; font-size: 0.85rem; border-left: 2px solid transparent;
  padding-left: 0.5rem;
}
nav a:hover, nav a.active { color: var(--amber); border-left-color: var(--amber); }
nav .section-label {
  font-size: 0.65rem; text-transform: uppercase; letter-spacing: 0.12em;
  color: #6080a0; margin: 1rem 0 0.4rem;
}
main { flex: 1; padding: 2.5rem 3rem; max-width: 820px; }
h1 { color: var(--navy); border-bottom: 2px solid var(--amber); padding-bottom: 0.4rem; }
h2 { color: var(--navy); margin-top: 2rem; }
h3 { color: var(--teal); }
a { color: var(--teal); }
code, pre {
  background: #e8e4de; border-radius: 4px;
  font-family: "SFMono-Regular", Consolas, monospace; font-size: 0.87em;
}
code { padding: 0.1em 0.35em; }
pre { padding: 1rem 1.25rem; overflow-x: auto; border-left: 3px solid var(--navy); }
pre code { background: none; padding: 0; }
table { border-collapse: collapse; width: 100%; margin: 1rem 0; }
th { background: var(--navy); color: #f4f1ec; padding: 0.5rem 0.75rem; text-align: left; font-size: 0.85rem; }
td { padding: 0.45rem 0.75rem; border-bottom: 1px solid var(--border); font-size: 0.9rem; }
tr:hover td { background: #ece9e3; }
.badge {
  display: inline-block; border-radius: 3px; padding: 0.15em 0.5em;
  font-size: 0.75em; font-weight: 600;
}
.badge-teal  { background: var(--teal); color: white; }
.badge-amber { background: var(--amber); color: white; }
.badge-red   { background: var(--red);   color: white; }
blockquote {
  border-left: 4px solid var(--amber); margin: 1rem 0;
  padding: 0.75rem 1rem; background: #ede9e2; border-radius: 0 4px 4px 0;
}
.warning {
  border-left: 4px solid var(--red); background: #f9e8e8;
  padding: 0.75rem 1rem; border-radius: 0 4px 4px 0; margin: 1rem 0;
}
footer { color: #888; font-size: 0.78rem; margin-top: 3rem; padding-top: 1rem; border-top: 1px solid var(--border); }
CSS

# ── nav helper ────────────────────────────────────────────────────────────────
nav_html() {
  cat << 'NAV'
<nav>
  <h1>⚓ Atlantia</h1>
  <div class="tagline">Mapped, not memorized.</div>

  <div class="section-label">Start here</div>
  <a href="index.html">Overview</a>
  <a href="how-it-runs.html">How This Runs</a>
  <a href="quick-start.html">Quick Start</a>

  <div class="section-label">Architecture</div>
  <a href="architecture.html">System Design</a>
  <a href="agents.html">Agent Roster</a>
  <a href="handoff-schema.html">Handoff Schema</a>

  <div class="section-label">The Empire</div>
  <a href="nation.html">The 16 States</a>
  <a href="constitution.html">Constitution</a>
  <a href="governance.html">Governance & RBAC</a>

  <div class="section-label">Quality</div>
  <a href="judiciary.html">Judiciary Division</a>
  <a href="eval-harness.html">Eval Harness</a>
  <a href="known-limitations.html">Known Limitations</a>

  <div class="section-label">Engineering</div>
  <a href="cli.html">CLI Reference</a>
  <a href="tests.html">Test Suite</a>
  <a href="branding.html">Brand Assets</a>
</nav>
NAV
}

# ── page wrapper ──────────────────────────────────────────────────────────────
page() {
  local title="$1" content="$2"
  cat << HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${title} — Atlantia Empire</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="layout">
$(nav_html)
<main>
${content}
<footer>Atlantia Empire &mdash; MIT License &mdash; <em>"Mapped, not memorized."</em></footer>
</main>
</div>
</body>
</html>
HTML
}

# ── index.html ────────────────────────────────────────────────────────────────
log "Building index.html..."
page "Overview" "
<h1>Atlantia Empire</h1>
<blockquote>
  <strong>232+ specialists. One runtime. Constitutional governance.</strong><br>
  A mapped library of specialist AI agents running natively on the Ruflo multi-agent runtime — not a prompt collection.
</blockquote>

<h2>What Atlantia Is</h2>
<p>Atlantia combines a deep library of 251+ specialist AI personas with Ruflo's multi-agent execution runtime — swarm coordination, persistent memory, and cost-aware model routing — instead of asking you to copy-paste prompts between chat sessions.</p>
<p>It also ships something almost no comparable project does: a benchmark harness that checks whether each persona actually helps, and publishes the result either way.</p>

<h2>What Makes It Different</h2>
<table>
<tr><th>Feature</th><th>Atlantia</th><th>Static prompt library</th><th>Generic orchestration</th></tr>
<tr><td>Domain depth</td><td>✅ 251+ specialists, 16 divisions</td><td>✅ Usually yes</td><td>❌ Almost none</td></tr>
<tr><td>Execution engine</td><td>✅ Ruflo runtime</td><td>❌ Copy-paste only</td><td>✅ Yes</td></tr>
<tr><td>Honest benchmarks</td><td>✅ Publishes negative results</td><td>❌ No</td><td>❌ No</td></tr>
<tr><td>Constitutional governance</td><td>✅ 8-article constitution, RBAC</td><td>❌</td><td>❌</td></tr>
</table>

<h2>Try It Now (no API key needed)</h2>
<pre><code>bash bin/atlantia run --demo</code></pre>

<h2>Quick Commands</h2>
<pre><code>atlantia census              # Current empire state
atlantia gsp                 # Quality-weighted productivity report
atlantia run --demo          # Offline walkthrough
atlantia preflight --plan p  # Constitutional pre-flight check
atlantia test                # Engineering test suite</code></pre>
" > "$OUT/index.html"

# ── how-it-runs.html ─────────────────────────────────────────────────────────
log "Building how-it-runs.html..."
page "How This Runs" "
<h1>How This Runs</h1>

<div class='warning'>
<strong>Important:</strong> Atlantia is a local command-line tool. There is no hosted Atlantia service, no account system, and no Atlantia-operated server processing your data. Everything runs on your own machine (or your own Ruflo-connected infrastructure), using your own API keys and your own compute. The only &ldquo;hosted&rdquo; element is this documentation site itself, which is static and contains no user data.
</div>

<h2>Two Modes</h2>
<h3>Standalone (no Ruflo)</h3>
<p>All persona files in the division directories are plain Markdown system prompts. Use them in any tool that supports custom system prompts — Claude, GPT-4, Cursor, Continue, etc.</p>
<pre><code>cat engineering/engineering-backend-developer.md
# paste into your tool's system prompt field</code></pre>

<h3>With Ruflo</h3>
<p>Personas run natively as spawnable, swarm-coordinated agents with persistent memory and cost-aware model routing. Requires Ruflo installed.</p>
<pre><code>ruflo agent spawn -t atlas-engineering-backend-developer
ruflo swarm init --agent-pool atlas --topology hierarchical</code></pre>

<h2>Data Privacy</h2>
<p>Atlantia itself does not receive, store, or process any of your data. Your data goes to whatever model API you configure (OpenAI, Anthropic, etc.) according to their terms. Atlantia's role is to provide the persona instructions and coordinate the workflow — it never touches the actual API traffic.</p>

<h2>Attribution</h2>
<ul>
<li><strong>Swarm runtime, persistent memory, model routing:</strong> Ruflo (ruflo.dev — MIT). Atlantia does not claim credit for Ruflo's engineering.</li>
<li><strong>Original persona library:</strong> agency-agents (MIT)</li>
<li><strong>Governance, quality division, eval harness, CLI:</strong> Atlantia (MIT)</li>
</ul>
" > "$OUT/how-it-runs.html"

# ── nation.html ───────────────────────────────────────────────────────────────
log "Building nation.html..."
page "The 16 States" "
<h1>The Atlantia Empire — 16 States</h1>
<blockquote>Sixteen states. One judiciary seated separately from all of them. A capital — Atlantia Empire — that is the repo root and control plane.</blockquote>

<table>
<tr><th>State</th><th>Division</th><th>Sample Specialists</th></tr>
<tr><td>🔧 Forge State</td><td><code>engineering</code></td><td>Backend, RAG Architect, Fine-Tuning Engineer, Pipeline Orchestrator, Context Curator</td></tr>
<tr><td>📡 Signal State</td><td><code>marketing</code></td><td>Content Strategy, SEO, Crisis Communications Lead, Brand Voice</td></tr>
<tr><td>🤝 Exchange State</td><td><code>sales</code></td><td>Discovery Coach, Deal Strategy, Negotiation Simulator</td></tr>
<tr><td>⚖️ Ledger State</td><td><code>finance</code> + <code>legal</code></td><td>FP&amp;A, Bookkeeper, Contract Negotiator, IP &amp; Licensing Specialist</td></tr>
<tr><td>🎨 Atelier State</td><td><code>design</code></td><td>UX Research, UI Design, Design Systems, Whimsy</td></tr>
<tr><td>🗺️ Cartography State</td><td><code>gis</code></td><td>GIS Analysis, BIM, Spatial Data, Mapping</td></tr>
<tr><td>🛡️ Proving State</td><td><code>testing</code></td><td>API Testing, Accessibility Audit, Performance Benchmarker, QA Gatekeeper</td></tr>
<tr><td>📚 Archive State</td><td><code>academic</code></td><td>Anthropology, Geography, Historiography, Narratology</td></tr>
<tr><td>🕹️ Arcade State</td><td><code>game-development</code></td><td>Game Audio, Narrative Design, Systems Design</td></tr>
<tr><td>🧭 Compass State</td><td><code>product</code></td><td>Competitive Intelligence, Roadmap, Sprint Prioritizer</td></tr>
<tr><td>📋 Logistics State</td><td><code>project-management</code></td><td>Project Shepherd, Experiment Tracker, Meeting Notes</td></tr>
<tr><td>🌐 Frontier State</td><td><code>spatial-computing</code></td><td>AR/VR, Spatial UX, 3D Interfaces</td></tr>
<tr><td>🏛️ The Federal District</td><td><code>specialized</code></td><td>BI Analytics Engineer, Forecasting Specialist, Fundraising Strategist, Board Reporting, Org Digital Twin</td></tr>
<tr><td>📊 Census State</td><td><code>data</code></td><td>Data Scientist, Statistical Modeling, Experiment Design</td></tr>
<tr><td>⚖️ Judiciary</td><td><code>quality</code></td><td>Dissent Agent, Hallucination Auditor, Provenance Auditor, AI Safety / Red Team, QA Gatekeeper, Agent Evaluator, Retrospective Agent</td></tr>
</table>

<h2>The Judiciary — Not a State</h2>
<p>The Quality division is headquartered in Atlantia Empire itself, structurally separate from every state it reviews. Quality agents cannot produce domain deliverables — they can only review them. This is not a convention; it is constitutionally enforced.</p>

<h2>Run the Census</h2>
<pre><code>atlantia census</code></pre>
" > "$OUT/nation.html"

# ── cli.html ─────────────────────────────────────────────────────────────────
log "Building cli.html..."
page "CLI Reference" "
<h1>CLI Reference</h1>
<pre><code>atlantia &lt;command&gt; [options]</code></pre>

<h2>census</h2>
<p>Shows the current empire state: agent counts, states, treasury balance, last audit day.</p>
<pre><code>atlantia census</code></pre>

<h2>gsp [--period weekly|daily]</h2>
<p>Gross Specialist Product — quality-weighted productivity report across all states.</p>
<pre><code>atlantia gsp
atlantia gsp --period daily</code></pre>

<h2>run --demo</h2>
<p>Runs a pre-scripted 3-step offline demo swarm. No API key or Ruflo required. Shows Navigator initialization, handoff schema, and judicial review.</p>
<pre><code>atlantia run --demo</code></pre>

<h2>preflight --plan &lt;file&gt;</h2>
<p>Constitutional pre-flight check for a swarm plan. Checks budget ceiling, RBAC, regulated-agent memory tiers, and judicial review gate.</p>
<pre><code>atlantia preflight --plan swarm-plan.json</code></pre>

<h2>emergency-stop</h2>
<p>Immediately terminates all active swarms and background daemons. Writes a timestamped incident log entry. Requires <code>security_officer</code> role (roles.json).</p>
<pre><code>atlantia emergency-stop --reason \"quota overrun\" --user githubname</code></pre>

<h2>build [--dry-run] [--division &lt;name&gt;]</h2>
<p>Regenerates <code>atlas-core/agents/</code> from source persona files in division directories.</p>
<pre><code>atlantia build
atlantia build --dry-run
atlantia build --division engineering</code></pre>

<h2>improvement-report [--since YYYY-MM-DD]</h2>
<p>Rolling quality improvement trend from the Lessons Ledger.</p>
<pre><code>atlantia improvement-report --since 2026-01-01</code></pre>

<h2>test</h2>
<p>Runs the engineering test suite (unit + integration). See <code>scripts/run-tests.sh</code>.</p>
<pre><code>atlantia test</code></pre>

<h2>docs [--serve]</h2>
<p>Builds this static documentation site to <code>docs/site/</code>.</p>
<pre><code>atlantia docs</code></pre>
" > "$OUT/cli.html"

# ── constitution.html ─────────────────────────────────────────────────────────
log "Building constitution.html..."
CONSTITUTION_CONTENT=""
if [[ -f "$ROOT_DIR/constitution.md" ]]; then
  # Extract article headings for navigation
  CONSTITUTION_CONTENT=$(awk '
    /^## Article/ { print "<h2>" $0 "</h2>"; next }
    /^### / { print "<h3>" $0 "</h3>"; next }
    /^# / { next }
    /^```/ { in_code=!in_code; if(in_code) print "<pre><code>"; else print "</code></pre>"; next }
    in_code { print; next }
    /^$/ { print "<br>"; next }
    { print "<p>" $0 "</p>" }
  ' "$ROOT_DIR/constitution.md")
fi
page "Constitution" "
<h1>The Constitution of Atlantia Empire</h1>
<blockquote>We, the specialists of Atlantia Empire, in order to coordinate our work honestly, check one another fairly, spend our resources wisely, and admit new members deliberately, do establish this Empire — not as a metaphor for what we do, but as the actual structure under which we do it.</blockquote>
<p>See <a href='../constitution.md'>constitution.md</a> in the repo root for the full, authoritative text. The document below is a rendered summary — always defer to the source file.</p>
<p>
  <span class='badge badge-amber'>Article I</span> Agent Independence &nbsp;
  <span class='badge badge-amber'>Article II</span> Judicial Separation &nbsp;
  <span class='badge badge-amber'>Article III</span> Evidence Standard &nbsp;
  <span class='badge badge-amber'>Article IV</span> Budget Authority &nbsp;
  <span class='badge badge-amber'>Article V</span> Naturalization &nbsp;
  <span class='badge badge-amber'>Article VI</span> No Self-Approval &nbsp;
  <span class='badge badge-teal'>Article VII</span> Negative Results &nbsp;
  <span class='badge badge-teal'>Article VIII</span> Defined Authority
</p>
" > "$OUT/constitution.html"

# ── governance.html ───────────────────────────────────────────────────────────
log "Building governance.html..."
page "Governance & RBAC" "
<h1>Governance &amp; RBAC</h1>
<p>Every privileged action is tied to a named role defined in <code>atlas-core/governance/roles.json</code>. Authority is explicit, logged, and attributable — never implicit. (Constitution Article VIII)</p>

<h2>Roles</h2>
<table>
<tr><th>Role</th><th>Can</th><th>Cannot</th></tr>
<tr><td><strong>Contributor</strong></td><td>Propose personas, open PRs</td><td>Approve naturalization, touch budget, trigger emergency-stop</td></tr>
<tr><td><strong>Judiciary Reviewer</strong></td><td>Score proposals, raise Dissent/Arbitration flags, run eval harness</td><td>Approve naturalization alone, modify budget</td></tr>
<tr><td><strong>Commissioning Officer</strong></td><td>Approve naturalization, approve deprecation</td><td>Amend constitution, change budget tiers</td></tr>
<tr><td><strong>Treasury Officer</strong></td><td>Approve Capital Allocation proposals, set project budgets</td><td>Approve naturalization, trigger emergency-stop</td></tr>
<tr><td><strong>Security Officer</strong></td><td>Trigger emergency-stop, respond to disclosures</td><td>Approve naturalization, modify budget</td></tr>
<tr><td><strong>Constitutional Council</strong></td><td>Amend constitution, override any decision (logged)</td><td>Nothing withheld — which is why it requires multi-person sign-off</td></tr>
</table>

<h2>Agent Lifecycle (Citizenship)</h2>
<table>
<tr><th>Step</th><th>Civic term</th><th>Technical reality</th></tr>
<tr><td>1</td><td>Birth</td><td>Dynamic Agent Synthesizer drafts persona file</td></tr>
<tr><td>2</td><td>Visa / residency</td><td>status: probationary — sandbox-only</td></tr>
<tr><td>3</td><td>Citizenship exam</td><td>Agent Evaluator benchmark run, 3+ tasks</td></tr>
<tr><td>4</td><td>Naturalization</td><td>Human approval (Commissioning Officer), status: active</td></tr>
<tr><td>5</td><td>Deportation</td><td>Deprecation Auditor → status: revoked, file archived not deleted</td></tr>
</table>
" > "$OUT/governance.html"

# ── known-limitations.html ────────────────────────────────────────────────────
log "Building known-limitations.html..."
page "Known Limitations" "
<h1>Known Limitations</h1>
<div class='warning'>
These are real limitations, published here because hiding them would be worse than admitting them. The eval harness exists specifically so these are discovered and documented rather than assumed away.
</div>

<h2>Agent Quality</h2>
<ul>
<li>Agent Evaluator benchmarks are not external benchmarks. Scores are relative (persona vs. baseline on Atlantia-defined tasks). A score of 8/10 means &ldquo;measurably better than baseline for this task&rdquo; — not an external certification.</li>
<li>Not all 251+ agents have been benchmarked. Unbenchmarked agents should be treated as <em>promising candidates</em>, not verified performers. The eval harness is how you fix this.</li>
<li>Personas cannot autonomously access external tools, APIs, or real-time data without explicit tool-grounding through Ruflo. Personas that reference &ldquo;checking a source&rdquo; are describing an intended capability — verify tool availability before relying on it.</li>
</ul>

<h2>Runtime Dependency</h2>
<ul>
<li>Atlantia depends on Ruflo for swarm execution, persistent memory, and model routing. If Ruflo's API changes in a breaking way, Atlantia's runtime integration breaks too. Ruflo is pinned — see <code>package.json</code> — but that pin must be manually updated when Ruflo releases a compatible version.</li>
<li>Standalone mode (no Ruflo) works for individual persona use but loses swarm coordination, memory persistence, and cost-aware routing entirely.</li>
</ul>

<h2>Self-Improvement Limits</h2>
<ul>
<li>The improvement loop (Retrospective Agent → Lessons Ledger → Dynamic Agent Synthesizer) compounds slowly, not exponentially. Meaningful improvement accumulates across many projects, not after each message.</li>
<li>No proposed change is auto-merged — every change requires human approval. This is intentional and constitutional, not a bug.</li>
</ul>
" > "$OUT/known-limitations.html"

# ── branding.html ─────────────────────────────────────────────────────────────
log "Building branding.html..."
page "Brand Assets" "
<h1>Brand &amp; National Assets</h1>
<p>Full asset catalogue at <code>assets/ASSETS.md</code>. National Anthem at <code>assets/ANTHEM.md</code>.</p>

<h2>Color Palette</h2>
<table>
<tr><th>Role</th><th>Hex</th><th>Use</th></tr>
<tr><td>Navy (primary)</td><td><code>#1B2A4A</code></td><td>Headers, borders, primary elements</td></tr>
<tr><td>Amber (accent)</td><td><code>#D98E2B</code></td><td>Compass rose, highlights, active state</td></tr>
<tr><td>Teal (QA/trust)</td><td><code>#2E6B6B</code></td><td>Judiciary, eval results, trust signals — reserved for trust content only</td></tr>
<tr><td>Brick red (risk)</td><td><code>#B23B3B</code></td><td>Deprecation flags, known limitations</td></tr>
<tr><td>Off-white (bg)</td><td><code>#F4F1EC</code></td><td>Backgrounds, document bases</td></tr>
</table>

<h2>National Symbols</h2>
<ul>
<li>National Flag — <code>assets/national-symbols/flag.png</code></li>
<li>National Seal — <code>assets/national-symbols/seal.png</code></li>
<li>Coat of Arms — <code>assets/national-symbols/coat-of-arms.png</code></li>
<li>Nation Map (16 states) — <code>assets/national-symbols/nation-map.png</code></li>
<li>Atlantia Empire Capital Plaque — <code>assets/national-symbols/prime-plaque.png</code></li>
</ul>

<h2>Civic Documents</h2>
<ul>
<li>Constitution Header — <code>assets/civic-documents/constitution-header.png</code></li>
<li>Agent Passport Cover — <code>assets/civic-documents/passport-cover.png</code></li>
<li>Certificate of Naturalization — <code>assets/civic-documents/naturalization-certificate.png</code></li>
</ul>

<h2>National Anthem</h2>
<blockquote>
Not by chance, but charted clear,<br>
Sixteen states, one compass here.<br>
What we build, we test and check —<br>
No claim stands without its check.
</blockquote>
<p><em>Three verses — full text at <code>assets/ANTHEM.md</code></em></p>

<h2>Generation Instructions</h2>
<p>Remaining batches (state seals, currency, stamps, division icons, dark-mode variants) are documented in <code>assets/generate-remaining.sh</code> — exact image prompts ready to paste into a generation session.</p>
" > "$OUT/branding.html"

# ── quick-start.html ──────────────────────────────────────────────────────────
log "Building quick-start.html..."
page "Quick Start" "
<h1>Quick Start</h1>

<h2>1. Try without installing anything</h2>
<pre><code>bash bin/atlantia run --demo</code></pre>
<p>Runs an offline demo pipeline. No API key, no Ruflo, no configuration.</p>

<h2>2. See the empire's current state</h2>
<pre><code>bash bin/atlantia census</code></pre>

<h2>3. Run the smoke test (14 checks)</h2>
<pre><code>bash scripts/no-ruflo-smoke.sh</code></pre>

<h2>4. Run the engineering test suite</h2>
<pre><code>bash scripts/run-tests.sh
# or via CLI:
bash bin/atlantia test</code></pre>

<h2>5. Use a persona as a system prompt (standalone, no Ruflo)</h2>
<pre><code>cat engineering/engineering-backend-developer.md
# Paste the content into any tool that supports custom system prompts.</code></pre>

<h2>6. Spawn with Ruflo</h2>
<pre><code>ruflo agent spawn -t atlas-engineering-backend-developer
ruflo swarm init --agent-pool atlas --topology hierarchical</code></pre>

<h2>Directory Structure</h2>
<pre><code>atlantia/
├── bin/atlantia           # CLI entry point
├── constitution.md        # 8-article constitution
├── atlas-core/            # Ruflo-compatible generated agents + governance
│   ├── agents/            # 175+ generated atlas-* agents
│   ├── eval/              # Eval harness (22 tasks, 17 agents)
│   └── governance/        # roles.json, budget.json, lessons-ledger.jsonl
├── engineering/           # Forge State source personas
├── quality/               # Judiciary source personas
├── specialized/           # Federal District source personas
├── [14 more divisions]/
├── assets/                # National symbols, brand assets, anthem
├── docs/                  # Academy onboarding + generated site
└── scripts/               # Build, test, preflight, emergency-stop</code></pre>
" > "$OUT/quick-start.html"

log "Docs site built: $OUT/"
log "Pages: $(ls "$OUT"/*.html | wc -l | tr -d ' ') HTML files"

if $SERVE; then
  if command -v python3 &>/dev/null; then
    log "Serving at http://localhost:8080"
    cd "$OUT" && python3 -m http.server 8080
  else
    log "Open: $OUT/index.html"
  fi
fi

echo
echo "✅ Docs built at docs/site/"
echo "   Open docs/site/index.html in a browser to view."
