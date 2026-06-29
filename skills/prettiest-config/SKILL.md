---
name: prettiest-config
description: Configure the prettiest terminal setup — the Starship prompt (directory path display, prompt character, modules, layout), the active colorway, the command aliases, and per-tool themes (bat, delta, btop). The colorway set matches system-hud — catppuccin, gruvbox, tokyonight, mono — and `prettiest theme <name>` recolors the prompt plus bat/delta/btop/fzf together. Use when the user wants to change how their prompt looks (e.g. shorten/lengthen the directory path, make it repo-relative, recolor a segment, move the path to its own line), add or remove a prompt module, switch colorway, or add/remove/disable a command alias. Edits the prettiest repo's source under assets/config/ (baked into the binary on build) or the live copies under ~/.config for a quick local change.
---

# prettiest — Config

How to change the look/behavior of a `prettiest` install. **Always edit the repo
source under `assets/config/`, then re-stage** so the change survives reinstall.

## When to Activate

- "shorten/lengthen the directory in my prompt", "show the full path", "make it repo-relative"
- "recolor the path / prompt", "move the path to its own line", "add/remove a prompt module"
- "switch to latte/macchiato/frappe", "change the theme"
- "stop aliasing X", "add an alias", "turn off the shadowing"

## prettiest is now a Go binary

prettiest is a single self-contained Go binary (`main.go` + `//go:embed` assets) that unpacks
everything offline. Configs are **embedded from `assets/config/`** at build time. So there are two
edit paths:

- **Quick live tweak (this machine):** edit the **live** file under `~/.config` directly, then
  re-source. Fast, no rebuild. Good for trying prompt/colorway changes.
- **Bake into the binary (ship it):** edit the **source** under `assets/config/`, then rebuild
  (`make darwin` / `make linux`). Required for the change to travel with the binary.

| What | Source (baked in) | Live (this machine) |
|---|---|---|
| Prompt | `assets/config/starship.toml` | `~/.config/starship.toml` |
| Aliases / shell init | `assets/config/prettiest.sh` | `~/.config/prettiest/prettiest.sh` |
| bat | `assets/config/bat/config` | `~/.config/bat/config` |
| delta wiring | generated | `~/.config/prettiest/delta/active.gitconfig` |
| active colorway | — | `~/.config/prettiest/theme` |

After a live edit: `source ~/.config/prettiest/prettiest.sh` (or open a new shell).
After a source edit: `make <target>` (re-embeds), then re-run `prettiest install`.

## Prompt: directory path (`[directory]` in starship.toml)

This is the path segment in the prompt. Key knobs:

| Goal | Setting |
|---|---|
| Full path always | `truncation_length = 0` |
| Current folder only | `truncation_length = 1` |
| Last N segments | `truncation_length = N` (default 3) |
| Relative to git repo root | `truncate_to_repo = true` |
| Truncation prefix | `truncation_symbol = "…/"` |
| Home as a symbol | `home_symbol = "~"` (or an icon) |
| Recolor | `style = "fg:crust bg:peach"` → change bg/fg; drop `bg:` for no pill |
| Folder icons | `[directory.substitutions]` map names→glyphs |

## Prompt: other common edits

- **Prompt character** (`[character]`): `success_symbol`/`error_symbol` (e.g. `❯`, `➜`, `λ`).
- **Move path to its own line / change order**: edit the top-level `format` string — segments
  are `$directory`, `$git_branch`, `$git_status`, `$nodejs`/`$python`/…, `$time`, `$character`.
  Insert `$line_break` to split lines; reorder/remove tokens to change layout.
- **Add a module**: add its token to `format` and a `[<module>]` block (see https://starship.rs/config).
- **Remove a module**: delete its token from `format` (and optionally `[module] disabled = true`).
- **Colors** come from the active `[palettes.<colorway>]`; `palette = "<colorway>"` selects which.
  Each palette defines the same **semantic keys** — `dir`, `git`, `accent`, `lang`, `muted`, `err`,
  `text` — so styles like `style = "bold fg:dir"` work across every colorway. Use those names, not raw hex.

## Colorway (matches system-hud)

prettiest ships **four colorways, same names as system-hud**: `catppuccin` (default), `gruvbox`,
`tokyonight`, `mono`. Don't hand-edit colors per file — use the command, which recolors the whole
stack at once (prompt + bat + delta + btop + fzf):

```sh
prettiest theme gruvbox      # or catppuccin | tokyonight | mono
```

What it touches:
- **starship** — rewrites `palette = "<colorway>"` in `starship.toml` (swaps the `[palettes.*]` in use).
- **delta** — regenerates `~/.config/prettiest/delta/active.gitconfig` (catppuccin uses the full
  feature set; others drive syntax highlighting off the matching bat theme).
- **btop** — sets `color_theme` (catppuccin → fetched theme file; gruvbox/tokyonight/mono → btop's
  bundled theme by name, best-effort).
- **bat + fzf** — `prettiest.sh` maps the colorway → `BAT_THEME` (catppuccin→`Catppuccin Mocha`,
  gruvbox→`gruvbox-dark`, tokyonight→`TwoDark`, mono→`ansi`) and `FZF_DEFAULT_OPTS` colors, applied
  on the next shell.

Adding a colorway: add a `[palettes.<name>]` block (same semantic keys) to `starship.toml`, a `case`
arm in `prettiest.sh` (BAT_THEME + fzf colors), and a `case` arm in `prettiest` (`COLORWAYS`,
btop theme). Re-stage after.

## Aliases (`assets/config/prettiest.sh`)

The shadow set is defined in the `if [ -z "${PRETTIEST_NO_ALIASES:-}" ]` block. Current defaults:
`ls`,`ll`→eza · `cat`→bat · `grep`→rg · `du`→dust · `df`→duf. (`cd`,`ps`,`top`,`fd` left native;
zoxide adds `z`/`zi`.) To add/remove an alias, edit that block, then re-stage `prettiest.sh`.
Disable all shadowing for a shell with `export PRETTIEST_NO_ALIASES=1` before it's sourced.

## Per-tool themes

bat/delta/btop pull the active Catppuccin flavor automatically via `prettiest theme`. To override
a single tool, edit its live config (`bat/config`, `active.gitconfig`, btop's conf) — but prefer the
`theme` command so everything stays coordinated.
