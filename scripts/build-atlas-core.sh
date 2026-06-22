#!/usr/bin/env bash
# build-atlas-core.sh
# Reads every persona file from the division source directories,
# converts frontmatter to Ruflo agent format, writes output to /atlas-core/agents/.
# This is the only source of truth for atlas-core/agents/ — do not hand-edit generated files.
#
# Usage:
#   ./scripts/build-atlas-core.sh [--dry-run] [--division <name>] [--verbose]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_DIR="$ROOT_DIR/atlas-core/agents"
TEMPLATE="$ROOT_DIR/templates/agent-template.md"

# Divisions to convert (quality is handled separately as Judicial branch)
DIVISIONS=(
  academic design engineering finance game-development gis
  marketing paid-media product project-management quality
  sales security spatial-computing specialized support testing
)

# Regulated domains — always get memory_tier: ephemeral
REGULATED_DIVISIONS=(finance security)
REGULATED_SUBSTRINGS=(legal healthcare medical billing hr-onboarding loan-officer real-estate)

DRY_RUN=false
VERBOSE=false
TARGET_DIVISION=""

# ── arg parsing ──────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)   DRY_RUN=true; shift ;;
    --verbose)   VERBOSE=true; shift ;;
    --division)  TARGET_DIVISION="$2"; shift 2 ;;
    --help)
      grep '^#' "$0" | sed 's/^# \?//'
      exit 0
      ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

log() { echo "[build-atlas-core] $*"; }
vlog() { $VERBOSE && echo "[build-atlas-core:verbose] $*" || true; }

# ── state_name mapping ───────────────────────────────────────────────────────
state_name_for_division() {
  case "$1" in
    engineering)        echo "Forge State" ;;
    marketing)          echo "Signal State" ;;
    paid-media)         echo "Signal State (Paid Media)" ;;
    sales)              echo "Exchange State" ;;
    support)            echo "Exchange State (Support)" ;;
    finance)            echo "Ledger State" ;;
    security)           echo "Ledger State (Security)" ;;
    design)             echo "Atelier State" ;;
    gis)                echo "Cartography State" ;;
    testing)            echo "Proving State" ;;
    academic)           echo "Archive State" ;;
    game-development)   echo "Arcade State" ;;
    product)            echo "Compass State" ;;
    project-management) echo "Logistics State" ;;
    spatial-computing)  echo "Frontier State" ;;
    specialized)        echo "The Federal District" ;;
    quality)            echo "Judiciary (Atlantia Empire)" ;;
    data)               echo "Census State" ;;
    *)                  echo "The Federal District" ;;
  esac
}

# ── determine memory_tier ────────────────────────────────────────────────────
memory_tier_for() {
  local division="$1"
  local filename="$2"

  # Check regulated divisions
  for reg in "${REGULATED_DIVISIONS[@]}"; do
    [[ "$division" == "$reg" ]] && echo "ephemeral" && return
  done

  # Check regulated substrings in filename
  for sub in "${REGULATED_SUBSTRINGS[@]}"; do
    [[ "$filename" == *"$sub"* ]] && echo "ephemeral" && return
  done

  echo "project-scoped"
}

# ── branch for division ──────────────────────────────────────────────────────
branch_for_division() {
  [[ "$1" == "quality" ]] && echo "judicial" || echo "executive"
}

# ── extract frontmatter field ────────────────────────────────────────────────
get_field() {
  local field="$1"
  local file="$2"
  awk -v key="$field" '
    /^---$/ { if(count++ == 0) { next } else { exit } }
    $0 ~ "^" key ": " {
      sub("^" key ": ", "")
      print
    }
  ' "$file"
}

# ── convert a single persona file ────────────────────────────────────────────
convert_persona() {
  local src="$1"
  local division="$2"
  local basename
  basename="$(basename "$src" .md)"
  local out_dir="$OUTPUT_DIR/$division"
  local out_file="$out_dir/$basename.md"

  # Read existing frontmatter fields
  local name
  name=$(get_field "name" "$src")
  local description
  description=$(get_field "description" "$src")
  local color
  color=$(get_field "color" "$src")

  # Derive atlas fields
  local ruflo_type="atlas-${division}-${basename}"
  ruflo_type="${ruflo_type//[[:space:]]/-}"
  ruflo_type="${ruflo_type,,}"
  local state_name
  state_name=$(state_name_for_division "$division")
  local memory_tier
  memory_tier=$(memory_tier_for "$division" "$basename")
  local branch
  branch=$(branch_for_division "$division")

  # Sanitize color for hex format
  if [[ -n "$color" ]] && [[ "$color" != "#"* ]]; then
    color=""
  fi

  vlog "Converting: $basename ($division) → ruflo_type: $ruflo_type, memory_tier: $memory_tier"

  if $DRY_RUN; then
    log "[DRY-RUN] Would write: $out_file"
    return
  fi

  mkdir -p "$out_dir"

  # Get the body (everything after the frontmatter block)
  local body
  body=$(awk 'BEGIN{f=0} /^---$/{f++; if(f==2){found=1; next}} found{print}' "$src")

  # Write converted file with Ruflo-compatible frontmatter
  cat > "$out_file" <<HEREDOC
---
name: ${name:-$basename}
description: ${description:-"Atlantia specialist agent — ${division} division"}
ruflo_type: $ruflo_type
division: $division
state_name: "$state_name"
branch: $branch
memory_tier: $memory_tier
status: active
model_hint: standard${color:+
color: "$color"}
_source: "Generated by scripts/build-atlas-core.sh from source file: ${division}/${basename}.md"
_note: "Edit the source file in ${division}/, then re-run build-atlas-core.sh. Do not edit this file directly."
---
$body
HEREDOC

  vlog "Written: $out_file"
}

# ── main ─────────────────────────────────────────────────────────────────────
log "Building atlas-core agents..."
log "Output dir: $OUTPUT_DIR"
$DRY_RUN && log "DRY RUN — no files will be written"

total=0
skipped=0

for division in "${DIVISIONS[@]}"; do
  # Skip if targeting a specific division
  if [[ -n "$TARGET_DIVISION" ]] && [[ "$TARGET_DIVISION" != "$division" ]]; then
    continue
  fi

  src_dir="$ROOT_DIR/$division"
  if [[ ! -d "$src_dir" ]]; then
    log "WARNING: Division directory not found: $src_dir — skipping"
    continue
  fi

  while IFS= read -r -d '' persona_file; do
    # Skip non-frontmatter files (like README.md, strategy playbooks, etc.)
    if ! grep -q '^---$' "$persona_file" 2>/dev/null; then
      vlog "No frontmatter, skipping: $persona_file"
      ((skipped++)) || true
      continue
    fi

    convert_persona "$persona_file" "$division"
    ((total++)) || true
  done < <(find "$src_dir" -maxdepth 1 -name "*.md" -print0 | sort -z)
done

log "Done. Converted: $total agents. Skipped: $skipped (no frontmatter)."
if $DRY_RUN; then
  log "Run without --dry-run to write files."
fi

# ── verify regulated domain memory_tier ─────────────────────────────────────
if ! $DRY_RUN; then
  log "Verifying regulated domain memory_tier enforcement..."
  fail=0
  for division in "${REGULATED_DIVISIONS[@]}"; do
    agent_dir="$OUTPUT_DIR/$division"
    [[ -d "$agent_dir" ]] || continue
    while IFS= read -r -d '' f; do
      tier=$(get_field "memory_tier" "$f")
      if [[ "$tier" != "ephemeral" ]]; then
        log "FAIL: $f — memory_tier is '$tier', expected 'ephemeral'"
        ((fail++)) || true
      fi
    done < <(find "$agent_dir" -name "*.md" -print0)
  done

  if [[ $fail -gt 0 ]]; then
    log "ERROR: $fail regulated-domain agents have wrong memory_tier. Fix before deploying."
    exit 1
  fi
  log "Memory tier verification: all regulated domains correctly set to ephemeral."
fi
