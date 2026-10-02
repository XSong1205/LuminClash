import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/lumin_motion.dart';

/// 纯粹柔和无硬边顺时针流光启停按钮 (Power FAB)
/// 特性：
/// 1. 按钮周围纯净柔和、无任何生硬线条的顺时针流动辉光 (Seamless Flowing Ambient Glow)
/// 2. 连续对称高斯能量环，彻底杜绝切边与生硬线段
/// 3. 瞬态点火扩散冲击波 (Ignition Shockwave Pulse)
/// 4. 磁吸按压弹性挤压形变 (Squash & Stretch Spring Physics)
/// 5. 动量回旋图标形态跃迁与触觉反馈
class PowerFabButton extends StatefulWidget {
  final bool isRunning;
  final VoidCallback onToggle;

  const PowerFabButton({
    super.key,
    required this.isRunning,
    required this.onToggle,
  });

  @override
  State<PowerFabButton> createState() => _PowerFabButtonState();
}

class _PowerFabButtonState extends State<PowerFabButton>
    with TickerProviderStateMixin {
  // 1. 弹性按压形变控制器
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  // 2. 顺时针流动辉光控制器 (3.6秒一整周平滑循环)
  late final AnimationController _flowController;

  // 3. 瞬态点火冲击波控制器
  late final AnimationController _shockwaveController;
  late final Animation<double> _shockwaveAnimation;

  // 4. 辉光呼吸微浮动控制器
  late final AnimationController _glowPulseController;
  late final Animation<double> _glowPulseAnimation;

  @override
  void initState() {
    super.initState();

    // 1. 按压弹性缩放
    _pressController = AnimationController(
      vsync: this,
      duration: LuminMotion.micro,
      reverseDuration: LuminMotion.expressive,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.86).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeOutCubic,
        reverseCurve: LuminMotion.springOvershoot,
      ),
    );

    // 2. 顺时针流动辉光 (匀速平滑流动)
    _flowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );

    // 3. 瞬态点火冲击波 (开启瞬间向外扩散)
    _shockwaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _shockwaveAnimation = CurvedAnimation(
      parent: _shockwaveController,
      curve: Curves.easeOutQuart,
    );

    // 4. 柔焦辉光呼吸微浮动
    _glowPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _glowPulseAnimation = CurvedAnimation(
      parent: _glowPulseController,
      curve: Curves.easeInOutSine,
    );

    if (widget.isRunning) {
      _flowController.repeat();
      _glowPulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PowerFabButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRunning != oldWidget.isRunning) {
      if (widget.isRunning) {
        _shockwaveController.forward(from: 0.0);
        _flowController.repeat();
        _glowPulseController.repeat(reverse: true);
      } else {
        _shockwaveController.reset();
        _flowController.stop();
        _glowPulseController.stop();
      }
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    _flowController.dispose();
    _shockwaveController.dispose();
    _glowPulseController.dispose();
    super.dispose();
  }

  Offset? _startPointerPosition;

  void _onPointerDown(PointerDownEvent event) {
    _startPointerPosition = event.position;
    LuminHaptics.light();
    _pressController.forward();
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_startPointerPosition != null) {
      final delta = (event.position - _startPointerPosition!).distance;
      if (delta > 14.0) {
        _startPointerPosition = null;
        _pressController.reverse();
      }
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _startPointerPosition = null;
    _pressController.reverse();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _startPointerPosition = null;
    _pressController.reverse();
  }

  void _handleTap() {
    if (!widget.isRunning) {
      LuminHaptics.heavy();
    } else {
      LuminHaptics.medium();
    }
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isRunning = widget.isRunning;

    final primaryColor = colorScheme.primary;
    final tertiaryColor = colorScheme.tertiary;

    final backgroundColor = isRunning
        ? primaryColor
        : colorScheme.surfaceContainerHighest;
    final foregroundColor = isRunning
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;

    const buttonWidth = 60.0;
    const buttonHeight = 60.0;
    const buttonRadius = 20.0;

    return Tooltip(
      message: isRunning ? '停止代理核心' : '启动代理核心',
      child: RepaintBoundary(
        child: SizedBox(
          width: 96,
          height: 96,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // -------------------------------------------------------------
              // 1. 瞬态点火扩散冲击波 (Ignition Shockwave Pulse)
              // -------------------------------------------------------------
              AnimatedBuilder(
                animation: _shockwaveAnimation,
                builder: (context, _) {
                  final progress = _shockwaveAnimation.value;
                  if (progress == 0.0 || progress == 1.0) {
                    return const SizedBox.shrink();
                  }

                  final shockwaveWidth = buttonWidth + 34.0 * progress;
                  final shockwaveHeight = buttonHeight + 34.0 * progress;
                  final opacity = (1.0 - progress).clamp(0.0, 0.75);

                  return Container(
                    width: shockwaveWidth,
                    height: shockwaveHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(buttonRadius + 10 * progress),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: opacity),
                        width: 2.0 * (1.0 - progress) + 0.5,
                      ),
                    ),
                  );
                },
              ),

              // -------------------------------------------------------------
              // 2. 按钮周围纯净柔和、无生硬线条的顺时针流动辉光 (Seamless Flowing Glow)
              // 采用连续平滑高斯渐变，起点与终点完全透明（C^1 连续），绝无任何线条突兀露出
              // -------------------------------------------------------------
              if (isRunning)
                AnimatedBuilder(
                  animation: Listenable.merge([_flowController, _glowPulseAnimation]),
                  builder: (context, _) {
                    final tPulse = _glowPulseAnimation.value;
                    final auraSize = 78.0 + 8.0 * tPulse;
                    final auraAlpha = 0.55 + 0.20 * tPulse;

                    return ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Transform.rotate(
                        angle: _flowController.value * 2 * math.pi,
                        child: Container(
                          width: auraSize,
                          height: auraSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                Colors.transparent,
                                primaryColor.withValues(alpha: auraAlpha * 0.25),
                                Color.lerp(primaryColor, tertiaryColor, 0.5)!
                                    .withValues(alpha: auraAlpha * 0.75),
                                tertiaryColor.withValues(alpha: auraAlpha),
                                Color.lerp(primaryColor, tertiaryColor, 0.5)!
                                    .withValues(alpha: auraAlpha * 0.75),
                                primaryColor.withValues(alpha: auraAlpha * 0.25),
                                Colors.transparent,
                              ],
                              // 0.0 与 1.0 完全平滑归零，形成完美连续高斯波峰，无任何锐利边缘
                              stops: const [0.0, 0.18, 0.38, 0.50, 0.62, 0.82, 1.0],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

              // -------------------------------------------------------------
              // 3. 核心实体按钮：极简纯净圆角矩形，绝无外露线条或裁切缝隙
              // -------------------------------------------------------------
              ScaleTransition(
                scale: _scaleAnimation,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Listener(
                    onPointerDown: _onPointerDown,
                    onPointerMove: _onPointerMove,
                    onPointerUp: _onPointerUp,
                    onPointerCancel: _onPointerCancel,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _handleTap,
                      child: AnimatedContainer(
                      duration: LuminMotion.standard,
                      curve: Curves.easeOutCubic,
                      width: buttonWidth,
                      height: buttonHeight,
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(buttonRadius),
                        gradient: isRunning
                            ? LinearGradient(
                                colors: [
                                  primaryColor,
                                  Color.lerp(primaryColor, tertiaryColor, 0.25)!,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        border: Border.all(
                          color: isRunning
                              ? Colors.white.withValues(alpha: 0.35)
                              : colorScheme.outlineVariant.withValues(alpha: 0.25),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isRunning
                                ? primaryColor.withValues(alpha: 0.35)
                                : Colors.black.withValues(alpha: 0.12),
                            blurRadius: isRunning ? 16 : 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        // 图标动量回旋与弹性切换
                        child: AnimatedRotation(
                          turns: isRunning ? 0.0 : -0.125,
                          duration: LuminMotion.expressive,
                          curve: LuminMotion.springOvershoot,
                          child: AnimatedSwitcher(
                            duration: LuminMotion.snappy,
                            switchInCurve: LuminMotion.springOvershoot,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: Icon(
                              Icons.power_settings_new_rounded,
                              key: ValueKey(isRunning),
                              size: 29,
                              color: foregroundColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
