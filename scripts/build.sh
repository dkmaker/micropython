#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# build.sh — Build the STEALTH_HID firmware for Raspberry Pi Pico 2 W
#
# Usage:
#   ./scripts/build.sh              # normal build
#   ./scripts/build.sh clean        # clean then build
#   ./scripts/build.sh flash        # build + flash via UF2 (auto-detects RPI-RP2)
#
# Prerequisites (one-time setup):
#   sudo apt install cmake gcc-arm-none-eabi libnewlib-arm-none-eabi build-essential
#   make -C mpy-cross              # build the MicroPython cross-compiler first
#   make -C ports/rp2 BOARD=STEALTH_HID submodules   # fetch Pico SDK etc.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

BOARD="STEALTH_HID"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$REPO_ROOT/ports/rp2/build-$BOARD"
UF2="$BUILD_DIR/firmware.uf2"

cd "$REPO_ROOT"

if [[ "${1:-}" == "clean" ]]; then
    echo ">>> Cleaning build-$BOARD ..."
    rm -rf "$BUILD_DIR"
fi

# ── 1. Build mpy-cross if missing ────────────────────────────────────────────
if [[ ! -f "$REPO_ROOT/mpy-cross/build/mpy-cross" ]]; then
    echo ">>> Building mpy-cross ..."
    make -C mpy-cross -j"$(nproc)"
fi

# ── 2. Build firmware ─────────────────────────────────────────────────────────
echo ">>> Building firmware for $BOARD ..."
make -C ports/rp2 BOARD="$BOARD" -j"$(nproc)"

echo ""
echo "✅  Build complete: $UF2"
echo "    $(du -sh "$UF2" | cut -f1)  $(sha256sum "$UF2" | cut -c1-16)..."

# ── 3. Flash (optional) ───────────────────────────────────────────────────────
if [[ "${1:-}" == "flash" ]]; then
    # Wait for RPI-RP2 or RP2350 mass storage (hold BOOTSEL while plugging USB)
    MOUNT=""
    for d in /media/"$USER"/{RPI-RP2,RP2350}; do
        [[ -d "$d" ]] && MOUNT="$d" && break
    done
    if [[ -z "$MOUNT" ]]; then
        echo "❌  No RPI-RP2/RP2350 mount found. Hold BOOTSEL, plug USB, then re-run."
        exit 1
    fi
    echo ">>> Flashing to $MOUNT ..."
    cp "$UF2" "$MOUNT/"
    echo "✅  Flashed. Pico will reboot as Logitech USB Receiver."
fi
