<div align="center">

<img src="https://raw.githubusercontent.com/Hyunki6040/tybre-md-releases/main/assets/icon.png" width="96" height="96" alt="Tybre.md" />

# Tybre.md

### Write. Run. See. — one window. Zero context-switching.

A markdown editor, a **real terminal**, and a **browser** — fused into one native window.
Stop Alt-Tabbing your flow away. All in **5MB**.

[![Latest release](https://img.shields.io/github/v/release/Hyunki6040/tybre-md-releases?label=download&color=4A7FBF)](https://github.com/Hyunki6040/tybre-md-releases/releases/latest)
[![Platforms](https://img.shields.io/badge/macOS%20·%20Windows-supported-111?logo=apple&logoColor=white)](#install)
![Size](https://img.shields.io/badge/app%20size-~5MB-22c55e)
![License](https://img.shields.io/badge/license-proprietary%20·%20non--commercial-555)

**English** · [한국어](./README.ko.md) · [Español](./README.es.md) · [中文](./README.zh.md)

<br />

<img src="https://raw.githubusercontent.com/Hyunki6040/tybre-md-releases/main/assets/hero-en.jpeg" alt="Tybre.md — Write. Run. See. One window." width="820" />

</div>

---

## 🤔 The problem

You're vibe-coding with Claude Code. Your workflow is scattered across windows:

- A markdown editor in one window, a terminal in another, a browser in a third.
- **Alt-Tab, Alt-Tab, Alt-Tab** — your focus leaks away on every switch.
- A new window (or app) per project, and `cd`-ing around to find the right directory.

Tybre.md collapses all of that into **a single window** that remembers everything.

| 😖 Before | 🎯 With Tybre |
|-----------|---------------|
| Spawn a new window/app per project and alt-tab to find it | Switch projects instantly with `Ctrl+1–9` — in one window |
| Juggle a separate terminal window for each project | The built-in terminal keeps a session **per project** — one window |
| `cd` to hunt down the project directory every time | Switch and its location, tabs, and terminal are **restored** as you left them |

---

## ✨ Features

| | |
|---|---|
| 📝 **WYSIWYG Markdown** | Syntax-reveal editor powered by Milkdown. Read clean prose, hover to reveal the markup. Code blocks with Shiki highlighting built in. |
| 🖥️ **Built-in Terminal** | Full PTY terminal via xterm.js. Run Claude Code, git, npm — without leaving the window. Multiple sessions per project. |
| 🌐 **Inline Browser** | Preview instantly with a built-in browser pane and URL bar. No more Alt-Tab to Chrome to check your work. |
| ⚡ **Instant Project Switch** | `Ctrl+1–9` to jump between projects. Each one keeps its own tabs, terminal sessions, and workspace state. |
| 💾 **Session Restore** | Close the app, reopen it — every project, tab, and terminal is exactly where you left it. |
| 🪶 **Native · 5MB** | Tauri-native build. Instant response without the Electron bloat. macOS (Apple Silicon & Intel) and Windows. |

---

## 📸 Screenshot

<div align="center">
<img src="https://raw.githubusercontent.com/Hyunki6040/tybre-md-releases/main/assets/screenshot.png" alt="Tybre.md editor — syntax-reveal WYSIWYG" width="760" />
<br />
<sub>Syntax-reveal WYSIWYG — hover a line to expose the <code>##</code> markup, with a live word & character count.</sub>
</div>

---

## ⚖️ Tybre vs. the others

|  | **Tybre.md** | Typora | Obsidian | VS Code | Notion |
|--|:--:|:--:|:--:|:--:|:--:|
| WYSIWYG Markdown | ✅ | ✅ | 🟡 | ❌ | ✅ |
| Built-in terminal | ✅ | ❌ | 🟡 | ✅ | ❌ |
| Built-in browser preview | ✅ | ❌ | 🟡 | 🟡 | ❌ |
| Claude Code native | ✅ | ❌ | ❌ | ❌ | ❌ |
| Instant project switch | ✅ | ❌ | 🟡 | 🟡 | ❌ |
| Native app (< 10MB) | ✅ | ✅ | ❌ | ❌ | ❌ |
| One-time price | ✅ | ✅ | 🟡 | ✅ | ❌ |

<sub>✅ yes · 🟡 partial · ❌ no</sub>

---

## 📦 Install

### macOS

Open **Terminal** and paste:

```bash
curl -fsSL https://raw.githubusercontent.com/Hyunki6040/tybre-md-releases/main/install.sh | bash
```

Supports **Apple Silicon (M1/M2/M3)** and **Intel**. After installing, search for "Tybre" in Spotlight (⌘ Space).

### Windows

**PowerShell:**

```powershell
irm https://raw.githubusercontent.com/Hyunki6040/tybre-md-releases/main/install.ps1 | iex
```

**Command Prompt (CMD):**

```batch
curl -fsSL https://raw.githubusercontent.com/Hyunki6040/tybre-md-releases/main/install.cmd -o install.cmd && install.cmd && del install.cmd
```

Installs the x64 build to `%LOCALAPPDATA%\Programs` (no admin required). After installing, search for "Tybre" in the Start Menu.

> Prefer a file? Grab the installer from the [**latest release**](https://github.com/Hyunki6040/tybre-md-releases/releases/latest).

---

## 🔄 Auto-update

Updates are delivered **automatically inside the app**. When a new version is available, a banner appears — click **"Update now"** and Tybre updates and restarts itself. No re-download, no reinstall.

---

## ⬇️ Downloads

See the [**Releases**](https://github.com/Hyunki6040/tybre-md-releases/releases) page for all versions and changelogs.

| Platform | File |
|----------|------|
| macOS (Apple Silicon) | `Tybre.md_*_aarch64.dmg` |
| macOS (Intel) | `Tybre.md_*_x64.dmg` |
| Windows (x64) | `Tybre.md_*_x64-setup.exe` |

---

## ℹ️ About

Tybre.md is built with **Tauri v2 + React 19**. The source code is maintained in a private repository; this repo exists to distribute public release binaries and the auto-update endpoint.

🇰🇷 Made in Korea by **Intense Lab**. Tybre.md is **proprietary software — personal, non-commercial use only** (not open source). Commercial use is prohibited without prior written permission. See [LICENSE](./LICENSE).
