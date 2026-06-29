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
prettiest theme <flavor>       # mocha (default) · macchiato · frappe · latte
prettiest doctor               # what's installed / wired / missing
prettiest uninstall            # remove wiring + configs (keeps the tools)
```

## How it works

- **Aliases (shadowing):** `prettiest.sh` aliases `ls`/`ll`→eza, `cat`→bat, `grep`→rg, `du`→dust, `df`→duf.
  `cd`/`ps`/`top` are left native; zoxide adds `z`/`zi` alongside `cd`.
  Opt out per-shell with `export PRETTIEST_NO_ALIASES=1` before it's sourced.
- **One source line** is added to `~/.zshrc`/`~/.bashrc`; it sources `~/.config/prettiest/prettiest.sh`,
  which sets the theme env, aliases, and inits starship/zoxide/fzf for your shell.
- **Themes** are fetched from the upstream Catppuccin repos (bat, btop, delta) at install time;
  starship palettes ship inline in `config/starship.toml`. `prettiest theme` flips the active flavor everywhere.
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
    starship.toml      # Catppuccin prompt (4 palettes embedded)
    bat/config         # bat defaults
    delta/             # active + fetched Catppuccin gitconfig (created on install)
```

## Notes & limits

- macOS-first (Homebrew). Linux is best-effort; on Debian, `bat`→`batcat` and `fd`→`fdfind` are aliased back automatically.
- Theme switching covers the four **Catppuccin** flavors (coherent everywhere). Other palettes aren't bundled.
- Not affiliated with Prettier or Catppuccin — just standing on their shoulders.
