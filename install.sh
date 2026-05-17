#!/bin/bash
set -euo pipefail

REPO="Hyunki6040/tybre-md-releases"
APP_NAME="Tybre.md"
INSTALL_DIR="/Applications"

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${BLUE}${BOLD}▶${NC} $*"; }
success() { echo -e "${GREEN}${BOLD}✓${NC} $*"; }
warn()    { echo -e "${YELLOW}${BOLD}!${NC} $*"; }
error()   { echo -e "${RED}${BOLD}✗${NC} $*" >&2; exit 1; }

# ── macOS check ───────────────────────────────────────────────────────────────
if [ "$(uname)" != "Darwin" ]; then
  error "This installer is for macOS only."
fi

# ── Architecture detection ────────────────────────────────────────────────────
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
  ASSET_SUFFIX="aarch64.dmg"
  ARCH_LABEL="Apple Silicon (M1/M2/M3)"
elif [ "$ARCH" = "x86_64" ]; then
  ASSET_SUFFIX="x64.dmg"
  ARCH_LABEL="Intel"
else
  error "Unsupported architecture: $ARCH"
fi

echo ""
echo -e "${BOLD}Tybre.md Installer${NC}"
echo "────────────────────────────────"
info "Detected: macOS ${ARCH_LABEL}"

# ── Fetch latest release ──────────────────────────────────────────────────────
info "Checking latest release..."
RELEASE_JSON=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" 2>/dev/null) \
  || error "Failed to fetch release info. Check your internet connection."

VERSION=$(echo "$RELEASE_JSON" | grep '"tag_name"' | head -1 | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/')
DOWNLOAD_URL=$(echo "$RELEASE_JSON" | grep '"browser_download_url"' | grep "$ASSET_SUFFIX" | head -1 | sed 's/.*"browser_download_url": *"\([^"]*\)".*/\1/')

[ -z "$VERSION" ]      && error "Could not determine version from GitHub API."
[ -z "$DOWNLOAD_URL" ] && error "Could not find .dmg download URL for $ARCH_LABEL."

info "Downloading ${APP_NAME} ${VERSION}..."

# ── Download ──────────────────────────────────────────────────────────────────
TMP_DMG="/tmp/tybre-$$.dmg"
trap 'rm -f "$TMP_DMG"' EXIT

curl -fsSL --progress-bar "$DOWNLOAD_URL" -o "$TMP_DMG" \
  || error "Download failed."

# ── Mount DMG ─────────────────────────────────────────────────────────────────
info "Mounting disk image..."
MOUNT_POINT=$(mktemp -d /tmp/tybre-mount-XXXXXX)
trap 'hdiutil detach "$MOUNT_POINT" -quiet 2>/dev/null; rm -f "$TMP_DMG"; rm -rf "$MOUNT_POINT"' EXIT

hdiutil attach "$TMP_DMG" -mountpoint "$MOUNT_POINT" -quiet -nobrowse \
  || error "Failed to mount disk image."

# ── Install app ───────────────────────────────────────────────────────────────
APP_SRC="${MOUNT_POINT}/${APP_NAME}.app"
APP_DEST="${INSTALL_DIR}/${APP_NAME}.app"

[ ! -d "$APP_SRC" ] && error "Could not find ${APP_NAME}.app inside the disk image."

info "Installing to ${INSTALL_DIR}..."
if [ -d "$APP_DEST" ]; then
  warn "Existing installation found — replacing..."
  rm -rf "$APP_DEST"
fi

cp -R "$APP_SRC" "$APP_DEST" \
  || error "Failed to copy app. Try running with sudo if permission is denied."

# ── Remove quarantine ─────────────────────────────────────────────────────────
info "Removing macOS security quarantine..."
xattr -cr "$APP_DEST" 2>/dev/null || true

# ── Cleanup ───────────────────────────────────────────────────────────────────
hdiutil detach "$MOUNT_POINT" -quiet 2>/dev/null || true
trap - EXIT
rm -f "$TMP_DMG"
rm -rf "$MOUNT_POINT"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
success "${BOLD}${APP_NAME} ${VERSION} installed successfully!${NC}"
echo ""
echo "  Open from: Finder → Applications → Tybre.md"
echo "  Or search in Spotlight (⌘ Space) → \"Tybre\""
echo ""
