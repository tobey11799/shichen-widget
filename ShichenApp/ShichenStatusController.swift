import AppKit
import SwiftUI
import ServiceManagement
import WidgetKit

/// 菜单栏标题的详略程度。
enum TitleStyle: Int, CaseIterable {
    case short = 0   // 时辰·经络
    case medium      // 时辰·经络 宜:…
    case full        // 时辰·经络 宜:… 忌:…

    var label: String {
        switch self {
        case .short:  return "简(仅时辰·经络)"
        case .medium: return "中(带宜)"
        case .full:   return "详(带宜和忌)"
        }
    }

    func title(for s: Shichen) -> String {
        switch self {
        case .short:  return " \(s.name)·\(s.meridian)"
        case .medium: return " \(s.name)·\(s.meridian)　宜:\(s.good)"
        case .full:   return " \(s.name)·\(s.meridian)　宜:\(s.good)　忌:\(s.bad)"
        }
    }
}

/// 负责菜单栏(静态,不滚动)、Dock 图标与面板窗口的当前时辰展示。
final class ShichenStatusController: NSObject, NSWindowDelegate {
    private var statusItem: NSStatusItem!
    private let dockTileView = DockTileView()
    private var timer: Timer?
    private var panel: NSWindow?
    private var lastShownId: Int?

    private let titleStyleKey = "menuBarTitleStyle"
    private var titleStyle: TitleStyle {
        get { TitleStyle(rawValue: UserDefaults.standard.integer(forKey: titleStyleKey)) ?? .full }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: titleStyleKey) }
    }

    func start() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        NSApp.dockTile.contentView = dockTileView
        // 首次运行默认「详」。
        if UserDefaults.standard.object(forKey: titleStyleKey) == nil {
            titleStyle = .full
        }
        refresh()

        // 睡眠唤醒后补刷(合盖跨时辰时,一次性 timer 可能不触发)。
        NSWorkspace.shared.notificationCenter.addObserver(
            self, selector: #selector(refreshIfNeeded),
            name: NSWorkspace.didWakeNotification, object: nil)

        // 每 30s 轮询,仅当时辰变化才重建,避免依赖单个边界 timer。
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.refreshIfNeeded()
        }
    }

    // MARK: - 刷新

    /// 仅当当前时辰与上次显示不同才刷新(轮询/唤醒都走这里)。
    @objc private func refreshIfNeeded() {
        if MeridianData.current().id != lastShownId {
            refresh()
        }
    }

    private func refresh() {
        let s = MeridianData.current()
        lastShownId = s.id

        // 菜单栏:按配置的详略程度静态显示,不跑马灯。
        statusItem.button?.title = titleStyle.title(for: s)
        statusItem.menu = buildMenu(for: s)

        // Dock 图标自绘。
        dockTileView.shichen = s
        NSApp.dockTile.contentView = dockTileView
        NSApp.dockTile.display()

        // app 抓到时辰变化时,顺带让 widget 时间线重建,保持同步。
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - 菜单

    private func buildMenu(for s: Shichen) -> NSMenu {
        let menu = NSMenu()

        let header = NSMenuItem(title: "\(s.name)  \(s.range)", action: nil, keyEquivalent: "")
        header.isEnabled = false
        menu.addItem(header)
        menu.addItem(info("经络:\(s.meridian)　脏腑:\(s.organ)"))
        menu.addItem(.separator())
        menu.addItem(info("宜: \(s.good)"))
        menu.addItem(info("忌: \(s.bad)"))
        menu.addItem(.separator())

        let open = NSMenuItem(title: "打开面板", action: #selector(openPanel), keyEquivalent: "")
        open.target = self
        menu.addItem(open)

        // 菜单栏显示详略,可配置。
        let styleItem = NSMenuItem(title: "菜单栏显示", action: nil, keyEquivalent: "")
        let styleMenu = NSMenu()
        for style in TitleStyle.allCases {
            let item = NSMenuItem(title: style.label,
                                  action: #selector(selectTitleStyle(_:)), keyEquivalent: "")
            item.target = self
            item.tag = style.rawValue
            item.state = (style == titleStyle) ? .on : .off
            styleMenu.addItem(item)
        }
        styleItem.submenu = styleMenu
        menu.addItem(styleItem)

        let login = NSMenuItem(title: launchAtLoginEnabled ? "取消开机启动" : "开机时启动",
                               action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        login.target = self
        login.state = launchAtLoginEnabled ? .on : .off
        menu.addItem(login)

        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "退出",
                                action: #selector(NSApplication.terminate(_:)),
                                keyEquivalent: "q"))
        return menu
    }

    private func info(_ title: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.isEnabled = false
        return item
    }

    // MARK: - 面板窗口(AppKit 自管,避免 SwiftUI WindowGroup 重开崩溃)

    @objc func openPanel() {
        NSApp.activate(ignoringOtherApps: true)

        if let panel = panel {
            panel.makeKeyAndOrderFront(nil)
            return
        }

        let hosting = NSHostingController(rootView: ContentView())
        let window = NSWindow(contentViewController: hosting)
        window.title = "时辰经络养生"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.setContentSize(NSSize(width: 600, height: 680))
        window.isReleasedWhenClosed = false   // 关键:关闭后不释放,可重开
        window.delegate = self
        window.center()
        window.makeKeyAndOrderFront(nil)
        panel = window
    }

    func windowWillClose(_ notification: Notification) {
        // 窗口关闭即丢弃引用,下次重新创建一个干净的。
        if (notification.object as? NSWindow) === panel {
            panel = nil
        }
    }

    // MARK: - 开机启动

    private var launchAtLoginEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    @objc private func selectTitleStyle(_ sender: NSMenuItem) {
        guard let style = TitleStyle(rawValue: sender.tag) else { return }
        titleStyle = style
        refresh()   // 立即套用新标题并重建菜单(勾选跟着变)。
    }

    @objc private func toggleLaunchAtLogin() {
        do {
            if launchAtLoginEnabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            let alert = NSAlert()
            alert.messageText = "设置开机启动失败"
            alert.informativeText = error.localizedDescription
            alert.runModal()
        }
        // 立即重建菜单,让开关文字/勾选状态反映最新结果。
        statusItem.menu = buildMenu(for: MeridianData.current())
    }
}

/// Dock 图标绘制:大字时辰 + 小字经络。
final class DockTileView: NSView {
    var shichen: Shichen = MeridianData.current() { didSet { needsDisplay = true } }

    convenience init() {
        self.init(frame: NSRect(x: 0, y: 0, width: 128, height: 128))
    }

    override func draw(_ dirtyRect: NSRect) {
        let r = bounds

        // 米色圆角底。
        let inset = r.width * 0.06
        let radius = r.width * 0.18
        let bg = NSBezierPath(roundedRect: r.insetBy(dx: inset, dy: inset),
                              xRadius: radius, yRadius: radius)
        NSColor(calibratedRed: 0.95, green: 0.93, blue: 0.87, alpha: 1).setFill()
        bg.fill()

        // 时辰单字(如「巳」)。
        drawCentered(String(shichen.name.prefix(1)),
                     yFraction: 0.40,
                     font: .systemFont(ofSize: r.height * 0.42, weight: .bold),
                     color: NSColor(calibratedRed: 0.18, green: 0.11, blue: 0.05, alpha: 1),
                     in: r)

        // 经络(如「脾经」)。
        drawCentered(shichen.meridian,
                     yFraction: 0.13,
                     font: .systemFont(ofSize: r.height * 0.16, weight: .semibold),
                     color: NSColor(calibratedRed: 0.55, green: 0.16, blue: 0.15, alpha: 1),
                     in: r)
    }

    private func drawCentered(_ text: String, yFraction: CGFloat,
                              font: NSFont, color: NSColor, in rect: NSRect) {
        let attr = NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
        let size = attr.size()
        attr.draw(at: NSPoint(x: rect.midX - size.width / 2, y: rect.height * yFraction))
    }
}
