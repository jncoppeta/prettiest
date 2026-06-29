---
name: prettiest-config
description: Configure the prettiest terminal setup — the Starship prompt (directory path display, prompt character, modules, two-line layout), the active Catppuccin flavor, the command aliases, and per-tool themes (bat, delta, btop). Use when the user wants to change how their prompt looks (e.g. shorten/lengthen the directory path, make it repo-relative, recolor a segment, move the path to its own line), add or remove a prompt module, switch Catppuccin flavor, or add/remove/disable a command alias. Edits the prettiest repo's source files under config/ then re-stages them to the live locations under ~/.config so the change takes effect on the next shell.
---

# prettiest — Config

How to change the look/behavior of a `prettiest` install. **Always edit the repo
source under `config/`, then re-stage** so the change survives reinstall.

## When to Activate

- "shorten/lengthen the directory in my prompt", "show the full path", "make it repo-relative"
- "recolor the path / prompt", "move the path to its own line", "add/remove a prompt module"
- "switch to latte/macchiato/frappe", "change the theme"
- "stop aliasing X", "add an alias", "turn off the shadowing"

## Files: source vs. live

| What | Repo source (edit here) | Live copy (re-stage to here) |
|---|---|---|
| Prompt | `config/starship.toml` | `~/.config/starship.toml` |
| Aliases / shell init | `config/prettiest.sh` | `~/.config/prettiest/prettiest.sh` |
| bat | `config/bat/config` | `$(bat --config-dir)/config` |
| delta wiring | generated | `~/.config/prettiest/delta/active.gitconfig` |
| active flavor | — | `~/.config/prettiest/theme` |

**Re-stage after editing** (pick one):
```sh
# just the file you changed, e.g. the prompt:
cp config/starship.toml ~/.config/starship.toml
cp config/prettiest.sh  ~/.config/prettiest/prettiest.sh
# …or re-run the staged install (no shell/git rewiring):
bin/prettiest install --no-wire
```
Then `source ~/.config/prettiest/prettiest.sh` (or open a new shell).

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
- **Colors** come from the active `[palettes.catppuccin_*]`; `palette = "catppuccin_<flavor>"`
  selects which. Use palette color *names* (e.g. `mauve`, `peach`, `crust`) in styles.

## Catppuccin flavor

Don't hand-edit colors per file — use the command (updates starship/bat/btop/delta/fzf together):
```sh
bin/prettiest theme mocha   # or macchiato | frappe | latte
```
It rewrites `palette =` in starship.toml, `$DEST/theme`, btop's `color_theme`, and the delta feature.

## Aliases (`config/prettiest.sh`)

The shadow set is defined in the `if [ -z "${PRETTIEST_NO_ALIASES:-}" ]` block. Current defaults:
`ls`,`ll`→eza · `cat`→bat · `grep`→rg · `du`→dust · `df`→duf. (`cd`,`ps`,`top`,`fd` left native;
zoxide adds `z`/`zi`.) To add/remove an alias, edit that block, then re-stage `prettiest.sh`.
Disable all shadowing for a shell with `export PRETTIEST_NO_ALIASES=1` before it's sourced.

## Per-tool themes

bat/delta/btop pull the active Catppuccin flavor automatically via `prettiest theme`. To override
a single tool, edit its live config (`bat/config`, `active.gitconfig`, btop's conf) — but prefer the
`theme` command so everything stays coordinated.
