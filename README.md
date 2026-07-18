# 时辰经络养生 Widget

一个小而美的 macOS 桌面/通知中心小组件,按中医「子午流注」显示**当前时辰**对应的**经络、脏腑与养生宜忌**。

- 纯本地、无网络、无后端、不收集任何数据
- 数据即一张固定的十二时辰经络映射表(`Shared/MeridianData.swift`)
- 每逢时辰交替(奇数整点)自动刷新

## 目录结构

```
ShichenWidget/
├── project.yml              # XcodeGen 工程定义(一键生成 .xcodeproj)
├── Shared/
│   └── MeridianData.swift   # 十二时辰 → 经络/脏腑/宜忌 数据 + 时辰计算
├── ShichenApp/
│   └── ShichenApp.swift     # 宿主 App(展示全表,widget 必须依附于 App)
└── ShichenWidget/
    └── ShichenWidget.swift  # WidgetKit 小组件(Small / Medium)
```

## 构建步骤

需要 **完整 Xcode**(App Store 免费下载),命令行工具不够。

```bash
# 1. 安装 XcodeGen(用于从 project.yml 生成 Xcode 工程)
brew install xcodegen

# 2. 生成工程
cd ShichenWidget
xcodegen generate

# 3. 打开并运行
open ShichenWidget.xcodeproj
```

在 Xcode 中:
1. 选中 `ShichenApp` 与 `ShichenWidgetExtension` 两个 target,在 *Signing & Capabilities* 里选你的个人 Apple ID(免费即可)自动签名。
2. 运行 `ShichenApp` scheme 一次(把 App 装到本机)。
3. 右键桌面 / 打开通知中心 → 编辑小组件 → 添加「时辰经络养生」。

## 自定义

养生文案想改,直接编辑 `Shared/MeridianData.swift` 里每个 `Shichen` 的 `good` / `bad` 字段即可。
