import WidgetKit
import SwiftUI

// MARK: - Timeline

struct ShichenEntry: TimelineEntry {
    let date: Date
    let shichen: Shichen
}

struct ShichenProvider: TimelineProvider {
    func placeholder(in context: Context) -> ShichenEntry {
        ShichenEntry(date: Date(), shichen: MeridianData.current())
    }

    func getSnapshot(in context: Context, completion: @escaping (ShichenEntry) -> Void) {
        completion(ShichenEntry(date: Date(), shichen: MeridianData.current()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ShichenEntry>) -> Void) {
        let now = Date()
        let entry = ShichenEntry(date: now, shichen: MeridianData.current(at: now))
        // 下个时辰开始时刷新。
        let refresh = MeridianData.nextBoundary(after: now)
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }
}

// MARK: - Views

struct ShichenWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: ShichenEntry

    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        default:
            mediumView
        }
    }

    private var accent: Color { Color(red: 0.55, green: 0.16, blue: 0.15) } // 朱砂

    private var smallView: some View {
        let s = entry.shichen
        return VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(s.name).font(.title2).bold()
                Spacer()
                Text(s.meridian).font(.headline).foregroundStyle(accent)
            }
            Text(s.range).font(.caption2).foregroundStyle(.secondary)
            Spacer(minLength: 2)
            Label(s.good, systemImage: "checkmark.circle")
                .font(.footnote).lineLimit(2).foregroundStyle(.primary)
            Label(s.bad, systemImage: "xmark.circle")
                .font(.footnote).lineLimit(1).foregroundStyle(.secondary)
        }
        .padding(4)
    }

    private var mediumView: some View {
        let s = entry.shichen
        return HStack(spacing: 14) {
            VStack(spacing: 2) {
                Text(s.name).font(.system(size: 40, weight: .bold))
                Text(s.range).font(.footnote).foregroundStyle(.secondary)
            }
            Divider()
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Text(s.meridian).font(.system(size: 24, weight: .bold)).foregroundStyle(accent)
                    Text("· \(s.organ)").font(.title3).foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                Label(s.good, systemImage: "checkmark.circle")
                    .font(.system(size: 17, weight: .medium)).lineLimit(2)
                Label(s.bad, systemImage: "xmark.circle")
                    .font(.system(size: 17)).foregroundStyle(.secondary).lineLimit(2)
                Spacer(minLength: 0)
            }
            .frame(maxHeight: .infinity)
            Spacer(minLength: 0)
        }
        .padding(6)
    }
}

// MARK: - Widget

struct ShichenWidget: Widget {
    let kind = "ShichenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ShichenProvider()) { entry in
            if #available(macOS 14.0, iOS 17.0, *) {
                ShichenWidgetEntryView(entry: entry)
                    .containerBackground(.background, for: .widget)
            } else {
                ShichenWidgetEntryView(entry: entry).padding()
            }
        }
        .configurationDisplayName("时辰经络养生")
        .description("按子午流注显示当前时辰对应的经络、脏腑与养生宜忌。")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct ShichenWidgetBundle: WidgetBundle {
    var body: some Widget {
        ShichenWidget()
    }
}
