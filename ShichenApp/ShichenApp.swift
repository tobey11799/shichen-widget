import SwiftUI

@main
struct ShichenApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultSize(width: 380, height: 460)
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
