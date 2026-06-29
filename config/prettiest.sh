# prettiest — shell integration. Sourced from your ~/.zshrc / ~/.bashrc.
# Disable command shadowing for one shell:  export PRETTIEST_NO_ALIASES=1  (before sourcing)
# shellcheck shell=bash

_pretti_have() { command -v "$1" >/dev/null 2>&1; }

# --- which shell are we in? (for tool init) ---
if [ -n "${ZSH_VERSION:-}" ]; then _PRETTI_SHELL=zsh
elif [ -n "${BASH_VERSION:-}" ]; then _PRETTI_SHELL=bash
else _PRETTI_SHELL=sh; fi

# --- Debian renames bat->batcat, fd->fdfind: normalise ---
if _pretti_have batcat && ! _pretti_have bat; then _PRETTI_BAT=batcat; else _PRETTI_BAT=bat; fi
if _pretti_have fdfind && ! _pretti_have fd; then _PRETTI_FD=fdfind; else _PRETTI_FD=fd; fi

# --- active colorway (written by `prettiest theme`; matches system-hud's set) ---
_PRETTI_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/prettiest"
_PRETTI_CW="$(cat "$_PRETTI_DIR/theme" 2>/dev/null || echo catppuccin)"
case "$_PRETTI_CW" in
  gruvbox)
    export BAT_THEME="gruvbox-dark"
    _PRETTI_FZF="--color=bg+:#3c3836,bg:#282828,spinner:#fb4934,hl:#fabd2f,fg:#ebdbb2,header:#fabd2f,info:#83a598,pointer:#fb4934,marker:#fe8019,fg+:#ebdbb2,prompt:#83a598,hl+:#fabd2f" ;;
  tokyonight)
    export BAT_THEME="TwoDark"
    _PRETTI_FZF="--color=bg+:#292e42,bg:#1a1b26,spinner:#bb9af7,hl:#7aa2f7,fg:#c0caf5,header:#7aa2f7,info:#7dcfff,pointer:#bb9af7,marker:#9ece6a,fg+:#c0caf5,prompt:#7dcfff,hl+:#7aa2f7" ;;
  mono)
    export BAT_THEME="ansi"
    _PRETTI_FZF="--color=bg+:#3a3a3a,bg:#1c1c1c,spinner:#dddddd,hl:#ffffff,fg:#cccccc,header:#ffffff,info:#999999,pointer:#ffffff,marker:#ffffff,fg+:#ffffff,prompt:#999999,hl+:#ffffff" ;;
  *) # catppuccin (default)
    export BAT_THEME="Catppuccin Mocha"
    _PRETTI_FZF="--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8,fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc,marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8" ;;
esac
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-} --height 40% --layout=reverse --border $_PRETTI_FZF"
_pretti_have "$_PRETTI_FD" && export FZF_DEFAULT_COMMAND="$_PRETTI_FD --type f --hidden --strip-cwd-prefix --exclude .git"

# --- command shadowing (the pretty replacements) ---
if [ -z "${PRETTIEST_NO_ALIASES:-}" ]; then
  if _pretti_have eza; then
    alias ls='eza --group-directories-first --icons=auto'
    alias ll='eza -lah --git --group-directories-first --icons=auto'   # long+all view (≈ ls -lach)
  fi
  _pretti_have "$_PRETTI_BAT" && alias cat="$_PRETTI_BAT --paging=never"
  _pretti_have rg   && alias grep='rg'
  _pretti_have dust && alias du='dust'
  _pretti_have duf  && alias df='duf'
fi

# --- prompt, smart-cd, fuzzy (interactive shells only; these need a TTY/ZLE) ---
case $- in
  *i*)
    if _pretti_have starship; then
      export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
      eval "$(starship init "$_PRETTI_SHELL")"
    fi
    # zoxide adds `z`/`zi` (does NOT shadow cd; native cd is left alone)
    _pretti_have zoxide && [ "$_PRETTI_SHELL" != sh ] && eval "$(zoxide init "$_PRETTI_SHELL")"
    # fzf key bindings + completion (modern fzf >= 0.48)
    _pretti_have fzf && [ "$_PRETTI_SHELL" != sh ] && eval "$(fzf --"$_PRETTI_SHELL" 2>/dev/null)"
    ;;
esac

unset _PRETTI_FZF
