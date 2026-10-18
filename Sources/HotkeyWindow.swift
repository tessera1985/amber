import AppKit
import KeyboardShortcuts

// Small window for changing the Save Tweet hotkey.
@MainActor
final class HotkeyWindowController: NSWindowController {
    convenience init() {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 360, height: 130),
                              styleMask: [.titled, .closable], backing: .buffered, defer: false)
        window.title = "Amber Hotkey"
        window.isReleasedWhenClosed = false
        self.init(window: window)

        let label = NSTextField(labelWithString: "Save Tweet hotkey:")
        let recorder = KeyboardShortcuts.RecorderCocoa(for: .saveTweet)
        let hint = NSTextField(wrappingLabelWithString: "Click the box, then press the new keys.")
        hint.textColor = .secondaryLabelColor
        hint.font = .systemFont(ofSize: NSFont.smallSystemFontSize)
        let reset = NSButton(title: "Reset to ⌃⌥⌘S", target: self, action: #selector(resetHotkey))

        let row = NSStackView(views: [label, recorder])
        row.spacing = 8
        let stack = NSStackView(views: [row, hint, reset])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 10
        stack.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        window.contentView = stack
        window.center()
    }

    @objc private func resetHotkey() {
        KeyboardShortcuts.reset(.saveTweet)
    }
}
