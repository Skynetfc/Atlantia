#!/usr/bin/env bash
# atlas-core/install.sh
# Installs the atlas-core plugin into a Ruflo instance.
# Also works standalone: copies persona files into the format expected by the target tool.
#
# Usage:
#   ./atlas-core/install.sh [--tool claude-code|gemini-cli|copilot|all] [--link] [--dry-run]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
AGENTS_DIR="$SCRIPT_DIR/agents"

DRY_RUN=false
LINK=false
TARGET_TOOL="auto"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)   DRY_RUN=true; shift ;;
    --link)      LINK=true; shift ;;
    --tool)      TARGET_TOOL="$2"; shift 2 ;;
    --help)
      echo "Usage: ./atlas-core/install.sh [--tool <tool>] [--link] [--dry-run]"
      echo "Tools: ruflo, claude-code, gemini-cli, copilot, all"
      exit 0
      ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

log() { echo "[atlas-core:install] $*"; }

# ── Build agents if not yet built ──────────────────────────────────────────────
if [[ ! -d "$AGENTS_DIR" ]] || [[ -z "$(ls -A "$AGENTS_DIR" 2>/dev/null)" ]]; then
  log "atlas-core/agents/ is empty. Running build-atlas-core.sh first..."
  bash "$ROOT_DIR/scripts/build-atlas-core.sh"
fi

# ── Install into Ruflo ─────────────────────────────────────────────────────────
install_ruflo() {
  if ! command -v ruflo &>/dev/null; then
    log "WARNING: ruflo not in PATH. Skipping ruflo plugin install."
    log "Install ruflo with: npm install -g ruflo"
    log "Then run: ruflo plugin install $ROOT_DIR/atlas-core"
    return
  fi

  log "Installing atlas-core plugin into Ruflo..."
  if $DRY_RUN; then
    log "[DRY-RUN] Would run: ruflo plugin install $ROOT_DIR/atlas-core"
  else
    ruflo plugin install "$ROOT_DIR/atlas-core" && log "Ruflo plugin install: OK"
  fi
}

# ── Install into Claude Code ───────────────────────────────────────────────────
install_claude_code() {
  local dest="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/agents"
  log "Installing to Claude Code: $dest"
  $DRY_RUN && { log "[DRY-RUN] Would copy $AGENTS_DIR/* to $dest"; return; }
  mkdir -p "$dest"
  if $LINK; then
    for div_dir in "$AGENTS_DIR"/*/; do
      local div
      div=$(basename "$div_dir")
      ln -sf "$div_dir" "$dest/atlas-$div" && log "Linked: atlas-$div"
    done
  else
    cp -r "$AGENTS_DIR"/. "$dest/atlas-atlantia/"
    log "Copied to $dest/atlas-atlantia/"
  fi
}

# ── Install into Gemini CLI ────────────────────────────────────────────────────
install_gemini_cli() {
  local dest="${GEMINI_AGENTS_DIR:-$HOME/.gemini/agents}"
  log "Installing to Gemini CLI: $dest"
  $DRY_RUN && { log "[DRY-RUN] Would copy $AGENTS_DIR/* to $dest"; return; }
  mkdir -p "$dest"
  cp -r "$AGENTS_DIR"/. "$dest/atlas-atlantia/"
  log "Copied to $dest/atlas-atlantia/"
}

# ── Auto-detect ────────────────────────────────────────────────────────────────
detect_and_install() {
  local installed=0
  command -v ruflo &>/dev/null && { install_ruflo; ((installed++)) || true; }
  [[ -d "${CLAUDE_CONFIG_DIR:-$HOME/.claude}" ]] && { install_claude_code; ((installed++)) || true; }
  [[ -d "${GEMINI_AGENTS_DIR:-$HOME/.gemini}" ]] && { install_gemini_cli; ((installed++)) || true; }
  [[ $installed -eq 0 ]] && log "No supported tools detected. Install ruflo or Claude Code first."
}

# ── Dispatch ───────────────────────────────────────────────────────────────────
case "$TARGET_TOOL" in
  ruflo)       install_ruflo ;;
  claude-code) install_claude_code ;;
  gemini-cli)  install_gemini_cli ;;
  all)         install_ruflo; install_claude_code; install_gemini_cli ;;
  auto)        detect_and_install ;;
  *)           echo "Unknown tool: $TARGET_TOOL" >&2; exit 1 ;;
esac

log "Done."
log "Run 'atlantia census' to confirm agents are visible."
