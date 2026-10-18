import Foundation

enum Settings {
    private static let folderKey = "saveFolder"

    static let defaultFolder = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Mobile Documents/com~apple~CloudDocs/Saved Tweets", isDirectory: true)

    static var saveFolder: URL {
        get {
            guard let path = UserDefaults.standard.string(forKey: folderKey) else { return defaultFolder }
            return URL(fileURLWithPath: path, isDirectory: true)
        }
        set { UserDefaults.standard.set(newValue.path, forKey: folderKey) }
    }

    static let logFile = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Logs/Amber/last-run.log")
}

// Runs the bundled save-tweet script (zsh + curl + jq, all built into macOS 15+)
// and returns its last line: "Saved: …", "Already saved: …" or "Not saved: …".
enum Saver {
    static func run() -> String {
        guard let script = Bundle.main.url(forResource: "save-tweet", withExtension: nil) else {
            return "Not saved: the saver script is missing from Amber."
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = [script.path]
        var env = ProcessInfo.processInfo.environment
        env["PATH"] = "/usr/bin:/bin:/usr/sbin:/sbin"
        env["TWEET_DIR"] = Settings.saveFolder.path
        env["TWEET_SAVER_LOG"] = Settings.logFile.path
        process.environment = env

        let output = Pipe()
        process.standardOutput = output
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
        } catch {
            return "Not saved: couldn't start the saver (\(error.localizedDescription))."
        }
        let data = output.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()

        let lines = String(decoding: data, as: UTF8.self)
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        return lines.last ?? "Not saved: the saver stopped unexpectedly. See Show Last Run Log."
    }
}
