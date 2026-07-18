import SwiftUI
import AppKit

@main
struct ShichenApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        // 不用 WindowGroup(会在启动时自动弹窗);面板由 AppKit 按需管理。
        Settings { EmptyView() }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let statusController = ShichenStatusController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusController.start()
    }

    // 面板关闭后不退出 App(常驻菜单栏/Dock)。
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    // 点 Dock 图标时打开面板。
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        statusController.openPanel()
        return true
    }
}
