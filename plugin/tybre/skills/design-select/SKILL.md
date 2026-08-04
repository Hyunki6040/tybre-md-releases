---
name: tybre-design-select
description: Use this whenever the user's message contains one or more `[design:"…" sel:"…" …]` tokens — they were injected by Tybre.md's HTML preview when the user clicked elements in the rendered page ("design select"). Each token pins a concrete DOM element inside an HTML file; the user is talking ABOUT those elements (change the style, rewrite the copy, move it, explain it, duplicate it…). Resolve the selector inside the named file and act on exactly that element.
---

# Design select

The user rendered an HTML file in Tybre's preview, turned on element
selection, and clicked elements. Each click injected one token into the
prompt, in click order:

```
[design:"<project-relative-file>" sel:"<css selector>" tag:<tagname> text:"<text excerpt>"]
```

The rest of the message (before/after/between tokens) is the user's actual
request about those elements. Treat the tokens as anchors, not as content to
echo back.

## Token grammar

- `design:"…"` — file path, relative to the project root (the terminal's
  cwd is normally that root; if the file isn't there, search for the
  basename before asking).
- `sel:"…"` — CSS path that uniquely identified the element **at click
  time**, built only from `#id`, `tag`, `.class` and `:nth-of-type(n)`
  segments, rooted at `<body>` (e.g. `main > button.cta:nth-of-type(2)`).
  `:nth-of-type(n)` counts siblings of the SAME tag only.
- `tag:` — the element's tag name (redundant with the selector's last
  segment; a quick sanity check).
- `text:"…"` — the element's trimmed text content, truncated to 60 chars.
  May be absent for empty/media elements. `\"` and `\\` are escape
  sequences inside every quoted field.
- Several tokens = several elements, selected in that order. The user may
  say "첫 번째 버튼" / "the second one" referring to token order.

## Procedure

1. Read the named file.
2. Locate each element by walking the selector against the file's markup.
   Robustness order: try the full selector; if the file changed since the
   click, fall back to the last selector segment + the `text:` excerpt to
   re-anchor, and say so if you had to guess.
3. Do what the user asked — edit in place (style/attributes/copy/structure),
   or just answer, if it's a question. Keep unrelated markup untouched;
   preserve the file's indentation and quoting style.
4. When you edit, keep the element findable: don't gratuitously remove the
   `id`/classes the selector relied on (renames the user asked for are of
   course fine).
5. If a change belongs in CSS rather than inline (the file has a
   `<style>` block or the element has classes reused elsewhere), prefer the
   stylesheet edit and mention the tradeoff in one line.

## Viewer artifacts — never trust these in the file

The preview injects viewer-only nodes that DO NOT exist in the file:
a console-mirror `<script>`, the picker `<script>`, `<style id="__tybre_zoom">`,
`<style id="__tybre_pick_style">`, a `viewport` meta, `data:` URLs substituted
into `img src`/`srcset`, and `data-tybre-hover`/`data-tybre-picked`
attributes. Selectors are rooted at `<body>` precisely so these `<head>`
artifacts don't shift them — but if a selector or the user's description
mentions any `__tybre_*`/`data-tybre-*` thing, ignore it: it is the viewer,
not the document.

## Example

Prompt:

```
[design:"landing/index.html" sel:"main > button.cta:nth-of-type(2)" tag:button text:"Sign up"] 이 버튼을 좀 더 크고 둥글게, 문구는 "지금 시작하기"로
```

→ Open `landing/index.html`, find the second `<button class="cta">` inside
`<main>`, enlarge it (padding/font-size — via its `.cta` rule if that rule
isn't shared, else a new class or inline style), round its corners, and
replace the label text with `지금 시작하기`. Reply with what changed, in the
user's language. Tybre's preview re-renders on save, so the user sees the
edit immediately — no need to tell them how to refresh.
