#!/usr/bin/env bash
# gsp.sh — Gross Specialist Product computation script
# Called by `atlantia gsp`. Also called by Capital Allocation Agent weekly.
# Reads from atlas-core/eval/runs/ and produces a structured GSP report.
#
# Usage:
#   ./scripts/gsp.sh [--period weekly|daily|all] [--json]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RUNS_DIR="$ROOT_DIR/atlas-core/eval/runs"

PERIOD="weekly"
JSON_OUTPUT=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --period) PERIOD="$2"; shift 2 ;;
    --json)   JSON_OUTPUT=true; shift ;;
    *) shift ;;
  esac
done

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if [[ ! -d "$RUNS_DIR" ]] || [[ -z "$(ls -A "$RUNS_DIR" 2>/dev/null)" ]]; then
  if $JSON_OUTPUT; then
    echo '{"period":"'"$PERIOD"'","timestamp":"'"$TIMESTAMP"'","total_deliverables":0,"avg_quality_score":null,"note":"No eval runs found. Run atlas-core/eval/run-eval.sh first."}'
  else
    echo "[gsp] No eval runs found. Run: bash atlas-core/eval/run-eval.sh"
  fi
  exit 0
fi

python3 - <<PYEOF
import json, os, glob
from datetime import datetime, timedelta, timezone

runs_dir = "$RUNS_DIR"
period = "$PERIOD"
timestamp = "$TIMESTAMP"
json_output = $JSON_OUTPUT

# Determine cutoff date based on period
now = datetime.now(timezone.utc)
if period == "daily":
    cutoff = now - timedelta(days=1)
elif period == "weekly":
    cutoff = now - timedelta(weeks=1)
else:
    cutoff = None  # "all"

# Gather results from all runs in period
all_results = []
state_results = {}

for results_file in glob.glob(f"{runs_dir}/*/results.json"):
    try:
        # Parse timestamp from parent dir name (format: 20260101T000000Z)
        dir_name = os.path.basename(os.path.dirname(results_file))
        try:
            run_dt = datetime.strptime(dir_name, "%Y%m%dT%H%M%SZ").replace(tzinfo=timezone.utc)
        except ValueError:
            run_dt = now  # fallback

        if cutoff and run_dt < cutoff:
            continue

        data = json.load(open(results_file))
        for r in data.get("results", []):
            all_results.append(r)
            division = r.get("agent", "").split("-")[0] if r.get("agent") else "unknown"
            state_results.setdefault(division, []).append(r)
    except Exception:
        continue

# Compute metrics
total = len(all_results)
scores = [r.get("persona_score", {}).get("weighted_total") for r in all_results if r.get("persona_score", {}).get("weighted_total") is not None]
avg_quality = round(sum(scores) / len(scores), 2) if scores else None
positive = sum(1 for r in all_results if r.get("verdict") == "positive_benefit")
no_benefit = sum(1 for r in all_results if r.get("verdict") == "no_measurable_benefit")

# State breakdown
state_summary = {}
for state, results in state_results.items():
    state_scores = [r.get("persona_score", {}).get("weighted_total") for r in results if r.get("persona_score", {}).get("weighted_total") is not None]
    state_summary[state] = {
        "deliverables": len(results),
        "avg_quality": round(sum(state_scores)/len(state_scores), 2) if state_scores else None
    }

highest_state = max(state_summary.items(), key=lambda x: x[1]["deliverables"], default=(None, {}))[0]
lowest_state = min(state_summary.items(), key=lambda x: x[1]["deliverables"], default=(None, {}))[0]

report = {
    "period": period,
    "timestamp": timestamp,
    "total_deliverables": total,
    "avg_quality_score": avg_quality,
    "positive_benefit_count": positive,
    "no_measurable_benefit_count": no_benefit,
    "highest_output_state": highest_state,
    "lowest_output_state": lowest_state,
    "state_breakdown": state_summary
}

if json_output:
    print(json.dumps(report, indent=2))
else:
    print(f"\n  Period: {period} | Generated: {timestamp}")
    print(f"  Total deliverables: {total}")
    print(f"  Average quality score: {avg_quality}/10")
    print(f"  Positive benefit: {positive} | No measurable benefit: {no_benefit}")
    print(f"  Highest output state: {highest_state}")
    if no_benefit > 0:
        print(f"\n  ⚠️  {no_benefit} agents with no measurable benefit — Deprecation Auditor review recommended")
PYEOF
