# Installing the Tybre plugin

**한국어 요약** — `/plugin marketplace add Hyunki6040/tybre-md-releases` 실행 후
`/plugin install tybre@tybre-md-releases`를 실행하세요. Tybre.md 앱을 설치하면 `tybre` 바이너리가
자동으로 PATH에 등록됩니다 (`tybre --version`으로 확인). 공식/커뮤니티 마켓플레이스
디렉토리 제출은 나중에 여유가 있을 때 고려할 추가 노출 옵션일 뿐, 지금 당장 필요하지
않습니다.

**Resumen en español** — Ejecuta `/plugin marketplace add Hyunki6040/tybre-md-releases`
y luego `/plugin install tybre@tybre-md-releases`. El binario `tybre` se registra automáticamente
en el PATH al instalar la app Tybre.md (compruébalo con `tybre --version`). Enviar el
plugin a un directorio oficial/comunitario es solo una opción de visibilidad adicional
para más adelante, no un requisito.

**中文摘要** — 运行 `/plugin marketplace add Hyunki6040/tybre-md-releases`，然后运行
`/plugin install tybre@tybre-md-releases`。安装 Tybre.md 应用后，`tybre` 命令会自动注册到 PATH
（可用 `tybre --version` 验证）。提交到官方/社区插件目录只是以后可选的额外曝光方式，
现在不是必需项。

---

## English (detailed)

The Tybre plugin lets Claude Code talk to a [Tybre.md](https://github.com/Hyunki6040/tybre-md-releases)
vault (a folder of markdown notes) through the bundled `tybre` CLI and MCP
server — open/create/search/print notes, read cross-project crosslinks, and
(with the edge skills) adjust, verify, disconnect, and reconnect them.

### Prerequisites

- The `tybre` binary must be on `PATH`. It is registered automatically when
  you install the Tybre.md desktop app (see
  [`docs/prd/30-cli.md`](../../docs/prd/30-cli.md) §4.3) — no separate CLI
  install step.
- Verify it resolves before installing the plugin:

  ```
  tybre --version
  ```

  If that fails, install/update the Tybre.md app first, then retry.

### Install (2 steps)

1. Add the marketplace — a public repo, so no authentication is needed:

   ```
   /plugin marketplace add Hyunki6040/tybre-md-releases
   ```

2. Install the plugin from it:

   ```
   /plugin install tybre@tybre-md-releases
   ```

That's it — `/tybre-help`, the `tybre` skill, the edge skills
(`edge-verify`/`edge-adjust`/`edge-disconnect`/`edge-reconnect`), the bundled
MCP server, and the activity hooks are all available immediately. See
[`README.md`](./README.md) for what each piece does and alternative
registration methods (direct `.mcp.json` entry, HTTP transport) if you'd
rather skip the plugin marketplace entirely.

### Updating

The plugin currently ships without a pinned `version` (it's under active
development) — `/plugin marketplace update` always pulls the latest
`plugin/tybre/` synced from the newest tagged app release. There is no
version pinning/rollback yet; that lands once the skill/hook/command surface
stabilizes.

### Uninstall

Use Claude Code's plugin management to remove `tybre@tybre-md-releases`, or remove the
`tybre` entry from `.mcp.json` if you registered it manually (Option B/C in
[`README.md`](./README.md)).

### Optional: official/community plugin directories

Submitting to Anthropic's official or community plugin directory
(`clau.de/plugin-directory-submission`) is a separate, optional path for
extra visibility later — it requires vendor review and isn't needed to use
the plugin today. The steps above are the complete, immediately-usable
install path.
