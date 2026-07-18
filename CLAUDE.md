# CLAUDE.md

给在此仓库工作的 AI agent 的入口说明。**动手前先读这两份**:

- [`.claude/DESIGN.md`](.claude/DESIGN.md) —— 架构与关键设计决策(为什么这么写)
- [`.claude/CONTRIBUTING.md`](.claude/CONTRIBUTING.md) —— 构建/运行流程 + 血泪坑

## 30 秒速览

macOS 原生小工具:按中医「子午流注」在 **Widget / Dock 图标 / 菜单栏 / 面板**展示当前时辰对应的经络、脏腑、养生宜忌。纯本地、无网络、无后端。

- 数据唯一源:`Shared/MeridianData.swift`(一张静态表)
- 工程用 **XcodeGen**:改 `.swift` 增删后必须 `xcodegen generate`
- **widget 只有用带 Team 的签名(免费 Apple ID 即可)才注册** —— ad-hoc 搜不到
- 分支:**禁止直提 main**,走 `feat/xxx` + PR

## 最省事的编译校验

```bash
env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcodebuild -project ShichenWidget.xcodeproj -scheme ShichenApp \
  -configuration Debug -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO build
```

真正运行 / 验证 widget 需在 Xcode 里用个人 Apple ID 签名后 Cmd+R。改动定位速查表见 CONTRIBUTING。
