package main

import "embed"

// Platform-independent payload: configs, themes, fonts, optional wezterm config.
//
//go:embed assets/config assets/fonts assets/wezterm
var dataFS embed.FS
