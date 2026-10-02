import 'package:flutter/material.dart';
import '../../core/theme/lumin_motion.dart';

/// 动态雷达呼吸脉冲状态徽章 (Pulse Glow Badge)
/// 在运行中状态下发射同心脉冲光环，传达生动的实时工作生命力
class PulseGlowBadge extends StatefulWidget {
  final bool isRunning;

  const PulseGlowBadge({
    super.key,
    required this.isRunning,
  });

  @override
  State<PulseGlowBadge> createState() => _PulseGlowBadgeState();
}

class _PulseGlowBadgeState extends State<PulseGlowBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOutQuad,
    );

    if (widget.isRunning) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant PulseGlowBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning != oldWidget.isRunning) {
      if (widget.isRunning) {
        _pulseController.repeat();
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: LuminMotion.standard,
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: widget.isRunning
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: widget.isRunning
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 动态脉冲点
          SizedBox(
            width: 14,
            height: 14,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (widget.isRunning)
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, _) {
                      final progress = _pulseAnimation.value;
                      return Transform.scale(
                        scale: 1.0 + 1.2 * progress,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.onPrimary.withValues(
                                alpha: (1.0 - progress).clamp(0.0, 0.8),
                              ),
                              width: 1.5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                // 中心核心点
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isRunning
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          AnimatedSwitcher(
            duration: LuminMotion.snappy,
            child: Text(
              widget.isRunning ? '运行中' : '已暂停',
              key: ValueKey(widget.isRunning),
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: widget.isRunning
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
