<div align="center">

<img src="https://raw.githubusercontent.com/Hyunki6040/tybre-md-releases/main/assets/icon.png" width="96" height="96" alt="Tybre.md" />

# Tybre.md

### 쓰고, 실행하고, 확인하고 — 창 하나로 끝.

마크다운 에디터 · **진짜 터미널** · **브라우저** 를 하나의 네이티브 창에.
더 이상 Alt-Tab으로 흐름 끊기지 마세요. 딱 **5MB**.

[![최신 릴리즈](https://img.shields.io/github/v/release/Hyunki6040/tybre-md-releases?label=download&color=4A7FBF)](https://github.com/Hyunki6040/tybre-md-releases/releases/latest)
[![지원 플랫폼](https://img.shields.io/badge/macOS%20·%20Windows-지원-111?logo=apple&logoColor=white)](#설치)
![용량](https://img.shields.io/badge/앱%20용량-~5MB-22c55e)
![License](https://img.shields.io/badge/license-proprietary%20·%20non--commercial-555)

[English](./README.md) · **한국어** · [Español](./README.es.md) · [中文](./README.zh.md)

<br />

<img src="https://raw.githubusercontent.com/Hyunki6040/tybre-md-releases/main/assets/hero-ko.jpeg" alt="Tybre.md — 쓰고, 실행하고, 확인하는 단 하나의 창" width="820" />

<br />

<img src="https://raw.githubusercontent.com/Hyunki6040/tybre-md-releases/main/assets/editor-demo.gif" alt="위지윅 문법 표시 편집" width="410" /> <img src="https://raw.githubusercontent.com/Hyunki6040/tybre-md-releases/main/assets/graph-demo.gif" alt="관성 스크롤 지식 그래프" width="410" />

</div>

---

## 🤔 문제

Claude Code로 바이브 코딩을 하면, 작업이 여러 창에 흩어집니다:

- 마크다운 에디터는 이 창, 터미널은 저 창, 브라우저는 또 다른 창.
- **Alt-Tab, Alt-Tab, Alt-Tab** — 전환할 때마다 집중력이 새어 나갑니다.
- 프로젝트마다 새 창(또는 앱)을 띄우고, `cd`로 디렉터리를 찾아 헤맵니다.

Tybre.md는 이 모든 걸 **자리와 상태를 전부 기억하는 단 하나의 창**으로 합칩니다.

| 😖 이전 | 🎯 Tybre 사용 시 |
|---------|------------------|
| 프로젝트마다 새 창·앱을 띄우고 alt-tab으로 헤매기 | 한 창에서 `Ctrl+1~9`로 프로젝트 즉시 전환 |
| 프로젝트별로 터미널 창을 따로 열어 관리하기 | 내장 터미널이 **프로젝트마다** 세션을 기억 — 창은 하나 |
| 매번 `cd`로 프로젝트 디렉터리를 찾아 들어가기 | 전환하면 그 프로젝트의 위치·탭·터미널이 **그대로 복원** |

---

## ✨ 기능

| | |
|---|---|
| 📝 **위지윅 마크다운** | Milkdown 기반 문법 표시 에디터. 깔끔한 글을 보다가 커서를 올리면 마크업이 나타납니다. Shiki 코드 하이라이팅 내장. |
| 🖥️ **내장 터미널** | xterm.js 풀 PTY 터미널. Claude Code, git, npm을 창을 벗어나지 않고 실행. 프로젝트당 다중 세션. |
| 🌐 **인라인 브라우저** | URL 바가 있는 내장 브라우저로 결과를 즉시 미리보기. 더 이상 크롬으로 Alt-Tab 하지 않아도 됩니다. |
| ⚡ **즉시 프로젝트 전환** | `Ctrl+1~9`로 프로젝트 사이를 점프. 각 프로젝트가 자기 탭·터미널·워크스페이스 상태를 기억합니다. |
| 💾 **세션 복원** | 앱을 닫았다 열어도 모든 프로젝트·탭·터미널 상태가 그대로. 떠난 자리에서 그대로 시작. |
| 🪶 **네이티브 · 5MB** | Tauri 네이티브 빌드. Electron 덩치 없이 즉각 반응. macOS(Apple Silicon·Intel)·Windows 지원. |

---

## 📸 스크린샷

<div align="center">
<img src="https://raw.githubusercontent.com/Hyunki6040/tybre-md-releases/main/assets/screenshot.png" alt="Tybre.md 에디터 — 문법 표시 위지윅" width="760" />
<br />
<sub>커서를 올리면 <code>##</code> 문법이 드러나는 위지윅, 그리고 실시간 단어·글자 수.</sub>
</div>

---

## ⚖️ Tybre vs. 다른 도구

|  | **Tybre.md** | Typora | Obsidian | VS Code | Notion |
|--|:--:|:--:|:--:|:--:|:--:|
| 위지윅 마크다운 | ✅ | ✅ | 🟡 | ❌ | ✅ |
| 내장 터미널 | ✅ | ❌ | 🟡 | ✅ | ❌ |
| 내장 브라우저 미리보기 | ✅ | ❌ | 🟡 | 🟡 | ❌ |
| Claude Code 네이티브 | ✅ | ❌ | ❌ | ❌ | ❌ |
| 즉시 프로젝트 전환 | ✅ | ❌ | 🟡 | 🟡 | ❌ |
| 네이티브 앱 (10MB 미만) | ✅ | ✅ | ❌ | ❌ | ❌ |
| 1회 결제 | ✅ | ✅ | 🟡 | ✅ | ❌ |

<sub>✅ 지원 · 🟡 부분 지원 · ❌ 미지원</sub>

---

## 📦 설치

### macOS

**터미널**을 열고 아래 한 줄을 붙여넣으세요:

```bash
curl -fsSL https://raw.githubusercontent.com/Hyunki6040/tybre-md-releases/main/install.sh | bash
```

**Apple Silicon(M1/M2/M3)**·**Intel** 지원. 설치 후 Spotlight(⌘ Space)에서 "Tybre"로 검색하면 실행됩니다.

### Windows

**PowerShell:**

```powershell
irm https://raw.githubusercontent.com/Hyunki6040/tybre-md-releases/main/install.ps1 | iex
```

**명령 프롬프트(CMD):**

```batch
curl -fsSL https://raw.githubusercontent.com/Hyunki6040/tybre-md-releases/main/install.cmd -o install.cmd && install.cmd && del install.cmd
```

x64 빌드를 `%LOCALAPPDATA%\Programs`에 설치합니다(관리자 권한 불필요). 설치 후 시작 메뉴에서 "Tybre"로 검색하세요.

> 파일로 받고 싶다면 [**최신 릴리즈**](https://github.com/Hyunki6040/tybre-md-releases/releases/latest)에서 설치 파일을 내려받으세요.

---

## 🔄 자동 업데이트

업데이트는 **앱 안에서 자동으로** 제공됩니다. 새 버전이 나오면 배너가 뜨고, **"Update now"**를 누르면 Tybre가 스스로 업데이트 후 재시작합니다. 다시 다운로드·재설치할 필요가 없습니다.

---

## ⬇️ 다운로드

모든 버전과 변경 내역은 [**Releases**](https://github.com/Hyunki6040/tybre-md-releases/releases) 페이지를 참고하세요.

| 플랫폼 | 파일 |
|--------|------|
| macOS (Apple Silicon) | `Tybre.md_*_aarch64.dmg` |
| macOS (Intel) | `Tybre.md_*_x64.dmg` |
| Windows (x64) | `Tybre.md_*_x64-setup.exe` |

---

## ℹ️ 소개

Tybre.md는 **Tauri v2 + React 19**로 만들었습니다. 소스 코드는 비공개 저장소에서 관리하며, 이 저장소는 공개 릴리즈 바이너리 배포와 자동 업데이트 엔드포인트 역할을 합니다.

🇰🇷 대한민국에서 **Intense Lab**이 만들었습니다. Tybre.md는 **독점 소프트웨어로 개인·비상업적 사용에 한합니다**(오픈소스 아님). 사전 서면 허가 없이 상업적 사용은 금지됩니다. [LICENSE](./LICENSE) 참고.
