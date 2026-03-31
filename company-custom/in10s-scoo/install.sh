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

# ── Step 1: Homebrew ──────────────────────────────────────────────────────────
info "Homebrew 확인 중..."
if command -v brew &>/dev/null; then
  success "Homebrew 이미 설치됨: $(brew --version | head -1)"
else
  info "Homebrew 설치 중... (시간이 걸릴 수 있습니다)"
  BREW_INSTALLER=$(mktemp /tmp/brew-installer-XXXXXX.sh)
  trap 'rm -f "$BREW_INSTALLER"' EXIT
  curl -fsSL -o "$BREW_INSTALLER" "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
  NONINTERACTIVE=1 bash "$BREW_INSTALLER"
  # Add brew to PATH for Apple Silicon and Intel
  if [ -f "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    grep -q 'homebrew' "$HOME/.zprofile" 2>/dev/null || echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    grep -q 'homebrew' "$HOME/.zshrc" 2>/dev/null || echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zshrc"
  elif [ -f "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
    grep -q 'homebrew' "$HOME/.zprofile" 2>/dev/null || echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
    grep -q 'homebrew' "$HOME/.zshrc" 2>/dev/null || echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zshrc"
  fi
  success "Homebrew 설치 완료"
fi
echo ""

# ── Step 2: Node.js (LTS) + npm ──────────────────────────────────────────────
info "Node.js 확인 중..."
if command -v node &>/dev/null; then
  NODE_VER=$(node --version)
  NPM_VER=$(npm --version)
  success "Node.js 이미 설치됨: ${NODE_VER} / npm ${NPM_VER}"
else
  info "Node.js LTS 설치 중..."
  brew install node
  success "Node.js 설치 완료: $(node --version) / npm $(npm --version)"
fi
echo ""

# ── Step 3: PostgreSQL (psql) ─────────────────────────────────────────────────
info "PostgreSQL (psql) 확인 중..."
if command -v psql &>/dev/null; then
  PSQL_VER=$(psql --version)
  success "psql 이미 설치됨: ${PSQL_VER}"
else
  info "PostgreSQL 설치 중..."
  brew install postgresql@16
  # Link psql to PATH
  brew link --force postgresql@16
  # Also add to PATH in case link doesn't cover current session
  PG_BIN="$(brew --prefix postgresql@16)/bin"
  export PATH="$PG_BIN:$PATH"
  grep -q 'postgresql' "$HOME/.zprofile" 2>/dev/null || echo "export PATH=\"${PG_BIN}:\$PATH\"" >> "$HOME/.zprofile"
  grep -q 'postgresql' "$HOME/.zshrc"   2>/dev/null || echo "export PATH=\"${PG_BIN}:\$PATH\"" >> "$HOME/.zshrc"
  success "PostgreSQL 설치 완료: $(psql --version 2>/dev/null || echo 'ok')"
fi
echo ""

# ── Step 4: Install Tybre.md ──────────────────────────────────────────────────
info "Tybre.md 설치 중..."

# Download installer to temp file to avoid curl | bash stdin conflict
TYBRE_INSTALLER=$(mktemp /tmp/tybre-installer-XXXXXX.sh)
# Append to existing trap if any
trap 'rm -f "$TYBRE_INSTALLER" "$BREW_INSTALLER" 2>/dev/null' EXIT

if ! curl -fsSL -o "$TYBRE_INSTALLER" "https://raw.githubusercontent.com/Hyunki6040/tybre-md-releases/main/install.sh"; then
  error "Tybre.md 설치 파일 다운로드 실패"
fi

bash "$TYBRE_INSTALLER"
echo ""

# ── Step 5: Claude Code ───────────────────────────────────────────────────────
info "Claude Code 확인 중..."
if command -v claude &>/dev/null; then
  CLAUDE_VER=$(claude --version 2>/dev/null | head -1 || echo "unknown")
  success "Claude Code 이미 설치됨: ${CLAUDE_VER}"
else
  info "Claude Code 설치 중..."
  npm install -g @anthropic-ai/claude-code \
    && success "Claude Code 설치 완료: $(claude --version 2>/dev/null | head -1 || echo 'ok')" \
    || warn "Claude Code 설치 실패. 수동으로 설치하세요: npm install -g @anthropic-ai/claude-code"
fi
echo ""

# ── Step 6: Auto-detect Google Drive account ─────────────────────────────────
info "Google Drive 계정 감지 중..."

CLOUD_BASE="$HOME/Library/CloudStorage"
CLOUD_ROOT=""

if [ ! -d "$CLOUD_BASE" ]; then
  echo ""
  warn "Google Drive가 설치되어 있지 않습니다."
  warn "아래 링크에서 설치하세요: ${BLUE}https://support.google.com/a/users/answer/13022292?hl=ko${NC}"
  warn "설치 후 이 스크립트를 다시 실행하세요."
  echo ""
  exit 0
fi

# Collect all GoogleDrive-* directories
GD_DIRS=()
while IFS= read -r -d '' d; do
  GD_DIRS+=("$d")
done < <(find "$CLOUD_BASE" -maxdepth 1 -type d -name 'GoogleDrive-*' -print0 2>/dev/null)

if [ ${#GD_DIRS[@]} -eq 0 ]; then
  echo ""
  warn "Google Drive 계정을 찾을 수 없습니다."
  warn "Google Drive for Desktop에 로그인 후 다시 실행하세요."
  echo ""
  exit 0
elif [ ${#GD_DIRS[@]} -eq 1 ]; then
  CLOUD_ROOT="${GD_DIRS[0]}"
  USER_EMAIL=$(basename "$CLOUD_ROOT" | sed 's/^GoogleDrive-//')
  success "Google Drive 계정 감지: ${USER_EMAIL}"
else
  # Multiple accounts — show numbered list and let user pick
  echo ""
  echo -e "  ${BOLD}Google Drive 계정이 여러 개 감지되었습니다:${NC}"
  for i in "${!GD_DIRS[@]}"; do
    echo "    $((i+1)). $(basename "${GD_DIRS[$i]}" | sed 's/^GoogleDrive-//')"
  done
  printf "  선택 (1-${#GD_DIRS[@]}): "
  read -r CHOICE </dev/tty
  IDX=$((CHOICE - 1))
  if [ "$IDX" -lt 0 ] || [ "$IDX" -ge ${#GD_DIRS[@]} ]; then
    warn "잘못된 선택입니다. 설치를 종료합니다."
    exit 0
  fi
  CLOUD_ROOT="${GD_DIRS[$IDX]}"
  USER_EMAIL=$(basename "$CLOUD_ROOT" | sed 's/^GoogleDrive-//')
  success "선택된 계정: ${USER_EMAIL}"
fi

# ── Step 7: Build project path ────────────────────────────────────────────────
PROJECT_PATH="${CLOUD_ROOT}/공유 드라이브/in10s Lab/scailout-agent-scoo/scoo-harness"

if [ ! -d "$PROJECT_PATH" ]; then
  echo ""
  warn "프로젝트 디렉토리를 찾을 수 없습니다:"
  warn "  ${PROJECT_PATH}"
  warn "Google Drive 동기화가 완료되면 자동으로 열리도록 설정을 진행합니다..."
  mkdir -p "$PROJECT_PATH"
fi

# ── Step 9: Create .tybre project config ─────────────────────────────────────
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

# ── Step 10: Register project as last session ─────────────────────────────────
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

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "────────────────────────────────────────"
success "${BOLD}모든 설치 및 설정이 완료되었습니다!${NC}"
echo ""
echo "  설치된 항목:"
echo "    ✓ Homebrew"
echo "    ✓ Node.js / npm"
echo "    ✓ PostgreSQL (psql)"
echo "    ✓ Tybre.md"
echo "    ✓ Claude Code"
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

# Apply PATH changes to the current shell session
# shellcheck disable=SC1090
source "$HOME/.zprofile" 2>/dev/null || true
source "$HOME/.zshrc"   2>/dev/null || true
