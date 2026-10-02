import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/lumin_motion.dart';

/// 极光深层柔焦漫反射光晕组件 (Aurora Defocus Glow)
/// 运用大半径高斯模糊 (sigma 32+) 与非线性正弦呼吸曲线，呈现如液态极光般流动的迷人背景
class AuroraDefocusGlow extends StatefulWidget {
  final bool isRunning;
  final BorderRadius borderRadius;

  const AuroraDefocusGlow({
    super.key,
    required this.isRunning,
    required this.borderRadius,
  });

  @override
  State<AuroraDefocusGlow> createState() => _AuroraDefocusGlowState();
}

class _AuroraDefocusGlowState extends State<AuroraDefocusGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: LuminMotion.breathe,
    );

    _breathAnimation = CurvedAnimation(
      parent: _controller,
      curve: LuminMotion.breatheCurve,
    );

    if (widget.isRunning) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant AuroraDefocusGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning != oldWidget.isRunning) {
      if (widget.isRunning) {
        _controller.repeat(reverse: true);
      } else {
        _controller.animateTo(0.0, duration: LuminMotion.standard);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: AnimatedBuilder(
          animation: _breathAnimation,
          builder: (context, _) {
            final t = _breathAnimation.value;
            final isRunning = widget.isRunning;

            // 动态主色光斑透明度与尺度
            final primaryAlpha = isRunning ? (0.28 + 0.12 * t) : 0.06;
            final tertiaryAlpha = isRunning ? (0.24 + 0.10 * (1 - t)) : 0.04;
            final primarySize = 140.0 + (isRunning ? 24.0 * t : 0.0);
            final tertiarySize = 120.0 + (isRunning ? 20.0 * (1 - t) : 0.0);

            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // 1. 右上方主要极光光斑 (Primary)
                Positioned(
                  top: -30 + 10 * t,
                  right: -20 - 10 * t,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                    child: Container(
                      width: primarySize,
                      height: primarySize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary.withValues(alpha: primaryAlpha),
                      ),
                    ),
                  ),
                ),

                // 2. 右侧偏下互补三级色光斑 (Tertiary)
                Positioned(
                  bottom: -20 - 8 * t,
                  right: 40 + 15 * t,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
                    child: Container(
                      width: tertiarySize,
                      height: tertiarySize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.tertiary.withValues(alpha: tertiaryAlpha),
                      ),
                    ),
                  ),
                ),

                // 3. 左下角微光辅色光斑 (Secondary) - 增加纵深通透感
                if (isRunning)
                  Positioned(
                    bottom: -15 + 8 * t,
                    left: 20 + 12 * (1 - t),
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.secondary.withValues(alpha: 0.16 + 0.08 * t),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
