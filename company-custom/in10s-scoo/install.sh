#!/bin/bash
# Note: No set -euo pipefail — this script is run via curl | bash which conflicts with
# nested curl calls and read -r /dev/tty when stdin is the pipe.

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

# ── macOS only ────────────────────────────────────────────────────────────────
[ "$(uname)" = "Darwin" ] || error "This installer is for macOS only."

echo ""
echo -e "${BOLD}Tybre.md — in10s Lab Company Setup${NC}"
echo "────────────────────────────────────────"
echo ""

# ── Step 1: Install Tybre.md ─────────────────────────────────────────────────
info "Installing Tybre.md..."

# Download installer to temp file to avoid curl | bash stdin conflict
TYBRE_INSTALLER=$(mktemp /tmp/tybre-installer-XXXXXX.sh)
trap 'rm -f "$TYBRE_INSTALLER"' EXIT

if ! curl -fsSL -o "$TYBRE_INSTALLER" "https://raw.githubusercontent.com/Hyunki6040/tybre-md-releases/main/install.sh"; then
  error "Tybre.md 설치 파일 다운로드 실패"
fi

bash "$TYBRE_INSTALLER"
echo ""

# ── Step 2: Get user Google account email ────────────────────────────────────
printf "${BOLD}Google 계정 이메일을 입력하세요${NC} (예: you@company.com): "
read -r USER_EMAIL </dev/tty

if [ -z "$USER_EMAIL" ]; then
  warn "이메일을 입력하지 않았습니다. 프로젝트 자동 설정을 건너뜁니다."
  success "Tybre.md 설치 완료!"
  exit 0
fi

# ── Step 3: Build paths ───────────────────────────────────────────────────────
CLOUD_ROOT="$HOME/Library/CloudStorage/GoogleDrive-${USER_EMAIL}"
# Project path with spaces — kept as a variable (quoted everywhere below)
PROJECT_PATH="${CLOUD_ROOT}/공유 드라이브/in10s Lab/scailout-agent-scoo/scoo-harness"

# ── Step 4: Check Google Drive is mounted ────────────────────────────────────
if [ ! -d "$HOME/Library/CloudStorage" ]; then
  echo ""
  warn "Google Drive가 설치되어 있지 않습니다."
  warn ""
  warn "아래 링크에서 Google Drive for Desktop을 설치하세요:"
  warn "  ${BLUE}https://support.google.com/a/users/answer/13022292?hl=ko${NC}"
  warn ""
  warn "설치 후 이 스크립트를 다시 실행하세요."
  echo ""
  exit 0
fi

if [ ! -d "$CLOUD_ROOT" ]; then
  echo ""
  warn "Google Drive 계정 디렉토리를 찾을 수 없습니다:"
  warn "  ${CLOUD_ROOT}"
  warn ""
  warn "확인 사항:"
  warn "  1. Google Drive for Desktop이 로그인되어 있는지 확인하세요"
  warn "  2. 이메일 주소가 정확한지 확인하세요: ${USER_EMAIL}"
  warn "  3. Google Drive 설치 가이드: ${BLUE}https://support.google.com/a/users/answer/13022292?hl=ko${NC}"
  echo ""
  exit 0
fi

if [ ! -d "$PROJECT_PATH" ]; then
  echo ""
  warn "프로젝트 디렉토리를 찾을 수 없습니다:"
  warn "  ${PROJECT_PATH}"
  warn ""
  warn "Google Drive 동기화가 완료되었는지 확인하세요."
  echo ""
  # Still continue — set up config so it loads once synced
  warn "프로젝트가 동기화되면 자동으로 열리도록 설정을 진행합니다..."
  mkdir -p "$PROJECT_PATH"
fi

# ── Step 5: Create .tybre project config ─────────────────────────────────────
info "프로젝트 설정 파일 생성 중..."

TYBRE_DIR="${PROJECT_PATH}/.tybre"
mkdir -p "$TYBRE_DIR"

# workspace.json — auto-claude + yolo + continue all enabled, terminal open
cat > "${TYBRE_DIR}/workspace.json" << 'WSJSON'
{
  "sidebar_open": true,
  "sidebar_width": 240,
  "memo_open": false,
  "memo_width": 280,
  "term_auto_claude": true,
  "term_yolo_mode": true,
  "term_continue_session": true,
  "terminal_open": true,
  "terminal_width": 0,
  "term_pre_command_enabled": false,
  "term_pre_command": "",
  "unified_tab_mode": false,
  "pre_unified_terminal_width": 0,
  "browser_open": false,
  "browser_width": 0,
  "browser_url": "http://localhost:3000",
  "pane_tree": null,
  "pane_ratio": 0.5
}
WSJSON

# tabs.json — empty tabs (project is recognized even with no open files)
cat > "${TYBRE_DIR}/tabs.json" << 'TJSON'
{
  "open_tabs": [],
  "active_tab": null,
  "terminal_session_names": ["claude"],
  "unified_tabs": [],
  "active_unified_tab": null
}
TJSON

success "프로젝트 설정 완료"

# ── Step 6: Register project as last session ─────────────────────────────────
info "Tybre 시작 프로젝트 등록 중..."

TYBRE_APP_DIR="$HOME/Library/Application Support/Tybre"
mkdir -p "$TYBRE_APP_DIR"

# Escape path for JSON (handles spaces and special chars)
PROJECT_JSON=$(printf '%s' "$PROJECT_PATH" | python3 -c "import json,sys; print(json.dumps(sys.stdin.read()))")

cat > "${TYBRE_APP_DIR}/last-session.json" << LSJSON
{
  "open_projects": [${PROJECT_JSON}],
  "active_project": ${PROJECT_JSON}
}
LSJSON

success "시작 프로젝트 등록 완료"

# ── Step 7: Install Claude Code ───────────────────────────────────────────────
info "Claude Code 설치 중..."

if command -v claude &>/dev/null; then
  CLAUDE_VER=$(claude --version 2>/dev/null | head -1 || echo "unknown")
  success "Claude Code 이미 설치됨: ${CLAUDE_VER}"
else
  # Try npm global install (requires Node.js)
  if command -v npm &>/dev/null; then
    npm install -g @anthropic-ai/claude-code 2>/dev/null \
      && success "Claude Code 설치 완료" \
      || warn "Claude Code 설치 실패. 수동으로 설치하세요: npm install -g @anthropic-ai/claude-code"
  else
    warn "Node.js가 설치되어 있지 않습니다."
    warn "먼저 Node.js를 설치하세요: https://nodejs.org"
    warn "그 후: npm install -g @anthropic-ai/claude-code"
  fi
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
success "${BOLD}설치 및 설정이 완료되었습니다!${NC}"
echo ""
echo "  프로젝트 경로:"
echo "    ${PROJECT_PATH}"
echo ""
echo "  터미널 설정 (자동 적용):"
echo "    ✓ Auto Claude 모드 켜짐"
echo "    ✓ Yolo 모드 켜짐"
echo "    ✓ Continue 모드 켜짐"
echo ""
echo "  Tybre.md 를 실행하면 해당 프로젝트가 자동으로 열립니다."
echo ""
