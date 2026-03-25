#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# sync-upstream.sh — Rebase custom/logitech-hid branch on top of latest
#                    micropython/micropython master
#
# Strategy: REBASE (not merge)
#   - Our changes live exclusively in ports/rp2/boards/STEALTH_HID/ and scripts/
#   - Upstream will never create that path, so rebase conflicts are essentially zero
#   - Result: a clean linear history, easy to inspect diffs
#
# Usage:
#   ./scripts/sync-upstream.sh              # dry-run: show what would change
#   ./scripts/sync-upstream.sh apply        # fetch + rebase + push
#
# After running with "apply":
#   1. Review build still works: ./scripts/build.sh
#   2. Push is done automatically to origin/custom/logitech-hid
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

CUSTOM_BRANCH="custom/logitech-hid"
UPSTREAM_REMOTE="upstream"
UPSTREAM_BRANCH="master"
ORIGIN_REMOTE="origin"

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

# ── Ensure we're on the right branch ─────────────────────────────────────────
CURRENT=$(git rev-parse --abbrev-ref HEAD)
if [[ "$CURRENT" != "$CUSTOM_BRANCH" ]]; then
    echo "⚠️   Not on $CUSTOM_BRANCH (currently: $CURRENT)"
    echo "     Run: git checkout $CUSTOM_BRANCH"
    exit 1
fi

# ── Fetch upstream ────────────────────────────────────────────────────────────
echo ">>> Fetching $UPSTREAM_REMOTE/$UPSTREAM_BRANCH ..."
git fetch "$UPSTREAM_REMOTE" "$UPSTREAM_BRANCH"

UPSTREAM_REF="$UPSTREAM_REMOTE/$UPSTREAM_BRANCH"
NEW_COMMITS=$(git log HEAD.."$UPSTREAM_REF" --oneline | wc -l | tr -d ' ')

if [[ "$NEW_COMMITS" -eq 0 ]]; then
    echo "✅  Already up to date. No upstream commits."
    exit 0
fi

echo ""
echo "📋  $NEW_COMMITS new upstream commit(s):"
git log HEAD.."$UPSTREAM_REF" --oneline | head -20
echo ""

if [[ "${1:-}" != "apply" ]]; then
    echo "ℹ️   Dry run. Run with 'apply' to rebase and push:"
    echo "     ./scripts/sync-upstream.sh apply"
    exit 0
fi

# ── Rebase ────────────────────────────────────────────────────────────────────
echo ">>> Rebasing $CUSTOM_BRANCH onto $UPSTREAM_REF ..."
git rebase "$UPSTREAM_REF"

echo ""
echo "✅  Rebase complete. Verifying our board definition still exists..."
[[ -f "ports/rp2/boards/STEALTH_HID/mpconfigboard.h" ]] || {
    echo "❌  STEALTH_HID board missing after rebase! Investigate."
    exit 1
}

# ── Push ──────────────────────────────────────────────────────────────────────
echo ">>> Force-pushing $CUSTOM_BRANCH to $ORIGIN_REMOTE ..."
git push "$ORIGIN_REMOTE" "$CUSTOM_BRANCH" --force-with-lease

echo ""
echo "✅  Sync complete. Remember to run ./scripts/build.sh to verify the build."
