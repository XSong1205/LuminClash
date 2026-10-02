import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/lumin_theme.dart';

/// 具有半透明磨砂质感与物理高光边缘的高级玻璃卡片容器
class FrostedGlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double blurSigma;
  final bool enableBlur;
  final Color? backgroundColor;
  final BoxBorder? customBorder;
  final List<BoxShadow>? shadows;

  const FrostedGlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blurSigma = 12.0,
    this.enableBlur = true,
    this.backgroundColor,
    this.customBorder,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final radius = borderRadius ?? BorderRadius.circular(LuminTheme.cardRadius);

    final effectiveBgColor = backgroundColor ??
        colorScheme.surfaceContainer.withValues(alpha: 0.82);

    final effectiveBorder = customBorder ??
        Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.28),
          width: 1.0,
        );

    final cardContent = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: radius,
        border: effectiveBorder,
        boxShadow: shadows ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      child: child,
    );

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: radius,
        child: enableBlur && blurSigma > 0
            ? BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: blurSigma,
                  sigmaY: blurSigma,
                ),
                child: cardContent,
              )
            : cardContent,
      ),
    );
  }
}
