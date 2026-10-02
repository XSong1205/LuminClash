import 'package:flutter/material.dart';
import '../../core/models/app_state.dart';
import '../../core/theme/lumin_motion.dart';
import 'bouncy_tap.dart';

/// Material Design 3 分段模式选择器 (M3 Expressive Segmented Tab Bar)
/// 严格依照 Material 3 离散分段胶囊规范与概念设计重塑：
/// 三个独立圆角胶囊按键、圆圈徽标图标、触感弹性按压与平滑色彩过渡
class FluidSegmentedBar extends StatelessWidget {
  final OutboundMode selectedMode;
  final ValueChanged<OutboundMode> onModeChanged;

  const FluidSegmentedBar({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  IconData _getModeIcon(OutboundMode mode) {
    switch (mode) {
      case OutboundMode.rule:
        return Icons.alt_route_rounded;
      case OutboundMode.global:
        return Icons.public_rounded;
      case OutboundMode.direct:
        return Icons.bolt_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final modes = OutboundMode.values;

    return Row(
      children: modes.map((mode) {
        final isSelected = mode == selectedMode;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: mode == modes.first ? 0 : 4,
              right: mode == modes.last ? 0 : 4,
            ),
            child: BouncyTap(
              pressScale: 0.94,
              hapticType: HapticType.none,
              onTap: () {
                if (!isSelected) {
                  LuminHaptics.selection();
                  onModeChanged(mode);
                }
              },
              child: AnimatedContainer(
                duration: LuminMotion.snappy,
                curve: Curves.easeOutCubic,
                height: 42,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.secondaryContainer
                      : colorScheme.surfaceContainerHighest.withValues(alpha: 0.52),
                  borderRadius: BorderRadius.circular(21),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.outlineVariant.withValues(alpha: 0.35)
                        : colorScheme.outlineVariant.withValues(alpha: 0.18),
                    width: 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.14),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 圆圈微标图标 (Circled Mode Icon)
                    AnimatedContainer(
                      duration: LuminMotion.snappy,
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? colorScheme.primary.withValues(alpha: 0.18)
                            : colorScheme.onSurfaceVariant.withValues(alpha: 0.08),
                      ),
                      child: Icon(
                        _getModeIcon(mode),
                        size: 13,
                        color: isSelected
                            ? colorScheme.onSecondaryContainer
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AnimatedDefaultTextStyle(
                      duration: LuminMotion.snappy,
                      curve: Curves.easeOutCubic,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? colorScheme.onSecondaryContainer
                            : colorScheme.onSurfaceVariant,
                        letterSpacing: 0.1,
                      ),
                      child: Text(mode.label),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

