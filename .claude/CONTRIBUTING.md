# 贡献指南 —— 时辰经络养生

面向后续贡献者(含 AI agent)。先读 [DESIGN.md](./DESIGN.md) 建立心智模型,再看本文的操作流程与「坑」。

## 环境要求

- **完整 Xcode**(App Store 免费),不是 Command Line Tools。
- **XcodeGen**:`brew install xcodegen`。工程文件由 `project.yml` 生成,`.xcodeproj` 不入库。

## 构建 / 运行

```bash
# 生成工程(每次增删 .swift 文件后都要重跑,见下方坑#1)
cd <repo> && xcodegen generate

# 命令行只做「编译校验」(不签名),快速验证代码能过:
env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcodebuild -project ShichenWidget.xcodeproj -scheme ShichenApp \
  -configuration Debug -destination 'platform=macOS' \
  CODE_SIGNING_ALLOWED=NO build

# 真正运行 / 让 widget 生效:用 Xcode 打开,选 ShichenApp scheme,Cmd+R
open ShichenWidget.xcodeproj
```

## 分支与提交

- **禁止直接提交 main**(pre-commit hook 拦截)。开 `feat/xxx` 分支,PR 合入。
- 提交信息用中文、说清「做了什么 + 为什么」。

## 血泪坑(务必知道)

### 坑 #1:增删源文件后必须 `xcodegen generate`
源码清单由 `project.yml` **按文件夹**收录,不是手动加进工程。新增 `.swift` 后不重新生成,Xcode 编译报 `Cannot find X in scope` / `BUILD FAILED`。重新生成后,若 Xcode 已打开,选 **Revert**(采用磁盘版)或重开工程。

### 坑 #2:widget 搜不到 = 签名没带 Team
WidgetKit 组件**只有用带 Team 的真实签名才会被系统注册**。命令行 ad-hoc 包 / 无 Team 签名,`pluginkit` 拒绝注册,组件库里永远搜不到。
解决:Xcode → 两个 target(ShichenApp + ShichenWidgetExtension)→ Signing & Capabilities → 勾 Automatically manage signing → Team 选个人 Apple ID(免费)。跑一次后,右键桌面「编辑小组件」搜 **时辰**(显示名是中文,不是 shichen)。
更新 widget 后建议**删掉桌面旧组件重新添加**,清缓存。

### 坑 #3:Dock 自绘 NSView 必须显式 frame
`DockTileView` 不设 frame 默认零尺寸,画不出东西、显示默认深色图标。已用 `convenience init` 固定 128×128。

### 坑 #4:别用 SwiftUI WindowGroup 开面板
会在关闭后重开时崩溃。面板由 `ShichenStatusController` 管一个 `NSWindow`(`isReleasedWhenClosed = false`)。详见 DESIGN 决策 #2。

### 坑 #5:Swift 中文字符串无法从二进制 grep
`strings` / `grep -a` 都读不到 Swift 里的 CJK 字面量(存储方式特殊)。**别靠 grep 二进制判断版本**,不可靠。要验证跑的是不是新代码,直接重编重跑。

## 改动定位速查

| 想改什么 | 改哪 |
|---|---|
| 养生宜忌 / 经络文案 | `Shared/MeridianData.swift` 的 `good`/`bad` 等字段 |
| 时辰↔经络对应、时间计算 | `Shared/MeridianData.swift` 的 `all` / `current` / `nextBoundary` |
| 小组件外观 | `ShichenWidget/ShichenWidget.swift`(smallView / mediumView) |
| 菜单栏标题 / 菜单项 | `ShichenApp/ShichenStatusController.swift` |
| Dock 图标画法 | `ShichenApp/ShichenStatusController.swift` 的 `DockTileView` |
| 面板内容 / 加新 tab | `ShichenApp/PanelView.swift` |
| 工程结构 / bundle id / 部署目标 | `project.yml`(改后 `xcodegen generate`) |
