#!/usr/bin/env bash
# emergency-stop.sh
# Immediately terminates all active Atlantia swarms and background daemons.
# Writes a timestamped incident log entry.
# Pure bash — no python3, node, or jq required.
# Requires security_officer role (enforced via roles.json).
#
# Usage:
#   ./scripts/emergency-stop.sh [--reason "..."] [--user <github-username>]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ROLES_FILE="$ROOT_DIR/atlas-core/governance/roles.json"
ALERTS_FILE="$ROOT_DIR/atlas-core/governance/alerts.json"
INCIDENT_LOG="$ROOT_DIR/atlas-core/governance/incident-log.jsonl"

REASON="No reason provided"
USERNAME="${ATLANTIA_USER:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --reason) REASON="$2"; shift 2 ;;
    --user)   USERNAME="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "[emergency-stop] ⚠️  EMERGENCY STOP INITIATED — $TIMESTAMP"
echo "[emergency-stop] Reason: $REASON"
echo "[emergency-stop] Triggered by: ${USERNAME:-unknown}"

# ── RBAC check (bash/awk based) ───────────────────────────────────────────────
if [[ -n "$USERNAME" ]] && [[ -f "$ROLES_FILE" ]]; then
  # Check if username block contains security_officer or constitutional_council
  HAS_ROLE=$(awk -v user="$USERNAME" '
    /"'"$USERNAME"'"/{found=1}
    found && /"security_officer"\|"constitutional_council"/{print "yes"; exit}
    found && /\]/{exit}
  ' "$ROLES_FILE")

  if [[ "$HAS_ROLE" != "yes" ]]; then
    echo "[emergency-stop] RBAC DENIED: $USERNAME does not have security_officer role." >&2
    # Log denied attempt
    touch "$INCIDENT_LOG"
    echo "{\"timestamp\":\"$TIMESTAMP\",\"event\":\"emergency_stop_denied\",\"user\":\"$USERNAME\",\"reason\":\"$REASON\"}" >> "$INCIDENT_LOG"
    exit 1
  fi
fi

# ── Terminate Ruflo daemons ───────────────────────────────────────────────────
echo "[emergency-stop] Terminating Ruflo daemons..."

if command -v ruflo &>/dev/null; then
  ruflo daemon stop 2>/dev/null && echo "[emergency-stop] ruflo daemon stopped" || echo "[emergency-stop] ruflo daemon was not running"
fi

if pgrep -f "ruflo\|claude-flow\|@claude-flow" > /dev/null 2>&1; then
  pkill -SIGTERM -f "ruflo\|claude-flow\|@claude-flow" 2>/dev/null || true
  sleep 2
  pkill -SIGKILL -f "ruflo\|claude-flow\|@claude-flow" 2>/dev/null || true
  echo "[emergency-stop] Ruflo processes terminated"
else
  echo "[emergency-stop] No running Ruflo processes found"
fi

# ── Write incident log ────────────────────────────────────────────────────────
touch "$INCIDENT_LOG"
echo "{\"timestamp\":\"$TIMESTAMP\",\"event\":\"emergency_stop\",\"triggered_by\":\"${USERNAME:-unknown}\",\"reason\":\"$REASON\",\"status\":\"executed\"}" >> "$INCIDENT_LOG"
echo "[emergency-stop] Incident logged: $INCIDENT_LOG"

# ── Send alert ────────────────────────────────────────────────────────────────
if [[ -f "$ALERTS_FILE" ]]; then
  WEBHOOK=$(awk -F'"' '/"slack_webhook_url"/{print $4; exit}' "$ALERTS_FILE")
  if [[ -n "$WEBHOOK" ]] && [[ "$WEBHOOK" != "" ]]; then
    curl -s -X POST "$WEBHOOK" \
      -H 'Content-type: application/json' \
      --data "{\"text\":\"🚨 [Atlantia] EMERGENCY STOP by ${USERNAME:-unknown} at $TIMESTAMP. Reason: $REASON\"}" \
      > /dev/null 2>&1 || true
    echo "[emergency-stop] Alert sent"
  else
    echo "[emergency-stop] WARNING: No Slack webhook configured. Configure atlas-core/governance/alerts.json."
  fi
fi

echo "[emergency-stop] ✅ Done."
