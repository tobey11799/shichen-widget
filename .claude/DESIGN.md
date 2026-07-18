# 设计文档 —— 时辰经络养生

沉淀架构与关键决策,帮助后续贡献者(含 AI agent)快速建立心智模型。

## 一句话

一个 macOS 原生小工具:按中医「子午流注」把当前时辰对应的**经络 / 脏腑 / 养生宜忌**呈现在 **WidgetKit 小组件 + Dock 图标 + 菜单栏 + 面板**四处。纯本地、无网络、无后端、不收集数据。

## 模块结构

```
Shared/MeridianData.swift          唯一数据源:十二时辰 ↔ 经络/脏腑/宜/忌 + 时辰计算
ShichenApp/
  ShichenApp.swift                 @main App + AppDelegate(生命周期、Dock 重开)
  ShichenStatusController.swift    菜单栏 NSStatusItem + Dock 自绘 + 面板窗口 + 开机启动
  PanelView.swift                  面板 SwiftUI(TabView:时辰/养生知识/穴位图)
ShichenWidget/
  ShichenWidget.swift              WidgetKit:TimelineProvider + Small/Medium 视图
project.yml                        XcodeGen 工程定义(源码按文件夹收录)
docs/                              HTML 预览、方案对比(非编译产物)
```

## 关键决策与理由

### 1. 数据是一张静态表,不是算法
`MeridianData.all` 是写死的十二条记录,`current(at:)` 只做「小时→索引」映射。**子午流注对应关系是固定文化常识,不该联网也不该复杂化**。改养生文案 = 改 `good`/`bad` 字段,仅此而已。

### 2. 面板用 AppKit NSWindow,不用 SwiftUI WindowGroup
早期用 `WindowGroup` 导致「打开面板」闪退:窗口关闭后 SwiftUI 释放,再开崩溃。改为 `ShichenStatusController` 自管一个 `NSWindow`,`isReleasedWhenClosed = false`,关闭后保留引用可重开。App 的 Scene 改成 `Settings { EmptyView() }` —— **避免启动时自动弹窗**,面板完全按需由控制器打开。

配套:
- `applicationShouldTerminateAfterLastWindowClosed → false`(面板关了 App 不退,常驻菜单栏/Dock)
- `applicationShouldHandleReopen`(点 Dock 图标打开面板)

### 3. Dock 图标是自绘的(NSDockTile + NSView)
`DockTileView` 重写 `draw(_:)` 画「时辰单字 + 经络」。**必须显式给 frame(128×128)**,否则默认零尺寸不渲染(踩过的坑)。

### 4. 菜单栏标题详略可配置
`TitleStyle` 三档(简/中/详)存 `UserDefaults`,菜单里「菜单栏显示」子菜单切换。因为「宜:…忌:…」全带上会很长,占菜单栏空间,交给用户选。

### 5. 面板用 TabView 以求扩展性
`ContentView` = TabView,当前三页(时辰 / 养生知识 / 穴位图)。**加新功能 = 加一个 View + 一行 `.tabItem`**,不动其他。穴位图目前是占位。

## 已知约束

- **必须完整 Xcode 编译**;Command Line Tools 不够。
- **WidgetKit 组件只有用带 Team 的真实签名(免费个人 Apple ID 即可)才会被系统注册**。命令行 ad-hoc 签名的包,widget 永远搜不到——这是硬约束,见 CONTRIBUTING「签名」。
- 面板/知识页文案目前中文硬编码,未做 i18n。

## 未来方向(欢迎接手)

- 穴位图 tab:放十二经络主要穴位图 + 简介。
- 养生知识 tab:扩充为可检索的条目。
- 时辰临界提醒(可选通知)。
- 深浅色/字号偏好。
