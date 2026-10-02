import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/lumin_motion.dart';

/// 极光高阶模糊数字刷新组件 (Blur Number Ticker)
/// 专为仪表盘核心数值（网络延迟、内存占用、实时流量）打造：
/// 1. 彻底纠正原先从左下角弹射的异常路径，采用正向垂直微滑移 (Vertical Micro-drift) 与中轴对齐；
/// 2. 融入高阶动态运动高斯模糊 (Directional Motion Blur: Y 轴流体柔焦 + X 轴透光)；
/// 3. 新旧数值无缝接驳：旧数值向上虚化融散 (Dissolve Upwards)，新数值从微下方伴随透光去模糊凝聚锁定；
/// 4. 闲置状态 0 额外 ImageFilter 开销，像素级锐利渲染。
class BlurNumberTicker extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final Curve switchInCurve;
  final Curve switchOutCurve;
  final Alignment alignment;

  const BlurNumberTicker({
    super.key,
    required this.text,
    this.style,
    this.duration = LuminMotion.standard,
    this.switchInCurve = LuminMotion.fluid,
    this.switchOutCurve = Curves.easeInCubic,
    this.alignment = Alignment.centerLeft,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: switchInCurve,
      switchOutCurve: switchOutCurve,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: alignment,
          clipBehavior: Clip.none,
          children: [
            ...previousChildren,
            ?currentChild,
          ],
        );
      },
      transitionBuilder: (child, animation) {
        final isIncoming = child.key == ValueKey(text);

        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final t = animation.value.clamp(0.0, 1.0);
            // 垂直位移：旧数字向上漂浮融散 (-0.35)，新数字由下方升起凝聚 (+0.35 -> 0)
            final verticalFraction = isIncoming
                ? 0.35 * (1.0 - t)
                : -0.35 * (1.0 - t);

            // 动态运动高斯模糊：Y 轴运动模糊 + X 轴微漫反射
            final blurSigmaY = 4.5 * (1.0 - t);
            final blurSigmaX = 0.8 * (1.0 - t);

            // 微缩放：由 0.94 平滑归正至 1.0，锚定在左中对齐点
            final scale = 0.94 + (0.06 * t);

            Widget result = child;

            // 1. 运动模糊滤镜 (仅在处于过渡态且模糊阈值显著时挂载，闲置 0 开销)
            if (blurSigmaY > 0.05) {
              result = ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: blurSigmaX,
                  sigmaY: blurSigmaY,
                ),
                child: result,
              );
            }

            // 2. 透明度淡入淡出
            if (t < 0.999) {
              result = Opacity(
                opacity: t,
                child: result,
              );
            }

            // 3. 原生微缩放
            if ((scale - 1.0).abs() > 0.005) {
              result = Transform.scale(
                scale: scale,
                alignment: alignment,
                child: result,
              );
            }

            // 4. 垂直分数微滑移 (自适应文本字号高度)
            if (verticalFraction.abs() > 0.005) {
              result = FractionalTranslation(
                translation: Offset(0.0, verticalFraction),
                child: result,
              );
            }

            return result;
          },
        );
      },
      child: Text(
        text,
        key: ValueKey(text),
        style: style,
      ),
    );
  }
}
