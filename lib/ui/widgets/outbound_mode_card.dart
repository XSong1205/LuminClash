import 'package:flutter/material.dart';
import '../../core/models/app_state.dart';
import 'fluid_segmented_bar.dart';
import 'frosted_glass_card.dart';

/// 升级版流体出站模式切换卡片 (Outbound Mode Card)
class OutboundModeCard extends StatelessWidget {
  final OutboundMode currentMode;
  final ValueChanged<OutboundMode> onModeChanged;

  const OutboundModeCard({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FrostedGlassCard(
      height: 104,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 顶部标题与副标识
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '出站模式',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Icon(
                Icons.alt_route_rounded,
                size: 14,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ],
          ),

          // 核心流体弹簧滑块分段器
          FluidSegmentedBar(
            selectedMode: currentMode,
            onModeChanged: onModeChanged,
          ),
        ],
      ),
    );
  }
}
