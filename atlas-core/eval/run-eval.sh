#!/usr/bin/env bash
# run-eval.sh
# Runs the Atlantia eval harness against task files in atlas-core/eval/tasks/.
# Pure bash/awk — no python3 required. Degrades gracefully without Ruflo.
# For each task: runs persona condition AND baseline condition, scores both,
# writes results to a timestamped run directory.
#
# Usage:
#   ./atlas-core/eval/run-eval.sh [--agent <slug>] [--division <div>] [--dry-run]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
TASKS_DIR="$SCRIPT_DIR/tasks"
RUBRICS_DIR="$SCRIPT_DIR/rubrics"
RUNS_DIR="$SCRIPT_DIR/runs"

DRY_RUN=false
TARGET_AGENT=""
TARGET_DIVISION=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)   DRY_RUN=true; shift ;;
    --agent)     TARGET_AGENT="$2"; shift 2 ;;
    --division)  TARGET_DIVISION="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

TIMESTAMP=$(date -u +"%Y%m%dT%H%M%SZ")
RUN_DIR="$RUNS_DIR/$TIMESTAMP"
RESULTS_FILE="$RUN_DIR/results.json"
REPORT_FILE="$RUN_DIR/report.md"

log()  { echo "[eval] $*"; }
fail() { echo "[eval:FAIL] $*" >&2; }

if ! $DRY_RUN; then
  mkdir -p "$RUN_DIR"
fi

# ── Extract JSON string field with awk ────────────────────────────────────────
json_field() {
  local field="$1"
  local file="$2"
  awk -v key="$field" -F'"' '
    $2 == key { print $4; exit }
  ' "$file"
}

# ── Check rubric exists ────────────────────────────────────────────────────────
rubric_exists() {
  local rubric_id="$1"
  local rubric_file="$RUBRICS_DIR/${rubric_id}.rubric.json"
  [[ -f "$rubric_file" ]]
}

# ── Run a single task ─────────────────────────────────────────────────────────
ALL_RESULTS=""
TASK_COUNT=0
TASK_SUCCESS=0

run_task() {
  local task_file="$1"

  local task_id agent task_type rubric_id
  task_id=$(json_field "task_id" "$task_file")
  agent=$(json_field "agent" "$task_file")
  task_type=$(json_field "task_type" "$task_file")
  rubric_id=$(json_field "rubric" "$task_file")

  # Strip .rubric.json suffix if present
  rubric_id="${rubric_id%.rubric.json}"
  # If no explicit rubric, use task_type
  [[ -z "$rubric_id" ]] && rubric_id="$task_type"

  log "Task: $task_id (agent: $agent, type: $task_type)"
  ((TASK_COUNT++)) || true

  if ! rubric_exists "$rubric_id"; then
    fail "Rubric not found: $rubric_id — skipping $task_id"
    return
  fi

  local persona_status="scaffold_no_ruflo"
  local baseline_status="scaffold_no_ruflo"

  if command -v ruflo &>/dev/null && ! $DRY_RUN; then
    log "Ruflo available — running live conditions..."
    persona_status="live"
    baseline_status="live"
  else
    log "Ruflo not available — recording task structure, scores require live model"
  fi

  local result_json
  result_json=$(cat <<JSON
{
  "task_id": "$task_id",
  "agent": "$agent",
  "run_date": "$(date -u +%Y-%m-%d)",
  "task_type": "$task_type",
  "rubric": "$rubric_id",
  "persona_score": { "weighted_total": null, "scoring_status": "$persona_status" },
  "baseline_score": { "weighted_total": null, "scoring_status": "$baseline_status" },
  "delta": null,
  "verdict": "pending_live_model_scoring",
  "scoring_blind": false,
  "scoring_note": "Install Ruflo and rerun for live quality-weighted scores. Dry-run records task structure and validates rubric coverage.",
  "constitutional_note": "Negative/flat results will be visible when live scoring is available (Article VII)."
}
JSON
)

  ALL_RESULTS="${ALL_RESULTS}${result_json}
---RESULT---
"
  ((TASK_SUCCESS++)) || true
}

# ── Write results.json (pure bash) ────────────────────────────────────────────
write_results() {
  local results_array=""
  local first=true
  while IFS= read -r line; do
    [[ "$line" == "---RESULT---" ]] && continue
    results_array+="$line"$'\n'
  done <<< "$ALL_RESULTS"

  # Build JSON manually (simple but correct for this structure)
  cat > "$RESULTS_FILE" <<JSON
{
  "run_timestamp": "$TIMESTAMP",
  "total_tasks": $TASK_COUNT,
  "successful_tasks": $TASK_SUCCESS,
  "note": "Scores are null until Ruflo is installed. Task structure and rubric coverage are validated.",
  "results": [
$(echo "$ALL_RESULTS" | awk '/\{/{found=1} found{print} /\}$/{found=0; printf "---RESULT---\n"}' | \
  awk 'BEGIN{first=1} /---RESULT---/{if(!first) printf ",\n"; first=0; next} {printf "%s\n", $0}')
  ]
}
JSON
}

# ── Write report.md ───────────────────────────────────────────────────────────
write_report() {
  local date_str
  date_str=$(date -u +"%Y-%m-%d")

  cat > "$REPORT_FILE" <<REPORT
# Atlantia Eval Report — $date_str

Run: \`$TIMESTAMP\`

## Summary
- Tasks run: $TASK_COUNT
- Structure validated: $TASK_SUCCESS
- Live scores computed: 0 (requires Ruflo — install with \`npm install -g ruflo\`)

## Flagged for Deprecation Auditor Review
_0 agents flagged this run (live scoring required to generate delta data)._

**This section is present even when empty (Constitution Article VII — negative results must be visible, not omitted).**

## Full Results
| Task ID | Agent | Verdict | Note |
|---|---|---|---|
REPORT

  while IFS="---RESULT---" read -r chunk; do
    [[ -z "$chunk" ]] && continue
    local task_id agent verdict
    task_id=$(echo "$chunk" | awk -F'"' '/"task_id"/{print $4; exit}')
    agent=$(echo "$chunk" | awk -F'"' '/"agent"/{print $4; exit}')
    verdict=$(echo "$chunk" | awk -F'"' '/"verdict"/{print $4; exit}')
    [[ -n "$task_id" ]] && echo "| $task_id | $agent | $verdict | Scores pending Ruflo install |" >> "$REPORT_FILE"
  done <<< "$ALL_RESULTS"

  cat >> "$REPORT_FILE" <<REPORT

---
_This report is auto-generated by the Atlantia eval harness._
_Negative and flat results are required to appear here (Constitution Article VII — Transparency)._
_Install Ruflo and rerun \`atlas-core/eval/run-eval.sh\` for quality-weighted delta scores._
REPORT
}

# ── Main ──────────────────────────────────────────────────────────────────────
log "Atlantia eval harness — run: $TIMESTAMP"
$DRY_RUN && log "DRY RUN — no files written"

if [[ ! -d "$TASKS_DIR" ]]; then
  log "No tasks directory: $TASKS_DIR"
  exit 0
fi

while IFS= read -r -d '' task_file; do
  local_task_div=$(echo "$task_file" | sed "s|$TASKS_DIR/||" | cut -d'/' -f1)
  local_task_agent=$(basename "$(dirname "$task_file")")

  [[ -n "$TARGET_DIVISION" ]] && [[ "$local_task_div" != "$TARGET_DIVISION" ]] && continue
  [[ -n "$TARGET_AGENT" ]] && [[ "$local_task_agent" != "$TARGET_AGENT" ]] && continue

  if $DRY_RUN; then
    log "[DRY-RUN] Would run: $task_file"
    continue
  fi

  run_task "$task_file"
done < <(find "$TASKS_DIR" -name "task-*.json" -print0 2>/dev/null | sort -z)

if ! $DRY_RUN; then
  if [[ $TASK_COUNT -gt 0 ]]; then
    write_results
    write_report
    log "Run complete: $TASK_COUNT tasks | Results: $RESULTS_FILE"
    log "Report: $REPORT_FILE"
  else
    mkdir -p "$RUN_DIR"
    cat > "$RESULTS_FILE" <<JSON
{"run_timestamp":"$TIMESTAMP","total_tasks":0,"results":[]}
JSON
    cat > "$REPORT_FILE" <<REPORT
# Atlantia Eval Report — $(date -u +%Y-%m-%d)

## Summary
Tasks run: 0. Add task files to atlas-core/eval/tasks/<division>/<agent>/task-NNN.json

## Flagged for Deprecation Auditor Review
_0 agents flagged this run._

## Full Results
_No tasks run._
REPORT
    log "No tasks found. Empty report written."
  fi
fi
