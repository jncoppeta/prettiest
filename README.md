# prettiest

> One self-contained binary that makes any terminal pretty — **fully offline**. Carry it to a machine, run `prettiest install`, and it unpacks a modern CLI toolset, a Starship prompt, coordinated Catppuccin themes, and a Nerd Font — no network, no package manager.

Built for **reusable, disconnected environments**: install WezTerm once per machine, drop the `prettiest` binary, run it. Everything it needs is embedded inside the binary.

```
$ prettiest install
```

## What's inside the binary

- **Tools:** eza, bat, fd, ripgrep, dust, duf, procs, fzf, zoxide, starship, git-delta (+ btop on Linux)
- **Configs:** plain full-path Starship prompt, `prettiest.sh` shell integration (aliases + init)
- **Themes:** Catppuccin (bat/delta/btop) — other colorways use the tools' built-ins
- **Font:** MesloLGS Nerd Font (icons/glyphs)
- **Optional** portable `wezterm.lua` that loads the bundled font without a system install

On `install` it unpacks to `~/.prettiest/bin`, drops configs under `~/.config`, installs the font, and adds **one block** to your `~/.zshrc`/`~/.bashrc` (prepends `~/.prettiest/bin` to `PATH` + sources the integration) and a delta `[include]` to `~/.gitconfig`. All backed up, all reversible.

## Use it (on the target machine, offline)

```sh
prettiest install            # unpack + wire shell & git
prettiest install --no-wire  # unpack only — test in one shell, touch nothing
prettiest theme <colorway>   # catppuccin (default) · gruvbox · tokyonight · mono
prettiest doctor             # what's unpacked / wired
prettiest uninstall          # remove wiring + ~/.prettiest (keeps system fonts)
```

Then restart your shell. For icons, set WezTerm's font to **MesloLGS Nerd Font** — or
`ln -sf ~/.prettiest/wezterm.lua ~/.wezterm.lua` to use the bundled config (loads the font from `~/.prettiest/fonts`, no system install needed).

Aliases: `ls`/`ll`→eza, `cat`→bat, `grep`→rg, `du`→dust, `df`→duf (disable per-shell with `export PRETTIEST_NO_ALIASES=1`). zoxide adds `z`/`zi`; fzf binds `Ctrl-R`/`Ctrl-T`/`Alt-C`.

## Build it (on a connected machine, once)

Requires Go + cargo (for `cargo-binstall`). Binaries are **per-OS/arch** — build one per target:

```sh
make darwin     # → dist/prettiest-darwin-arm64
make linux      # → dist/prettiest-linux-amd64
make all        # both
```

`make <target>` runs `build/fetch.sh` (downloads prebuilt tool binaries + the Nerd Font into `assets/`) then `go build` with the matching `GOOS/GOARCH`. The fetched payload (`assets/bin/`, `assets/fonts/`) is git-ignored — only source, configs, and themes are committed. Carry the resulting `dist/` binary to the target via scp/USB.

## Layout

```
prettiest/
  main.go                 # CLI: install · theme · doctor · uninstall
  embed_darwin_arm64.go   # //go:embed assets/bin/darwin_arm64  (build-tag gated)
  embed_linux_amd64.go    # //go:embed assets/bin/linux_amd64
  assets.go               # //go:embed assets/config assets/fonts assets/wezterm
  assets/
    config/               # prettiest.sh, starship.toml, bat/, btop/, delta/  (committed)
    bin/<target>/         # tool binaries  (fetched, git-ignored)
    fonts/                # Nerd Font ttf  (fetched, git-ignored)
    wezterm/wezterm.lua   # optional portable config
  build/fetch.sh          # populate assets/ for a target
  Makefile
  skills/prettiest-config # how to reconfigure prompt / colorway / aliases
```

## Notes & limits

- One binary per OS/arch (darwin-arm64, linux-amd64 today; add triples in `Makefile`/`fetch.sh`).
- Size ≈ 60–75 MB (a dozen binaries + a font, embedded).
- `procs` has no linux-gnu prebuilt and isn't bundled on Linux; `btop` is Linux-only here.
- WezTerm itself is installed normally per machine — prettiest ships the *config*, not WezTerm.
- Tools, font, and themes are all redistributable (MIT/Apache/OFL).
