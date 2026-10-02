import 'package:flutter/material.dart';
import '../../core/models/app_state.dart';
import '../../core/theme/lumin_motion.dart';
import 'blur_number_ticker.dart';
import 'bouncy_tap.dart';
import 'frosted_glass_card.dart';

/// 升级版网络探测卡片 (Network Probe Card)
/// 支持弹性微按压、360度弹簧超调旋转刷新与延迟色阶光点
class NetworkProbeCard extends StatefulWidget {
  final DashboardState state;
  final VoidCallback onRefresh;

  const NetworkProbeCard({
    super.key,
    required this.state,
    required this.onRefresh,
  });

  @override
  State<NetworkProbeCard> createState() => _NetworkProbeCardState();
}

class _NetworkProbeCardState extends State<NetworkProbeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _handleRefresh() {
    LuminHaptics.light();
    _spinController.forward(from: 0.0);
    widget.onRefresh();
  }

  Color _getLatencyColor(ColorScheme colorScheme, int latency) {
    if (latency <= 0) return colorScheme.outline;
    if (latency < 100) return const Color(0xFF10B981); // 翠绿极速 (<= 99ms, 如 30ms)
    if (latency < 200) return const Color(0xFF22C55E); // 浅绿良好 (100 - 199ms)
    if (latency < 350) return const Color(0xFFF59E0B); // 琥珀稍慢 (200 - 349ms)
    return const Color(0xFFEF4444); // 珊瑚红高延迟/拥堵 (>= 350ms)
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final latency = widget.state.latencyMs;
    final latencyColor = _getLatencyColor(colorScheme, latency);

    return BouncyTap(
      pressScale: 0.95,
      hapticType: HapticType.none, // 由 _handleRefresh 处理震动
      onTap: _handleRefresh,
      child: FrostedGlassCard(
        height: 114,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 标题与带弹簧超调回转的刷新图标
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '网络检测',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                RotationTransition(
                  turns: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _spinController,
                      curve: Curves.easeOutBack,
                    ),
                  ),
                  child: Icon(
                    Icons.refresh_rounded,
                    size: 15,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),

            // 出口 IP 与国旗 (优先 TwemojiCountryFlags，保障 Windows 端完整旗帜渲染)
            Row(
              children: [
                Text(
                  widget.state.countryFlag,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'TwemojiCountryFlags',
                    fontFamilyFallback: [
                      'TwemojiCountryFlags',
                      'Segoe UI Emoji',
                      'sans-serif',
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    widget.state.outboundIp,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),

            // 延迟数值 (直接着色，不再显示前置小圆点)
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                BlurNumberTicker(
                  text: '$latency',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: latencyColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  'ms',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
