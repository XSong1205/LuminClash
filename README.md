# LuminClash 🪐

**LuminClash** 是一款基于 **Flutter** 与 **Mihomo (Clash.Meta)** 内核打造的现代跨平台代理客户端。界面设计汲取了知名 Android Root 管理器 **FolkPatch** 的紧凑人机工效美学，全方位采用 **Material You (Material 3 Expressive)** 动态色彩与原生动效体系。

---

## 📸 核心设计特性

- 🎨 **原生 Material 3 Expressive (M3E) 动态色彩系统**：
  - 基于 Google 官方 `DynamicSchemeVariant.expressive` 算法，在桌面与移动端动态派生高表现力主色阶与互补三级色 (Tertiary)；
  - 严谨遵循 M3E 语义容器规范（`surfaceContainer`、`primaryContainer`、`tertiaryContainer` 等），杜绝硬编码色值。
- 📱 **移动端单手触控优化**：
  - 侧边栏/导航轨 Tab 按键下沉至屏幕下半部拇指触控黄金区，大屏握持更舒适；
  - 状态栏自适应避让，全面适配前摄挖孔、灵动岛与各类异形屏。
- ⚡ **原生 Material 动效系统**：
  - 采用 Flutter 原生 Material 3 控件（`FloatingActionButton`、`SegmentedButton`、`AnimatedSwitcher`、`InkWell` 水波纹）；
  - 消除冗余数学计算，保障 60/120Hz 满帧丝滑运行。
- 💻 **跨平台桌面与移动端同源**：
  - 完美适配 **Windows 桌面端**（无边框沉浸式窗口拖拽、系统托盘就绪）与 **Android 移动端**。

---

## 📁 项目工程目录结构

```
LuminClash/
├── lib/
│   ├── main.dart                  # 应用入口与全局主题绑定
│   ├── core/
│   │   ├── models/                # 状态实体模型 (DashboardState, OutboundMode)
│   │   ├── providers/             # Riverpod 状态管理 (DashboardNotifier)
│   │   └── theme/                 # Material You (Monet) 动态主题生成器
│   └── ui/
│       ├── pages/
│       │   ├── main_screen.dart   # 根部双栏容器与转场控制器
│       │   ├── dashboard_page.dart# 仪表盘主画卷
│       │   └── settings_page.dart # 外观与系统设置页
│       └── widgets/
│           ├── hero_dashboard_card.dart  # 极光状态 Hero 大色块
│           ├── left_status_rail.dart     # 左侧紧凑状态轨与下沉导航
│           ├── network_probe_card.dart   # 实时网络与延迟卡片
│           ├── memory_stat_card.dart     # 核心内存占用卡片
│           ├── outbound_mode_card.dart   # 原生 M3 三段出站模式单选
│           ├── power_fab_button.dart     # 原生 M3 发光启停电源按钮
│           └── window_title_bar.dart     # 桌面端无边框窗口控制器
├── android/                       # 原生 Android 工程配置
├── windows/                       # 原生 Windows C++ Runner
└── pubspec.yaml                   # 依赖清单
```

---

## 🛠️ 构建与运行指南

### Windows 桌面端
```powershell
# 运行开发热重载模式
flutter run -d windows

# 构建 Release 正式版
flutter build windows
# 生成文件位于: build\windows\x64\runner\Release\lumin_clash.exe
```

### Android 移动端
```bash
# 构建 Release 正式安装包 (APK)
flutter build apk --release
# 生成文件位于: build/app/outputs/flutter-apk/app-release.apk
```
