# prettiest — FAQ

Installed to `~/.config/prettiest/FAQ.md` so it travels with the binary.

## Icons show as boxes (□) or are missing

The tools emit **Nerd Font** glyphs — your terminal needs a Nerd Font set.

- **WezTerm:** add the font (keep your text font, fall back to Meslo for glyphs):
  ```lua
  config.font = wezterm.font_with_fallback({ "JetBrains Mono", "MesloLGS Nerd Font", "Menlo" })
  ```
- **VS Code / Cursor / code-server terminal:** set the terminal font in settings.json:
  ```json
  "terminal.integrated.fontFamily": "MesloLGS Nerd Font"
  ```
  (`Cmd+Shift+P` → *Preferences: Open User Settings (JSON)*. It's a **setting**, not a Command-Palette
  command. Try `MesloLGL Nerd Font` / `MesloLGM Nerd Font` if the first doesn't render.)
- **Remote dev (SSH / code-server / dev container):** the terminal font is a **client-side** setting.
  Install the Nerd Font on the machine running the *UI* (your laptop), not the remote box — the
  font prettiest installs on the remote host only helps server-side GUI apps.
- **Don't want icons at all?** `export PRETTIEST_NO_ALIASES=1` keeps the real `ls`, or ask for the
  no-icons prompt variant.

## My prompt didn't change after `install`

The line that puts `~/.prettiest/bin` on `PATH` lives in your shell **rc block**, not in
`prettiest.sh`. Reload the rc (or open a new terminal):

```sh
source ~/.bashrc     # or ~/.zshrc
```

Sourcing `~/.config/prettiest/prettiest.sh` by itself won't add the tools to `PATH`, so `starship`
and friends won't be found.

## "cannot execute binary file" / `bash: //go:build ...`

`prettiest` is a **compiled binary**, not a shell script. Run it directly — don't `bash` it:

```sh
./dist/prettiest-darwin-arm64 install     # or prettiest-linux-amd64
```

## Building from a fresh clone

The prebuilt binary is git-ignored, so a clone has source only. Building needs **Go + cargo +
internet** (it fetches prebuilt tool binaries + the font):

```sh
make darwin     # → dist/prettiest-darwin-arm64
make linux      # → dist/prettiest-linux-amd64
```

Air-gapped target with no toolchain? Build on a connected machine and copy the single `dist/`
binary over — it's fully self-contained.

## Change the look / behavior

- Recolor everything: `prettiest theme catppuccin | gruvbox | tokyonight | mono`
- Disable command shadowing for a shell: `export PRETTIEST_NO_ALIASES=1`
- Reshape the prompt (path length, modules, colors): see the `prettiest-config` skill.

## macOS build is downloading a 1 GB Haskell compiler

You're on an older macOS past Homebrew's bottle window, so `brew` source-builds `eza` (→ pandoc →
GHC). prettiest's build avoids brew entirely — it uses `cargo-binstall` for prebuilt binaries. If you
hit this outside prettiest, install the tools with `cargo binstall` instead of `brew`.
