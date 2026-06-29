#!/usr/bin/env bash
# prettiest — fetch the embeddable payload for one target (run on a CONNECTED machine).
# Populates assets/bin/<target>/ with prebuilt tool binaries + assets/fonts/.
# Rust tools come via cargo-binstall (prebuilt, per --target); fzf/duf/btop via GitHub releases.
#   build/fetch.sh darwin-arm64 | linux-amd64
set -euo pipefail
target="${1:?usage: fetch.sh <darwin-arm64|linux-amd64>}"
root="$(cd "$(dirname "$0")/.." && pwd)"

case "$target" in
  darwin-arm64) triple=aarch64-apple-darwin;     dest="$root/assets/bin/darwin_arm64"; fzf=darwin_arm64; duf=darwin_arm64; btop="" ;;
  linux-amd64)  triple=x86_64-unknown-linux-gnu; dest="$root/assets/bin/linux_amd64";  fzf=linux_amd64;  duf=linux_x86_64;  btop=x86_64-linux-musl ;;
  *) echo "unknown target: $target" >&2; exit 1 ;;
esac
mkdir -p "$dest" "$root/assets/fonts"
export PATH="$HOME/.cargo/bin:$PATH"
warn(){ echo "   ! $*" >&2; }

echo "==> rust tools via cargo-binstall ($triple)"
command -v cargo-binstall >/dev/null 2>&1 || \
  curl -L --proto '=https' --tlsv1.2 -fsSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
# Prebuilt only (--disable-strategies compile): never source-build, and fetch per-tool
# so a tool lacking a prebuilt for this triple is skipped instead of aborting the run.
for crate in eza ripgrep fd-find bat git-delta du-dust procs zoxide starship; do
  cargo-binstall --no-confirm --disable-strategies compile --target "$triple" \
    --install-path "$dest" "$crate" || warn "$crate: no prebuilt for $triple — skipped"
done

gh_latest(){ curl -fsSL "https://api.github.com/repos/$1/releases/latest" | sed -n 's/.*"tag_name": *"v\{0,1\}\([^"]*\)".*/\1/p' | head -1; }

echo "==> fzf"
fv=$(gh_latest junegunn/fzf)
curl -fsSL "https://github.com/junegunn/fzf/releases/download/v${fv}/fzf-${fv}-${fzf}.tar.gz" | tar xz -C "$dest" fzf || warn "fzf fetch failed"

echo "==> duf"
dv=$(gh_latest muesli/duf)
curl -fsSL "https://github.com/muesli/duf/releases/download/v${dv}/duf_${dv}_${duf/linux_/Linux_}.tar.gz" 2>/dev/null \
  | tar xz -C "$dest" duf 2>/dev/null || echo "   (duf fetch best-effort; skip if it fails)"

if [ -n "$btop" ]; then
  # Linux-only extras that lack a binstall prebuilt for this triple.
  echo "==> procs (linux, from GitHub release)"
  pv=$(gh_latest dalance/procs)
  tmp=$(mktemp -d)
  if curl -fsSL "https://github.com/dalance/procs/releases/download/v${pv}/procs-v${pv}-x86_64-linux.zip" -o "$tmp/p.zip" \
     && unzip -joq "$tmp/p.zip" procs -d "$tmp"; then
    cp "$tmp/procs" "$dest/procs"
  else warn "procs fetch failed"; fi
  rm -rf "$tmp"

  echo "==> btop (linux, asset URL resolved from API)"
  burl=$(curl -fsSL https://api.github.com/repos/aristocratos/btop/releases/latest \
         | grep -o 'https://[^"]*btop-x86_64-unknown-linux-musl\.tar\.gz' | head -1)
  if [ -n "$burl" ]; then
    tmp=$(mktemp -d)
    if curl -fsSL "$burl" | tar xz -C "$tmp" 2>/dev/null; then
      f=$(find "$tmp" -type f -name btop -perm -u+x | head -1)
      [ -n "$f" ] && cp "$f" "$dest/btop" || warn "btop binary not found in archive"
    else warn "btop download failed"; fi
    rm -rf "$tmp"
  else warn "btop asset URL not found"; fi
fi

echo "==> Nerd Font (MesloLGS NF)"
if ! ls "$root"/assets/fonts/*.ttf >/dev/null 2>&1; then
  tmp=$(mktemp -d)
  curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip -o "$tmp/Meslo.zip"
  unzip -joq "$tmp/Meslo.zip" '*MesloLGLDZNerdFont-Regular.ttf' '*MesloLGLDZNerdFont-Bold.ttf' \
    '*MesloLGLDZNerdFont-Italic.ttf' '*MesloLGLDZNerdFont-BoldItalic.ttf' -d "$root/assets/fonts" || true
  rm -rf "$tmp"
fi

chmod +x "$dest"/* 2>/dev/null || true
echo "==> done: $(ls "$dest" | wc -l | tr -d ' ') binaries in $dest"
