# Tybre.md — Releases

This repository contains public release builds of **Tybre.md**, a WYSIWYG Markdown editor built with Tauri v2 + React 19.

> Source code is maintained in a private repository. This repo exists solely to distribute release binaries to users without requiring a paid Apple Developer account.

---

## Install (macOS)

Open Terminal and paste:

```bash
curl -fsSL https://raw.githubusercontent.com/Hyunki6040/tybre-md-releases/main/install.sh | bash
```

Supports **Apple Silicon (M1/M2/M3)** and **Intel** Macs.

After installation, search for "Tybre" in Spotlight (⌘ Space).

---

## Install (Windows)

**PowerShell:**

```powershell
irm https://raw.githubusercontent.com/Hyunki6040/tybre-md-releases/main/install.ps1 | iex
```

**Command Prompt (CMD):**

```batch
curl -fsSL https://raw.githubusercontent.com/Hyunki6040/tybre-md-releases/main/install.cmd -o install.cmd && install.cmd && del install.cmd
```

Installs the x64 build to `%LOCALAPPDATA%\Programs` (no admin required). After installation, search for "Tybre" in the Start Menu.

---

## Auto-Update

Updates are delivered automatically inside the app. When a new version is available, a banner appears — click **"Update now"** and the app will update and restart itself.

No re-download or reinstall required.

---

## Releases

See the [Releases](../../releases) page for all available versions and changelogs.

| Platform | File |
|----------|------|
| macOS (Apple Silicon) | `Tybre.md_*_aarch64.dmg` |
| macOS (Intel) | `Tybre.md_*_x64.dmg` |
| Windows | `Tybre.md_*_x64-setup.exe` |
| Linux | `tybre-md_*_amd64.AppImage` |

---

## License

MIT — see [LICENSE](LICENSE).
