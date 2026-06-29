-- prettiest — portable WezTerm config (optional).
-- `prettiest install` writes this to ~/.prettiest/wezterm.lua and prints how to use it.
-- It loads the bundled Nerd Font from ~/.prettiest/fonts so glyphs work WITHOUT a
-- system font install — handy on locked-down / disconnected machines.
--
-- To use as-is:           ln -sf ~/.prettiest/wezterm.lua ~/.wezterm.lua
-- To merge into your own:  copy the font_dirs + font lines below into your config.

local wezterm = require("wezterm")
local config = wezterm.config_builder()
local home = os.getenv("HOME")

-- Load the bundled Nerd Font without installing it system-wide:
config.font_dirs = { home .. "/.prettiest/fonts" }
config.font = wezterm.font_with_fallback({ "MesloLGL Nerd Font", "MesloLGS Nerd Font", "Menlo" })
config.font_size = 14.0

-- Catppuccin Mocha to match prettiest's default colorway:
config.color_scheme = "Catppuccin Mocha"
config.window_background_opacity = 0.97
config.macos_window_background_blur = 20
config.window_decorations = "RESIZE"
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
config.scrollback_lines = 10000
config.audible_bell = "Disabled"
config.hide_tab_bar_if_only_one_tab = true

return config
