// prettiest — a single self-contained binary that sets up a pretty terminal
// environment fully offline: it carries the tool binaries, configs, Catppuccin
// themes, and a Nerd Font embedded inside itself, and unpacks + wires them on run.
package main

import (
	"fmt"
	"io/fs"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"runtime"
	"strings"
	"time"
)

var colorways = []string{"catppuccin", "gruvbox", "tokyonight", "mono"}

const (
	beginMark = "# >>> prettiest >>>"
	endMark   = "# <<< prettiest <<<"
	gitBegin  = "# >>> prettiest (delta) >>>"
	gitEnd    = "# <<< prettiest (delta) <<<"
)

// ---- paths ----
func home() string            { h, _ := os.UserHomeDir(); return h }
func configHome() string      { if x := os.Getenv("XDG_CONFIG_HOME"); x != "" { return x }; return filepath.Join(home(), ".config") }
func prettiestDir() string    { return filepath.Join(home(), ".prettiest") }
func binDir() string          { return filepath.Join(prettiestDir(), "bin") }
func themeFile() string       { return filepath.Join(configHome(), "prettiest", "theme") }
func deltaActive() string     { return filepath.Join(prettiestDir(), "delta", "active.gitconfig") }
func fontInstallDir() string {
	if runtime.GOOS == "darwin" {
		return filepath.Join(home(), "Library", "Fonts")
	}
	return filepath.Join(home(), ".local", "share", "fonts")
}

// ---- logging ----
func say(s string)  { fmt.Printf("\033[38;5;183m◆\033[0m %s\n", s) }
func ok(s string)   { fmt.Printf("\033[38;5;120m✓\033[0m %s\n", s) }
func warn(s string) { fmt.Fprintf(os.Stderr, "\033[38;5;215m▲\033[0m %s\n", s) }
func die(s string)  { fmt.Fprintf(os.Stderr, "\033[38;5;210m✗\033[0m %s\n", s); os.Exit(1) }

// ---- helpers ----
func mustWrite(path string, data []byte, mode os.FileMode) {
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		die(err.Error())
	}
	if err := os.WriteFile(path, data, mode); err != nil {
		die(err.Error())
	}
}
func backup(path string) {
	if b, err := os.ReadFile(path); err == nil {
		_ = os.WriteFile(path+".bak."+time.Now().Format("20060102150405"), b, 0o644)
		say("backed up " + path)
	}
}
func data(name string) []byte {
	b, err := dataFS.ReadFile(name)
	if err != nil {
		die("missing embedded asset: " + name)
	}
	return b
}

// removeBlock strips a begin..end marker block (inclusive) from s.
func removeBlock(s, begin, end string) string {
	for {
		i := strings.Index(s, begin)
		if i < 0 {
			return s
		}
		j := strings.Index(s[i:], end)
		if j < 0 {
			return s[:i]
		}
		j = i + j + len(end)
		// also swallow a trailing newline
		if j < len(s) && s[j] == '\n' {
			j++
		}
		s = s[:i] + s[j:]
	}
}

// ---- extract ----
func extractBins() {
	entries, err := fs.ReadDir(binFS, binRoot)
	if err != nil {
		die("no embedded binaries: " + err.Error())
	}
	if err := os.MkdirAll(binDir(), 0o755); err != nil {
		die(err.Error())
	}
	n := 0
	for _, e := range entries {
		if e.IsDir() {
			continue
		}
		b, err := binFS.ReadFile(binRoot + "/" + e.Name())
		if err != nil {
			warn("read " + e.Name() + ": " + err.Error())
			continue
		}
		mustWrite(filepath.Join(binDir(), e.Name()), b, 0o755)
		n++
	}
	ok(fmt.Sprintf("extracted %d tool binaries -> %s", n, binDir()))
}

func extractConfigs() {
	cfg := configHome()
	// shell integration
	mustWrite(filepath.Join(cfg, "prettiest", "prettiest.sh"), data("assets/config/prettiest.sh"), 0o644)
	// starship
	st := filepath.Join(cfg, "starship.toml")
	backup(st)
	mustWrite(st, data("assets/config/starship.toml"), 0o644)
	// bat
	mustWrite(filepath.Join(cfg, "bat", "config"), data("assets/config/bat/config"), 0o644)
	mustWrite(filepath.Join(cfg, "bat", "themes", "Catppuccin Mocha.tmTheme"), data("assets/config/bat/themes/Catppuccin Mocha.tmTheme"), 0o644)
	// btop
	mustWrite(filepath.Join(cfg, "btop", "themes", "catppuccin_mocha.theme"), data("assets/config/btop/themes/catppuccin_mocha.theme"), 0o644)
	// delta theme defs
	mustWrite(filepath.Join(prettiestDir(), "delta", "catppuccin.gitconfig"), data("assets/config/delta/catppuccin.gitconfig"), 0o644)
	// optional wezterm config
	mustWrite(filepath.Join(prettiestDir(), "wezterm.lua"), data("assets/wezterm/wezterm.lua"), 0o644)
	ok("placed configs")
	// build bat theme cache with the extracted bat
	if bat := filepath.Join(binDir(), "bat"); exists(bat) {
		cmd := exec.Command(bat, "cache", "--build")
		if cmd.Run() == nil {
			ok("bat theme cache built")
		} else {
			warn("bat cache build failed (themes may not register)")
		}
	}
}

func extractFonts() {
	entries, err := fs.ReadDir(dataFS, "assets/fonts")
	if err != nil {
		warn("no embedded fonts")
		return
	}
	dst := fontInstallDir()
	pdst := filepath.Join(prettiestDir(), "fonts")
	n := 0
	for _, e := range entries {
		if e.IsDir() {
			continue
		}
		b := data("assets/fonts/" + e.Name())
		mustWrite(filepath.Join(pdst, e.Name()), b, 0o644) // for wezterm font_dirs
		mustWrite(filepath.Join(dst, e.Name()), b, 0o644)  // system user font dir
		n++
	}
	if runtime.GOOS == "linux" {
		_ = exec.Command("fc-cache", "-f", dst).Run()
	}
	ok(fmt.Sprintf("installed %d font files (Nerd Font)", n))
}

func exists(p string) bool { _, err := os.Stat(p); return err == nil }

// ---- theme ----
func currentColorway() string {
	if b, err := os.ReadFile(themeFile()); err == nil {
		if s := strings.TrimSpace(string(b)); s != "" {
			return s
		}
	}
	return "catppuccin"
}

func writeDeltaActive(cw string) {
	var body string
	if cw == "catppuccin" {
		body = fmt.Sprintf(`# prettiest — delta wiring. Regenerated by `+"`prettiest theme`"+`.
[core]
	pager = delta
[interactive]
	diffFilter = delta --color-only
[delta]
	navigate = true
	line-numbers = true
	features = catppuccin-mocha
[include]
	path = %s
`, filepath.Join(prettiestDir(), "delta", "catppuccin.gitconfig"))
	} else {
		bt := map[string]string{"gruvbox": "gruvbox-dark", "tokyonight": "TwoDark", "mono": "ansi"}[cw]
		body = fmt.Sprintf(`# prettiest — delta wiring (%s). Regenerated by `+"`prettiest theme`"+`.
[core]
	pager = delta
[interactive]
	diffFilter = delta --color-only
[delta]
	navigate = true
	line-numbers = true
	syntax-theme = %s
`, cw, bt)
	}
	mustWrite(deltaActive(), []byte(body), 0o644)
}

func setTheme(cw string) {
	valid := false
	for _, c := range colorways {
		if c == cw {
			valid = true
		}
	}
	if !valid {
		die("colorway must be one of: " + strings.Join(colorways, " "))
	}
	mustWrite(themeFile(), []byte(cw+"\n"), 0o644)
	// starship palette
	st := filepath.Join(configHome(), "starship.toml")
	if b, err := os.ReadFile(st); err == nil {
		re := regexp.MustCompile(`(?m)^palette = .*$`)
		mustWrite(st, re.ReplaceAll(b, []byte(`palette = "`+cw+`"`)), 0o644)
	}
	// btop color_theme
	btopTheme := map[string]string{
		"catppuccin": filepath.Join(configHome(), "btop", "themes", "catppuccin_mocha.theme"),
		"gruvbox":    "gruvbox_dark", "tokyonight": "tokyo-night", "mono": "greyscale",
	}[cw]
	btopConf := filepath.Join(configHome(), "btop", "btop.conf")
	if b, err := os.ReadFile(btopConf); err == nil {
		re := regexp.MustCompile(`(?m)^color_theme = .*$`)
		mustWrite(btopConf, re.ReplaceAll(b, []byte(`color_theme = "`+btopTheme+`"`)), 0o644)
	} else {
		mustWrite(btopConf, []byte(fmt.Sprintf("color_theme = \"%s\"\ntheme_background = False\n", btopTheme)), 0o644)
	}
	writeDeltaActive(cw)
	ok("colorway set to " + cw + " (prompt + delta now; bat/fzf/btop on next shell)")
}

// ---- wiring ----
func wireShell() {
	block := strings.Join([]string{
		beginMark,
		`export PATH="$HOME/.prettiest/bin:$PATH"`,
		`[ -f "$HOME/.config/prettiest/prettiest.sh" ] && . "$HOME/.config/prettiest/prettiest.sh"`,
		endMark,
	}, "\n")
	rcs := []string{filepath.Join(home(), ".zshrc"), filepath.Join(home(), ".bashrc")}
	for _, rc := range rcs {
		if rc == filepath.Join(home(), ".bashrc") && !exists(rc) {
			continue
		}
		old, _ := os.ReadFile(rc)
		backup(rc)
		cleaned := removeBlock(string(old), beginMark, endMark)
		if cleaned != "" && !strings.HasSuffix(cleaned, "\n") {
			cleaned += "\n"
		}
		mustWrite(rc, []byte(cleaned+"\n"+block+"\n"), 0o644)
		ok("wired " + filepath.Base(rc))
	}
}

func wireGit() {
	gc := filepath.Join(home(), ".gitconfig")
	old, _ := os.ReadFile(gc)
	if strings.Contains(string(old), gitBegin) {
		say("git already wired for delta")
		return
	}
	backup(gc)
	block := fmt.Sprintf("\n%s\n[include]\n\tpath = %s\n%s\n", gitBegin, deltaActive(), gitEnd)
	mustWrite(gc, append(old, []byte(block)...), 0o644)
	ok("wired git pager -> delta")
}

// ---- commands ----
func cmdInstall(noWire bool) {
	say("unpacking prettiest (offline)…")
	extractBins()
	extractConfigs()
	extractFonts()
	if !exists(themeFile()) {
		mustWrite(themeFile(), []byte("catppuccin\n"), 0o644)
	}
	writeDeltaActive(currentColorway())
	if noWire {
		fmt.Println()
		ok("staged (no shell/git wiring). Test it in a separate shell:")
		say(`export PATH="$HOME/.prettiest/bin:$PATH" && . "$HOME/.config/prettiest/prettiest.sh"`)
	} else {
		wireShell()
		wireGit()
		fmt.Println()
		ok("installed. Restart your shell (or source ~/.config/prettiest/prettiest.sh).")
	}
	say("optional WezTerm config (loads the bundled Nerd Font): ~/.prettiest/wezterm.lua")
	say("  use it:  ln -sf ~/.prettiest/wezterm.lua ~/.wezterm.lua")
}

func cmdTheme(args []string) {
	if len(args) == 0 {
		die("usage: prettiest theme <" + strings.Join(colorways, "|") + ">")
	}
	setTheme(args[0])
}

func cmdDoctor() {
	say("binaries (" + binDir() + "):")
	if entries, err := fs.ReadDir(binFS, binRoot); err == nil {
		for _, e := range entries {
			if e.IsDir() {
				continue
			}
			if exists(filepath.Join(binDir(), e.Name())) {
				ok(e.Name())
			} else {
				warn(e.Name() + " not extracted (run: prettiest install)")
			}
		}
	}
	say("wiring:")
	checkContains(filepath.Join(home(), ".zshrc"), beginMark, ".zshrc sourced")
	checkContains(filepath.Join(home(), ".gitconfig"), gitBegin, "git delta wired")
	say("colorway: " + currentColorway())
}

func checkContains(path, needle, label string) {
	b, _ := os.ReadFile(path)
	if strings.Contains(string(b), needle) {
		ok(label)
	} else {
		warn(label + " — missing")
	}
}

func cmdUninstall() {
	say("removing prettiest wiring + files (system fonts left in place)…")
	for _, rc := range []string{filepath.Join(home(), ".zshrc"), filepath.Join(home(), ".bashrc")} {
		if b, err := os.ReadFile(rc); err == nil && strings.Contains(string(b), beginMark) {
			backup(rc)
			mustWrite(rc, []byte(removeBlock(string(b), beginMark, endMark)), 0o644)
			ok("unwired " + filepath.Base(rc))
		}
	}
	gc := filepath.Join(home(), ".gitconfig")
	if b, err := os.ReadFile(gc); err == nil && strings.Contains(string(b), gitBegin) {
		backup(gc)
		mustWrite(gc, []byte(removeBlock(string(b), gitBegin, gitEnd)), 0o644)
		ok("removed git delta wiring")
	}
	_ = os.RemoveAll(prettiestDir())
	ok("removed " + prettiestDir())
}

func cmdHelp() {
	fmt.Print(`prettiest — offline, self-contained pretty terminal.

  prettiest install [--no-wire]   unpack bundled tools+configs+font; wire shell+git
  prettiest theme <colorway>      ` + strings.Join(colorways, " | ") + `
  prettiest doctor                what's unpacked / wired
  prettiest uninstall             remove wiring + ~/.prettiest (keeps system fonts)
  prettiest help

Everything is embedded in this binary — no network required.
Disable alias shadowing for a shell:  export PRETTIEST_NO_ALIASES=1
`)
}

func main() {
	args := os.Args[1:]
	cmd := "help"
	if len(args) > 0 {
		cmd = args[0]
		args = args[1:]
	}
	switch cmd {
	case "install":
		cmdInstall(len(args) > 0 && args[0] == "--no-wire")
	case "theme":
		cmdTheme(args)
	case "doctor":
		cmdDoctor()
	case "uninstall":
		cmdUninstall()
	case "help", "-h", "--help":
		cmdHelp()
	default:
		cmdHelp()
		os.Exit(1)
	}
}
