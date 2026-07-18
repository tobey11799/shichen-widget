import SwiftUI

/// 面板主视图:用 TabView 承载多个功能页,便于以后扩展(养生知识、穴位图等)。
struct ContentView: View {
    var body: some View {
        TabView {
            ShichenTableView()
                .tabItem { Label("时辰", systemImage: "clock") }

            KnowledgeView()
                .tabItem { Label("养生知识", systemImage: "book") }

            AcupointView()
                .tabItem { Label("穴位图", systemImage: "figure.stand") }
        }
        .padding(.top, 6)
        .frame(minWidth: 560, minHeight: 640)
    }
}

// MARK: - 时辰表

struct ShichenTableView: View {
    private let now = Date()
    private var current: Shichen { MeridianData.current(at: now) }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 6) {
                Text("时辰经络养生").font(.title2).bold()
                Text("按子午流注,当前 \(current.name) · \(current.meridian)")
                    .font(.subheadline).foregroundStyle(.secondary)
            }
            .padding(.vertical, 12)

            Divider()

            List(MeridianData.all) { s in
                let isNow = s.id == current.id
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading) {
                        Text(s.name).font(.headline)
                        Text(s.range).font(.caption2).foregroundStyle(.secondary)
                    }
                    .frame(width: 96, alignment: .leading)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(s.meridian).bold()
                                .foregroundStyle(Color(red: 0.55, green: 0.16, blue: 0.15))
                            Text("· \(s.organ)").font(.subheadline).foregroundStyle(.secondary)
                        }
                        Label(s.good, systemImage: "checkmark.circle").font(.callout)
                        Label(s.bad, systemImage: "xmark.circle")
                            .font(.callout).foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 5)
                .listRowBackground(isNow ? Color.accentColor.opacity(0.12) : Color.clear)
            }
        }
    }
}

// MARK: - 养生知识(占位,可扩展)

struct KnowledgeView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("子午流注").font(.title2).bold()
                Text("""
                子午流注是中医学说:一日十二时辰与人体十二条经络一一对应。\
                每个时辰内,对应经络气血最旺、所属脏腑最活跃,\
                顺应时辰作息养生,即「按时养生」。
                """)
                .foregroundStyle(.secondary)

                Divider()

                Text("十二时辰养生要点").font(.headline)
                ForEach(MeridianData.all) { s in
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(s.name) \(s.meridian)")
                            .font(.subheadline).bold()
                            .frame(width: 110, alignment: .leading)
                        Text(s.good).font(.subheadline).foregroundStyle(.secondary)
                        Spacer(minLength: 0)
                    }
                }
            }
            .padding(20)
        }
    }
}

// MARK: - 穴位图(占位,以后放经络穴位图)

struct AcupointView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.stand")
                .font(.system(size: 56)).foregroundStyle(.secondary)
            Text("穴位图").font(.title3).bold()
            Text("经络穴位图即将上线")
                .font(.subheadline).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
