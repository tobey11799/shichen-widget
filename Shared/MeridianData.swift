import Foundation

/// 一个时辰对应的子午流注养生信息。
struct Shichen: Identifiable {
    let id: Int          // 0...11,子时为 0
    let name: String     // 时辰名,如 "子时"
    let startHour: Int   // 起始小时(24 小时制),子时为 23
    let meridian: String // 对应经络,如 "胆经"
    let organ: String    // 所属脏腑,如 "胆"
    let good: String     // 宜
    let bad: String      // 忌

    /// 时辰时间段文字,如 "23:00 – 01:00"。
    var range: String {
        let end = (startHour + 2) % 24
        return String(format: "%02d:00 – %02d:00", startHour, end)
    }
}

enum MeridianData {
    /// 十二时辰子午流注表(按一天顺序,从子时开始)。
    static let all: [Shichen] = [
        Shichen(id: 0,  name: "子时", startHour: 23, meridian: "胆经",   organ: "胆",
                good: "上床入睡,养胆气、生阳气", bad: "熬夜、进食、情绪激动"),
        Shichen(id: 1,  name: "丑时", startHour: 1,  meridian: "肝经",   organ: "肝",
                good: "熟睡养肝血、解毒排毒",   bad: "熬夜、生气、饮酒"),
        Shichen(id: 2,  name: "寅时", startHour: 3,  meridian: "肺经",   organ: "肺",
                good: "保持深睡,肺朝百脉",     bad: "受凉、剧烈活动"),
        Shichen(id: 3,  name: "卯时", startHour: 5,  meridian: "大肠经", organ: "大肠",
                good: "起床、排便、喝温水",     bad: "赖床、憋便"),
        Shichen(id: 4,  name: "辰时", startHour: 7,  meridian: "胃经",   organ: "胃",
                good: "吃营养早餐",             bad: "不吃早餐、吃太凉"),
        Shichen(id: 5,  name: "巳时", startHour: 9,  meridian: "脾经",   organ: "脾",
                good: "专注工作、适量饮水",     bad: "久坐、思虑过度、吃甜腻"),
        Shichen(id: 6,  name: "午时", startHour: 11, meridian: "心经",   organ: "心",
                good: "午餐后小憩养心",         bad: "剧烈运动、暴饮暴食"),
        Shichen(id: 7,  name: "未时", startHour: 13, meridian: "小肠经", organ: "小肠",
                good: "午后饮水,助吸收",        bad: "午餐过晚、过饱"),
        Shichen(id: 8,  name: "申时", startHour: 15, meridian: "膀胱经", organ: "膀胱",
                good: "多喝水、学习工作",        bad: "憋尿"),
        Shichen(id: 9,  name: "酉时", startHour: 17, meridian: "肾经",   organ: "肾",
                good: "晚餐清淡、适度休息",      bad: "过劳、纵欲"),
        Shichen(id: 10, name: "戌时", startHour: 19, meridian: "心包经", organ: "心包",
                good: "散步、放松、家人相处",    bad: "大喜大怒、久视屏幕"),
        Shichen(id: 11, name: "亥时", startHour: 21, meridian: "三焦经", organ: "三焦",
                good: "静心、准备入睡",          bad: "兴奋、宵夜、剧烈运动"),
    ]

    /// 返回给定时间所处的时辰。
    static func current(at date: Date = Date(), calendar: Calendar = .current) -> Shichen {
        let hour = calendar.component(.hour, from: date)
        // 子时跨越 23:00–01:00,单独处理。
        if hour == 23 || hour == 0 { return all[0] }
        // 其余时辰:startHour 为 1,3,5...21,每个覆盖 2 小时。
        let index = ((hour - 1) / 2 + 1) % 12
        return all[index]
    }

    /// 给定时间之后,下一个时辰开始的时刻(用于 widget 刷新时间线)。
    static func nextBoundary(after date: Date = Date(), calendar: Calendar = .current) -> Date {
        let hour = calendar.component(.hour, from: date)
        // 下一个时辰边界所在的小时:奇数小时(1,3,...,23)。
        let nextOddHour = hour % 2 == 0 ? hour + 1 : hour + 2
        let base = calendar.date(bySettingHour: nextOddHour % 24,
                                 minute: 0, second: 0, of: date) ?? date
        // 若换算后的时刻不晚于当前(如跨天),加一天。
        if base <= date { return calendar.date(byAdding: .day, value: 1, to: base) ?? base }
        return base
    }

    /// 从给定时刻起,未来若干个时辰的 (起始时刻, 时辰)。
    /// 首项是当前时辰(date 本身),其后每项是各时辰边界。用于 WidgetKit 一次性预生成
    /// 足够覆盖一整天的时间线,避免依赖系统频繁回调 getTimeline。
    static func upcoming(from date: Date = Date(), calendar: Calendar = .current,
                         count: Int = 14) -> [(date: Date, shichen: Shichen)] {
        var result: [(Date, Shichen)] = [(date, current(at: date, calendar: calendar))]
        var cursor = date
        for _ in 0..<count {
            let b = nextBoundary(after: cursor, calendar: calendar)
            result.append((b, current(at: b, calendar: calendar)))
            cursor = b
        }
        return result
    }
}
