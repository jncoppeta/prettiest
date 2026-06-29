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

# --- active Catppuccin flavor (written by `prettiest theme`) ---
_PRETTI_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/prettiest"
_PRETTI_FLAVOR="$(cat "$_PRETTI_DIR/theme" 2>/dev/null || echo mocha)"
case "$_PRETTI_FLAVOR" in
  latte)
    export BAT_THEME="Catppuccin Latte"
    _PRETTI_FZF="--color=bg+:#ccd0da,bg:#eff1f5,spinner:#dc8a78,hl:#d20f39,fg:#4c4f69,header:#d20f39,info:#8839ef,pointer:#dc8a78,marker:#dc8a78,fg+:#4c4f69,prompt:#8839ef,hl+:#d20f39" ;;
  frappe)
    export BAT_THEME="Catppuccin Frappe"
    _PRETTI_FZF="--color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284,fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf,marker:#f2d5cf,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284" ;;
  macchiato)
    export BAT_THEME="Catppuccin Macchiato"
    _PRETTI_FZF="--color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796,fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6,marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796" ;;
  *) # mocha (default)
    export BAT_THEME="Catppuccin Mocha"
    _PRETTI_FZF="--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8,fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc,marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8" ;;
esac
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-} --height 40% --layout=reverse --border $_PRETTI_FZF"
_pretti_have "$_PRETTI_FD" && export FZF_DEFAULT_COMMAND="$_PRETTI_FD --type f --hidden --strip-cwd-prefix --exclude .git"

# --- command shadowing (the pretty replacements) ---
if [ -z "${PRETTIEST_NO_ALIASES:-}" ]; then
  if _pretti_have eza; then
    alias ls='eza --group-directories-first --icons=auto'
    alias ll='eza -lah --group-directories-first --icons=auto --git'
    alias la='eza -a  --group-directories-first --icons=auto'
    alias lt='eza --tree --level=2 --icons=auto'
  fi
  _pretti_have "$_PRETTI_BAT" && alias cat="$_PRETTI_BAT --paging=never"
  [ "$_PRETTI_FD" = fdfind ] && alias fd='fdfind'
  _pretti_have rg    && alias grep='rg'
  _pretti_have dust  && alias du='dust'
  _pretti_have duf   && alias df='duf'
  _pretti_have procs && alias ps='procs'
  _pretti_have btop  && { alias top='btop'; alias htop='btop'; }
fi

# --- prompt, smart-cd, fuzzy (interactive shells only; these need a TTY/ZLE) ---
case $- in
  *i*)
    if _pretti_have starship; then
      export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
      eval "$(starship init "$_PRETTI_SHELL")"
    fi
    # zoxide shadows cd (still behaves like cd, but learns + enables `z`/`zi`)
    _pretti_have zoxide && [ "$_PRETTI_SHELL" != sh ] && eval "$(zoxide init "$_PRETTI_SHELL" --cmd cd)"
    # fzf key bindings + completion (modern fzf >= 0.48)
    _pretti_have fzf && [ "$_PRETTI_SHELL" != sh ] && eval "$(fzf --"$_PRETTI_SHELL" 2>/dev/null)"
    ;;
esac

unset _PRETTI_FZF
