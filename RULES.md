# SpotTerm Engineering Rules

**Target:** Native macOS HUD Terminal (AppKit + SwiftTerm) written in Swift 6.  
**Scope:** Single source of truth for architectural constraints, styling, process management, and workflows.

---

## 0. Philosophy

1. **Lean Over Clever**: The smallest working implementation wins. Zero speculative abstractions or generic wrappers for single-call AppKit APIs.
2. **Sub-millisecond Latency**: The terminal HUD must summon instantly. Shell processes stay warm; view hierarchies are recycled rather than reallocated on hotkey toggle.
3. **Strict Correctness**: Swift 6 Complete Concurrency (`SWIFT_STRICT_CONCURRENCY=complete`). Warnings are treated as errors.
4. **AppKit Native**: Do not wrap SwiftUI views inside `NSHostingView` for the terminal core. Host `LocalProcessTerminalView` directly in AppKit view hierarchies for optimal keyboard event dispatch.

---

## 1. Swift Language & Style Conventions

### 1.1 Naming
- `UpperCamelCase` for types, protocols, and enum cases.
- `lowerCamelCase` for variables, properties, functions, and enum associated values.
- File name must match the primary type declared within it (e.g., `TerminalPanel.swift` contains `TerminalPanel`).
- Booleans read as assertions: `isSummoned`, `hasActiveProcess`, `canBecomeKey`.

### 1.2 Access Control & Immutability
- Default to `internal`. Use `private` for file-internal implementation details.
- Mark all concrete classes `final`.
- Default to `let`. Use `var` only when value mutation is required.
- Never use force-unwraps (`!`), force-casts (`as!`), or `try!` in production code.

### 1.3 Error Handling
- Model domain errors as typed enums conforming to `Error` and `LocalizedError`.
- Never swallow process launch or PTY errors silently (`try?`) without explicit fallback or logged diagnostics.

---

## 2. macOS Window & Multi-Space Rules

### 2.1 The Floating HUD Contract
The HUD panel must behave consistently across all macOS Spaces, Mission Control, and Full-Screen modes:

1. **Window Subclass**: Must inherit from `NSPanel` and explicitly override:
   ```swift
   override var canBecomeKey: Bool { true }
   override var canBecomeMain: Bool { false }
   ```
2. **Collection Behavior**: To guarantee immediate summoning on whichever Virtual Desktop (Space) the user is on without triggering macOS desktop-switching animation:
   ```swift
   panel.collectionBehavior = [
     .canJoinAllSpaces,
     .canJoinAllApplications,
     .fullScreenAuxiliary,
     .transient,
     .ignoresCycle
   ]
   ```
3. **Window Level**: Use `.floating` for standard desktop overlays, or `.screenSaver` if the HUD must sit on top of third-party full-screen spaces (Xcode, Safari).
4. **Multi-Display Anchoring**: When summoned via hotkey, the window origin must be computed against the screen containing `NSEvent.mouseLocation`, never hardcoded to `NSScreen.main`.

---

## 3. Terminal & PTY (Process) Discipline

1. **Process Isolation**: The interactive shell process (`/bin/zsh`, `bash`, `fish`) lives in a pseudo-terminal (`pty`). Never block the `@MainActor` during process launch or pipe read/write.
2. **Window Resizing (`SIGWINCH`)**: When the panel frame changes, `LocalProcessTerminalView` must immediately propagate terminal row/column dimension changes to the child process via `ioctl(fd, TIOCSWINSZ, &ws)`.
3. **Shell Exit (`SIGHUP` / `SIGCHLD`)**: If the user runs `exit`, the app should dismiss the window or cleanly spawn a fresh shell session rather than leaving a dead view.
4. **Environment Propagation**: Spawn shells in login mode (`-l`) and forward sanitized user environment variables (`HOME`, `PATH`, `USER`, `TERM=xterm-256color`, `LANG=en_US.UTF-8`).

---

## 4. Swift 6 Concurrency Rules

1. All AppKit UI, window state mutations, and terminal views are `@MainActor`-isolated.
2. Background tasks (e.g. process monitoring, shortcut listening, configuration disk persistence) must use Swift `actor` or structured concurrency (`Task { }`).
3. Never use `@unchecked Sendable` or `nonisolated(unsafe)` to bypass compiler concurrency diagnostics.
4. Always handle `Task.isCancelled` when piping asynchronous terminal streams.

---

## 5. Tooling & Linter Thresholds

Strict compliance with SwiftLint is enforced in CI (`swiftlint --strict`):

| Metric | Warning Limit | Error Limit |
| :--- | :--- | :--- |
| `function_body_length` | 40 lines | 80 lines |
| `type_body_length` | 250 lines | 400 lines |
| `file_length` | 400 lines | 700 lines |
| `cyclomatic_complexity` | 10 | 15 |
| `function_parameter_count` | 5 | 8 |

- **Imports**: Alphabetical order only (`sorted_imports`).
- **Whitespace**: Exactly one space after commas, zero spaces before. Single trailing newline at end of file.

---

## 6. Commit Message Format

Use Conventional Commits:
```
<type>(<scope>): <short imperative description>

[optional body explaining WHY, not WHAT]
```
- **Types**: `feat`, `fix`, `refactor`, `perf`, `test`, `chore`.
- **Examples**:
  - `feat(window): center panel on cursor display when summoned`
  - `fix(terminal): forward SIGWINCH on window resize`
  - `perf(pty): recycle warm shell session on HUD dismiss`
