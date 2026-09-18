#!/usr/bin/env bash
#
# Creates the Android SDK packages and the emulator AVD used for React
# Native / Expo work, without installing Android Studio. Safe to re-run —
# the SDK step is idempotent and the AVD is left alone unless RECREATE=1.
#
# The AVD's own config.ini is deliberately NOT tracked in this repo: the
# emulator rewrites it on exit and whenever you change something in its
# UI, it points at a system image that has to be installed already, and
# its sibling ~/.android/avd/<name>.ini carries an absolute path. The
# reproducible thing is this recipe, not the artifact it produces.
#
# Usage:
#   ~/dotfiles/scripts/android-avd.sh            # create if missing
#   RECREATE=1 ~/dotfiles/scripts/android-avd.sh # wipe and rebuild it
#
# Options (env vars):
#   AVD_NAME     AVD name (default: px)
#   AVD_DEVICE   Device profile, see `avdmanager list device` (default: pixel_8)
#   ANDROID_API  API level for platform + system image (default: 36.1)
#   AVD_TAG      System image tag (default: google_apis)
#   AVD_RAM      Emulator RAM (default: 3G)
#   AVD_HEAP     Per-app ART heap (default: 256M)
#   RECREATE     Set to 1 to delete an existing AVD and build it fresh
#
# RECREATE=1 wipes userdata: installed apps and logged-in sessions go
# with it.
#
set -euo pipefail

log() {
  echo "[android-avd] $*"
}

AVD_NAME="${AVD_NAME:-px}"
AVD_DEVICE="${AVD_DEVICE:-pixel_8}"
ANDROID_API="${ANDROID_API:-36.1}"
AVD_TAG="${AVD_TAG:-google_apis}"
AVD_RAM="${AVD_RAM:-3G}"
AVD_HEAP="${AVD_HEAP:-256M}"

if [[ "$(uname)" != "Darwin" ]]; then
  echo "This script only supports macOS for now." >&2
  exit 1
fi

# --- 1. Locate the SDK ---
# The android-commandlinetools cask is declared in configs/nix-darwin/
# homebrew.nix, so it arrives with `darwin-rebuild switch` rather than
# being installed here.
export ANDROID_HOME="${ANDROID_HOME:-$(brew --prefix)/share/android-commandlinetools}"

if [[ ! -x "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]]; then
  echo "No sdkmanager at $ANDROID_HOME." >&2
  echo "The android-commandlinetools cask is missing — run: darwin-rebuild switch" >&2
  exit 1
fi

# Without this, the newer cmdline-tools honour XDG_CONFIG_HOME and look
# for AVDs under ~/.config/.android, while the emulator binary still uses
# the legacy ~/.android. Each tool then sees a different set of AVDs:
# `avdmanager delete` reports the AVD doesn't exist while `emulator
# -list-avds` happily lists it. configs/shell/20_exports.sh sets this for
# interactive shells; repeat it here so the script works standalone.
export ANDROID_USER_HOME="${ANDROID_USER_HOME:-$HOME/.android}"

export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

case "$(uname -m)" in
  arm64) AVD_ABI="arm64-v8a" ;;
  *) AVD_ABI="x86_64" ;;
esac

SYSTEM_IMAGE="system-images;android-${ANDROID_API};${AVD_TAG};${AVD_ABI}"
AVD_CONFIG="$ANDROID_USER_HOME/avd/${AVD_NAME}.avd/config.ini"

# --- 2. SDK packages ---
# No NDK: React Native 0.81+ ships prebuilt Android artifacts, and the
# NDK alone is ~5 GB.
log "Installing SDK packages (no-op if already present)..."
yes | sdkmanager --licenses >/dev/null 2>&1 || true
sdkmanager \
  "platform-tools" \
  "emulator" \
  "build-tools;36.0.0" \
  "platforms;android-${ANDROID_API}" \
  "$SYSTEM_IMAGE" >/dev/null

# --- 3. The AVD ---
if avdmanager list avd 2>/dev/null | grep -q "Name: ${AVD_NAME}$"; then
  if [[ "${RECREATE:-0}" != "1" ]]; then
    log "AVD '$AVD_NAME' already exists — leaving it alone (RECREATE=1 to rebuild)."
    exit 0
  fi

  # The emulator rewrites config.ini when it shuts down, so any edit made
  # while it is running is lost. Same reason the delete below needs it gone.
  if pgrep -f "qemu-system.*${AVD_NAME}" >/dev/null 2>&1; then
    echo "The '$AVD_NAME' emulator is running. Stop it first: adb emu kill" >&2
    exit 1
  fi

  log "RECREATE=1 — deleting AVD '$AVD_NAME' (userdata goes with it)..."
  avdmanager delete avd -n "$AVD_NAME"
fi

# `avdmanager create` prints "Error: Could not load devices from
# .../devices.xml" for the system image directory. It is noise: the
# device profile resolves from the built-in catalogue instead, and
# hw.device.name lands in config.ini correctly. The `no` answers its
# "create a custom hardware profile?" prompt.
log "Creating AVD '$AVD_NAME' ($AVD_DEVICE, android-${ANDROID_API}, $AVD_ABI)..."
echo "no" | avdmanager create avd -n "$AVD_NAME" -d "$AVD_DEVICE" -k "$SYSTEM_IMAGE" \
  2>&1 | grep -v "devices.xml" || true

if [[ ! -f "$AVD_CONFIG" ]]; then
  echo "Expected config at $AVD_CONFIG but it isn't there — AVD creation failed." >&2
  exit 1
fi

# --- 4. Settings the device profile doesn't cover ---
# -d pixel_8 gets the screen right (1080x2400 @ 420dpi) and bumps the ART
# heap off the generic profile's unusable 32M, but leaves these at
# defaults that make the emulator slow, unusable, or both.
set_cfg() {
  local key="$1" value="$2"
  if grep -q "^${key}=" "$AVD_CONFIG"; then
    sed -i '' "s|^${key}=.*|${key}=${value}|" "$AVD_CONFIG"
  else
    echo "${key}=${value}" >>"$AVD_CONFIG"
  fi
}

log "Applying config.ini overrides..."
set_cfg hw.keyboard yes        # type with the host keyboard instead of the on-screen one
set_cfg hw.gpu.enabled yes     # default is software rendering, which is painfully slow
set_cfg hw.gpu.mode host
set_cfg hw.ramSize "$AVD_RAM"
set_cfg vm.heapSize "$AVD_HEAP"

log ""
log "Done. Start it with:  emulator -avd $AVD_NAME"
log "Window too tall for the display?  emulator -avd $AVD_NAME -scale 0.4"
