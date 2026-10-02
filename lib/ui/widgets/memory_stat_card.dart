import 'package:flutter/material.dart';
import '../../core/models/app_state.dart';
import '../../core/theme/lumin_motion.dart';
import 'blur_number_ticker.dart';
import 'bouncy_tap.dart';
import 'frosted_glass_card.dart';

/// 升级版内存占用监控卡片 (Memory Stat Card)
class MemoryStatCard extends StatelessWidget {
  final DashboardState state;

  const MemoryStatCard({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isRunning = state.isRunning;
    final ramRatio = isRunning
        ? (state.ramMb / 120.0).clamp(0.05, 1.0)
        : 0.05;

    return BouncyTap(
      pressScale: 0.95,
      hapticType: HapticType.light,
      onTap: () {
        // 触觉轻触反馈
      },
      child: FrostedGlassCard(
        height: 114,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 标题与图标
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '内存占用',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Icon(
                  Icons.memory_rounded,
                  size: 15,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ],
            ),

            // 内存数值
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                BlurNumberTicker(
                  text: state.ramMb.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  'MB',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            // 底部动态平滑指示条
            TweenAnimationBuilder<double>(
              duration: LuminMotion.expressive,
              curve: LuminMotion.fluid,
              tween: Tween<double>(begin: 0.05, end: ramRatio),
              builder: (context, value, _) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: value,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isRunning
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    ),
                    minHeight: 5,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
