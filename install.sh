#!/usr/bin/env bash
# prettiest bootstrap — make the CLI executable and run a full install.
#   git clone … && cd prettiest && ./install.sh
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
chmod +x "$ROOT/bin/prettiest"
# expose `prettiest` on PATH if ~/.local/bin exists or can be made
mkdir -p "$HOME/.local/bin"
ln -sf "$ROOT/bin/prettiest" "$HOME/.local/bin/prettiest"
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) echo "note: add ~/.local/bin to PATH to call 'prettiest' directly";; esac
exec "$ROOT/bin/prettiest" install
