# Security Policy

## Supported Versions

| Version | Supported |
|---|---|
| 1.x (current) | ✅ |

## Reporting a Vulnerability

If you discover a security issue in Atlantia — the persona library, atlas-core plugin,
or governance scripts — please report it privately rather than opening a public issue.

Ruflo itself has its own security process. Security issues in Ruflo's runtime (swarm
engine, MCP server, AgentDB) should be reported to the ruvnet/ruflo repo directly.

**Contact:**

- Email: [ADD YOUR SECURITY CONTACT EMAIL HERE]
- Expected acknowledgment: within 5 business days
- Expected initial assessment: within 14 days of acknowledgment

## What counts as a security issue here

- A persona's instructions can be manipulated to bypass the memory-tiering rules
  (`atlas-core/governance/budget.json`, prompt4.md Section 2) for regulated-domain agents
- A way to trigger naturalization or budget changes without going through the
  RBAC-defined approval roles (`atlas-core/governance/roles.json`)
- A prompt-injection vector that survives Ruflo's existing ADR boundaries (ADR-144/145/146)
  when routed through an Atlantia persona specifically
- `atlas-core/governance/dissent-log.jsonl` being cleared by a non-human process

## What is NOT a security issue here

Report as a normal bug or feature request instead:

- A persona giving low-quality or incorrect domain advice — report to the Agent
  Evaluator / Deprecation Auditor process (`atlas-core/eval/`, `quality/deprecation-auditor.md`)
- General Ruflo runtime bugs unrelated to Atlantia's own code — report upstream to
  ruvnet/ruflo directly
- Requesting a new persona or persona improvement — open a regular GitHub issue

## Disclosure Timeline

We aim to patch confirmed critical issues within:
- Regulated-domain data exposure: 14 days
- RBAC bypass: 30 days
- Other confirmed security issues: 60 days

Reporters will be credited in CHANGELOG.md unless anonymity is requested.

## Known Limitations

Memory tiering (`ephemeral` namespace for regulated-domain agents) prevents long-term
retention in Atlantia's own memory layer. It does NOT:

- Make any persona HIPAA, GDPR, or SOC2 compliant on its own
- Prevent the underlying model provider's own data handling policies from applying
- Replace the user's own infrastructure, contracts, and compliance review

Atlantia is a tool; regulatory compliance is the user's responsibility. This is not
a limitation we intend to obscure — it is stated plainly because obscuring it would
create false confidence in a regulated-use context.
