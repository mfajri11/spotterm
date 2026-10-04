import Foundation

enum ShellEnvironment {
    private static let fallbackShell = "/bin/zsh"
    private static let fallbackDirectory = "/bin/sh"

    static func resolveShell(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        fileManager: FileManager = .default
    ) -> String {
        if let preferred = environment["SHELL"],
           !preferred.isEmpty,
           fileManager.isExecutableFile(atPath: preferred) {
            return preferred
        }

        if fileManager.isExecutableFile(atPath: fallbackShell) {
            return fallbackShell
        }

        return fallbackDirectory
    }

    static func buildEnvironment(
        systemEnvironment: [String: String] = ProcessInfo.processInfo.environment
    ) -> [String] {
        var merged = systemEnvironment

        if merged["TERM"] == nil || merged["TERM"]?.isEmpty == true {
            merged["TERM"] = "xterm-256color"
        }
        if merged["COLORTERM"] == nil || merged["COLORTERM"]?.isEmpty == true {
            merged["COLORTERM"] = "truecolor"
        }
        if merged["LANG"] == nil || merged["LANG"]?.isEmpty == true {
            merged["LANG"] = "en_US.UTF-8"
        }

        return merged.map { "\($0.key)=\($0.value)" }.sorted()
    }

    static func defaultWorkingDirectory(fileManager: FileManager = .default) -> String {
        fileManager.homeDirectoryForCurrentUser.path
    }
}
