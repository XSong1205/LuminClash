import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/clash_provider.dart';
import '../../core/theme/lumin_motion.dart';
import '../widgets/hero_dashboard_card.dart';
import '../widgets/memory_stat_card.dart';
import '../widgets/network_probe_card.dart';
import '../widgets/outbound_mode_card.dart';
import '../widgets/power_fab_button.dart';

/// 升级版仪表盘页面 (Dashboard Page)
/// 拥有悬浮毛玻璃顶栏 (Frosted Floating Header) 与多层景深模糊滚动效果
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

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
          // 1. 主体卡片内容流 (穿透至顶栏下方，形成毛玻璃滚动景深)
          ListView(
            padding: const EdgeInsets.fromLTRB(16, headerHeight + contentGap, 16, 96),
            children: [
              // 顶部 Hero 大色块极光卡片
              HeroDashboardCard(state: state),

              const SizedBox(height: 12),

              // 中层双列卡片 (网络检测 + 内存占用)
              Row(
                children: [
                  Expanded(
                    child: NetworkProbeCard(
                      state: state,
                      onRefresh: () => notifier.refreshProbe(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MemoryStatCard(state: state),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 底层出站模式选择卡片 (流体弹簧滑块)
              OutboundModeCard(
                currentMode: state.outboundMode,
                onModeChanged: (mode) => notifier.setOutboundMode(mode),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '仪表盘',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                      IconButton(
                        constraints: const BoxConstraints.tightFor(
                          width: 36,
                          height: 36,
                        ),
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        onPressed: () {
                          LuminHaptics.light();
                          notifier.refreshProbe();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. 右下角高阶 Power FAB 启停按钮
          Positioned(
            bottom: 18,
            right: 14,
            child: PowerFabButton(
              isRunning: state.isRunning,
              onToggle: () => notifier.togglePower(),
            ),
          ),
        ],
      ),
    );
  }
}
