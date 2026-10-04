import Foundation
@testable import SpotTerm
import Testing

struct ShellEnvironmentTests {
    @Test func defaultShellResolutionUsesValidExecutable() {
        let shell = ShellEnvironment.resolveShell(environment: ["SHELL": "/bin/zsh"])
        #expect(shell == "/bin/zsh")
    }

    @Test func defaultShellResolutionFallsBackWhenEmpty() {
        let shell = ShellEnvironment.resolveShell(environment: ["SHELL": ""])
        #expect(shell == "/bin/zsh" || shell == "/bin/sh")
    }

    @Test func defaultShellResolutionFallsBackWhenMissing() {
        let shell = ShellEnvironment.resolveShell(environment: [:])
        #expect(shell == "/bin/zsh" || shell == "/bin/sh")
    }

    @Test func environmentIncludesEssentialTerminalVariables() {
        let env = ShellEnvironment.buildEnvironment(systemEnvironment: ["PATH": "/usr/bin:/bin"])
        let containsTerm = env.contains("TERM=xterm-256color")
        let containsColor = env.contains("COLORTERM=truecolor")
        let containsLang = env.contains("LANG=en_US.UTF-8")
        let containsPath = env.contains("PATH=/usr/bin:/bin")

        #expect(containsTerm)
        #expect(containsColor)
        #expect(containsLang)
        #expect(containsPath)
    }

    @Test func environmentPreservesExistingTerminalVariables() {
        let customEnv = [
            "TERM": "screen-256color",
            "LANG": "fr_FR.UTF-8"
        ]
        let env = ShellEnvironment.buildEnvironment(systemEnvironment: customEnv)
        #expect(env.contains("TERM=screen-256color"))
        #expect(env.contains("LANG=fr_FR.UTF-8"))
    }

    @Test func defaultWorkingDirectoryIsNotEmpty() {
        let directory = ShellEnvironment.defaultWorkingDirectory()
        #expect(!directory.isEmpty)
    }
}
