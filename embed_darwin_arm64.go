//go:build darwin && arm64

package main

import "embed"

//go:embed assets/bin/darwin_arm64
var binFS embed.FS

const binRoot = "assets/bin/darwin_arm64"
