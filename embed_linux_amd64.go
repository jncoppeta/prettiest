//go:build linux && amd64

package main

import "embed"

//go:embed assets/bin/linux_amd64
var binFS embed.FS

const binRoot = "assets/bin/linux_amd64"
