---
name: New persona proposal
about: Propose a new domain-specialist agent for the Atlantia Empire
title: "[PERSONA] <Name> — <Division>"
labels: persona, enhancement
assignees: ''
---

**Persona name**
e.g. `Supply Chain Analyst`

**Target division**
Which of the 17 divisions does this belong to? (Run `bash bin/atlantia census` for the full list.)

**Justification**
What gap in the existing 261 personas does this fill? Why can't an existing agent handle this?

**Draft frontmatter**
```yaml
---
name: Supply Chain Analyst
division: Operations
tier: specialist
role: analyst
skills:
  - logistics-optimization
  - vendor-management
  - demand-forecasting
constitutional_constraints:
  - article_ii_judicial_review: required
  - article_iv_budget_cap_usd: 2.00
---
```

**Sample tasks**
List 2–3 concrete tasks this agent should handle that no existing agent covers.
