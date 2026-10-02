# LuminClash 架构规范与项目开发指南 (`gemini.md`)

> **本项目适用 AI 代理开发规范**：在处理 LuminClash 代码库的任何任务时，必须严格遵守本文档所规定的架构规范、组件规范、动效原则与设计准则。

---

## 1. 项目简介 (Project Overview)

- **项目名称**：LuminClash
- **定位**：基于 **Flutter** 与 **Mihomo (Clash.Meta)** 高性能内核打造的现代跨平台代理客户端，兼顾 Windows 桌面端 (x64) 与 Android 移动端 (ARM64 / x86_64)。
- **设计范式**：汲取 Android Root 管理器 **FolkPatch** 的紧凑人机工效布局（左侧固定紧凑状态轨 + 右侧功能大画卷），全面采用 Google **Material You (Material 3 Expressive)** 动态色彩与原生动效体系。
- **视觉基调**：**严禁任何动漫/二次元元素**；以极光渐变 (Aurora Gradient)、磨砂质感和 M3 Tonal Container 构筑极简、克制且充满未来感的科技美学。

---

## 2. 技术栈与环境规范 (Tech Stack & Environment)

| 维度 | 技术选型 | 版本要求 / 说明 |
| :--- | :--- | :--- |
| **运行时框架** | Flutter | `>= 3.47.1` (Channel stable / beta) |
| **编程语言** | Dart | `>= 3.13.1` (强类型，开启严格空安全与 lints) |
| **状态管理** | `flutter_riverpod` | `^3.4.3` (严格采用 `Notifier` / `NotifierProvider` 架构) |
| **窗口管理** | `window_manager` | `^0.5.2` (Windows 沉浸式无边框、亚克力背景与自定义拖拽顶栏) |
| **格式化与国际化** | `intl` | `^0.20.3` (时间格式化、流量数据转换) |
| **代码静态分析** | `flutter_lints` | `^6.0.0` (提交前必须保证 `flutter analyze` 0 错误 0 警告) |
| **代理内核** | Mihomo (Clash.Meta) | External Controller REST API (`127.0.0.1:9090`) + WebSocket 实时管道 |

---

## 3. 核心设计与动效开发铁律 (Critical Design & Animation Rules)

> [!IMPORTANT]
> **以下为参与本项目开发不可违背的铁律，违者将导致 UI 崩坏或严重体验退化：**

### (1) 动画规范：严格使用 Material 3 原生动效，如自写动效也应该保证性能
- **必须采用 Flutter 原生 M3 组件与原生动效**：
  - **核心启停按钮**：必须使用原生 `FloatingActionButton`，享受系统原生 Ink 水波纹、Elevation 投影层深及弹性反馈，严禁使用自定义 `CustomPainter` 或手写发光投影覆盖；
  - **出站模式切换**：必须使用原生 `SegmentedButton<OutboundMode>`，享受平滑的原生胶囊滑块及状态选中动效；
  - **进度与内存监控**：必须使用原生 `LinearProgressIndicator` / `CircularProgressIndicator`；
  - **轻量状态/图标翻转**：优先使用 `AnimatedSwitcher`（配搭 `scale` / `fade` 变换）、`AnimatedContainer`、`AnimatedOpacity`；
  - **页面级切换**：使用原生 `FadeTransition` 或 `SharedAxisTransition`。
- **严禁使用手写循环**：禁止引入易造成内存泄露、图层撕裂或发黑重影的手写 `TickerProviderStateMixin` 连续正弦/余弦脉冲循环。

### (2) 色彩规范：严格使用 Monet 语义色彩令牌 (Semantic Color Tokens)
- **严禁硬编码 Hex 色值**（禁止在业务代码中写入如 `#1E2532`、`#3355BA`、`#FFFFFF` 等直接颜色）；
- **统一使用 `Theme.of(context).colorScheme` 语义 Token**：
  - 应用主背景：`colorScheme.surface`
  - 侧边状态轨底色：`colorScheme.surfaceContainerLow`
  - 状态胶囊与微型徽章底色：`colorScheme.surfaceContainerHighest`
  - 功能卡片主底色：`colorScheme.surfaceContainer`
  - 高亮/卡片边框：`colorScheme.outlineVariant`
  - 主强调色与内容：`colorScheme.primary`、`colorScheme.onPrimary`
  - 次级强调色：`colorScheme.secondaryContainer`、`colorScheme.onSecondaryContainer`
- **动态 Monet 引擎**：
  - 由 `lib/core/theme/lumin_theme.dart` 提供动态色板，内置 6 款精心校准的种子调色板（Pixel Blue、Emerald Mint、Aurora Violet、Ocean Cyan、Coral Rose、Sunset Gold）；
  - 全局支持亮色 (Light)、暗色 (Dark) 及跟随系统 (System) 模式；
  - 切换主题种子色或暗色模式时，全局组件必须 100% 自动响应着色。

### (3) 移动端与桌面端双适配工效学 (Ergonomics & Inset Guidelines)
- **移动端状态栏统一下沉避让**：
  - 根级布局必须使用 `SafeArea(top: true, bottom: true)` 包裹整个左右双栏视图；
  - 确保左侧状态轨与右侧画卷统一避让系统状态栏、前置挖孔镜头、水滴屏与灵动岛，严禁任何组件被状态栏顶栏遮挡；
- **单手拇指触控区沉降**：
  - 左侧导航栏的功能 Tab（仪表盘、节点、设置等）必须通过 `Spacer()` 弹性下推到屏幕下半部分（拇指黄金触控区），顶栏仅承载非交互的实时网速监控胶囊；
- **排版字号与留白紧凑原则**：
  - 主 Hero 标题字号保持在 22~24sp 之间，并严格设置 `maxLines: 1` + `overflow: TextOverflow.ellipsis` 防换行折断；
  - 统计数据卡片主读数控制在 20~22sp，副标签控制在 11~13sp，保持精致与信息密集度，避免字体过大造成移动端臃肿截断。

---

## 4. 项目架构与目录索引 (Project Structure)

```
d:/LuminClash/
├── assets/
│   └── core/
│       └── mihomo.exe             # 桌面端预置 Mihomo (Clash.Meta) 二进制
├── lib/
│   ├── main.dart                  # 应用启动入口、Window 窗口无边框控制、Riverpod Scope 挂载
│   ├── core/
│   │   ├── models/                # 纯数据实体与不可变状态
│   │   │   ├── app_state.dart     # DashboardState, OutboundMode, MemoryStat 状态定义
│   │   │   ├── proxy_models.dart  # ProxyNode, ProxyGroup, ProxyGroupType 代理实体
│   │   │   ├── connection_model.dart # 实时连接跟踪实体
│   │   │   └── profile_model.dart # ProfileItem 订阅配置实体
│   │   ├── providers/             # Riverpod 3.x 状态机
│   │   │   ├── clash_provider.dart# DashboardNotifier (内核启停、实时速率、出站模式、Monet色板切换)
│   │   │   ├── proxies_provider.dart # ProxiesNotifier (节点列表、策略组切换、延迟测速)
│   │   │   ├── rules_provider.dart   # RulesNotifier (分流规则与实时连接监控)
│   │   │   └── profiles_provider.dart# ProfilesNotifier (订阅文件管理、链接导入、激活配置)
│   │   ├── services/              # 底层服务层
│   │   │   ├── core_process_service.dart # Mihomo 内核进程生命周期管控 (Win32 JobObject 防孤儿)
│   │   │   ├── clash_api_client.dart     # External Controller REST/WebSocket 客户端
│   │   │   ├── system_proxy_service.dart # Windows 系统代理托管 (WinINet 注册表与生效广播)
│   │   │   └── profile_service.dart      # 订阅解析、本地存储与配置生成
│   │   └── theme/
│   │       └── lumin_theme.dart   # Monet 6 色种子池与 M3 ThemeData 生成器
│   └── ui/
│       ├── pages/                 # 主场景与子页面
│       │   ├── main_screen.dart   # 双栏视口宿主、SafeArea 统筹、FadeTransition 页面切换
│       │   ├── dashboard_page.dart# 仪表盘主画卷 (Hero 卡片 + 双列指标 + 出站模式 + 启停 FAB)
│       │   ├── proxies_page.dart  # 代理节点与策略组画卷 (分组卡片、节点网格、单选切换、延迟测速)
│       │   ├── rules_page.dart    # 分流规则与连接监控页 (命中统计与连接详情)
│       │   ├── profiles_page.dart # 订阅管理画卷 (导入、切换激活、刷新订阅)
│       │   └── settings_page.dart # 外观与通用设置页 (Monet 色板点选器、深浅主题切换)
│       └── widgets/               # 高复用原子与业务卡片
│           ├── hero_dashboard_card.dart  # 极光 Hero 卡片 (运行状态与一键详情)
│           ├── left_status_rail.dart     # 左侧状态轨 (上下行微胶囊 + 下沉拇指 Tab 按钮)
│           ├── network_probe_card.dart   # 网络探测卡片 (出口 IP、延迟波形与状态指示灯)
│           ├── memory_stat_card.dart     # 内存监控卡片 (原生 LinearProgressIndicator 指示)
│           ├── outbound_mode_card.dart   # 原生 M3 SegmentedButton 规则/全局/直连切换
│           ├── power_fab_button.dart     # 原生 M3 FloatingActionButton 启停组件
│           ├── proxy_group_card.dart     # 策略组卡片 (折叠展开、类型徽标、快速测速)
│           ├── proxy_node_card.dart      # 代理节点卡片 (紧凑网格、选中高亮、动态延迟色彩)
│           └── window_title_bar.dart     # Windows 沉浸式拖拽顶栏 (Android 下自适应收起)
├── android/
│   └── app/src/main/jniLibs/      # Android 原生动态内核库 (由 LuminClashCore 产出)
│       ├── arm64-v8a/libclash.so
│       ├── armeabi-v7a/libclash.so
│       └── x86_64/libclash.so
├── windows/                       # Windows C++ 工程配置 (window_manager runner, mihomo.exe)
├── test/                          # 单元测试与 Widget 测试目录 (包含 16+ 核心测试用例)
├── pubspec.yaml                   # 依赖清单与版本锁 (包含 assets/core/mihomo.exe)
└── gemini.md                      # 本架构规范文件 (Authoritative Rulebook)
```

---

## 5. 进程管理与桌面调试纪律 (Process & Environment Protocols)

> [!WARNING]
> **Windows 后台会话隔离限制**：
> - 自动化 Agent 终端运行在非交互式背景服务（Session 0）中，无法直接在用户的 Windows 交互式桌面上唤起 GUI 窗口；
> - 若需要启动桌面 GUI 查看实时界面，必须提示用户在其本机的交互式 PowerShell 中运行：
>   ```powershell
>   flutter run -d windows
>   # 或直接运行 Release 产物
>   .\build\windows\x64\runner\Release\lumin_clash.exe
>   ```
> - **Mihomo 内核进程防孤儿保护**：在 Windows 端拉起 `mihomo.exe` 时，必须挂载至 Win32 Job Object（设置 `JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE`），确保 LuminClash 退出或意外崩溃时，后台不会残留孤儿代理进程抢占网络端口。

### 内核集成与编译交付铁律 (Core Integration & Packaging Rules)

> [!IMPORTANT]
> **编译打包必带 Core 产物**：严禁在缺失 Mihomo 内核的情况下编译发布裸包！
> 
> 1. **内核上游自动化仓库**：
>    - 核心由独立仓库 **[XSong1205/LuminClashCore](https://github.com/XSong1205/LuminClashCore)** 统一编译维护；
>    - 每 6 小时自动同步 `MetaCubeX/mihomo` 上游 Release，包含 `-tags with_gvisor` 标签编译，全量支持 TUN 模式；
> 2. **Windows 编译必须包含**：
>    - `assets/core/mihomo.exe` 以及 `windows/runner/mihomo.exe`；
>    - 若缺失，从 `LuminClashCore` Release 下载 Windows 架构包解压置入；
> 3. **Android 编译必须包含**：
>    - `android/app/src/main/jniLibs/` 下的三大架构动态库：
>      - `arm64-v8a/libclash.so`
>      - `armeabi-v7a/libclash.so`
>      - `x86_64/libclash.so`
>    - 若缺失，必须在执行 `flutter build apk` 前拉取解压最新 `LuminClashCore-android-jniLibs-*.zip`。

---

## 6. 常用构建与验证命令 (CLI Commands)

任何功能交付或正式发版前，必须严格按照以下顺序执行：

```powershell
# 0. 内核完整性检查与拉取 (确保 Windows 与 Android 动态库就绪)
# Android jniLibs 缺失时拉取：
gh release download --repo XSong1205/LuminClashCore --pattern "LuminClashCore-android-jniLibs-*.zip" --dir android/app/src/main
Expand-Archive -Path android\app\src\main\LuminClashCore-android-jniLibs-*.zip -DestinationPath android\app\src\main\ -Force
Remove-Item android\app\src\main\LuminClashCore-android-jniLibs-*.zip

# 1. 静态代码分析 (严格要求 0 错误 0 警告)
flutter analyze

# 2. 执行所有组件与逻辑测试
flutter test

# 3. 构建 Windows Release 生产二进制
flutter build windows

# 4. 构建 Android Release 正式安装包 (按 ABI 独立打包，严禁打包 250MB+ 全量胖包)
flutter build apk --split-per-abi

# 5. APK 远程分发与下载规范 (复制到 artifacts 目录)
Copy-Item build\app\outputs\flutter-apk\app-arm64-v8a-release.apk C:\Users\XSong\.gemini\antigravity\brain\61a3f538-344a-4fec-a65e-271ff0b1601b\LuminClash-android-arm64-v8a.apk -Force
Copy-Item build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk C:\Users\XSong\.gemini\antigravity\brain\61a3f538-344a-4fec-a65e-271ff0b1601b\LuminClash-android-armeabi-v7a.apk -Force
Copy-Item build\app\outputs\flutter-apk\app-x86_64-release.apk C:\Users\XSong\.gemini\antigravity\brain\61a3f538-344a-4fec-a65e-271ff0b1601b\LuminClash-android-x86_64.apk -Force
```

---

## 7. 核心 API 与下一阶段演进路线 (Roadmap & API Blueprint)

### (1) Mihomo 内核集成接口定义
- **配置与状态**：`GET /configs`、`PATCH /configs`
- **节点与策略组**：`GET /proxies`、`GET /proxies/{name}/delay`
- **实时流量与监控**：`GET /traffic` (WebSocket 管道)
- **核心内存数据**：`GET /memory`

### (2) 页面与功能演进
1. **节点与策略组视图 (Tab 2: Proxies Page)**：
   - 树状/分组展示 Proxy Group（Selector、URL-Test、Fallback）；
   - 一键并发批量测速，延迟根据 `Theme.of(context).colorScheme` 动态着色（绿色优质、琥珀色中等、暗红色超时）。
2. **连接监控与分流规则 (Tab 3: Connections & Rules)**：
   - 实时连接进程树与已分流规则命中追踪；
   - 快速断开指定连接。
3. **订阅配置引擎 (Tab 4: Profiles Engine)**：
   - 支持 Clash YAML 远程订阅链接解析与本地安全持久化；
   - 提供自动定时刷新策略及更新日志记录。
