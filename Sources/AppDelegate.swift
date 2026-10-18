import AppKit
import KeyboardShortcuts
import ServiceManagement
import UserNotifications

extension KeyboardShortcuts.Name {
    // Default: Control + Option + Command + S. Changeable from the menu.
    static let saveTweet = Self("saveTweet", default: .init(.s, modifiers: [.control, .option, .command]))
}

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate, UNUserNotificationCenterDelegate {
    private var statusItem: NSStatusItem!
    private let saveItem = NSMenuItem(title: "Save Tweet", action: #selector(saveTweet), keyEquivalent: "")
    private let lastResultItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    private let folderItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    private let loginItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
    private var hotkeyWindow: HotkeyWindowController?
    private var saving = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        let icon = NSImage(named: "MenuIcon")
        icon?.isTemplate = true
        icon?.accessibilityDescription = "Amber"
        statusItem.button?.image = icon
        statusItem.menu = buildMenu()

        KeyboardShortcuts.onKeyUp(for: .saveTweet) { [weak self] in self?.saveTweet() }

        // Ask for notification permission up front: without it, results never show.
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    // MARK: Menu

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()
        menu.delegate = self
        saveItem.target = self
        saveItem.setShortcut(for: .saveTweet)
        menu.addItem(saveItem)
        lastResultItem.isEnabled = false
        lastResultItem.isHidden = true
        menu.addItem(lastResultItem)
        menu.addItem(.separator())
        menu.addItem(item("Open Saved Tweets Folder", #selector(openFolder)))
        menu.addItem(.separator())
        folderItem.isEnabled = false
        menu.addItem(folderItem)
        menu.addItem(item("Choose Save Folder…", #selector(chooseFolder)))
        menu.addItem(item("Change Hotkey…", #selector(changeHotkey)))
        loginItem.target = self
        menu.addItem(loginItem)
        menu.addItem(.separator())
        menu.addItem(item("Show Last Run Log", #selector(showLog)))
        menu.addItem(item("Quit Amber", #selector(NSApplication.terminate(_:)), key: "q", target: NSApp))
        return menu
    }

    private func item(_ title: String, _ action: Selector, key: String = "", target: AnyObject? = nil) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.target = target ?? self
        return item
    }

    func menuWillOpen(_ menu: NSMenu) {
        folderItem.title = "Saving to: " + Settings.saveFolder.lastPathComponent
        loginItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
    }

    // MARK: Saving

    @objc func saveTweet() {
        guard !saving else { return }
        saving = true
        DispatchQueue.global(qos: .userInitiated).async {
            let message = Saver.run()
            DispatchQueue.main.async {
                self.saving = false
                self.show(message)
            }
        }
    }

    private func show(_ message: String) {
        lastResultItem.title = "Last: " + (message.count > 70 ? String(message.prefix(70)) + "…" : message)
        lastResultItem.isHidden = false

        let content = UNMutableNotificationContent()
        content.title = "Amber"
        content.body = message
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    // Show banners even though Amber counts as the "front" app for its own notifications.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list])
    }

    // Clicking a notification opens the folder.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        DispatchQueue.main.async { self.openFolder() }
        completionHandler()
    }

    // MARK: Settings

    @objc func openFolder() {
        let folder = Settings.saveFolder
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        NSWorkspace.shared.open(folder)
    }

    @objc func chooseFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.prompt = "Save Here"
        panel.message = "Choose where Amber saves tweets."
        panel.directoryURL = Settings.saveFolder
        NSApp.activate(ignoringOtherApps: true)
        if panel.runModal() == .OK, let url = panel.url {
            Settings.saveFolder = url
        }
    }

    @objc func changeHotkey() {
        if hotkeyWindow == nil { hotkeyWindow = HotkeyWindowController() }
        NSApp.activate(ignoringOtherApps: true)
        hotkeyWindow?.showWindow(nil)
        hotkeyWindow?.window?.makeKeyAndOrderFront(nil)
    }

    @objc func toggleLaunchAtLogin() {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            let alert = NSAlert()
            alert.messageText = "Couldn't change Launch at Login"
            alert.informativeText = error.localizedDescription
                + "\n\nYou can add Amber by hand: System Settings → General → Login Items → +."
            NSApp.activate(ignoringOtherApps: true)
            alert.runModal()
        }
    }

    @objc func showLog() {
        let log = Settings.logFile
        if FileManager.default.fileExists(atPath: log.path) {
            NSWorkspace.shared.open(log)
        } else {
            show("No runs logged yet.")
        }
    }
}
