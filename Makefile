# prettiest — build self-contained, offline binaries.
# Run on a CONNECTED machine; carry the resulting dist/ binary to the target.

.PHONY: all darwin linux clean fetch-darwin fetch-linux

all: darwin linux

# macOS arm64
fetch-darwin:
	bash build/fetch.sh darwin-arm64
darwin: fetch-darwin
	GOOS=darwin GOARCH=arm64 go build -trimpath -o dist/prettiest-darwin-arm64 .
	@echo "built dist/prettiest-darwin-arm64"

# Linux x86_64
fetch-linux:
	bash build/fetch.sh linux-amd64
linux: fetch-linux
	GOOS=linux GOARCH=amd64 go build -trimpath -o dist/prettiest-linux-amd64 .
	@echo "built dist/prettiest-linux-amd64"

clean:
	rm -rf dist assets/bin assets/fonts
