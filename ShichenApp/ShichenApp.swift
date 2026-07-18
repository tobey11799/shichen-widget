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

struct ContentView: View {
    private let now = Date()
    private var current: Shichen { MeridianData.current(at: now) }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 6) {
                Text("时辰经络养生")
                    .font(.title2).bold()
                Text("按子午流注,当前 \(current.name) · \(current.meridian)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("在通知中心 / 桌面添加「时辰经络养生」小组件即可常驻查看")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()

            Divider()

            List(MeridianData.all) { s in
                let isNow = s.id == current.id
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading) {
                        Text(s.name).font(.headline)
                        Text(s.range).font(.caption2).foregroundStyle(.secondary)
                    }
                    .frame(width: 92, alignment: .leading)
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(s.meridian).bold()
                                .foregroundStyle(Color(red: 0.55, green: 0.16, blue: 0.15))
                            Text("· \(s.organ)").font(.subheadline).foregroundStyle(.secondary)
                        }
                        Label(s.good, systemImage: "checkmark.circle").font(.footnote)
                        Label(s.bad, systemImage: "xmark.circle")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 4)
                .listRowBackground(isNow ? Color.accentColor.opacity(0.12) : Color.clear)
            }
        }
    }
}
