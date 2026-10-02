import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/clash_provider.dart';
import '../../core/theme/lumin_motion.dart';
import 'bouncy_tap.dart';

/// 升级版左侧紧凑状态轨 (Left Status Rail)
/// 集成实时数据流脉冲指示、弹性弹簧导航胶囊与触觉反馈
class LeftStatusRail extends ConsumerWidget {
  const LeftStatusRail({super.key});

  bool get _isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final topPadding = _isDesktop ? 8.0 : 8.0;

    return Container(
      width: 84,
      color: colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          SizedBox(height: topPadding),

          // 顶部实时上下行速率胶囊 (采用 RepaintBoundary 隔离高频重绘)
          RepaintBoundary(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 上行速度
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_upward_rounded,
                        size: 11,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          state.upSpeed,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // 下行速度
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_downward_rounded,
                        size: 11,
                        color: colorScheme.tertiary,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          state.downSpeed,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.tertiary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 使用 Spacer 弹性下沉至拇指黄金触控区
          const Spacer(),

          // 纵向导航项列表 (集成 BouncyTap 与弹簧胶囊)
          _RailNavItem(
            icon: Icons.dashboard_customize_rounded,
            label: '仪表盘',
            isActive: state.activeNavIndex == 0,
            onTap: () => ref.read(dashboardProvider.notifier).setActiveNav(0),
          ),
          _RailNavItem(
            icon: Icons.language_rounded,
            label: 'Proxies',
            isActive: state.activeNavIndex == 1,
            onTap: () => ref.read(dashboardProvider.notifier).setActiveNav(1),
          ),
          _RailNavItem(
            icon: Icons.article_outlined,
            label: 'Rules',
            isActive: state.activeNavIndex == 2,
            onTap: () => ref.read(dashboardProvider.notifier).setActiveNav(2),
          ),
          _RailNavItem(
            icon: Icons.folder_open_rounded,
            label: 'Profiles',
            isActive: state.activeNavIndex == 3,
            onTap: () => ref.read(dashboardProvider.notifier).setActiveNav(3),
          ),
          _RailNavItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            isActive: state.activeNavIndex == 4,
            onTap: () => ref.read(dashboardProvider.notifier).setActiveNav(4),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _RailNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _RailNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
      child: BouncyTap(
        pressScale: 0.92,
        hapticType: HapticType.selection,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 平滑背景指示胶囊
            AnimatedContainer(
              duration: LuminMotion.standard,
              curve: Curves.easeOutCubic,
              width: isActive ? 52 : 42,
              height: 30,
              decoration: BoxDecoration(
                color: isActive
                    ? colorScheme.secondaryContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: AnimatedScale(
                  scale: isActive ? 1.15 : 1.0,
                  duration: LuminMotion.snappy,
                  curve: LuminMotion.springOvershoot,
                  child: Icon(
                    icon,
                    size: 19,
                    color: isActive
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: LuminMotion.snappy,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
