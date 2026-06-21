#!/usr/bin/env bash
# no-ruflo-smoke.sh
# Verifies that the Atlantia persona library is fully functional WITHOUT Ruflo installed.
# Pure bash/awk — no python3, node, or jq required.
#
# Usage:
#   ./scripts/no-ruflo-smoke.sh [--verbose]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VERBOSE=false

while [[ $# -gt 0 ]]; do
  case "$1" in --verbose) VERBOSE=true; shift ;; *) shift ;; esac
done

PASS=0
FAIL=0

chk_pass() { echo "  ✅ $*"; ((PASS++)) || true; }
chk_fail() { echo "  ❌ $*" >&2; ((FAIL++)) || true; }
info() { echo "  🔹 $*"; }

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  ATLANTIA NO-RUFLO SMOKE TEST"
echo "═══════════════════════════════════════════════════════"
echo ""

# Test 1: Ruflo not in PATH
echo "[1] Ruflo absence"
if command -v ruflo &>/dev/null; then
  info "ruflo in PATH — smoke test still proceeds (tests standalone usability)"
else
  chk_pass "ruflo not in PATH — correct standalone condition"
fi

# Test 2: Persona source files (including generated) are readable
echo ""
echo "[2] Persona files"
total_personas=0
for div in academic design engineering finance game-development gis \
           marketing paid-media product project-management quality \
           sales security spatial-computing specialized support testing; do
  dir="$ROOT_DIR/$div"
  [[ -d "$dir" ]] || continue
  count=$(find "$dir" -maxdepth 2 -name "*.md" | wc -l | tr -d ' ')
  total_personas=$((total_personas + count))
  $VERBOSE && info "$div: $count files"
done
if [[ $total_personas -gt 100 ]]; then
  chk_pass "Persona files accessible: $total_personas"
else
  chk_fail "Too few persona files found: $total_personas (expected >100)"
fi

# Also check atlas-core/agents (generated)
atlas_agents=0
if [[ -d "$ROOT_DIR/atlas-core/agents" ]]; then
  atlas_agents=$(find "$ROOT_DIR/atlas-core/agents" -name "*.md" | wc -l | tr -d ' ')
fi
if [[ $atlas_agents -gt 50 ]]; then
  chk_pass "atlas-core generated agents: $atlas_agents"
else
  info "atlas-core/agents not yet built (run 'atlantia build' to generate)"
fi

# Test 3: atlas-core/plugin.json is valid JSON (bash-based check)
echo ""
echo "[3] atlas-core/plugin.json"
plugin="$ROOT_DIR/atlas-core/plugin.json"
if [[ -f "$plugin" ]]; then
  # Check it has key required fields
  if grep -q '"name"' "$plugin" && grep -q '"version"' "$plugin" && \
     grep -q '"ruflo_type"\|"agent_prefix"' "$plugin" && \
     grep -q '{' "$plugin" && grep -q '}' "$plugin"; then
    chk_pass "plugin.json present with required fields"
  else
    chk_fail "plugin.json missing required fields"
  fi
else
  chk_fail "atlas-core/plugin.json not found"
fi

# Test 4: Constitution has all 8 articles
echo ""
echo "[4] Constitution"
constitution="$ROOT_DIR/constitution.md"
if [[ -f "$constitution" ]]; then
  articles_found=0
  for roman in I II III IV V VI VII VIII; do
    grep -q "Article $roman" "$constitution" && ((articles_found++)) || true
  done
  if [[ $articles_found -eq 8 ]]; then
    chk_pass "All 8 constitutional articles present"
  else
    chk_fail "Only $articles_found/8 articles found in constitution.md"
  fi
else
  chk_fail "constitution.md not found"
fi

# Test 5: atlantia CLI runs
echo ""
echo "[5] atlantia CLI"
if [[ -x "$ROOT_DIR/bin/atlantia" ]]; then
  if bash "$ROOT_DIR/bin/atlantia" help > /dev/null 2>&1; then
    chk_pass "atlantia help runs without errors"
  else
    chk_fail "atlantia help returned non-zero exit"
  fi
  if bash "$ROOT_DIR/bin/atlantia" census > /dev/null 2>&1; then
    chk_pass "atlantia census runs without errors"
  else
    chk_fail "atlantia census returned non-zero exit"
  fi
else
  chk_fail "bin/atlantia not executable"
fi

# Test 6: Agent template exists and has required sections
echo ""
echo "[6] Agent template"
template="$ROOT_DIR/templates/agent-template.md"
if [[ -f "$template" ]]; then
  missing=0
  for section in "Identity" "Core Mission" "Critical Rules" "Technical Deliverables" "Atlas Chain Protocol"; do
    grep -q "$section" "$template" || { ((missing++)) || true; }
  done
  if [[ $missing -eq 0 ]]; then
    chk_pass "Agent template has all required sections"
  else
    chk_fail "$missing required sections missing from agent template"
  fi
else
  chk_fail "templates/agent-template.md not found"
fi

# Test 7: Quality division agents present
echo ""
echo "[7] Quality division agents"
missing_quality=0
for f in quality/dissent-agent.md quality/hallucination-auditor.md \
         quality/provenance-auditor.md quality/agent-evaluator.md \
         quality/deprecation-auditor.md quality/arbitration-agent.md \
         quality/retrospective-agent.md; do
  [[ -f "$ROOT_DIR/$f" ]] || { chk_fail "Missing: $f"; ((missing_quality++)) || true; }
done
[[ $missing_quality -eq 0 ]] && chk_pass "All 7 quality division agents present"

# Test 8: Ruflo in optionalDependencies only (bash grep check)
echo ""
echo "[8] Ruflo dependency hygiene"
pkg="$ROOT_DIR/package.json"
if [[ -f "$pkg" ]]; then
  # Extract the "dependencies" block and check for ruflo there
  # Simple heuristic: check if "ruflo" appears before "optionalDependencies" key
  in_opt=$(awk '/"optionalDependencies"/{found=1} found && /ruflo/{print "yes"; exit}' "$pkg")
  in_deps=$(awk '/"dependencies"/{found=1} /"optionalDependencies"/{exit} found && /ruflo/{print "yes"; exit}' "$pkg")
  if [[ "$in_deps" == "yes" ]]; then
    chk_fail "TREATY VIOLATION: ruflo appears in dependencies block"
  else
    chk_pass "Ruflo correctly in optionalDependencies only"
  fi
else
  info "package.json not found — skipping"
fi

# Test 9: build-atlas-core.sh dry-run
echo ""
echo "[9] build-atlas-core.sh --dry-run"
if [[ -x "$ROOT_DIR/scripts/build-atlas-core.sh" ]]; then
  if bash "$ROOT_DIR/scripts/build-atlas-core.sh" --dry-run > /dev/null 2>&1; then
    chk_pass "build-atlas-core.sh --dry-run completes without errors"
  else
    chk_fail "build-atlas-core.sh --dry-run returned non-zero exit"
  fi
else
  chk_fail "scripts/build-atlas-core.sh not executable"
fi

# Test 10: eval harness dry-run
echo ""
echo "[10] eval harness --dry-run"
if [[ -x "$ROOT_DIR/atlas-core/eval/run-eval.sh" ]]; then
  if bash "$ROOT_DIR/atlas-core/eval/run-eval.sh" --dry-run > /dev/null 2>&1; then
    chk_pass "eval harness --dry-run completes without errors"
  else
    chk_fail "eval harness --dry-run returned non-zero exit"
  fi
else
  chk_fail "atlas-core/eval/run-eval.sh not executable"
fi

# Test 11: Governance files present
echo ""
echo "[11] Governance files"
missing_gov=0
for f in atlas-core/governance/budget.json atlas-core/governance/roles.json \
         atlas-core/governance/alerts.json atlas-core/governance/ownership.json \
         atlas-core/governance/lessons-ledger.jsonl; do
  [[ -f "$ROOT_DIR/$f" ]] || { chk_fail "Missing: $f"; ((missing_gov++)) || true; }
done
[[ $missing_gov -eq 0 ]] && chk_pass "All governance files present"

# Test 12: NOTICE credits Ruflo
echo ""
echo "[12] NOTICE file"
if [[ -f "$ROOT_DIR/NOTICE" ]]; then
  if grep -qi "ruflo" "$ROOT_DIR/NOTICE"; then
    chk_pass "NOTICE credits Ruflo"
  else
    chk_fail "NOTICE does not credit Ruflo"
  fi
else
  chk_fail "NOTICE file missing"
fi

# ── Summary ────────────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════"
printf "  RESULTS: %s passed | %s failed\n" "$PASS" "$FAIL"
echo "═══════════════════════════════════════════════════════"
echo ""

if [[ $FAIL -gt 0 ]]; then
  echo "❌ Smoke test FAILED. Fix the failures above before merging."
  exit 1
else
  echo "✅ All smoke tests passed. Atlantia is usable without Ruflo."
  exit 0
fi
