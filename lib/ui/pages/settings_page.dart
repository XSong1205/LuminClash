import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_info.dart';
import '../../core/providers/clash_provider.dart';
import '../../core/theme/lumin_motion.dart';
import '../../core/theme/lumin_theme.dart';
import '../widgets/bouncy_tap.dart';
import '../widgets/frosted_glass_card.dart';

/// 升级版设置页面 (Settings Page)
/// 拥有悬浮毛玻璃顶栏 (Frosted Floating Header)、触觉弹性色板与高阶微动效
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final notifier = ref.read(dashboardProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop =
        !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
    final headerRadius = BorderRadius.only(
      topLeft: const Radius.circular(24),
      topRight: Radius.circular(isDesktop ? 0 : 24),
    );
    const headerHeight = 56.0;
    const contentGap = 12.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. 内容流 (滚动穿透至悬浮顶栏下方，产生毛玻璃磨砂景深)
          ListView(
            padding: const EdgeInsets.fromLTRB(16, headerHeight + contentGap, 16, 40),
            children: [
              // 分区标题 1: 外观与个性化
              _buildSectionHeader(context, '外观与个性化', Icons.palette_outlined),
              const SizedBox(height: 10),

              // 1.1 Monet 动态种子色彩选择器
              FrostedGlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Material 3 Expressive 动态色彩',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'M3E 引擎',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onTertiaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '基于 Material 3 Expressive 算法，动态生成高表现力主色与谐调三级补色色板',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 色板网格 (6 套经典 Monet 种子，带 BouncyTap 弹跳动效)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: LuminTheme.monetSeedPalette.length,
                      itemBuilder: (context, index) {
                        final item = LuminTheme.monetSeedPalette[index];
                        final isSelected = state.monetSeedIndex == index;

                        return BouncyTap(
                          pressScale: 0.92,
                          hapticType: HapticType.selection,
                          onTap: () => notifier.setMonetSeedIndex(index),
                          child: AnimatedContainer(
                            duration: LuminMotion.snappy,
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorScheme.secondaryContainer
                                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.outlineVariant.withValues(alpha: 0.2),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: item.color.withValues(alpha: 0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                AnimatedScale(
                                  scale: isSelected ? 1.15 : 1.0,
                                  duration: LuminMotion.snappy,
                                  curve: LuminMotion.springOvershoot,
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: item.color,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: item.color.withValues(alpha: 0.45),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            size: 14,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.nameZh,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? colorScheme.onSecondaryContainer
                                              : colorScheme.onSurface,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        item.nameEn,
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          color: isSelected
                                              ? colorScheme.onSecondaryContainer
                                                  .withValues(alpha: 0.7)
                                              : colorScheme.onSurfaceVariant,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 1.2 深浅色主题模式选择
              FrostedGlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '主题外观模式',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildThemeModeChip(
                          context,
                          label: '深色模式',
                          icon: Icons.dark_mode_rounded,
                          mode: ThemeMode.dark,
                          current: state.themeMode,
                          onTap: () => notifier.setThemeMode(ThemeMode.dark),
                        ),
                        const SizedBox(width: 8),
                        _buildThemeModeChip(
                          context,
                          label: '浅色模式',
                          icon: Icons.light_mode_rounded,
                          mode: ThemeMode.light,
                          current: state.themeMode,
                          onTap: () => notifier.setThemeMode(ThemeMode.light),
                        ),
                        const SizedBox(width: 8),
                        _buildThemeModeChip(
                          context,
                          label: '跟随系统',
                          icon: Icons.brightness_auto_rounded,
                          mode: ThemeMode.system,
                          current: state.themeMode,
                          onTap: () => notifier.setThemeMode(ThemeMode.system),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 分区标题 2: 常用常规设置
              _buildSectionHeader(context, '常规网络与系统', Icons.tune_rounded),
              const SizedBox(height: 10),

              // 2.1 常规设置卡片
              FrostedGlassCard(
                child: Column(
                  children: [
                    _buildSwitchTile(
                      context,
                      title: '开机自启动',
                      subtitle: '系统登录时自动在后台启动 LuminClash',
                      value: false,
                      onChanged: (_) {
                        LuminHaptics.light();
                      },
                    ),
                    Divider(
                      height: 1,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                    ),
                    _buildSwitchTile(
                      context,
                      title: '关闭时最小化至托盘',
                      subtitle: '点击窗口右上角关闭按钮时保持核心后台驻留',
                      value: true,
                      onChanged: (_) {
                        LuminHaptics.light();
                      },
                    ),
                    Divider(
                      height: 1,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                    ),
                    _buildSwitchTile(
                      context,
                      title: '允许局域网连接 (Allow LAN)',
                      subtitle: '开启后同局域网内的其它设备可通过本机代理上网',
                      value: true,
                      onChanged: (_) {
                        LuminHaptics.light();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 分区标题 3: 代理内核与系统设置 (Mihomo Core)
              _buildSectionHeader(context, 'Mihomo 内核与系统代理', Icons.memory_rounded),
              const SizedBox(height: 10),

              FrostedGlassCard(
                child: Column(
                  children: [
                    _buildSwitchTile(
                      context,
                      title: 'Windows 系统代理',
                      subtitle: '自动设置系统网络代理为 127.0.0.1:7890 并刷新 WinINet',
                      value: state.systemProxyEnabled,
                      onChanged: (_) {
                        LuminHaptics.medium();
                        notifier.toggleSystemProxy();
                      },
                    ),
                    Divider(
                      height: 1,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '内核版本与状态',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                state.coreVersion ?? 'Mihomo v1.19.32 (AMD64)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: state.isRunning
                                  ? colorScheme.primaryContainer.withValues(alpha: 0.4)
                                  : colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              state.isRunning ? '运行中' : '未运行',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: state.isRunning
                                    ? colorScheme.primary
                                    : colorScheme.outline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '端口配置',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '混合代理: 7890 | 外部控制: 9090',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () {
                              LuminHaptics.light();
                              notifier.refreshProbe();
                            },
                            icon: const Icon(Icons.bolt_rounded, size: 16),
                            label: const Text('重置探测'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 分区标题 4: 关于与系统支持 (About LuminClash)
              _buildSectionHeader(context, '关于与系统支持', Icons.info_outline_rounded),
              const SizedBox(height: 10),

              FrostedGlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [colorScheme.primary, colorScheme.tertiary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.bolt_rounded,
                            color: colorScheme.onPrimary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  AppInfo.appName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: colorScheme.onSurface,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    AppInfo.releaseStage,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '版本: v${AppInfo.fullVersion}',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
                    const SizedBox(height: 12),
                    _buildInfoRow(context, '内核集成', AppInfo.coreEngine),
                    const SizedBox(height: 8),
                    _buildInfoRow(context, '最低 Android 限制', AppInfo.androidMinSdk),
                    const SizedBox(height: 8),
                    _buildInfoRow(context, '目标 Android SDK', AppInfo.androidTargetSdk),
                    const SizedBox(height: 8),
                    _buildInfoRow(context, '桌面系统支持', AppInfo.windowsMinVersion),
                  ],
                ),
              ),
            ],
          ),

          // 2. 悬浮毛玻璃顶栏 (Frosted Floating Header)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: headerRadius,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  height: headerHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.72),
                    borderRadius: headerRadius,
                    border: Border(
                      bottom: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                        width: 0.8,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '设置',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeModeChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode current,
    required VoidCallback onTap,
  }) {
    final isSelected = mode == current;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: BouncyTap(
        pressScale: 0.92,
        hapticType: HapticType.selection,
        onTap: onTap,
        child: AnimatedContainer(
          duration: LuminMotion.snappy,
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.secondaryContainer
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant.withValues(alpha: 0.2),
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              AnimatedScale(
                scale: isSelected ? 1.12 : 1.0,
                duration: LuminMotion.snappy,
                curve: LuminMotion.springOvershoot,
                child: Icon(
                  icon,
                  size: 19,
                  color: isSelected
                      ? colorScheme.onSecondaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? colorScheme.onSecondaryContainer
                      : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
