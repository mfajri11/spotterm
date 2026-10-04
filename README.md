# SpotTerm

A Spotlight-style, liquid glass floating terminal for macOS. Summon from any virtual desktop or full-screen app with **⌥Space**.

---

## Features

- **Global Availability**: Spawns instantaneously on whatever Space, virtual desktop, or full-screen app you are currently using without switching desktops.
- **Native & Ultra-Lightweight**: Built with pure Swift, AppKit, and `SwiftTerm` (no Electron, no Chromium).
- **Liquid Glass Visuals**: Native `NSVisualEffectView` frosted blur with adaptive light/dark appearance and border gradient highlight.
- **Full Shell Capabilities**: Runs your default shell (`zsh`, `bash`, `fish`) with complete ANSI color support, Vim/Neovim, Tmux, and mouse reporting.
- **Multi-Monitor Aware**: Automatically centers on the display containing your mouse pointer.
- **Menu Bar Agent**: Runs discreetly as an `LSUIElement` agent with a status item menu.

---

## Requirements

- macOS 14.0+ (Sonoma / Sequoia)
- Xcode 16+ (Swift 6 toolchain)

---

## Quick Start

```bash
# Clone the repository
git clone https://github.com/your-username/spotterm.git
cd spotterm

# One-time toolchain setup (SwiftLint, swift-format)
./scripts/setup.sh

# Build and run
./scripts/run.sh
```

Summon or hide the terminal at any time using **⌥Space** (customizable in Preferences).

---

## Common Tasks

| Task | Script | Make |
| :--- | :--- | :--- |
| Format Code | `./scripts/fmt.sh` | `make fmt` |
| Strict Lint | `./scripts/lint.sh` | `make lint` |
| Run Test Suite | `./scripts/test.sh` | `make test` |
| Build `.app` | `./scripts/build.sh [debug\|release]` | `make build` / `make release` |
| Build & Launch | `./scripts/run.sh` | `make run` |
| CI Pipeline Check | `./scripts/ci.sh` | `make ci` |

`./scripts/ci.sh` runs: `tools-check -> fmt-check -> strict lint -> build -> test`.

---

## Architecture Overview

```
[ Carbon Hotkey (⌥Space) ]
             │
             ▼
[ TerminalPanel (NSPanel) ]
  ├── Level: .floating / .screenSaver (floats above full-screen apps)
  ├── CollectionBehavior: [.canJoinAllSpaces, .fullScreenAuxiliary, .transient, .ignoresCycle]
  └── VisualEffectView (Liquid Glass Frosted Backdrop)
             │
             ▼
   [ SwiftTerm: LocalProcessTerminalView ]
             │
       (/dev/ptmx)
             │
             ▼
      [ /bin/zsh -l ]
```

---

## Contributing

Read [`RULES.md`](./RULES.md) before writing code or opening a PR. It outlines Swift 6 strict concurrency rules, AppKit window lifecycle discipline, and linter constraints.
