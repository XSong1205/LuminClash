import 'package:flutter/material.dart';
import '../../core/models/app_state.dart';
import '../../core/theme/lumin_motion.dart';
import '../../core/theme/lumin_theme.dart';
import 'aurora_defocus_glow.dart';
import 'bouncy_tap.dart';
import 'pulse_glow_badge.dart';

/// 极光呼吸高阶 Hero 仪表盘主卡片
class HeroDashboardCard extends StatelessWidget {
  final DashboardState state;

  const HeroDashboardCard({
    super.key,
    required this.state,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good morning';
    } else if (hour >= 12 && hour < 18) {
      return 'Good afternoon';
    } else if (hour >= 18 && hour < 22) {
      return 'Good evening';
    } else {
      return 'Good night';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isRunning = state.isRunning;
    final cardRadius = BorderRadius.circular(LuminTheme.cardRadius);

    return BouncyTap(
      pressScale: 0.97,
      hapticType: HapticType.light,
      borderRadius: cardRadius,
      onTap: () {
        // 卡片触觉微按压反馈
      },
      child: AnimatedContainer(
        duration: LuminMotion.expressive,
        curve: LuminMotion.fluid,
        width: double.infinity,
        height: 148,
        decoration: BoxDecoration(
          borderRadius: cardRadius,
          gradient: LinearGradient(
            colors: isRunning
                ? [
                    colorScheme.primaryContainer.withValues(alpha: 0.95),
                    colorScheme.tertiaryContainer.withValues(alpha: 0.70),
                  ]
                : [
                    colorScheme.surfaceContainerHigh,
                    colorScheme.surfaceContainer,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: isRunning
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.22),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
          border: Border.all(
            color: isRunning
                ? colorScheme.outlineVariant.withValues(alpha: 0.4)
                : colorScheme.outlineVariant.withValues(alpha: 0.25),
            width: 1.2,
          ),
        ),
        child: Stack(
          children: [
            // 1. 底层极光高斯柔焦漫反射流体 (Aurora Defocus Glow)
            Positioned.fill(
              child: AuroraDefocusGlow(
                isRunning: isRunning,
                borderRadius: cardRadius,
              ),
            ),

            // 2. 卡片前层信息内容
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 顶部行：状态徽章与模式标记
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 动态脉冲状态雷达胶囊
                      PulseGlowBadge(isRunning: isRunning),

                      // 右上角轻量微徽章
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isRunning
                              ? colorScheme.surface.withValues(alpha: 0.35)
                              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          isRunning ? 'Mihomo Core' : 'Standby',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isRunning
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurfaceVariant,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 底部行：问候语与动态状态描述
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getGreeting(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isRunning
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      AnimatedSwitcher(
                        duration: LuminMotion.snappy,
                        child: Text(
                          isRunning
                              ? '${state.outboundMode.label}模式'
                              : '点击右下角按钮开启代理',
                          key: ValueKey(isRunning),
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: isRunning
                                ? colorScheme.onPrimaryContainer.withValues(alpha: 0.8)
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
