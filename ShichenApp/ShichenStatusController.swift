import AppKit

/// 负责菜单栏(静态,不滚动)与 Dock 图标的当前时辰展示。
final class ShichenStatusController: NSObject {
    private var statusItem: NSStatusItem!
    private let dockTileView = DockTileView()
    private var timer: Timer?

    func start() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        NSApp.dockTile.contentView = dockTileView
        refresh()
    }

    // MARK: - 刷新

    private func refresh() {
        let s = MeridianData.current()

        // 菜单栏:静态显示「时辰·经络」,不跑马灯。
        statusItem.button?.title = " \(s.name)·\(s.meridian)"
        statusItem.menu = buildMenu(for: s)

        // Dock 图标自绘。
        dockTileView.shichen = s
        NSApp.dockTile.contentView = dockTileView
        NSApp.dockTile.display()

        scheduleNext()
    }

    private func scheduleNext() {
        timer?.invalidate()
        let interval = max(1, MeridianData.nextBoundary().timeIntervalSinceNow)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.refresh()
        }
    }

    // MARK: - 菜单

    private func buildMenu(for s: Shichen) -> NSMenu {
        let menu = NSMenu()

        let header = NSMenuItem(title: "\(s.name)  \(s.range)", action: nil, keyEquivalent: "")
        header.isEnabled = false
        menu.addItem(header)
        menu.addItem(info("经络:\(s.meridian)　脏腑:\(s.organ)"))
        menu.addItem(.separator())
        menu.addItem(info("宜　\(s.good)"))
        menu.addItem(info("忌　\(s.bad)"))
        menu.addItem(.separator())

        let open = NSMenuItem(title: "打开面板", action: #selector(openPanel), keyEquivalent: "")
        open.target = self
        menu.addItem(open)
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

    @objc private func openPanel() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.windows.first(where: { $0.canBecomeMain })?.makeKeyAndOrderFront(nil)
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
