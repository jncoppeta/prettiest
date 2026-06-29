# prettiest

> Make your terminal the prettiest. One command bundles a modern CLI toolset **and** drops in coordinated [Catppuccin](https://catppuccin.com)-themed configs — the part the "modern-unix" lists leave to you.

The lists tell you to install `eza`, `bat`, `ripgrep`… then leave you to theme and wire everything by hand. `prettiest` does the whole thing: installs the tools, a prompt, a Nerd Font, themed configs for every tool, and the shell glue — all matching, all reversible.

```
$ prettiest install
```

## What you get

**Tools** (your list + the glue that actually makes output pretty):

| Replaces | Tool | | Replaces | Tool |
|---|---|---|---|---|
| `ls`   | eza       | | `ps`     | procs |
| `cat`  | bat       | | `top`    | btop |
| `find` | fd        | | prompt   | **starship** |
| `grep` | ripgrep   | | fuzzy    | **fzf** |
| `du`   | dust      | | smart cd | **zoxide** |
| `df`   | duf       | | diffs    | git-delta |

Plus the **MesloLGS Nerd Font** (icons/glyphs) and **Catppuccin** themes wired into starship, bat, delta, btop, fzf — one coherent palette.

## Install

```sh
git clone https://github.com/jncoppeta/prettiest.git
cd prettiest && ./install.sh
```

- **macOS:** installs via `brew bundle` (`Brewfile`).
- **Linux:** `apt` + `cargo` (best-effort, per `packages.txt`) + starship's installer.

`install` is idempotent and backs up anything it touches (`~/.zshrc`, `~/.gitconfig`, `starship.toml`).
Then restart your shell, and set your terminal font to **MesloLGS Nerd Font**.

## Commands

```sh
prettiest install              # tools + themes + shell/git wiring
prettiest theme <colorway>     # catppuccin (default) · gruvbox · tokyonight · mono
prettiest doctor               # what's installed / wired / missing
prettiest uninstall            # remove wiring + configs (keeps the tools)
```

## How it works

- **Aliases (shadowing):** `prettiest.sh` aliases `ls`/`ll`→eza, `cat`→bat, `grep`→rg, `du`→dust, `df`→duf.
  `cd`/`ps`/`top` are left native; zoxide adds `z`/`zi` alongside `cd`.
  Opt out per-shell with `export PRETTIEST_NO_ALIASES=1` before it's sourced.
- **One source line** is added to `~/.zshrc`/`~/.bashrc`; it sources `~/.config/prettiest/prettiest.sh`,
  which sets the theme env, aliases, and inits starship/zoxide/fzf for your shell.
- **Colorways** (`catppuccin` · `gruvbox` · `tokyonight` · `mono`, matching system-hud) ship as
  inline starship palettes; `prettiest theme <name>` recolors prompt + bat + delta + btop + fzf together.
  Catppuccin theme files for bat/btop/delta are fetched from upstream at install; the other colorways
  use the tools' built-in themes.
- **git diffs** route through delta via an `[include]` added to `~/.gitconfig`.

## Layout

```
prettiest/
  bin/prettiest        # install · theme · doctor · uninstall
  Brewfile             # macOS toolset
  packages.txt         # Linux apt/cargo map
  install.sh           # bootstrap → bin/prettiest install
  config/
    prettiest.sh       # shell integration (aliases, env, init)
    starship.toml      # plain full-path prompt (4 colorway palettes embedded)
    bat/config         # bat defaults
    delta/             # active + fetched Catppuccin gitconfig (created on install)
```

## Notes & limits

- macOS-first (Homebrew). Linux is best-effort; on Debian, `bat`→`batcat` and `fd`→`fdfind` are aliased back automatically.
- Four colorways (`catppuccin`/`gruvbox`/`tokyonight`/`mono`). Prompt + bat + fzf are fully themed per
  colorway; btop/delta are best-effort for the non-catppuccin ones (tool built-in themes).
- Not affiliated with Prettier or Catppuccin — just standing on their shoulders.
