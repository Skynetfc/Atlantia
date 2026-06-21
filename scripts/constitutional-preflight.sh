#!/usr/bin/env bash
# constitutional-preflight.sh
# Runs before any Atlantia swarm executes.
# Pure bash/awk — no python3, node, or jq required.
# Checks: regulated agents have ephemeral memory, budget ceiling, RBAC config.
#
# Usage:
#   ./scripts/constitutional-preflight.sh [--plan <swarm-plan.json>] [--verbose]
#
# Exit codes:
#   0  — All checks passed, swarm may proceed
#   1  — One or more blocking violations found

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BUDGET_FILE="$ROOT_DIR/atlas-core/governance/budget.json"
ROLES_FILE="$ROOT_DIR/atlas-core/governance/roles.json"
DISSENT_LOG="$ROOT_DIR/atlas-core/governance/dissent-log.jsonl"
ALERTS_FILE="$ROOT_DIR/atlas-core/governance/alerts.json"

PLAN_FILE=""
VERBOSE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --plan)    PLAN_FILE="$2"; shift 2 ;;
    --verbose) VERBOSE=true; shift ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

log()  { echo "[preflight] $*"; }
vlog() { $VERBOSE && echo "[preflight:verbose] $*" || true; }
fail() { echo "[preflight:FAIL] $*" >&2; }

VIOLATIONS=0
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# ── Article II: Judicial review check ────────────────────────────────────────
check_judicial_review() {
  log "Article II: Checking Executive outputs have Judicial review step..."

  if [[ -z "$PLAN_FILE" ]] || [[ ! -f "$PLAN_FILE" ]]; then
    log "No plan file provided — check atlas-core/agents source files directly"
    # Count executive vs judicial agents in atlas-core/agents
    local exec_count judicial_count
    exec_count=$(grep -rl 'branch: executive' "$ROOT_DIR/atlas-core/agents/" 2>/dev/null | wc -l | tr -d ' ')
    judicial_count=$(grep -rl 'branch: judicial' "$ROOT_DIR/atlas-core/agents/" 2>/dev/null | wc -l | tr -d ' ')
    log "Article II: $exec_count executive agents, $judicial_count judicial agents in pool"
    [[ $judicial_count -gt 0 ]] && log "Article II: OK (judicial agents available for swarm plans)"
    return
  fi

  # Check plan JSON for executive agents and review_steps
  local has_executive has_review
  has_executive=$(grep -c '"branch".*"executive"' "$PLAN_FILE" 2>/dev/null || echo "0")
  has_review=$(grep -c '"review_steps"\|"judicial"' "$PLAN_FILE" 2>/dev/null || echo "0")

  if [[ $has_executive -gt 0 ]] && [[ $has_review -eq 0 ]]; then
    fail "Article II violation: Executive agents in plan but no Judicial review step."
    fail "Add an atlas-quality-dissent-agent to review_steps."
    ((VIOLATIONS++)) || true
  else
    log "Article II: OK"
  fi
}

# ── Article III: Memory sovereignty ──────────────────────────────────────────
check_memory_sovereignty() {
  log "Article III: Checking regulated-domain agents have ephemeral memory..."

  local fail_count=0
  for div in finance security; do
    local agent_dir="$ROOT_DIR/atlas-core/agents/$div"
    [[ -d "$agent_dir" ]] || continue
    while IFS= read -r -d '' f; do
      local tier
      tier=$(awk '/^---$/{if(count++==0)next;else exit} /^memory_tier:/{sub(/^memory_tier: /,"");print}' "$f")
      if [[ "$tier" != "ephemeral" ]]; then
        fail "Article III violation: $f has memory_tier '$tier' (expected ephemeral)"
        ((VIOLATIONS++)) || true
        ((fail_count++)) || true
      fi
    done < <(find "$agent_dir" -name "*.md" -print0 2>/dev/null)
  done

  [[ $fail_count -eq 0 ]] && log "Article III: OK"
}

# ── Article IV: Budget limits ─────────────────────────────────────────────────
check_budget() {
  log "Article IV: Checking budget limits..."

  if [[ ! -f "$BUDGET_FILE" ]]; then
    fail "budget.json not found at $BUDGET_FILE"
    ((VIOLATIONS++)) || true
    return
  fi

  local ceiling
  ceiling=$(grep -o '"default_project_budget_credits":[^,}]*' "$BUDGET_FILE" | grep -o '[0-9]*' | head -1)
  ceiling="${ceiling:-1000}"

  if [[ -n "$PLAN_FILE" ]] && [[ -f "$PLAN_FILE" ]]; then
    local estimated
    estimated=$(grep -o '"estimated_credits":[^,}]*' "$PLAN_FILE" | grep -o '[0-9]*' | head -1)
    estimated="${estimated:-0}"

    if [[ $estimated -le $ceiling ]]; then
      log "Article IV: OK (estimated $estimated credits, ceiling $ceiling)"
    else
      fail "Article IV violation: Estimated credits ($estimated) exceeds ceiling ($ceiling)."
      fail "Obtain explicit human override from a Treasury Officer before proceeding."
      ((VIOLATIONS++)) || true
    fi
  else
    log "Article IV: Budget ceiling set to $ceiling credits. No plan file — skipping estimate check."
  fi
}

# ── Check RBAC config exists ──────────────────────────────────────────────────
check_rbac() {
  log "Article VIII: Checking RBAC config..."
  if [[ ! -f "$ROLES_FILE" ]]; then
    fail "roles.json not found at $ROLES_FILE — Article VIII cannot be enforced"
    ((VIOLATIONS++)) || true
  else
    log "Article VIII: OK (roles.json present)"
  fi
}

# ── Verify constitution.md has all articles ────────────────────────────────────
check_constitution() {
  log "Article I: Checking constitution.md..."
  if [[ ! -f "$ROOT_DIR/constitution.md" ]]; then
    fail "constitution.md not found — constitutional governance cannot be enforced"
    ((VIOLATIONS++)) || true
    return
  fi

  local missing=0
  for roman in I II III IV V VI VII VIII; do
    grep -q "Article $roman" "$ROOT_DIR/constitution.md" || {
      fail "Missing Article $roman from constitution.md"
      ((missing++)) || true
    }
  done
  [[ $missing -eq 0 ]] && log "Article I: constitution.md complete (all 8 articles present)"
  ((VIOLATIONS += missing)) || true
}

# ── Initialize dissent log ────────────────────────────────────────────────────
init_dissent_log() {
  if [[ ! -f "$DISSENT_LOG" ]]; then
    touch "$DISSENT_LOG"
    vlog "Initialized dissent log: $DISSENT_LOG"
  fi
}

# ── Send alert if configured ──────────────────────────────────────────────────
send_alert() {
  local event="$1"
  local detail="$2"

  if [[ ! -f "$ALERTS_FILE" ]]; then return; fi

  local webhook
  webhook=$(awk -F'"' '/"slack_webhook_url"/{print $4; exit}' "$ALERTS_FILE")

  if [[ -n "$webhook" ]] && [[ "$webhook" != "" ]]; then
    curl -s -X POST "$webhook" \
      -H 'Content-type: application/json' \
      --data "{\"text\": \"[Atlantia Preflight] $event: $detail ($(date -u))\"}" \
      > /dev/null 2>&1 || true
  fi
}

# ── Main ──────────────────────────────────────────────────────────────────────
log "Constitutional pre-flight check — $TIMESTAMP"
[[ -n "$PLAN_FILE" ]] && log "Plan: $PLAN_FILE"

init_dissent_log
check_constitution
check_judicial_review
check_memory_sovereignty
check_budget
check_rbac

if [[ $VIOLATIONS -gt 0 ]]; then
  fail "Pre-flight FAILED: $VIOLATIONS constitutional violation(s). Swarm is blocked."
  send_alert "PREFLIGHT_BLOCKED" "$VIOLATIONS violations"
  exit 1
else
  log "Pre-flight PASSED: 0 violations. Swarm may proceed."
  exit 0
fi
